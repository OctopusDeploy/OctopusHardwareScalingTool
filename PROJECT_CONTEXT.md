# Octopus Hardware Scaling Calculator - Project Context

## Project Overview

This is a Blazor Server application that provides an interactive calculator for Octopus Deploy customers to understand how parallel deployments and CPU cores affect deployment performance. The tool helps customers make informed decisions about hardware scaling.

**Tech Stack:** .NET 9.0, Blazor Server, Bootstrap 5

**Running:** http://localhost:5008 (via `dotnet run --project OctopusHardwareScalingTool/OctopusHardwareScalingTool.csproj`)

## Data Source

Performance testing data is located in: `data/Q3C2 Scenario results.xlsx`

See `data/README.md` for detailed information about the test scenarios and data structure.

**Key test scenarios:**
- **Scenario 3 - Machine Parallelism:** Primary data source for calculator
  - Tests various CPU core counts (2, 2.5, 3, 4 cores)
  - Parallel targets per deployment (10, 15)
  - 100 deployments with task cap of 20
  - Baseline: 2 cores, 10 targets, TC20 = 607s total, 110s single deployment

## Implementation Details

### Main Files

1. **OctopusHardwareScalingTool/Components/Pages/Home.razor** (379 lines)
   - Interactive calculator UI
   - Real-time performance calculations
   - Comparison table
   - Educational content sections
   - Uses `@rendermode InteractiveServer` for reactivity

2. **OctopusHardwareScalingTool/wwwroot/app.css** (431 lines)
   - Octopus pricing page styling
   - Blue (#0d80d8) and Navy (#0a151e) color scheme
   - Fully responsive design (mobile, tablet, desktop)
   - Gradient hero section, card-based layout

### Calculator Features

**Input Controls:**
- CPU Cores dropdown: 2, 2.5, 3, 4, 8 cores
- Parallel Targets slider: 1-20 targets
- Number of Deployments slider: 10-200
- Task Cap dropdown: 5, 10, 20, 40, 80 concurrent deployments

**Outputs:**
- Single deployment duration (seconds)
- Total batch duration (formatted as s/m/h)
- VM CPU utilization percentage
- Database CPU utilization percentage
- Status indicators (✅ Good headroom, ⚠️ Moderate, 🔴 High load)

**Smart Recommendations:**
- Automatically suggests hardware upgrades when CPU > 70%
- Suggests optimization when CPU < 30%
- Provides specific upgrade paths

**Comparison Table:**
- Shows all CPU configurations side-by-side
- Highlights currently selected configuration
- Performance indicators (🟢 Excellent, 🟡 Good, 🔴 Stressed)

### Calculation Logic

**Baseline data from performance tests:**
```csharp
Cores = 2.0
Targets = 10
TaskCap = 20
SingleDuration = 110s
TotalDuration = 607s
VmCpu = 35%
DbCpu = 10%
```

**Scaling factors:**
- `coreScaleFactor = baselineCores / selectedCores`
- `targetScaleFactor = selectedTargets / baselineTargets`
- More cores = faster processing (power curve: 0.7)
- More parallel targets = longer single deployments (square root scaling)
- CPU usage increases with workload, decreases with more cores

**Formula:**
```
serialBatches = ceil(numDeployments / taskCap)
baseBatchTime = estimatedSingleDuration * serialBatches
estimatedTotalDuration = baseBatchTime * pow(coreScaleFactor, 0.7)
```

## Educational Content

Four info cards explain key concepts:
1. **Parallel Deployments** - Task cap limits concurrent deployments
2. **Parallel Targets** - Multiple targets per deployment
3. **CPU Scaling** - Adding cores for better performance
4. **Optimization Tips** - Balancing resources

## Styling Details

**Colors:**
- Primary Blue: #0d80d8
- Navy: #0a151e
- Background: #f8f9fa
- Borders: #e8ecef

**Layout:**
- Hero section with gradient background
- White calculator card with rounded corners (12px)
- Grid-based responsive layout
- Card hover effects with subtle transforms
- Octopus pricing page aesthetic

## Git Status

**Current branch:** main
**Latest commit:** d2bed07 "Add Hardware Scaling Calculator for Octopus Deploy"
**Status:** Clean working tree

## Next Steps / Future Iterations

**Potential improvements:**
- Add actual performance data for more CPU configurations from the spreadsheet
- Create charts/graphs for visualizing performance curves
- Add export/share functionality
- Integrate with real customer data
- Add cost estimation based on hardware tiers
- Include database performance metrics
- Add scenario presets (small/medium/large deployments)
- Memory utilization estimates
- Network I/O considerations

## Testing Notes

- Build succeeds with no warnings or errors
- Application runs successfully on localhost:5008
- Blazor interactive mode works correctly
- Calculations update in real-time
- Responsive design tested conceptually (needs browser testing)

## Dependencies

- .NET 9.0 SDK
- Bootstrap 5 (included in wwwroot/lib)
- No external npm packages required

## Performance Data Summary

From spreadsheet (Scenario 3 - Machine Parallelism):

| CPU (millicores) | Targets | Pipeline | Instance | Total Duration | Single Duration | VM CPU % | DB CPU % |
|------------------|---------|----------|----------|----------------|-----------------|----------|----------|
| 2000 (2 cores)   | 10      | V1       | i064516  | ~607s          | ~111s           | 35%      | 10%      |
| 2000 (2 cores)   | 10      | V2       | i064517  | ~627s          | ~109s           | 60%      | 23%      |
| 2500 (2.5 cores) | 10      | V2       | i064522  | -              | -               | -        | -        |
| 3000 (3 cores)   | 10      | V2       | i064519  | -              | -               | -        | -        |
| 4000 (4 cores)   | 10      | V2       | i064520  | -              | -               | -        | -        |

**Note:** Some data points were not available in the spreadsheet extract, so calculations use mathematical modeling based on the baseline.

## Design Inspiration

Based on Octopus pricing page at: https://octopus.com/pricing/overview
- Clean, modern sans-serif fonts
- Grid-based modular design
- Blue gradient accents
- High contrast for readability
- Minimal and professional aesthetic
