# Comparison to other open-source tools

GHE.jl is not the first open-source effort in this space. This page positions the ecosystem against
the other open-source ground heat exchanger (GHE) and ground-source heat pump (GSHP) tools that are
available, so you can pick the right tool for the job, including one that isn't this one.

Only actively-maintained **open-source** projects with public source code are listed. Long-standing
freeware/commercial tools relevant to the same design problem, GLHEPRO, LoopLink, Ground Loop
Design (GLD), EED, GshpCalc, GHE Analysis, TRT Analysis, sit outside that scope and are omitted.

## The landscape

| Tool | Language | License | Scope |
|---|---|---|---|
| **GHE.jl ecosystem** | Julia | GPL-3.0 | Modular: resistance, *g*-functions, simulation, sizing, thermal response test interpretation as separate packages |
| [pygfunction](https://github.com/MassimoCimmino/pygfunction) | Python | BSD-3-Clause | Monolithic: *g*-functions, borehole resistance (multipole), load aggregation, fluid temperatures |
| [GHEtool](https://github.com/wouterpeere/GHEtool) | Python | BSD-3-Clause (Community edition) | Borefield sizing and ground-temperature evolution, built on pygfunction |
| [GHEDesigner](https://github.com/BETSRG/GHEDesigner) | Python | BSD-3-Clause | Automated borefield sizing and layout optimization, built on pygfunction |
| [GSHPsDesigner](https://gitlab.com/mlfasci/GSHPsDesigner) | Julia | MIT | Full GSHP system design |
| [cpgfunction](https://github.com/j-c-cook/cpgfunction) | C++ | BSD-3-Clause | Low-level *g*-function kernel, a memory-efficient alternative to pygfunction's core solver |

Two whole-building energy simulation tools are worth naming even though they play in a different
league: **[EnergyPlus](https://energyplus.net/)**'s `GroundHeatExchanger:Vertical` object and the
**[Modelica Buildings Library](https://github.com/lbl-srg/modelica-buildings)**'s borehole models
both embed a *g*-function-based GHE component inside a full building/HVAC simulation, rather than
offering it as a standalone analysis library. They're the right choice when the GHE is one
component among many in a whole-building model; GHE.jl and the packages above are the right choice
when the GHE itself is the object of study.

## Where each project sits

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

**[cpgfunction](https://github.com/j-c-cook/cpgfunction)** (Cook) is narrower in scope than the rest
of this table: a C++ re-implementation of just the *g*-function kernel, built to cut the memory
footprint of large-borefield *g*-function calculations on HPC clusters. It's a solver, not a design
tool.

## What GHE.jl brings

None of this is a claim that GHE.jl is strictly *better*, pygfunction and its downstream tools
have years of production use, a larger user base, and (for GHEtool) a commercial support offering
GHE.jl doesn't have. The ecosystem is younger, and licensed GPL-3.0 rather than the permissive BSD-3-Clause/MIT
terms used by every other projects. What it does differently where it *is* a fit:

- **Modular definition of the core components of a GHE.** Every other tool in the table above (except
  GSHPsDesigner) is a single package that grew a sizing/design layer on top of a computation layer.
  GHE.jl splits resistance (`BoreholeResistance.jl`), ground response (`GroundResponse.jl`),
  simulation (`GroundHeatExchanger.jl`), sizing (`GroundHeatExchangerSizing.jl`) and thermal response test interpretation (`ThermalResponseTest.jl`) into packages
  that each have their own versioning, tests, and docs, and compose through a small, stable public
  API. Concretely, `GroundResponse.jl` exposes `AbstractGroundModel` as an extension point: a new
  ground model becomes usable everywhere `ground_response` is, including inside
  `GroundHeatExchanger.jl`'s simulation, without touching either package. See
  [Extensibility](@ref) (in [Ecosystem](ecosystem.md)) for details. That's a lower bar for a
  contributor to add one new model or layer without having to understand or vendor the whole stack.

- **Every model checked against a published number or referenced article, not just internal consistency.** The test
  suites assert against tables and figures from the papers each model implements rather than only comparing outputs to earlier runs of the same code. Each package's
  `References` page (e.g. [BoreholeResistance.jl](boreholeresistance/references.md),
  [GroundResponse.jl](groundresponse/references.md)) lists exactly which paper backs which function.

- **Compiled performance without leaving the high-level language.** Julia's JIT-compiled numerics
  mean the same code that reads like the equations in a paper runs close to native speed, no
  drop to C/C++ or vectorization contortions needed for the inner loop. That matters most for
  workloads that call the same model thousands of times with perturbed inputs, such as in Monte Carlo
  uncertainty propagation, global sensitivity analysis, design-space sweeps, where call
  overhead dominates total runtime.
