
import yaml, os, pandas as pd, json, argparse
from azure.identity import AzureCliCredential
# OutputFolder = "Output"
# workspace_id = "/subscriptions/fe4a3fcb-2888-4963-bf3c-81083cd04390/resourceGroups/DecoyLogger/providers/Microsoft.OperationalInsights/workspaces/decoylogs"
print("""
███████████████████████████████████████████████████████████████████████████████████████████
█─▄▄▄─█▄─▄███─▄▄─█▄─██─▄█▄─▄▄▀█▀▀▀▀▀██▄─▄▄▀█▄─▄▄─█─▄▄▄─█▄─▄▄─█▄─▄▄─█─▄─▄─█▄─▄█─▄▄─█▄─▀█▄─▄█
█─███▀██─██▀█─██─██─██─███─██─█████████─██─██─▄█▀█─███▀██─▄█▀██─▄▄▄███─████─██─██─██─█▄▀─██
▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▀▀▄▄▄▄▀▀▄▄▄▄▀▀▀▀▀▀▀▀▀▄▄▄▄▀▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▀▀▀▀▄▄▄▀▀▄▄▄▀▄▄▄▄▀▄▄▄▀▀▄▄▀

[-] Created by @pbssubhash [-]
   [-] Alert Deployer [-]
""")
parser = argparse.ArgumentParser(
                    prog='Deception Alerter',
                    description='Deploy alerts.',
                    epilog='For any queries, please open an issue at https://github.com/pbssubhash/Cloud-Deception')
parser.add_argument("--OutputFolder", default="Output", help = "Enter Output Folder")
parser.add_argument("--workspaceId", help = "Enter workspace ID")
args = parser.parse_args()
OutputFolder = args.OutputFolder
workspace_id = args.workspaceId

detections = ""
with open("detections.yaml","r") as stream:
    try:
        detections = yaml.safe_load(stream)
    except yaml.YAMLError as e:
        print(e)
user_df = pd.DataFrame([json.loads(x) for x in open(OutputFolder + os.sep + "user.json").readlines()])
msi_df = pd.DataFrame([json.loads(x) for x in open(OutputFolder + os.sep + "msi.json").readlines()])
res_df = pd.DataFrame([json.loads(x) for x in open(OutputFolder + os.sep + "resources.json").readlines()])
import requests
import json
def createAlert(detect, workspace_id,token):
  subscription_id = workspace_id.split("/")[2]
  resource_group = workspace_id.split("/")[4]
  query = detect['query'].replace("{KeyVault_Name}",",".join(["'"+x+"'" for x in res_df[res_df.service == "Azure_KeyVault"].name.values]).replace("\n","")).replace("{USERS}",",".join(["'"+x+"'" for x in user_df.UserPrincipalName.values])).replace("\n","")
  url = "https://management.azure.com/subscriptions/"+subscription_id +"/resourceGroups/"+resource_group+"/providers/microsoft.insights/scheduledqueryrules/" + detect['alertTitle'] + "?api-version=2021-08-01"
  payload = json.dumps({
    "location": "westus2",
    "id": "",
    "properties": {
      "displayName": detect['alertTitle'],
      "actions": {
        "actionGroups": [],
        "customProperties": {},
        "actionProperties": {}
      },
      "criteria": {
        "allOf": [
          {
            "metricMeasureColumn": "count_",
            "operator": "GreaterThan",
            "query": query,
            "threshold": 0,
            "timeAggregation": "Total",
            "dimensions": [],
            "failingPeriods": {
              "minFailingPeriodsToAlert": 1,
              "numberOfEvaluationPeriods": 1
            }
          }
        ]
      },
      "description": "", 

      "enabled": True,
      "autoMitigate": False,
      "evaluationFrequency": "P1D",
      "scopes": [
        "{}".format(workspace_id)
      ],
      "severity": 2,
      "windowSize": "P1D",
      "muteActionsDuration": None,
      "overrideQueryTimeRange": None,
      "targetResourceTypes": [
        "Microsoft.OperationalInsights/workspaces"
      ]
    },
    "tags": {}
  })
  headers = {
    'x-ms-command-name': 'Microsoft_Azure_Monitoring.',
    'Accept-Language': 'en',
    'Authorization': 'Bearer '+ token,
    'x-ms-effective-locale': 'en.en-us',
    'Content-Type': 'application/json',
    'Accept': '*/*',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.42'
  }
  response = requests.request("PUT", url, headers=headers, data=payload)
  # print(response.text)
  print("##### "+detect['alertTitle'])
  print(query)
  print("\n\n")

credential = AzureCliCredential()
for i in detections:
    createAlert(i,workspace_id,credential.get_token("https://management.azure.com").token)