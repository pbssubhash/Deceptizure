# Deceptizure

▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
██░▄▄▀█░▄▄█▀▄▀█░▄▄█▀▄▄▀█▄░▄██▄██▄▄░█░██░█░▄▄▀█░▄▄
██░██░█░▄▄█░█▀█░▄▄█░▀▀░██░███░▄█▀▄██░██░█░▀▀▄█░▄▄
██░▀▀░█▄▄▄██▄██▄▄▄█░█████▄██▄▄▄█▄▄▄██▄▄▄█▄█▄▄█▄▄▄
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀


Deceptizure is an Azure Honeypot Toolkit. It was created to allow defenders to put deceptive objectives in Azure and allow creation of Initial access points and lateral movement opportunities.


## How to install?
The following are required for Deceptizure to work:
- Get an Azure account. Use a dev/test account to test the script. It's currently recommended to be used in DEV/STAGING and not in PROD.
- Azure CLI with authentication enabled. [Please check here for more information on how to do this](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- Install the requirements for Python script using the following language: <br>
  `pip3 install -r requirements.txt`
- Enable PowerShell (if disabled).

## How does it work?

1. The user can create deceptive objects using `create_decoy.py`. There are several options available for customizing deceptive objects.

| Parameter         | Required?   | # Description |
|--------------|-----------|------------|
| `--subscriptionId` | YES     | The subscription ID that is to be targeted for deploying deceptions. Currently, it only supports deploying deception to single subscription at once.    |
| `--industry`| NO, but recommended for highly deceptive objects.  | The Industry you are in? It determines names for resources, etc. For eg. If you are in healthcare, you can use Healthcare as the value and it generates server names from a pool of predefined healthcare applicable names. This makes deception more believable. |
|`--domain` | YES | The domain associated with your tenant.|
|`--passFile` | NO |  The weak passwords file that you want to use for creating weak password users.|
|`--outputFolder` | NO | Folder for storing interim deceptive objects in JSON format. |
|`--mode` | YES | This controls the number of levels of deceptive objects to create. Supported values: simple, balanced, godmode|
|`--userPattern` | NO, but recommended for highly deceptive objects. | It's a regex string to create usernames. Using variables such as firstname, fname, lastname and lname, you can give pattern of username to create. Eg. {first_name}.{lname}@{domain}|
|`--msiPattern` | NO, but recommended for highly deceptive objects.|2 variables: name and key are available to customize. These keys are randomly drawn and are dependent on Industry. Eg. There are certain names and keys for certain Industries |
|`--resourceNamePattern` |NO, but recommended for highly deceptive objects. | 2 variables: name and purpose are available to customize. These keys are randomly drawn and are dependent on Industry. Eg. There are certain names and keys for certain Industries|



2. 
