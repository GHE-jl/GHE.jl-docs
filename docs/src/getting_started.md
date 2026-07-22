# Getting started

This page gets you from a fresh Julia session to a first ground heat exchanger simulation.

## Installation

The GHE.jl packages are not yet registered in the Julia General registry, so install them
directly from their GitHub repositories. For most users, installing the integration package is
enough — it pulls in the other two:

```julia
using Pkg
Pkg.add(url = "https://github.com/GHE-jl/GroundResponse.jl")
Pkg.add(url = "https://github.com/GHE-jl/BoreholeResistance.jl")
Pkg.add(url = "https://github.com/GHE-jl/GroundHeatExchanger.jl")
```

You can also add just the layer you need — `GroundResponse.jl` (ground models only) or
`BoreholeResistance.jl` (borehole resistance only) — each works standalone.

### Developing locally

If you are working on the packages, clone the three repositories **side by side** and develop them
as local path dependencies:

```julia
using Pkg
Pkg.develop(path = "BoreholeResistance.jl")
Pkg.develop(path = "GroundResponse.jl")
Pkg.develop(path = "GroundHeatExchanger.jl")
Pkg.instantiate()
```

`GroundHeatExchanger.jl` declares the other two as path `[sources]`, so developing it picks up the
matching local checkouts.

## Your first simulation

A complete one-year, hourly single-borehole run, using only `using GroundHeatExchanger`:

```julia
using GroundHeatExchanger

# Geometry [m] and ground / material properties
H, D, rb, s, ro, ri = 150.0, 2.0, 0.08, 0.05, 0.022, 0.017
ks, Cs, kg, kp      = 3.0, 2.11e6, 1.6, 0.4
T0, V               = 10.0, 30/6e4          # 10 °C undisturbed, 30 L/min flow

# Time vector: 1 year, hourly [s]
t = collect(3600.0:3600:3600*24*365)

# Fluid properties (re-exported from BoreholeResistance.jl)
kf = water_k(T0); cf = water_cp(T0); ρf = water_ρ(T0); μf = water_μ(T0)
Cf = cf * ρf                                 # volumetric heat capacity [J/m³·K]

# 1. Borehole resistance  →  BoreholeResistance.jl
Rb = resistance_ULoop_effective(V, H, s, rb, ro, ri, ks, kg, kp, kf, cf, ρf, μf)

# 2. Ground model + load  →  GroundResponse.jl
model = FLSModel(H, D, ks, Cs)
Q     = ground_load_profile(t ./ 3600)         # synthetic annual load [W]

# 3. Temperatures  →  GroundHeatExchanger.jl
Tf   = fluid_temperature(t, Q ./ H, model, rb, T0, ks, Rb)
Tout = outlet_temperature(Tf, Q, V, Cf)
Tin  = inlet_temperature(Tf, Q, V, Cf)
```

The three numbered steps map exactly onto the three packages — see [Ecosystem](ecosystem.md).

## Going to a borehole field

Swap the single borehole for a field by building a coordinate matrix; spatial superposition is
applied automatically:

```julia
xy = borefield(:rectangle, 3, 4, 6.0)        # 3×4 grid, 6 m spacing
Tf = fluid_temperature(t, Q ./ (H * size(xy, 1)), model, rb, xy, T0, ks, Rb)
```

## Learning more

Each package ships a full manual with a tutorial, the modeling theory, and an API reference:

- [BoreholeResistance.jl](https://GHE-jl.github.io/BoreholeResistance.jl) — resistances and water properties
- [GroundResponse.jl](https://GHE-jl.github.io/GroundResponse.jl) — ground models and borefields
- [GroundHeatExchanger.jl](https://GHE-jl.github.io/GroundHeatExchanger.jl) — simulation and temporal superposition

Every package also includes runnable, plotted validation scripts under its `script/` directory.
