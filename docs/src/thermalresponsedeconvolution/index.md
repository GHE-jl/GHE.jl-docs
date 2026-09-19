# ThermalResponseDeconvolution.jl

*Recover a borehole outlet thermal response function of a ground heat exchanger by deconvolution.*

`ThermalResponseDeconvolution.jl` recovers a borehole's **outlet thermal response function**
directly from paired fluid-temperature and heat-load data, by solving a constrained,
multi-objective optimization problem, rather than fitting a physical ground model (as
[ThermalResponseTest.jl](https://github.com/GHE-jl/ThermalResponseTest.jl) does). Because it makes
no ground-model assumption, it applies equally to data from a dedicated thermal response test (TRT)
or from ordinary ground source heat pump (GSHP) operating data logged over time — anywhere paired
inlet/outlet fluid-temperature and heat-load series with a constant time step are available.

The package sits downstream of the same data shape a TRT or a GSHP produces: measured `T_in`,
`T_out` and load. Its `convolution` reimplements the same non-circular FFT convolution as
[GroundHeatExchanger.jl](https://github.com/GHE-jl/GroundHeatExchanger.jl)'s internal
`convolutionf`, independently, so the package can validate a recovered response function (or be
used standalone) without depending on `GroundHeatExchanger.jl`.

## Installation

The package is registered in the Julia General registry:

```julia
using Pkg
Pkg.add("ThermalResponseDeconvolution")
```

or, in the Pkg REPL mode (press `]`):

```
pkg> add ThermalResponseDeconvolution
```

## Quick start

```julia
using ThermalResponseDeconvolution

# f: incremental perturbation function [degC], Texp: measured temperature variation [degC]
f = diff([0.0; Tin .- Tout])
Texp = Tout .- Tout[1]

ĝ, gOpt = deconvolution(t, f, Texp; n=50, c=2)  # ĝ: thermal response function, gOpt: node values
T̂ = collect(convolution(f, ĝ))                  # reconstructed temperature, for validation
rmse = rms(T̂ .- Texp)                           # Temperature root mean square error
```

## Manual outline

- **Tutorial** — a worked example on sample thermal response test data, step by step.
- **Modeling theory** — the multi-objective formulation, constraints, and initial guess.
- **API reference** — the complete docstring reference for every exported function.
- **References** — the bibliography underpinning the implementation.

## Conventions used throughout

| Symbol | Meaning | Unit |
|---|---|---|
| `t` | Time array, starting at 0, with constant time step | s |
| `f` | Incremental perturbation function, `diff([0; Tin .- Tout])` | degC |
| `Texp` | Measured temperature variation, `Tout .- Tout[1]` | degC |
| `ĝ` | Estimated thermal response function, interpolated at every index | - |
| `gOpt` | Optimized thermal response function values at the node indices, before interpolation | - |
| `T̂` | Reconstructed temperature variation, `T̂ = convolution(f, ĝ)` | degC |
| `n` | Number of nodes in the optimization problem | - |
| `c` | Choice of inequality constraints on `ĝ` (0, 1 or 2) | - |

## Ecosystem

`ThermalResponseDeconvolution.jl` is a model-free, standalone alternative to the model-based
inversion in [ThermalResponseTest.jl](https://github.com/GHE-jl/ThermalResponseTest.jl): the two
packages solve related but distinct problems and can be used independently or side by side —
deconvolution recovers the borehole thermal response function itself, while model inversion
recovers physical ground properties (e.g. thermal conductivity) from an assumed ground model.
Neither package depends on the other, and `ThermalResponseDeconvolution.jl` has no dependency on
`GroundHeatExchanger.jl`, `GroundResponse.jl` or `BoreholeResistance.jl` either — the relationship
to the rest of the ecosystem is a conceptual, data-flow one (its inputs look like a TRT or GSHP
record, and its `convolution` mirrors `GroundHeatExchanger.jl`'s own), not a package dependency. See
[Ecosystem](../ecosystem.md) for the full dependency graph.
