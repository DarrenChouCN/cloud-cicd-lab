## Creating a CI/CD pipeline for Azure Container Apps

#### 1. Variable

```bash
RESOURCE_GROUP="rg-cicd-lab-dev-ase-001"
LOCATION="australiasoutheast"
CONTAINERAPPS_ENVIRONMENT="acae-cicd-lab-dev-ase-001"
CONTAINERAPPS_APP="ca-cicd-lab-api-dev-ase-001"

az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"
```

#### 2. Create a Container Apps

```bash
az containerapp env create \
  --name "$CONTAINERAPPS_ENVIRONMENT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"

az containerapp create \
  --name "$CONTAINERAPPS_APP" \
  --resource-group "$RESOURCE_GROUP" \
  --environment "$CONTAINERAPPS_ENVIRONMENT" \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress external
```

#### 3. Create Azure Service Principal for Pipelines (deprecated)

```bash
RESOURCE_GROUP="rg-cicd-lab-dev-ase-001"

RESOURCE_GROUP_ID=$(az group show --name "$RESOURCE_GROUP" --query id -o tsv)
echo "$RESOURCE_GROUP_ID"

SPN_NAME="spn-cicd-lab-aca-dev-ase-001"

az ad sp create-for-rbac \
  --name "$SPN_NAME" \
  --role "Contributor" \
  --scopes "$RESOURCE_GROUP_ID" \
  --sdk-auth > spn-aca-ado.json

echo "Saved credentials to: spn-aca-ado.json"
```

#### 4. Configure Pipelines

_ADO -> Your Project -> Project Settings -> Pipelines -> Service connections -> Create service connection_

**Azure Connection**
![](images/azure-connection.png)

**Docker Hub Connection**
![](images/docker-hub-connection.png)
