# Comparison to other open-source tools

GHE.jl is not the first open-source geo-exchange simulation tool provided by the community. This page positions the ecosystem against
the other open-source ground heat exchanger (GHE) and ground-source heat pump (GSHP) tools that are
available to provide a broader view the available alternative.

Only actively-maintained **open-source** projects with public source code are listed. Long-standing
freeware/commercial tools relevant to the same design problem, GLHEPRO, LoopLink, Ground Loop
Design (GLD), EED, GshpCalc, GHE Analysis, TRT Analysis, sit outside that scope and are omitted.

## Brief summary of the available ground heat exchanger simulation tools

| Tool | Language | License | Scope |
|---|---|---|---|
| **GHE.jl ecosystem** | Julia | AGPL-3.0 | Modular: resistance, *g*-functions, simulation, sizing, thermal response test interpretation as separate packages |
| [pygfunction](https://github.com/MassimoCimmino/pygfunction) | Python | BSD-3-Clause | Monolithic: *g*-functions, borehole resistance (multipole), load aggregation, fluid temperatures |
| [GHEtool](https://github.com/wouterpeere/GHEtool) | Python | BSD-3-Clause (Community edition) | Borefield sizing and ground-temperature evolution, built on pygfunction |
| [GHEDesigner](https://github.com/BETSRG/GHEDesigner) | Python | BSD-3-Clause | Automated borefield sizing and layout optimization, built on pygfunction |
| [GSHPsDesigner](https://gitlab.com/mlfasci/GSHPsDesigner) | Julia | MIT | Full GSHP system design |
| [BoreholeNetworksSimulator.jl](https://github.com/marcbasquensmunoz/BoreholeNetworksSimulator.jl) | Julia | MIT | Networks of interconnected boreholes: *g*-functions, non-history-dependent temporal superposition, pluggable hydraulic/control configurations |
| [cpgfunction](https://github.com/j-c-cook/cpgfunction) | C++ | BSD-3-Clause | Low-level *g*-function kernel, a memory-efficient alternative to pygfunction's core solver |
| [Fimbul.jl](https://github.com/sintefmath/Fimbul.jl) | Julia | MIT | Full 3D numerical geothermal reservoir simulation (built on JutulDarcy.jl): EGS, ATES/BTES/FTES, deep coaxial wells, well doublets |
| [GeothermalWells.jl](https://github.com/cwittens/GeothermalWells.jl) | Julia | MIT | GPU-accelerated 3D numerical simulation of deep coaxial borehole heat exchangers, single wells and arrays |

Two whole-building energy simulation tools are worth naming even though they play in a different
league: **[EnergyPlus](https://energyplus.net/)**'s `GroundHeatExchanger:Vertical` object and the
**[Modelica Buildings Library](https://github.com/lbl-srg/modelica-buildings)**'s borehole models
both embed a *g*-function-based GHE component inside a full building/HVAC simulation, rather than
offering it as a standalone analysis library. They're the right choice when the GHE is one
component among many in a whole-building model; GHE.jl and the packages above are the right choice
when the GHE itself is the object of study.

## The goal of each simulation tool

**[pygfunction](https://github.com/MassimoCimmino/pygfunction)** (Cimmino, 2018) is the reference
implementation of the finite-line-source *g*-function method in the field and the closest
functional match to GHE.jl as a whole: it covers borehole thermal resistance (multipole method),
*g*-functions for arbitrary borefields, and load-aggregated fluid-temperature simulation in one
package. It is mature, fast for large fields, and the dependency that both GHEtool and GHEDesigner
build their sizing logic on top of.

**[GHEtool](https://github.com/wouterpeere/GHEtool)** (Peere et al., 2022, published in
[JOSS](https://doi.org/10.21105/joss.04406)) sits a layer up: it doesn't compute its own
*g*-functions, it calls pygfunction and adds fast (millisecond-scale) borefield sizing against
monthly or hourly loads, plus a commercial cloud front-end (GHEtool Cloud) alongside the open-source
Community edition. It plays roughly the role of `GroundHeatExchangerSizing.jl` in this ecosystem.

**[GHEDesigner](https://github.com/BETSRG/GHEDesigner)** (Oklahoma State University / Oak Ridge
National Laboratory / NREL, DOE-funded) is the other pygfunction-based sizing tool, distinguished by
its RowWise borefield layout optimizer for irregular property boundaries and district-scale,
multi-GHE system simulation. It overlaps with `GroundHeatExchangerSizing.jl` and, at the system
level, `GroundSourceHeatPumpDesign.jl`.

**[GSHPsDesigner](https://gitlab.com/mlfasci/GSHPsDesigner)** is the other Julia entry in the space,
aimed at full GSHP system design, the closest counterpart to `GroundSourceHeatPumpDesign.jl` here.
It's a smaller, single-maintainer project without the layered package structure described in
[Ecosystem](ecosystem.md).

**[BoreholeNetworksSimulator.jl](https://github.com/marcbasquensmunoz/BoreholeNetworksSimulator.jl)**
(Basquens Muñoz) is the closest Julia analog to the `GroundResponse.jl` + `GroundHeatExchanger.jl`
pair: a pure-Julia, single-package framework for simulating networks of interconnected boreholes,
computing fluid and borehole-wall temperatures via *g*-functions and a non-history-dependent
temporal superposition scheme (linear rather than FFT-convolution complexity in the number of
timesteps). Its focus is network topology and control-strategy flexibility, series/parallel piping,
load-following control via time-step callbacks, rather than the sizing or TRT-interpretation problem;
it isn't in the Julia General registry and needs a custom registry to install.

**[cpgfunction](https://github.com/j-c-cook/cpgfunction)** (Cook) is narrower in scope than the rest
of this table: a C++ re-implementation of just the *g*-function kernel, built to cut the memory
footprint of large-borefield *g*-function calculations on HPC clusters. It's a solver, not a design
tool.

**[Fimbul.jl](https://github.com/sintefmath/Fimbul.jl)** (SINTEF Digital, built on
[JutulDarcy.jl](https://github.com/sintefmath/JutulDarcy.jl)) solves a different problem with a
different method: full 3D, automatic-differentiable finite-volume simulation of subsurface flow and
heat transport, covering aquifer/borehole/fractured thermal energy storage and enhanced geothermal
systems, including heterogeneous and fractured geology that no *g*-function can represent. It's a
mesh-based numerical reservoir simulator that happens to ship a closed-loop-well validation case, not
a GHE design tool. Where GHE.jl trades geological generality for millisecond-scale, closed-form or
semi-analytical evaluation of the standard vertical U-tube case, Fimbul.jl trades setup complexity
and per-run cost for the ability to model geology GHE.jl's *g*-functions cannot.

**[GeothermalWells.jl](https://github.com/cwittens/GeothermalWells.jl)** (Wittenstein) occupies a
narrower version of the same numerical corner: GPU-accelerated (CUDA/ROCm via
[KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl)) full 3D transient
conduction simulation of deep coaxial borehole heat exchangers, single wells and arrays, built for
rapid design-space exploration on hardware GHE.jl doesn't target. It covers a well geometry, deep
coaxial, that GHE.jl's analytical models don't, at the cost of a mesh and a numerical PDE solve per
design point rather than the evaluation of a closed-form expression.

## What GHE.jl brings

None of this is a claim that GHE.jl is strictly *better*, pygfunction and its downstream tools
have years of production use, a larger user base, and (for GHEtool) a commercial support offering. Fimbul.jl can model geology no *g*-function-based tool touches at all. The
ecosystem is younger, and licensed AGPL-3.0 rather than the permissive BSD-3-Clause/MIT terms used
by every other project. What it does differently where it *is* a fit:

- **Modular definition of the core components of a GHE.** Every other *g*-function-based tool in the
  table above (except GSHPsDesigner and BoreholeNetworksSimulator.jl) is a single package that grew a
  sizing/design layer on top of a computation layer. GHE.jl splits resistance
  (`BoreholeResistance.jl`), ground response (`GroundResponse.jl`), simulation
  (`GroundHeatExchanger.jl`), sizing (`GroundHeatExchangerSizing.jl`) and thermal response test
  interpretation (`ThermalResponseTest.jl`) into packages that each have their own versioning, tests,
  and docs, and compose through a small, stable public API. Concretely, `GroundResponse.jl` exposes
  `AbstractGroundModel` as an extension point: a new ground model becomes usable everywhere
  `ground_response` is, including inside `GroundHeatExchanger.jl`'s simulation, without touching
  either package. See [Extensibility](@ref) (in [Ecosystem](ecosystem.md)) for details. That's a
  lower bar for a contributor to add one new model or layer without having to understand or vendor
  the whole stack, and it means you can depend on, say, just `BoreholeResistance.jl` for a resistance
  calculation without pulling in a sizing or TRT layer you don't need.

- **Every model checked against a published number or referenced article, not just internal
  consistency.** The test suites assert against tables and figures from the papers each model
  implements rather than only comparing outputs to earlier runs of the same code. Each package's
  `References` page (e.g. [BoreholeResistance.jl](boreholeresistance/references.md),
  [GroundResponse.jl](groundresponse/references.md)) lists exactly which paper backs which function,
  so a claim in the docs is traceable to a specific number in a specific source rather than taken on
  faith. That standard applies uniformly across all five packages, not just the ones with the most
  users.

- **Compiled performance without leaving the high-level language.** Julia's JIT-compiled numerics
  mean the same code that reads like the equations in a paper runs close to native speed, no drop to
  C/C++ or vectorization contortions needed for the inner loop. Because the underlying method is
  closed-form or semi-analytical rather than a meshed numerical solve, a single *g*-function or
  sizing evaluation runs in milliseconds, cheap enough to call thousands of times over. That matters
  most for workloads that call the same model thousands of times with perturbed inputs, Monte Carlo
  uncertainty propagation, global sensitivity analysis, design-space sweeps, where call overhead
  dominates total runtime and a mesh-based reservoir solve (Fimbul.jl, GeothermalWells.jl) would be
  far too slow per evaluation to use the same way.

- **A codebase built to be read, not just run.** Because each package is small, implements a method
  that reads like the paper's own equations, and stays in one language end to end rather than a
  compiled core wrapped by a scripting layer, a student can open the source for, say, the finite-line-
  source *g*-function or the first-order-approximation TRT fit and step through it line by line in the
  REPL to see exactly how the textbook formula becomes code. That's harder to do in a tool whose
  performance-critical core is C++ (cpgfunction, and the multipole kernel pygfunction wraps) or whose
  result comes out of a mesh and a linear solve rather than a traceable closed-form expression
  (Fimbul.jl, GeothermalWells.jl). Combined with the literature-anchored tests above, that makes the
  ecosystem a workable teaching tool for GSHP design methods, not only a production one: a course can
  assign a single package, `BoreholeResistance.jl`'s multipole method or `GroundResponse.jl`'s finite
  line source, without requiring students to install or understand the rest of the stack.
