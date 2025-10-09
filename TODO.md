# TODO - Octopus Hardware Sizing Tool

## Critical UX/Messaging Updates for Location-Centric Customers 🎯

### Immediate Priority - Reframe Tool Purpose
- [ ] **Change intro headline** from "Will Octopus Perform Well For You?" to something like "Right-Size Your Octopus Hardware" or "Hardware Sizing Calculator for Octopus Deploy"
- [ ] **Reframe tool purpose** - Position as a hardware sizing/planning tool, not a performance predictor
- [ ] **Restructure workflow** to match Location-Centric thinking:
  1. First: Describe your deployment scenario (targets, concurrent deployments, etc.)
  2. Second: Show expected performance/load with recommended hardware
  3. Third: Allow adjustment of available hardware to see impact

### Location-Centric Customer Focus 🏪
Based on archetype document, Location-Centric customers (Bunnings, Next, DRB, Philips, Pet Supplies Plus, Tabcorp) have:
- **High number of tenants** (one per store/location)
- **High number of targets per tenant** (multiple POS devices, inventory systems per store)
- **Edge hardware** (Windows 10, K3s, often resource-constrained)
- **Bandwidth/network challenges** (store-managed infrastructure)
- **Maintenance windows** (nightly deployments outside business hours)
- **All projects deployed at once** during maintenance windows

### Required Changes for Location-Centric Messaging
- [ ] Add **"Number of Locations/Stores"** input field
- [ ] Add **"Devices per Location"** input field (to calculate total targets)
- [ ] Include **network bandwidth** as a consideration
- [ ] Add **maintenance window duration** input
- [ ] Frame performance in terms of **"Can you deploy to all locations within your maintenance window?"**
- [ ] Add **"Deployment Window Calculator"** - shows if deployments will fit in maintenance window

### UI/UX Improvements Based on Customer Archetype
- [ ] Use location-centric terminology:
  - "Locations" or "Stores" instead of "Tenants"
  - "Devices" or "Endpoints" instead of just "Targets"
  - "Nightly deployment window" instead of generic timing
- [ ] Add presets/templates:
  - "Retail Chain" preset (many locations, multiple devices per location)
  - "Global B2B SaaS" preset (many tenants, fewer targets)
  - "Continuous Deployment" preset (no tenants, many environments)
- [ ] Show time estimates: "Estimated time to deploy to all locations: X minutes"

## Completed Changes ✅
- [x] Fixed dropdown text visibility issues with CSS
- [x] Redesigned UX from technical calculator to customer-focused journey
- [x] Fixed slider reactivity issues (added property setters, StateHasChanged, recursion protection)
- [x] Removed unused "Deployments in Batch" slider
- [x] Removed unused "Task Cap" dropdown
- [x] Added CPU cores slider for self-hosted scenarios (2-16 cores)
- [x] Replaced batch/task cap with "Concurrent Deployments" slider
- [x] Updated all text to remove "Standard Plan" references
- [x] Made upgrade slider smart (starts from current cores + 1)
- [x] Dynamic text updates based on selected CPU cores