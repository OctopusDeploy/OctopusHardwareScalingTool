# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Blazor Server** application that provides an interactive calculator for Octopus Deploy customers to estimate deployment performance based on hardware configurations. The tool helps users understand how CPU cores and parallel deployments affect deployment times.

**Tech Stack:** .NET 9.0, Blazor Server, Bootstrap 5

## Running the Application

```bash
# Run the application
dotnet run --project OctopusHardwareScalingTool/OctopusHardwareScalingTool.csproj

# Application URL
# http://localhost:5008
```

## Building and Testing

```bash
# Build the solution
dotnet build OctopusHardwareScalingTool.sln

# Clean build artifacts
dotnet clean OctopusHardwareScalingTool.sln

# Restore dependencies
dotnet restore OctopusHardwareScalingTool.sln
```

## Architecture

### Blazor Server Interactive Mode

This application uses **Blazor Server with Interactive Server rendering** (`@rendermode InteractiveServer`). The main calculator component maintains state on the server and updates the UI in real-time through SignalR connections.

**Key architectural points:**
- State is maintained server-side in the Razor component's `@code` block
- UI updates are reactive and automatic when state changes
- No separate API layer - calculations happen directly in the component

### Project Structure

```
OctopusHardwareScalingTool/
├── Components/
│   ├── Pages/
│   │   └── Home.razor          # Main calculator page (379 lines)
│   ├── Layout/
│   └── App.razor
├── wwwroot/
│   ├── app.css                  # Custom styles (431 lines)
│   └── lib/                     # Bootstrap 5
└── Program.cs                   # ASP.NET Core setup

data/
├── Q3C2 Scenario results.xlsx   # Performance test data
└── README.md                    # Data documentation
```

### Calculator Implementation

The calculator in `Home.razor` has three main sections:

1. **Input Controls** (lines 22-82):
   - CPU Cores dropdown (2, 2.5, 3, 4, 8 cores)
   - Parallel Targets slider (1-20)
   - Number of Deployments slider (10-200)
   - Task Cap dropdown (5, 10, 20, 40, 80)

2. **Calculation Logic** (lines 236-296):
   - Baseline data from performance tests (2 cores, 10 targets, TC20)
   - Scaling factors for CPU, targets, and task cap
   - Power curve scaling for CPU performance (0.7 exponent)
   - Square root scaling for parallel target impact
   - Real-time recalculation on input change

3. **Comparison Table** (lines 332-368):
   - Shows all CPU configurations side-by-side
   - Calls `GetComparisonConfigurations()` which temporarily modifies state
   - **IMPORTANT:** This method has a known state mutation pattern that could cause issues if modified incorrectly

### Performance Data Source

The calculator is calibrated using real performance test data from `data/Q3C2 Scenario results.xlsx`:

**Baseline (from Scenario 3 - Machine Parallelism):**
```csharp
Cores = 2.0
Targets = 10
TaskCap = 20
SingleDuration = 110s
TotalDuration = 607s
VmCpu = 35%
DbCpu = 10%
```

When updating performance data:
1. Replace the Excel file in `data/`
2. Update baseline values in `Home.razor:238-248`
3. Review scaling factors if test methodology changes
4. Update `data/README.md` with new scenarios
5. Update `PROJECT_CONTEXT.md` performance summary

### Styling

The application follows the **Octopus pricing page aesthetic** with:
- Primary Blue: `#0d80d8`
- Navy: `#0a151e`
- Card-based layout with rounded corners (12px)
- Responsive grid system (mobile/tablet/desktop)
- Gradient hero section

**CSS organization in `app.css`:**
- Lines 1-75: Base Blazor styles
- Lines 76-431: Custom calculator styles (hero, inputs, results, comparison, info cards)
- Lines 379-431: Responsive breakpoints

## Common Development Tasks

### Modifying Calculator Logic

When changing calculation formulas:
1. Locate baseline data in `CalculateEstimates()` method (line 236)
2. Update scaling factors (lines 251-253)
3. Modify estimation logic (lines 256-272)
4. Test with various inputs to ensure results are reasonable
5. Consider updating `GetComparisonConfigurations()` if new calculations needed

### Adding New Input Controls

1. Add the control in the `input-section` div (line 22)
2. Create a new private field for state (line 200-204)
3. Add `@bind` or `@onchange` handler
4. Call `CalculateEstimates()` in the change handler
5. Update calculation logic to use the new input

### Updating Styles

- **Dropdown visibility:** Ensure `form-select` has `color` and `background-color` (lines 173-186)
- **Interactive elements:** Add `:hover` and `:focus` states
- **Responsive:** Test breakpoints at 768px and 480px
- **Colors:** Maintain consistency with Octopus brand colors

### Working with Blazor Interactive Components

- Use `@bind:event="oninput"` for real-time updates (line 48)
- Use `@onchange` for dropdowns to get ChangeEventArgs (line 28)
- State changes automatically trigger re-renders
- Keep heavy calculations in methods, not in the markup

## Known Considerations

- The `GetComparisonConfigurations()` method temporarily modifies component state during rendering. This works but is fragile - consider refactoring to use a separate calculation method that doesn't mutate state if making significant changes.
- No backend API - all calculations are client-driven through Blazor Server
- No database - all data is embedded in the component
- Performance test data is static and loaded from the Excel file (not parsed at runtime)

## Project Documentation

- `PROJECT_CONTEXT.md` - Comprehensive project overview, implementation details, and change history
- `data/README.md` - Performance test data structure and usage notes
