#!/bin/bash
set -e

# Octopus Hardware Sizing Calculator - Deployment Script
# This script deploys the application to Azure and creates a GitHub repository

# Configuration
AZURE_SUBSCRIPTION="a64630ce-fe4a-4d9d-92f2-3f770daa7d54"
AZURE_TENANT="3d13e379-e666-469e-ac38-ec6fd61c1166"
RESOURCE_GROUP="rg-octopus-hardware-calculator"
LOCATION="australiaeast"
APP_SERVICE_PLAN="plan-octopus-hardware-calculator"
WEB_APP_NAME="octopus-hardware-calculator"
GITHUB_ORG="OctopusDeploy"
GITHUB_REPO="OctopusHardwareScalingTool"

echo "=========================================="
echo "Octopus Hardware Calculator Deployment"
echo "=========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed. Please install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI is not installed. Please install it from https://cli.github.com/"
    exit 1
fi

if ! command -v dotnet &> /dev/null; then
    echo "ERROR: .NET SDK is not installed. Please install .NET 9.0 or later"
    exit 1
fi

echo "✓ All prerequisites installed"
echo ""

# Login to Azure
echo "Logging in to Azure..."
az login --tenant "$AZURE_TENANT"
az account set --subscription "$AZURE_SUBSCRIPTION"
echo "✓ Logged in to Azure"
echo ""

# Check if user wants to create GitHub repo
echo "Do you want to create a GitHub repository in the OctopusDeploy organization? (y/n)"
read -r CREATE_REPO

if [ "$CREATE_REPO" = "y" ]; then
    # Configure GitHub CLI to use SSH for git operations
    echo "Configuring GitHub CLI to use SSH..."
    gh config set git_protocol ssh
    echo "✓ GitHub CLI configured for SSH"

    echo "Creating GitHub repository..."

    # Check if repo already exists
    if gh repo view "$GITHUB_ORG/$GITHUB_REPO" &> /dev/null; then
        echo "Repository $GITHUB_ORG/$GITHUB_REPO already exists"
    else
        # Create the repository
        gh repo create "$GITHUB_ORG/$GITHUB_REPO" \
            --public \
            --description "Interactive hardware sizing calculator for Octopus Deploy infrastructure" \
            --source=. \
            --remote=origin

        echo "✓ GitHub repository created: https://github.com/$GITHUB_ORG/$GITHUB_REPO"
    fi

    # Push code to GitHub
    echo "Pushing code to GitHub..."
    git remote add origin "git@github.com:$GITHUB_ORG/$GITHUB_REPO.git" 2>/dev/null || true
    git push -u origin main
    echo "✓ Code pushed to GitHub"
    echo ""
fi

# Create Azure resources
echo "Creating Azure Resource Group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "project=OctopusHardwareCalculator" "team=ServerAtScale"
echo "✓ Resource Group created"
echo ""

echo "Creating App Service Plan..."
az appservice plan create \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku B1 \
    --is-linux
echo "✓ App Service Plan created"
echo ""

echo "Creating Web App..."
az webapp create \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "DOTNETCORE|9.0"
echo "✓ Web App created"
echo ""

# Enable WebSockets (required for Blazor Server SignalR)
echo "Enabling WebSockets..."
az webapp config set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --web-sockets-enabled true
echo "✓ WebSockets enabled"
echo ""

# Set startup command for Linux App Service
echo "Setting startup command..."
az webapp config set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --startup-file "dotnet OctopusHardwareScalingTool.dll"
echo "✓ Startup command configured"
echo ""

# Configure Web App settings
echo "Configuring Web App settings..."
az webapp config appsettings set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
        ASPNETCORE_ENVIRONMENT="Production"
echo "✓ App settings configured"
echo ""

# Get Web App details for AAD configuration
WEB_APP_ID=$(az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query id -o tsv)
WEB_APP_URL="https://$WEB_APP_NAME.azurewebsites.net"

# Upgrade authentication to V2 if needed (required for az webapp auth microsoft update)
echo "Checking authentication version..."
AUTH_NAME=$(az webapp auth show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "name" -o tsv 2>/dev/null | grep -v WARNING || echo "authsettings")
if [ "$AUTH_NAME" != "authsettingsV2" ]; then
    echo "Upgrading authentication to V2..."
    az webapp auth config-version upgrade \
        --name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP"
    echo "✓ Authentication upgraded to V2"
else
    echo "✓ Authentication already at V2"
fi
echo ""

echo "Configuring Azure AD authentication..."
az webapp auth microsoft update \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --tenant-id "$AZURE_TENANT" \
    --client-id "$(az ad app create --display-name "$WEB_APP_NAME-auth" --sign-in-audience AzureADMyOrg --query appId -o tsv)" \
    --allowed-audiences "$WEB_APP_URL"
echo "✓ Azure AD authentication configured"
echo ""

# Enable authentication and require login
echo "Enabling authentication enforcement..."
az webapp auth update \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --enabled true \
    --action LoginWithAzureActiveDirectory
echo "✓ Authentication enforcement enabled"
echo ""

# Build and publish the application
echo "Building application..."
cd "$(dirname "$0")"
dotnet publish OctopusHardwareScalingTool/OctopusHardwareScalingTool.csproj \
    -c Release \
    -o ./publish
echo "✓ Application built"
echo ""

# Create deployment package
echo "Creating deployment package..."
cd publish
zip -r ../app.zip .
cd ..
echo "✓ Deployment package created"
echo ""

# Deploy to Azure
echo "Deploying to Azure..."
az webapp deployment source config-zip \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --src app.zip
echo "✓ Application deployed"
echo ""

# Clean up
rm -f app.zip
rm -rf publish

# Display results
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Application URL: $WEB_APP_URL"
echo "Resource Group: $RESOURCE_GROUP"
echo "App Service: $WEB_APP_NAME"
echo ""
echo "Next Steps:"
echo "1. Test the application at $WEB_APP_URL"
echo "2. Configure custom domain if needed"
echo "3. Configure Azure AD group assignment if required"
echo ""
echo "To view logs:"
echo "  az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo ""
