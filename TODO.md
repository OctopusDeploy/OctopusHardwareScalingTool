# TODO - Octopus Hardware Sizing Tool

## Critical UX/Messaging Updates for Location-Centric Customers 🎯

### Immediate Priority - Reframe Tool Purpose ✅
- [x] **Change intro headline** from "Will Octopus Perform Well For You?" to something like "Right-Size Your Octopus 
  Hardware" or "Hardware Sizing Calculator for Octopus Deploy"
- [x] **Reframe tool purpose** - Position as a hardware sizing/planning tool, not a performance predictor
- [x] **Restructure workflow** to match Location-Centric thinking:
  1. First: Describe your deployment scenario (targets, concurrent deployments, etc.)
  2. Second: Show expected performance/load with recommended hardware
  3. Third: Allow adjustment of available hardware to see impact

### Location-Centric Customer Focus 🏪 ✅
Based on archetype document, Location-Centric customers (Bunnings, Next, DRB, Philips, Pet Supplies Plus, Tabcorp) have:
- **High number of tenants** (one per store/location)
- **High number of targets per tenant** (multiple POS devices, inventory systems per store)
- **Edge hardware** (Windows 10, K3s, often resource-constrained)
- **Bandwidth/network challenges** (store-managed infrastructure)
- **Maintenance windows** (nightly deployments outside business hours)
- **All projects deployed at once** during maintenance windows

### Required Changes for Location-Centric Messaging ✅
- [x] Add **"Number of Locations/Stores"** input field
- [x] Add **"Devices per Location"** input field (to calculate total targets)
- [x] Include **network bandwidth** as a consideration
- [x] Add **maintenance window duration** input
- [x] Frame performance in terms of **"Can you deploy to all locations within your maintenance window?"**
- [x] Add **"Deployment Window Calculator"** - shows if deployments will fit in maintenance window

### UI/UX Improvements Based on Customer Archetype ✅
- [x] Use location-centric terminology:
  - "Locations" or "Stores" instead of "Tenants"
  - "Devices" or "Endpoints" instead of just "Targets"
  - "Nightly deployment window" instead of generic timing
- [x] Add presets/templates:
  - "Retail Chain" preset (many locations, multiple devices per location)
  - "Global B2B SaaS" preset (many tenants, fewer targets)
  - "Continuous Deployment" preset (no tenants, many environments)
- [x] Show time estimates: "Estimated time to deploy to all locations: X minutes"

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

## Small Tweaks to the Existing Content ✅
- [x] Remove the left hand and top navigation bar
- [x] Remove the section on Understanding Performance Levels as it has the same information as Expected Resource
  Utilization
- [x] Change the icons for Recommended Hardware Specifications use:
    - A cpu chip for cpu cores
    - A ram din chip for memory
    - A database icon for the database server

## Add Cloud Pricing ✅
- [x] Add the same header as https://octopus.com/pricing/overview
- [x] Add tabs for Octopus Server and Octopus Cloud like on the https://octopus.com/pricing/overview page the current experience is for the server tab
- [x] Have a very similar experience however instead of allowing the customer to select the number of cores they want to assume a core costs $100 per month and the cloud platform will provide all the cores up to a specific budget they can set per month
- [x] add the same describe your deployment scenario section as the server tab

## Make it look like this page is actually on Octopus.com ✅
- [x] Add exactly the same nav bar  as https://octopus.com/pricing/overview
- [x] make the server and cloud tabs look exactly the same as https://octopus.com/pricing/overview
- [x] Make the title look exactly the same as https://octopus.com/pricing/overview and make the title "Octopus
  scales to meet your deployment needs"

## Deploy it to azure and push it to github
- Create a repo for this in the Ocotpus org https://github.com/OctopusDeploy
- Explain in the readme that this is an example of how we can use the data the Server At Scale team is collecting top build trust with customers
- Publish it so its accesible in azure in the directory 3d13e379-e666-469e-ac38-ec6fd61c1166
and in the subscription a64630ce-fe4a-4d9d-92f2-3f770daa7d54
- Make it so only users in the group bead26f3-a84d-459f-9443-f1609a37a62f can access it 