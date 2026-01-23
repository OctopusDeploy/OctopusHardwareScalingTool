# Octopus Hardware Sizing Calculator

An interactive web-based tool to help customers determine the right hardware specifications for their Octopus Deploy infrastructure based on their deployment scenarios.

## Purpose

This tool demonstrates how the **Executions Foundations team's performance data** can be used to build customer trust and help them make informed decisions about their Octopus Deploy infrastructure. By collecting real-world performance metrics from large-scale deployments, we can provide accurate hardware sizing recommendations that ensure customers have the right resources for their specific needs.

## What It Does

The Hardware Sizing Calculator helps customers:

1. **Define their deployment scenario** - Number of locations/stores, devices per location, applications to deploy, and maintenance windows
2. **Get hardware recommendations** - CPU cores, RAM, and database server specifications based on actual performance data
3. **Validate deployment feasibility** - Check if deployments will fit within their maintenance windows
4. **Compare hosting options** - Choose between self-hosted Octopus Server or Octopus Cloud with budget-based sizing

## Key Features

- **Location-Centric Design**: Tailored for customers with many deployment locations (retail chains, distributed businesses)
- **Preset Configurations**: Quick-start templates for common scenarios (Retail Chain, Regional Business, Enterprise)
- **Deployment Window Analysis**: Validates if your infrastructure can complete deployments within your maintenance window
- **Real-Time Calculations**: Based on Application archetype data (20 steps, DB migrations, ~2 min per deployment)
- **Dual-Mode Calculator**:
  - **Server**: Self-hosted with hardware tuning controls
  - **Cloud**: Budget-based sizing ($100/core/month)
- **Octopus.com Integration**: Styled to match the Octopus.com website for seamless customer experience

## Technology Stack

- **Framework**: Blazor Server (.NET 9.0)
- **Rendering**: Interactive Server-side rendering
- **Styling**: Custom CSS matching Octopus.com design system
- **Hosting**: Azure App Service with Azure AD authentication

## Local Development

### Prerequisites

- .NET 9.0 SDK or later
- Your favorite IDE (Visual Studio, Rider, or VS Code)

### Running Locally

```bash
# Clone the repository
git clone https://github.com/OctopusDeploy/OctopusHardwareScalingTool.git
cd OctopusHardwareScalingTool

# Run the application
dotnet run --project OctopusHardwareScalingTool/OctopusHardwareScalingTool.csproj

# Navigate to http://localhost:5008 in your browser
```

### Development with Hot Reload

```bash
dotnet watch --project OctopusHardwareScalingTool/OctopusHardwareScalingTool.csproj
```

## Deployment

This application is deployed to Azure App Service with Azure AD authentication restricting access to authorized Octopus team members.

### Automated Deployment

Run the deployment script from the project root:

```bash
# For Mac/Linux
./deploy.sh

# For Windows
.\deploy.ps1
```

The script will:
1. Create a GitHub repository in the OctopusDeploy organization
2. Set up Azure infrastructure (Resource Group, App Service Plan, Web App)
3. Configure Azure AD authentication
4. Deploy the application
5. Configure access restrictions

### Manual Deployment

See the [Deployment Guide](./docs/DEPLOYMENT.md) for manual deployment instructions.

## Performance Data Sources

The calculator uses performance data collected by the Executions Foundations team from:
- Q3C2 Scenario testing (Application archetype)
- Real customer deployment patterns
- Performance benchmarks across various hardware configurations

**Data Location**: `/data/Q3C2 Scenario results.xlsx`

## Architecture

### Calculation Logic

The tool uses these key calculations based on the Application deployment archetype:

```csharp
// Base: 2 cores can handle 10 targets with 5 concurrent deployments
workloadFactor = (totalTargets / 10.0) * (applications / 2.0)
recommendedCores = Max(4, Ceiling(2 * Sqrt(workloadFactor)))
recommendedRam = recommendedCores * 4 GB

// Deployment time: ~2 min per deployment per target
baseTime = 2 minutes
parallelism = Min(cpuCores * 2, totalDeployments)
deploymentTime = (totalDeployments * baseTime * 20 steps) / parallelism

// Add overhead for large deployments (>100 targets)
if (totalTargets > 100) {
    deploymentTime *= 1.2 (20% coordination overhead)
}
```

### Components

- **Home.razor**: Main calculator UI with Server/Cloud tabs
- **NavMenu.razor**: Octopus.com-style navigation bar
- **MainLayout.razor**: Full-width layout container
- **app.css**: Comprehensive styling matching Octopus.com design

## Access Control

The production deployment is restricted to members of the Azure AD group:
- **Group ID**: `bead26f3-a84d-459f-9443-f1609a37a62f`
- **Directory**: `3d13e379-e666-469e-ac38-ec6fd61c1166`

## Contributing

This tool is maintained by the Executions Foundations team. For questions or suggestions:
- Open an issue in this repository
- Contact the Executions Foundations team in Slack

## License

Copyright © Octopus Deploy. All rights reserved.

## Acknowledgments

Built with data and insights from the Executions Foundations team's performance testing and customer deployment patterns.
