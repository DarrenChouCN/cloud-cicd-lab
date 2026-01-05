## Creating a CI/CD pipeline for Azure Container Apps

#### 1. Create a Container Apps

```bash
RESOURCE_GROUP="rg-cicd-aca-dev-ase-001"
LOCATION="australiasoutheast"
CONTAINERAPPS_ENVIRONMENT="acae-cicd-ase-01"
CONTAINERAPPS_APP="aca-album-ase-01"

az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

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

#### 2. Create Azure Service Principal for Pipelines (deprecated)

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

#### 3. Create Service Connection

_ADO -> Your Project -> Project Settings -> Pipelines -> Service connections -> Create service connection_

**Azure Connection**

![](images/azure-connection.png)

**Docker Hub Connection**

![](images/docker-hub-connection.png)

#### 4. Configure Pipelines

**See** [`container-app-pipelines.yaml`](./pipelines/container-app-pipelines.yaml)

#### 5. Confirm Results

**Pipeline**

![](images/pipelines-result.png)

**Docker Hub**

![](images/docker-hub-result.png)

**Container App**

![](images/container-app-result.png)
