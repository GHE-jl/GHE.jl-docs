# GHE.jl Documentation

Central documentation hub for the GHE.jl ecosystem, a collection of Julia packages
for geothermal simulation, ground heat exchanger design, and ground source heat pump analysis.

## Packages

| Package | Description |
|---------|-------------|
| [GroundResponse.jl](https://github.com/GHE-jl/GroundResponse.jl) | Ground thermal response models (ILS, ICS, FLS, MILS, MFLS, ANN) and borefield spatial superposition |
| [BoreholeResistance.jl](https://github.com/GHE-jl/BoreholeResistance.jl) | Internal borehole thermal resistance (multipole method, fluid convection, pipe conduction) |
| [GroundHeatExchanger.jl](https://github.com/GHE-jl/GroundHeatExchanger.jl) | Temporal superposition and mean fluid / outlet temperature simulation |
| [ThermalResponseTest.jl](https://github.com/GHE-jl/ThermalResponseTest.jl) | Thermal response test interpretation |
| [ThermalResponseDeconvolution.jl](https://github.com/GHE-jl/ThermalResponseDeconvolution.jl) | Borehole outlet thermal response function recovery by deconvolution |
| [GroundHeatExchangerSizing.jl](https://github.com/GHE-jl/GroundHeatExchangerSizing.jl) | Ground heat exchanger sizing |
| [GroundSourceHeatPumpDesign.jl](https://github.com/GHE-jl/GroundSourceHeatPumpDesign.jl) | Full ground source heat pump system design |

## Package dependency graph

```
GroundResponse.jl          BoreholeResistance.jl
        │                           │
        └────────────┬──────────────┘
                     ↓
          GroundHeatExchanger.jl
                     │
        ┌────────────┼──────────────────────────┐
        ↓            ↓                           ↓
ThermalResponseTest.jl  GroundHeatExchangerSizing.jl  GroundSourceHeatPumpDesign.jl
        ↓
ThermalResponseDeconvolution.jl
```

`ThermalResponseTest.jl`, `GroundHeatExchangerSizing.jl` and `GroundSourceHeatPumpDesign.jl` are
independent siblings.
`ThermalResponseDeconvolution.jl` is shown downstream of `ThermalResponseTest.jl` as a conceptual,
data-flow relationship only (both work from TRT/GSHP-shaped data); it has no Julia package
dependency on any other package in the ecosystem and can be installed and used standalone.

## Compared to other tools

GHE.jl is one of several open-source options for ground heat exchanger analysis — see
[Comparison to other tools](https://GHE-jl.github.io/GHE.jl-docs/comparison) for the full writeup.
In short:

| Tool | Language | License |
|---|---|---|
| **GHE.jl ecosystem** | Julia | AGPL-3.0 |
| [pygfunction](https://github.com/MassimoCimmino/pygfunction) | Python | BSD-3-Clause |
| [GHEtool](https://github.com/wouterpeere/GHEtool) | Python | BSD-3-Clause |
| [GHEDesigner](https://github.com/BETSRG/GHEDesigner) | Python | BSD-3-Clause |
| [GSHPsDesigner](https://gitlab.com/mlfasci/GSHPsDesigner) | Julia | MIT |

GHE.jl's angle: independently-versioned packages per physical layer (rather than one monolith with
a sizing layer bolted on), every model checked against a table or figure from its source paper, and
Julia's compiled performance for workloads that call a model thousands of times (Monte Carlo,
sensitivity analysis, design-space sweeps).

## Getting started

`BoreholeResistance.jl`, `GroundResponse.jl`, `GroundHeatExchanger.jl`,
`GroundHeatExchangerSizing.jl`, `ThermalResponseTest.jl` and `ThermalResponseDeconvolution.jl` are
all registered in the Julia General registry:

```julia
using Pkg
Pkg.add("GroundResponse")        # ground models only
Pkg.add("BoreholeResistance")    # borehole resistance only
Pkg.add("GroundHeatExchanger")   # full GHE simulation, pulls in the two above
```

See [Getting started](https://GHE-jl.github.io/GHE.jl-docs/getting_started) for the other
registered packages, the still-unregistered `GroundSourceHeatPumpDesign.jl`, and the
local-development workflow.
