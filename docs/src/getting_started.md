# Getting started

This page gets you from a fresh Julia session to a first ground heat exchanger simulation.

## Installation

`BoreholeResistance.jl`, `GroundResponse.jl`, `GroundHeatExchanger.jl`,
`GroundHeatExchangerSizing.jl`, `ThermalResponseTest.jl` and `ThermalResponseDeconvolution.jl` are
all registered in the Julia General registry. For most users, installing the integration package
is enough to start with:

```julia
using Pkg
Pkg.add("GroundHeatExchanger")
```

You can also add just the layer you need, `GroundResponse.jl` (ground models only) or
`BoreholeResistance.jl` (borehole resistance only). Each works as a standalone package, but are also
included in `GroundHeatExchanger.jl`:

```julia
Pkg.add("GroundResponse")
Pkg.add("BoreholeResistance")
```

Three further packages sit downstream of `GroundHeatExchanger.jl`, and are installed the same way:

```julia
Pkg.add("GroundHeatExchangerSizing")       # borehole-length sizing
Pkg.add("ThermalResponseTest")             # TRT interpretation
Pkg.add("ThermalResponseDeconvolution")    # response-function deconvolution
```

`ThermalResponseDeconvolution.jl` has no `[deps]` on any package above and is fully usable
standalone.

`GroundSourceHeatPumpDesign.jl` is early / in development and not yet registered — install it
directly from GitHub if you need it:

```julia
Pkg.add(url = "https://github.com/GHE-jl/GroundSourceHeatPumpDesign.jl")
```

### Developing locally

If you are working on the packages, clone the repositories you need **side by side** and develop
them as local path dependencies. For the core three:

```julia
using Pkg
Pkg.develop(path = "BoreholeResistance.jl")
Pkg.develop(path = "GroundResponse.jl")
Pkg.develop(path = "GroundHeatExchanger.jl")
Pkg.instantiate()
```

To help with the development of the latest versions of all packages, refer to the GitHub projects
for each package, which can be found under the GHE.jl [GitHub organization](https://github.com/GHE-jl).
`GroundHeatExchanger.jl` declares the other two as path `[sources]`, so developing it picks up the
matching local checkouts. `GroundHeatExchangerSizing.jl` and `ThermalResponseTest.jl` do the same
for their own direct dependencies — clone them alongside the packages above and `Pkg.develop` them
the same way.

## A first simulation

A complete one-year, hourly single-borehole run, using only `using GroundHeatExchanger`:

```julia
using GroundHeatExchanger

# Geometry [m] and ground / material properties
H, D, rb, s, ro, ri = 150.0, 2.0, 0.08, 0.05, 0.022, 0.017
ks, Cs, kg, kp = 3.0, 2.11e6, 1.6, 0.4
T0, V = 10.0, 30/6e4          # 10 °C undisturbed, 30 L/min flow

# Time vector: 1 year, hourly [s]
t = collect(3600.0:3600:3600*24*365)

# Fluid properties (re-exported from BoreholeResistance.jl)
kf, cf, ρf, μf = fluid_property(T0, :water)
Cf = cf * ρf                                 # volumetric heat capacity [J/m³·K]

# 1. Borehole resistance (BoreholeResistance.jl)
Rb = resistance_ULoop_effective(V, H, s, rb, ro, ri, ks, kg, kp, kf, cf, ρf, μf)

# 2. Ground model + load (GroundResponse.jl)
model = FLSModel(H, D, ks, Cs)
Q     = ground_load_profile(t ./ 3600)         # synthetic annual load [W]

# 3. Temperatures (GroundHeatExchanger.jl)
Tf   = fluid_temperature(t, Q ./ H, model, rb, T0, ks, Rb)
Tout = outlet_temperature(Tf, Q, V, Cf)
Tin  = inlet_temperature(Tf, Q, V, Cf)
```

The three numbered steps map exactly onto the three packages (see [Ecosystem](ecosystem.md)).

## Going to a borehole field

Swap the single borehole for a field by building a coordinate matrix; spatial superposition is
applied automatically:

```julia
xy = borefield(:rectangle, 3, 4, 6.0)        # 3×4 grid, 6 m spacing
Tf = fluid_temperature(t, Q ./ (H * size(xy, 1)), model, rb, xy, T0, ks, Rb)
```

## Learning more

Each package ships a full manual with a tutorial, the modeling theory, and an API reference:

- [BoreholeResistance.jl](https://GHE-jl.github.io/BoreholeResistance.jl) — resistances and fluid properties
- [GroundResponse.jl](https://GHE-jl.github.io/GroundResponse.jl) — ground models and borefields
- [GroundHeatExchanger.jl](https://GHE-jl.github.io/GroundHeatExchanger.jl) — simulation and temporal superposition
- [GroundHeatExchangerSizing.jl](https://GHE-jl.github.io/GroundHeatExchangerSizing.jl) — borehole-length sizing
- [ThermalResponseTest.jl](https://GHE-jl.github.io/ThermalResponseTest.jl) — thermal response test interpretation
- [ThermalResponseDeconvolution.jl](https://GHE-jl.github.io/ThermalResponseDeconvolution.jl) — thermal response function deconvolution

Every package also includes runnable, plotted validation scripts under its `script/` directory.
