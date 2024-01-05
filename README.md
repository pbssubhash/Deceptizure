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

## What types of resources are created.
The solution currently supports the following:
- Deceptive Users: Users with real names, weak passwords (the user can specify the weak password list that they want to use). Users can also define format of the user name.
- Deceptive MSIs: Managed Identities with look-alike names are created. The names are picked from a pool of names related to the Industry (that user has selected) and the format that the user has specified.
- Deceptive Resources
    - Keyvault
    - Logic Apps
    - Storage Account
- Deceptive permissions from Users and MSIs onto the newly created deceptive users: What good is a deceptive solution which doesn't create fake attack paths? This solution creates complex yet fake attack paths from users and MSIs to the newly created resources.

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

Based on the given inputs, the following JSON deception definition files are created.

| Deception Definition         | Description   | # Sample File |
|--------------|-----------|------------|
| User | | Sample User File: [Users.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/user.json)|
| User permissions | | Sample User Permissions File [user_perm.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/user_perm.json)|
|MSI | | Sample MSI File [msi.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/msi.json)|
| MSI Permissions| | Sample MSI Permission files [msi_perm.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/msi_perm.json)|
| MSI attachments | | Sample MSI attachment files [msi_attach.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/attach_msi.json)|
|Resources | | Sample resources file [resources.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/resources.json)|
| Storage Account Permissions| | Sample storage account file [storage_perms.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/storage_perms.json)|
| Keyvault permissions| | Sample Keyvault permission files [kv_perms.json](https://github.com/pbssubhash/Deceptizure/blob/main/Output/kv_perms.json)|

2. 
