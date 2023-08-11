from azure.identity import AzureCliCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.kusto import KustoManagementClient
from azure.mgmt.storage import StorageManagementClient
from azure.mgmt.keyvault import KeyVaultManagementClient
import os, json, subprocess, requests, random, pandas as pd, string
from faker import Faker
import regex as re, argparse, sys
credential = AzureCliCredential()
print("""
███████████████████████████████████████████████████████████████████████████████████████████
█─▄▄▄─█▄─▄███─▄▄─█▄─██─▄█▄─▄▄▀█▀▀▀▀▀██▄─▄▄▀█▄─▄▄─█─▄▄▄─█▄─▄▄─█▄─▄▄─█─▄─▄─█▄─▄█─▄▄─█▄─▀█▄─▄█
█─███▀██─██▀█─██─██─██─███─██─█████████─██─██─▄█▀█─███▀██─▄█▀██─▄▄▄███─████─██─██─██─█▄▀─██
▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▀▀▄▄▄▄▀▀▄▄▄▄▀▀▀▀▀▀▀▀▀▄▄▄▄▀▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▀▀▀▀▄▄▄▀▀▄▄▄▀▄▄▄▄▀▄▄▄▀▀▄▄▀

[-] Created by @pbssubhash [-]
""")
parser = argparse.ArgumentParser(
                    prog='Deception Creator',
                    description='Creates Deceptive Objects which can be later ingested.',
                    epilog='For any queries, please open an issue at https://github.com/pbssubhash/Cloud-Deception')
parser.add_argument("--subscriptionId", help = "Enter Subscription ID")
parser.add_argument("--industry", default="IT", help = "Enter your Industry; Currently supported values: Healthcare, IT, Energy, Chemical, Construction.")
parser.add_argument("--domain", help="Enter the domain name that's associated with your tenant")
parser.add_argument("--passFile", default="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt", help="Enter filepath or URL of the password file that you wish to use")
parser.add_argument("--outputFolder",default="Output", help="Enter a location where all the output can be stored")
parser.add_argument("--mode", default="balanced", help="Enter the mode you want to choose; Currently supported: simple, balanced, godmode")
parser.add_argument("--userPattern",default="{first_name}.{lname}@{domain}",help="Pattern to guide the creation of users. Check github.com/pbssubhash/Cloud-Deception for more details")
parser.add_argument("--msiPattern",default="{name}-{key}",help="Pattern to guide the creation of users. Check github.com/pbssubhash/Cloud-Deception for more details")
parser.add_argument("--resourceNamePattern",default="{name}-{purpose}",help="Pattern to guide the creation of users. Check github.com/pbssubhash/Cloud-Deception for more details")
# userPattern = "{first_name}.{lname}@{domain}" #Regex - Take user input; Allowed Keywords: fname,lname,firstname,lastname, domain = fomain fqdn
# msiPattern = "{name}-{key}" #Regex - Take user input; name: random_name, key: industry centric key, role: is the role.
# resourceNamePattern = "{name}-{purpose}" #Regex - Take user input; name: random_name, purpose: web, db, func, logger, backup, mailer, ftp
args = parser.parse_args()
subscription_id = args.subscriptionId
industry = args.industry
domain = args.domain 
passFile = args.passFile
modes = args.mode
userPattern = args.userPattern
msiPattern = args.msiPattern
output_folder = args.outputFolder
resourceNamePattern = args.resourceNamePattern
if subscription_id == None or domain == None:
    parser.print_help()
    sys.exit("Mandatory arguments: [subscriptionId, domain] not specified. Try again.")
# subscription_id = "c86448d0-d711-41f7-b25d-013c9af96b53"
# industry = "IT" # Take user input
# domain = "subhashpopurioutlook.onmicrosoft.com"
# subscriptionId = "c86448d0-d711-41f7-b25d-013c9af96b53"
# passFile = "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt"
# output_folder = "Output"
# modes = "balanced"

resource_client = ResourceManagementClient(credential, subscription_id)
group_list = resource_client.resource_groups.list()
group_list = [x for x in group_list]
res = [[x.name,x.location] for x in group_list]
users = [x.replace("\r","") for x in subprocess.check_output(['powershell','-c','.\Get-User.ps1']).decode().split("\n") if x!=""]
msi = [x.replace("\r","") for x in subprocess.check_output(['powershell','-c','.\Get-MSI.ps1']).decode().split("\n") if x!=""]
def checkAvailability(loc,name,service):
    if service=="Kusto":
        client = KustoManagementClient(
            credential=credential,
            subscription_id=subscription_id,
        )

        response = client.clusters.check_name_availability(
        location=loc,
        cluster_name={"name": name, "type": "Microsoft.Kusto/clusters"},
    )
        return response.name_available
    elif service == "Azure_Function":
        headers = {'Content-Type':'application/json',
           'Authorization': 'Bearer '+ credential.get_token("https://management.azure.com").token}
        params = {
	        "name": name,
	        "type": "Microsoft.Web/sites"
        }
        resp = requests.post("https://management.azure.com/subscriptions/{}/providers/Microsoft.Web/checknameavailability?api-version=2022-03-01".format(subscription_id), json=params,headers=headers).json()
        return resp['nameAvailable']
    elif service == "Azure_KeyVault":
        client = KeyVaultManagementClient(
            credential=credential,
            subscription_id=subscription_id,
        )
        response = client.vaults.check_name_availability(
            vault_name={"name": name, "type": "Microsoft.KeyVault/vaults"},
        )
        return response.name_available
    
    elif service == "Azure_Storage":
        return True 
        # As this is not working for few accounts. Throwing Subscription Not found. Have to bear with some conflicts due to this for now.
        client = StorageManagementClient(
            credential=credential,
            subscription_id=subscription_id,
        )
        response = client.storage_accounts.check_name_availability(
            account_name={"name": name, "type": "Microsoft.Storage/storageAccounts"},
        )
        return response.name_available
    elif service == "Azure_Logic_App":
        return checkAvailability("test",name,"Azure_Function")
# def createStorageAccountNames()
globalSeed = {
                        "Healthcare":['EMR', 'EHR', 'PACS', 'HIS', 'RIS', 'LIS', 'DICOM', 'HL7', 'CCD', 'CPOE', 'HIE', 'PHR', 'FHIR', 'ICD', 'DB2', 'Oracle', 'SQLServer', 'MySQL', 'PostgreSQL', 'MongoDB', 'Cassandra', 'Redis', 'Apache', 'Nginx','Tomcat', 'IIS', 'Jboss', 'WebLogic', 'Node.js', 'Kafka', 'RabbitMQ'],
                        "IT":['web', 'app', 'db', 'cache', 'loadbalancer', 'dev', 'test', 'prod', 'mail', 'backup', 'ftp', 'dns', 'monitoring', 'logging','SQLServer', 'MySQL', 'PostgreSQL', 'MongoDB', 'Cassandra', 'Redis', 'Apache', 'Nginx','Tomcat', 'IIS', 'Jboss', 'WebLogic', 'Node.js', 'Kafka', 'RabbitMQ'],
                        "Construction":['bim', 'project', 'file', 'cad', 'render', 'print', 'backup', 'database', 'web', 'ftp', 'mail', 'monitoring', 'logging','MySQL', 'PostgreSQL', 'MongoDB', 'Cassandra', 'Redis', 'Apache','SQLServer', 'MySQL', 'PostgreSQL', 'MongoDB', 'Cassandra', 'Redis', 'Apache', 'Nginx','Tomcat', 'IIS', 'Jboss', 'WebLogic', 'Node.js', 'Kafka', 'RabbitMQ'],
                        "Chemical":["ERP","CRM","FINANCE","HRMS","AUDIT","LABTEST","ORACLE","SALESFORCE","POSTGRESQL",'MySQL', 'PostgreSQL', 'MongoDB', 'Cassandra', 'Redis', 'Apache','test', 'prod', 'mail','SQLServer', 'MySQL', 'PostgreSQL', 'MongoDB', 'Cassandra', 'Redis', 'Apache', 'Nginx','Tomcat', 'IIS', 'Jboss', 'WebLogic', 'Node.js', 'Kafka', 'RabbitMQ'],
                        "Energy":['bim', 'project', 'file', 'cad', 'render', 'print', 'backup', 'database', 'web', 'ftp', 'mail','monitoring', 'logging'],
                }
services = ["Azure_Function","Azure_Automation","Azure_Storage","Azure_Logic_App","Azure_KeyVault","Disk"]
role_names = ["owner","contributor","reader","admin","finance","billing","svcadmin"]
purpose = ["web","db","func","logger","backup","mailer","ftp","billing","cache","server","loadbalancer","networking","compute","directory"]
storage_roles = ["User Access Administrator","Storage Blob Data Reader","Storage Blob Data Owner","Storage Account Contributor","Reader","Contributor"]


reg = re.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[&%$@]).{8,}$")
def checkPassword(password):
    if reg.search(password) == None:
        return False
    else:
        return True
if "http" in passFile:
        passList = requests.get(passFile).text
        passList = passList.split("\n")
else:
        passList = open(passFile).readlines()
passList = [x for x in passList if checkPassword(x)]
def createUsers(userPattern,count):
    fake = Faker()
    users = []
    for i in range(0,count):
        first_name = fake.first_name()
        last_name = fake.last_name()
        fname = first_name[0]
        lname = last_name[0] 
        name = userPattern.replace("{fname}",fname).replace("{lname}",lname).replace("{first_name}",first_name).replace("{last_name}",last_name).replace("{domain}",domain).lower()
        if name not in users:
            users.append({"UserPrincipalName":name,"DisplayName":first_name + " "+last_name,"UserName":name.split("@")[0].replace(".",""),"Password":random.choice(passList)})
        else:
            users.append(createUsers(userPattern,1)[0])
    return pd.DataFrame(users)

def createMSI(spnPattern,count):
    msi = []
    i=0
    while i <= count:
        rg = random.choice(res)
        name = spnPattern.replace("{key}",random.choice(role_names)).replace("{name}",random.choice(globalSeed[industry])).replace(".","").lower()
        if name not in str(msi):
            msi.append({"name":name,"ResourceGroup":rg[0],"Location":rg[1]})
            i = i + 1
    return pd.DataFrame(msi)

random_words_list = requests.get("https://raw.githubusercontent.com/xyfir/rword/main/words/big.json").json()
random_words_list = [x for x in random_words_list if len(x) > 5 and len(x) < 8]
def createResource(resourceNamePattern,count):
    resources = []
    i = 0
    while i <= count:
        properties = {}
        service = random.choice(services)
        rg = random.choice(res)
        name = resourceNamePattern.replace("{name}",random.choice(random_words_list)).replace("{purpose}",random.choice(purpose))
        if service == "Disk":
            properties['Location'] = rg[1]
            properties['DiskSizeGB'] = random.choice([1,3])
            properties['SkuName'] = "Standard_LRS"
            properties['OsType'] = "Windows"
            properties['CreateOption'] = "Empty"
            properties['EncryptionSettingsEnabled'] = "$false"
        elif service == "Azure_Function":
            properties['Runtime'] = "Python"
            properties['StorageAccountName'] = (name + random.choice(random_words_list))[0:22].replace("_","").replace("-","")
        elif service == "Azure_Logic_App":
            pass
        elif service == "Azure_KeyVault":
            pass
        elif service == "Azure_Storage":
            properties['SkuName'] = "Standard_LRS"
            name = name.replace("-","").replace("_","")
        elif service == "Azure_Automation":
            pass
        if checkAvailability(rg[1],name,service):
            i = i + 1
            resources.append({"service":service,"name":name,"res_group":rg[0],"location":rg[1],"properties": properties})
    #print(resources)
    return pd.DataFrame(resources)
def start():
    modex = ["simple","balanced","godmode"]

    if modes == "simple":
        userx = createUsers(userPattern,random.choice(range(2,5)))
        msix = createMSI(msiPattern,random.choice(range(2,5)))
        reso = createResource(resourceNamePattern, random.choice(range(2,5)))
    elif modes == "balanced":
        userx = createUsers(userPattern,random.choice(range(10,15)))
        msix = createMSI(msiPattern,random.choice(range(5,12)))
        reso = createResource(resourceNamePattern, random.choice(range(8,15)))
    else:
        userx = createUsers(userPattern,random.choice(range(20,40)))
        msix = createMSI(msiPattern,random.choice(range(15,30)))
        reso = createResource(resourceNamePattern, random.choice(range(15,20)))

    roles = ["Owner","Contributor","Reader","User Access Administrator"]
    storage_roles = ["Storage Blob Data Reader","Reader and Data Access"] + roles


    perm = []
    fake = Faker()
    resources = reso.name.values
    for user in userx.UserPrincipalName.values:
        for i in range(0,random.choice(range(0,5))):
            if fake.boolean(chance_of_getting_true=75):
                asd = random.choice(resources)
                perm.append({"user":user,"role":random.choice(roles),"rg":reso[reso.name == asd].res_group.values[0], "resource":asd, "type":reso[reso.name == asd].service.values[0]})
            if fake.boolean(chance_of_getting_true=50):
                asd = random.choice(resources)
                perm.append({"user":user,"role":random.choice(roles),"rg":reso[reso.name == asd].res_group.values[0], "resource":asd, "type":reso[reso.name == asd].service.values[0]})

    attach_msi = []
    perm_msi = []
    resources = reso[reso.service.isin(["Azure_Logic_App","Azure_Automation","Azure_Functions"])].name.values
    resourcesx = reso.name.values
    for msi in msix.name.values:
        resa = random.choice(resources)
        attach_msi.append({"name":msi,"subscription_id":subscription_id,"rg":reso[reso.name == resa].res_group.values[0],"msi_rg":msix[msix.name == msi].ResourceGroup.values[0],"resource": resa,"type":reso[reso.name == resa].service.values[0]})
        if fake.boolean(chance_of_getting_true=75):
            resa = random.choice(resourcesx)
            perm_msi.append({"name":msi,"msi_rg":msix[msix.name == msi].ResourceGroup.values[0],"rg":reso[reso.name == resa].res_group.values[0],"resource":resa,"role":random.choice(roles),"type":"msi"})
        if fake.boolean(chance_of_getting_true=50):
            resa = random.choice(resourcesx)
            perm_msi.append({"name":msi,"msi_rg":msix[msix.name == msi].ResourceGroup.values[0],"rg":reso[reso.name == resa].res_group.values[0],"resource":resa,"role":random.choice(roles),"type":"msi"})
    kv_perms = []
    resources = reso[reso.service.isin(['Azure_KeyVault'])].name.values
    for r in range(0,random.choice(range(1,int(len(userx)/1.2)))):
        kv_perms.append({"user":random.choice(userx.UserPrincipalName.values),"name":random.choice(resources),"type":"user","rg":""})
        msia = random.choice(msix.name.values)
        kv_perms.append({"user":msia,"name":random.choice(resources),"type":"msi","rg":msix[msix.name == msia].ResourceGroup.values[0]})
    kv_perms = pd.DataFrame(kv_perms)
    storage_perms = []
    resources = reso[reso.service.isin(['Azure_Storage'])].name.values
    for r in range(0,random.choice(range(1,int(len(userx)/1.2)))):
        permx = random.choice(storage_roles)
        sa = random.choice(resources)
        storage_perms.append({"user":random.choice(userx.UserPrincipalName.values),"perm":permx,"name":sa,"type":"user","rg":"","sa_rg":reso[reso.name == sa].res_group.values[0]})
        msia = random.choice(msix.name.values)
        permx = random.choice(storage_roles)
        sa = random.choice(resources)
        storage_perms.append({"user":msia,"perm":permx,"name":sa,"type":"msi","rg":msix[msix.name == msia].ResourceGroup.values[0],"sa_rg":reso[reso.name == sa].res_group.values[0]})
    storage_perms = pd.DataFrame(storage_perms)

    f = open(output_folder + os.sep + "msi_perm.json","w")
    for i in perm_msi:
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
    f = open(output_folder + os.sep + "attach_msi.json","w")
    for i in attach_msi:
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
    f = open(output_folder + os.sep + "user_perm.json","w")
    for i in perm:
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
    f = open(output_folder + os.sep + "user.json","w")
    for i in json.loads(userx.to_json(orient="records")):
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
    f = open(output_folder + os.sep + "msi.json","w")
    for i in json.loads(msix.to_json(orient="records")):
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
    f = open(output_folder + os.sep + "resources.json","w")
    for i in json.loads(reso.to_json(orient="records")):
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
    f = open(output_folder + os.sep + "kv_perms.json","w")
    for i in json.loads(kv_perms.to_json(orient="records")):
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
    f = open(output_folder + os.sep + "storage_perms.json","w")
    for i in json.loads(storage_perms.to_json(orient="records")):
        f.write(json.dumps(i))
        f.write("\n")
    f.close()
start()
print("[-] All files have been written to " + output_folder)
print("[-] To Ingest, run: powershell.exe -c res.ps1 -Mode Deploy -OutputFolder "+output_folder)
print("[=] K, Thnx, Bye [=]")