# Octopus Hardware Sizing Calculator - Deployment Script (PowerShell)
# This script deploys the application to Azure and creates a GitHub repository

$ErrorActionPreference = "Stop"

# Configuration
$AZURE_SUBSCRIPTION = "a64630ce-fe4a-4d9d-92f2-3f770daa7d54"
$AZURE_TENANT = "3d13e379-e666-469e-ac38-ec6fd61c1166"
$RESOURCE_GROUP = "rg-octopus-hardware-calculator"
$LOCATION = "australiaeast"
$APP_SERVICE_PLAN = "plan-octopus-hardware-calculator"
$WEB_APP_NAME = "octopus-hardware-calculator"
$GITHUB_ORG = "OctopusDeploy"
$GITHUB_REPO = "OctopusHardwareScalingTool"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Octopus Hardware Calculator Deployment" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Azure CLI is not installed. Please install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Red
    exit 1
}

if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: GitHub CLI is not installed. Please install it from https://cli.github.com/" -ForegroundColor Red
    exit 1
}

if (!(Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: .NET SDK is not installed. Please install .NET 9.0 or later" -ForegroundColor Red
    exit 1
}

Write-Host "✓ All prerequisites installed" -ForegroundColor Green
Write-Host ""

# Login to Azure
Write-Host "Logging in to Azure..." -ForegroundColor Yellow
az login --tenant $AZURE_TENANT
az account set --subscription $AZURE_SUBSCRIPTION
Write-Host "✓ Logged in to Azure" -ForegroundColor Green
Write-Host ""

# Check if user wants to create GitHub repo
$createRepo = Read-Host "Do you want to create a GitHub repository in the OctopusDeploy organization? (y/n)"

if ($createRepo -eq "y") {
    Write-Host "Creating GitHub repository..." -ForegroundColor Yellow

    # Check if repo already exists
    $repoExists = gh repo view "$GITHUB_ORG/$GITHUB_REPO" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Repository $GITHUB_ORG/$GITHUB_REPO already exists" -ForegroundColor Yellow
    } else {
        # Create the repository
        gh repo create "$GITHUB_ORG/$GITHUB_REPO" `
            --public `
            --description "Interactive hardware sizing calculator for Octopus Deploy infrastructure" `
            --source=. `
            --remote=origin

        Write-Host "✓ GitHub repository created: https://github.com/$GITHUB_ORG/$GITHUB_REPO" -ForegroundColor Green
    }

    # Push code to GitHub
    Write-Host "Pushing code to GitHub..." -ForegroundColor Yellow
    git remote add origin "https://github.com/$GITHUB_ORG/$GITHUB_REPO.git" 2>$null
    git push -u origin main
    Write-Host "✓ Code pushed to GitHub" -ForegroundColor Green
    Write-Host ""
}

# Create Azure resources
Write-Host "Creating Azure Resource Group..." -ForegroundColor Yellow
az group create `
    --name $RESOURCE_GROUP `
    --location $LOCATION `
    --tags "project=OctopusHardwareCalculator" "team=ServerAtScale"
Write-Host "✓ Resource Group created" -ForegroundColor Green
Write-Host ""

Write-Host "Creating App Service Plan..." -ForegroundColor Yellow
az appservice plan create `
    --name $APP_SERVICE_PLAN `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku B1 `
    --is-linux
Write-Host "✓ App Service Plan created" -ForegroundColor Green
Write-Host ""

Write-Host "Creating Web App..." -ForegroundColor Yellow
az webapp create `
    --name $WEB_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --plan $APP_SERVICE_PLAN `
    --runtime "DOTNETCORE:9.0"
Write-Host "✓ Web App created" -ForegroundColor Green
Write-Host ""

# Configure Web App settings
Write-Host "Configuring Web App settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $WEB_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --settings `
        ASPNETCORE_ENVIRONMENT="Production" `
        WEBSITE_RUN_FROM_PACKAGE="1"
Write-Host "✓ App settings configured" -ForegroundColor Green
Write-Host ""

# Get Web App details for AAD configuration
$WEB_APP_URL = "https://$WEB_APP_NAME.azurewebsites.net"

Write-Host "Configuring Azure AD authentication..." -ForegroundColor Yellow
$appId = az ad app create --display-name "$WEB_APP_NAME-auth" --sign-in-audience AzureADMyOrg --query appId -o tsv
az webapp auth microsoft update `
    --name $WEB_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --tenant-id $AZURE_TENANT `
    --client-id $appId `
    --allowed-audiences $WEB_APP_URL
Write-Host "✓ Azure AD authentication configured" -ForegroundColor Green
Write-Host ""

# Build and publish the application
Write-Host "Building application..." -ForegroundColor Yellow
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath
dotnet publish OctopusHardwareScalingTool/OctopusHardwareScalingTool.csproj `
    -c Release `
    -o ./publish
Write-Host "✓ Application built" -ForegroundColor Green
Write-Host ""

# Create deployment package
Write-Host "Creating deployment package..." -ForegroundColor Yellow
Set-Location publish
Compress-Archive -Path * -DestinationPath ../app.zip -Force
Set-Location ..
Write-Host "✓ Deployment package created" -ForegroundColor Green
Write-Host ""

# Deploy to Azure
Write-Host "Deploying to Azure..." -ForegroundColor Yellow
az webapp deployment source config-zip `
    --name $WEB_APP_NAME `
    --resource-group $RESOURCE_GROUP `
    --src app.zip
Write-Host "✓ Application deployed" -ForegroundColor Green
Write-Host ""

# Clean up
Remove-Item app.zip -Force
Remove-Item publish -Recurse -Force

# Display results
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Application URL: $WEB_APP_URL" -ForegroundColor Green
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor Green
Write-Host "App Service: $WEB_APP_NAME" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Test the application at $WEB_APP_URL"
Write-Host "2. Configure custom domain if needed"
Write-Host "3. Configure Azure AD group assignment if required"
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "  az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
Write-Host ""
