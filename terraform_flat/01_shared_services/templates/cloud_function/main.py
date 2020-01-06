"""
 Copyright 2019 Google LLC. This software is provided as-is, without warranty
 or representation for any use or purpose. Your use of it is subject to your 
 agreement with Google.  
"""
from googleapiclient import discovery
from googleapiclient.errors import HttpError
import base64
import json
import re
import os

# ID of the Shared Services project, where the fireall rules will be created
SRV_PROJECT = os.getenv('SRV_PROJECT', '')
# Network in the Shared Services project where the services instances are located.
SRV_NETWORK = os.getenv('SRV_NETWORK', '')
# TCP ports to open for ingress connection on the target instances.
PROXY_PORTS = os.getenv('PROXY_PORTS', '').split(',')
# Service accounts take precedence over tags. If you declare the former, the latter
# will be ignored when creating the firewall rule.
TARGET_SAS = os.getenv('TARGET_SAS', '').split(',')
TARGET_TAGS = os.getenv('TARGET_TAGS', '').split(',')
# Name pattern for the firewall rules that will be managed by this function. The '%s'
# symbol will be replaced by the CNZ project ID.
FWR_PATTERN = 'allow-from-proxy-%s'

def fw_updater(event, context):
  """
  Firewall updater cloud funtion.
  This function will be called each time a new proxy instance is added to or
  removed from a CNZ. The function will get the list of the proxy instances,
  get their erternal IP address and create or update a firewall rule to enable
  incoming connections from the proxy to the shared service.
  """
  if not 'data' in event:
    print('Ignoring event. No data found.')
    return

  pubsub_message = base64.b64decode(event['data']).decode('utf-8')
  pubsub_json = json.loads(pubsub_message)
  cnz_project = pubsub_json['resource']['labels']['project_id']
  instance_group = pubsub_json['resource']['labels']['instance_group_name']
  zone = pubsub_json['resource']['labels']['location']
  region = zone[:-2]

  # log the type of event
  if 'event_subtype' in pubsub_json['jsonPayload']:
    event = pubsub_json['jsonPayload']['event_subtype']
    if event == 'compute.instanceGroups.addInstances':
      print('instance added to instance group \'%s\' in project \'%s\'' % (instance_group, cnz_project))
    elif event == 'compute.instanceGroups.removeInstances':
      print('instance removed from instance group \'%s\' in project \'%s\'' % (instance_group, cnz_project))
    else:
      print('undetermined event (\'%s\') on instance group \'%s\' in project \'%s\'' % (event, instance_group, cnz_project))

  # Initialize the compute API
  service = discovery.build('compute', 'v1', cache_discovery=False)

  # Look for the external IP addresses attached to the inbstances created by
  # the outboud proxy managed instance group.
  proxy_external_ips = []
  request = service.regionInstanceGroupManagers().listManagedInstances(project=cnz_project, region=region, instanceGroupManager=instance_group)
  while request is not None:
    response = request.execute()
    for instance in response['managedInstances']:
      if 'instance' in instance:
        instance_url = instance['instance']
        m = re.match('^.*projects/([^/]+)/zones/([^/]+)/instances/([^/]+)$', instance_url)
        if m:
          ireq = service.instances().get(project=m.group(1), zone=m.group(2), instance=m.group(3))
          ires = ireq.execute()
          if 'networkInterfaces' in ires:
            for ni in ires['networkInterfaces']:
              if 'accessConfigs' in ni:
                for ac in ni['accessConfigs']:
                  if 'natIP' in ac:
                    proxy_external_ips.append(ac['natIP'])
    request = service.instanceGroups().listInstances_next(previous_request=request, previous_response=response)

  # Check if we already have created the firewall rule for this project's outbound proxy
  fw_rule_name = FWR_PATTERN % (cnz_project)
  fw_rule_project = SRV_PROJECT
  fw_rule_exists = False
  fw_request = service.firewalls().get(project=fw_rule_project, firewall=fw_rule_name)
  try:
    response = fw_request.execute()
    if response and 'name' in response:
      fw_rule_exists = True
      print('firewall rule \'%s\' found in project \'%s\'. Will update current one.' % (fw_rule_name, fw_rule_project))
  except HttpError:
    print('firewall rule \'%s\' not found in project \'%s\'. Will create a new one.' % (fw_rule_name, fw_rule_project))

  # construct the data for the firewall rule
  fw_rule_data = {
    'name' : fw_rule_name,
    'description': 'allows ingress from outbound proxy for CNZ \'%s\'' % (cnz_project),
    'network': 'https://www.googleapis.com/compute/v1/projects/%s/global/networks/%s' % (SRV_PROJECT, SRV_NETWORK),
    'priority': 1000,
    'targetServiceAccounts': None,
    'targetTags': None,
    'sourceRanges': [s + '/32' for s in proxy_external_ips],
    'allowed': [ { 'IPProtocol': 'tcp', 'ports': PROXY_PORTS } ],
    'direction': 'INGRESS',
    'logConfig': {  'enable': False },
  }
  # Apply the rule to instances attachec to the provided service acounts (if any)
  if TARGET_SAS and len(TARGET_SAS) > 0 and len(TARGET_SAS[0]) > 0:
    fw_rule_data['targetServiceAccounts'] = TARGET_SAS
  # Or to the provided network tags (if any)
  elif TARGET_TAGS and len(TARGET_TAGS) > 0 and len(TARGET_TAGS[0]) > 0:
    fw_rule_data['targetTags'] = TARGET_TAGS
  # Do not create the rule otherwise. We do not want to allow access to any
  # instance in the services network.
  else:
    print('ignoring firewall creation request. A network tag or target service accounbt must be provided (in the Cloud Function config).')

  # create or update the firewall rule
  if fw_rule_exists:
    request = service.firewalls().patch(project=SRV_PROJECT, firewall=fw_rule_name, body=fw_rule_data)
    response = request.execute()
    print('updated firewall rule \'%s\' in project \'%s\'' % (fw_rule_name, SRV_PROJECT))
  else:
    request = service.firewalls().insert(project=SRV_PROJECT, body=fw_rule_data)
    response = request.execute()
    print('created firewall rule \'%s\' in project \'%s\'' % (fw_rule_name, SRV_PROJECT))
