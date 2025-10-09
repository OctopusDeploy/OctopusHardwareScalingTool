# Performance Test Data

This directory contains performance testing data used to power the Hardware Scaling Calculator.

## Files

### Q3C2 Scenario results.xlsx

Performance testing results for Octopus Deploy server under various hardware configurations.

**Key Scenarios:**

- **Scenario 1 - Component**: Small component deployments (TC5, 10 deployments, 1 target)
- **Scenario 2 - Medium, Realistic**: Medium application deployments (TC20/40/80, 100 deployments, 2 targets)
- **Scenario 3 - Machine Parallelism**: Tests varying parallel targets (2, 5, 10, 20 targets per deployment)
- **Scenario 4 - Step Parallelism**: Tests step-level parallelism
- **Scenario 5/6 - Limits**: Performance limit testing
- **Scenario 7 - Variables**: Variable handling performance
- **Scenario 8 - Large Packages**: Large package deployment testing

**Data Structure:**

Each scenario sheet contains:
- Configuration details (Hardware, Task Cap, Concurrent Deployments, etc.)
- Performance metrics:
  - Single execution duration (seconds)
  - Total duration (seconds)
  - VM CPU utilization (%)
  - DB CPU utilization (%)
  - DB Log IO (%)
  - API Responsiveness (P95, ms)
- Links to Performance Test Orchestrator (PTO), dashboards, and Honeycomb
- Threshold comparisons and traffic light indicators

**Primary Data Source for Calculator:**

The calculator primarily uses **Scenario 3 - Machine Parallelism** data:
- CPU millicores tested: 2000, 2500, 3000, 4000
- Targets per deployment: 10, 15
- Task cap: 20
- Number of deployments: 100
- Baseline (2 cores, 10 targets): 607s total, 111s single deployment

## Data Usage

The calculator in `Home.razor` uses this data to:
1. Establish baseline performance metrics
2. Calculate scaling factors for different CPU configurations
3. Estimate deployment times based on user inputs
4. Provide hardware upgrade recommendations

## Data Updates

When updating this file:
1. Replace the Excel file with new test results
2. Review `Home.razor:238-248` for baseline data structure
3. Update calculation logic if test scenarios change significantly
4. Update PROJECT_CONTEXT.md with new performance data summary
