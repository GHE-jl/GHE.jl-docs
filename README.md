# GeothermalJL Documentation

Central documentation hub for the GeothermalJL ecosystem — a collection of Julia packages
for geothermal simulation, ground heat exchanger design, and ground source heat pump analysis.

## Packages

| Package | Description |
|---------|-------------|
| [GroundResponse.jl](https://github.com/GeothermalJL/GroundResponse.jl) | Ground thermal response models (ILS, ICS, FLS, MILS, MFLS, ANN) and borefield spatial superposition |
| [BoreholeResistance.jl](https://github.com/GeothermalJL/BoreholeResistance.jl) | Internal borehole thermal resistance (multipole method, fluid convection, pipe conduction) |
| [GroundHeatExchanger.jl](https://github.com/GeothermalJL/GroundHeatExchanger.jl) | Temporal superposition and mean fluid / outlet temperature simulation |
| [ThermalResponseTest.jl](https://github.com/GeothermalJL/ThermalResponseTest.jl) | Thermal response test interpretation |
| [GroundHeatExchangerSizing.jl](https://github.com/GeothermalJL/GroundHeatExchangerSizing.jl) | Ground heat exchanger sizing |
| [GroundSourceHeatPumpDesign.jl](https://github.com/GeothermalJL/GroundSourceHeatPumpDesign.jl) | Full ground source heat pump system design |

## Package dependency graph

```
GroundResponse.jl          BoreholeResistance.jl
        │                           │
        └────────────┬──────────────┘
                     ↓
          GroundHeatExchanger.jl
                     │
         ┌───────────┼───────────┐
         ↓           ↓           ↓
  ThermalResponse  GHESizing  (other tools)
  Test.jl          .jl
         │           │
         └─────┬─────┘
               ↓
  GroundSourceHeatPumpDesign.jl
```

## Getting started

Install the full ecosystem:
```julia
using Pkg
Pkg.add("GroundSourceHeatPumpDesign")
```

Or install individual packages:
```julia
Pkg.add("GroundResponse")        # ground models only
Pkg.add("BoreholeResistance")    # borehole resistance only
Pkg.add("GroundHeatExchanger")   # full GHE simulation
```
