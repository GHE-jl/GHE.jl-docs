# Ecosystem

GHE.jl is built as a set of single-responsibility packages that compose. This page explains
what each one contains, how they depend on one another, and the shared conventions that let them
interoperate cleanly.

## The dependency graph

```
GroundResponse.jl          BoreholeResistance.jl
        │                           │
        └────────────┬──────────────┘
                     ↓
          GroundHeatExchanger.jl
                     |
        ────────────────────────────────────────────────────────────────
        |                           |                                   |
ThermalResponseTest.jl    GroundHeatExchangerSizing.jl    GroundSourceHeatPumpDesign.jl
        ↓
ThermalResponseDeconvolution.jl
```

`GroundResponse.jl` and `BoreholeResistance.jl` are independent leaves, neither depends on the
other. `GroundHeatExchanger.jl` depends on both and **re-exports their full public API**, so
downstream code only needs to import the integration package.

## The packages

### BoreholeResistance.jl

The *inside-the-borehole* layer. It computes the steady-state thermal resistances along the path
from the circulating fluid to the borehole wall:

- temperature-dependent **fluid properties** (`fluid_property`, for water and antifreeze mixtures
  via CoolProp; the standalone `water_k`, `water_cp`, `water_ρ`, `water_μ` are deprecated);
- the **fluid convective resistance** via the Gnielinski correlation
  (`Reynolds`, `Prandtl`, `Nusselt`, friction factors, `resistance_fluid`);
- the **pipe wall conductive resistance** (`resistance_pipe`);
- the **borehole / grout resistance** and **internal resistance** via the zeroth- and first-order
  **multipole method** (`resistance_borehole_multipole`, `resistance_total_internal_multipole`);
- the **effective borehole resistance** ``R_b^*`` that corrects for axial thermal short-circuiting
  (`resistance_ULoop_effective`).

Single and double U-tube configurations are supported. → [Documentation](https://GHE-jl.github.io/BoreholeResistance.jl)

### GroundResponse.jl

The *outside-the-borehole* layer. It evaluates analytical ground thermal response functions
(*g*-functions) and assembles borehole fields:

- five models — infinite line source (`ils`/`ILSModel`), infinite cylindrical source
  (`ics`/`ICSModel`), finite line source (`fls`/`FLSModel`), and the moving variants for
  groundwater advection (`mils`/`MILSModel`, `mfls`/`MFLSModel`);
- a single high-level entry point (`ground_response`) dispatching over model and field size;
- **spatial superposition** for borehole fields (`successive_flux`, `bloc_matrix`);
- a family of **borefield layout** generators (`borefield`, `borefield_rectangle`, …).

It is designed as a computational backbone: it returns uninterpolated responses at arbitrary times
and radii, leaving sampling and system modelling to downstream packages.
→ [Documentation](https://GHE-jl.github.io/GroundResponse.jl)

### GroundHeatExchanger.jl

The *integration* layer. It ties resistance and ground response together over a time-varying load:

- **temporal superposition** via FFT convolution, stationary (`convolution`) and non-stationary
  (`convolution_ns`) for time-varying operating conditions;
- **fluid-temperature simulation** — mean (`fluid_temperature`), outlet (`outlet_temperature`) and
  inlet (`inlet_temperature`);
- a **g-function compression** wrapper (`ground_response` with PCHIP interpolation) that makes long
  hourly simulations tractable;
- utilities — a synthetic annual load (`ground_load_profile`) and pipe head loss
  (`head_loss_Darcy_Weisbach`).

→ [Documentation](https://GHE-jl.github.io/GroundHeatExchanger.jl)

### GroundHeatExchangerSizing.jl

The *sizing* layer. Given ground thermal loads, it finds the borehole length that keeps the
heat-pump fluid temperature within its operating limits, at three levels of load-resolution detail
(L2 three-pulse, L3 monthly, L4 hourly):

- the **alternative ASHRAE sizing equation** (Ahmadfard & Bernier, 2018, 2019), which removes the
  temperature-penalty term by evaluating the finite-line-source *g*-function for the actual
  borefield directly, solved by fixed-point iteration;
- **borehole-outlet transfer-function sizing** (Dion & Pasquier, 2025), which replaces the
  borehole-wall *g*-function with a dimensionless transfer function defined at the borehole outlet,
  solved by a bounded one-dimensional optimisation ([Optim.jl](https://github.com/JuliaNLSolvers/Optim.jl)'s `Brent` method).

It builds on `GroundHeatExchanger.jl` (and therefore transitively on `GroundResponse.jl` and
`BoreholeResistance.jl`) and sizes on **ground** loads. Converting a building load to a ground load
through the heat pump's COP is the job of `GroundSourceHeatPumpDesign.jl` — see the note on `Q_COP`
below.

→ [Documentation](https://GHE-jl.github.io/GroundHeatExchangerSizing.jl)

### ThermalResponseTest.jl

The *interpretation* layer, working in the opposite direction from the packages above: instead of
predicting fluid temperature from known ground properties, it infers the ground thermal
conductivity ``k_s``, the effective borehole resistance ``R_b^*``, and (with the moving ground
models) the groundwater Darcy velocity ``v_D``, from a measured thermal response test (TRT) log.
Two complementary interpretation families are provided:

- **first-order approximation (FOA)** — fast closed-form regressions built on the infinite line
  source (Pasquier, 2018), with heating and recovery variants using either the temperature itself
  or its time derivative;
- **model inversion** — bounded least-squares fitting of a full ground-response model (any of the
  `GroundResponse.jl` models, static or moving) to the entire measured signal, using
  [Optimization.jl](https://github.com/SciML/Optimization.jl).

It depends on `GroundHeatExchanger.jl` for the `GroundResponse.jl` ground models and the
`convolution` temporal-superposition routine that both the model inversions and the package's
synthetic-TRT tests are built on.

→ [Documentation](https://GHE-jl.github.io/ThermalResponseTest.jl)

### ThermalResponseDeconvolution.jl

The *model-free interpretation* layer, downstream of a thermal response test (TRT) or ground
source heat pump (GSHP) operating record in the same way as `ThermalResponseTest.jl`, but without
fitting a physical ground model. Given paired inlet/outlet fluid temperature and heat-load data at
a constant time step, it recovers the borehole outlet thermal response function itself, by solving
a constrained multi-objective optimization problem:

- a **non-circular FFT convolution** (`convolution`) between a load and a response function, used
  both to build the deconvolution inputs and to validate a recovered response function;
- **deconvolution** (`deconvolution`) of the response function from measured temperature and load,
  posed as a weighted temperature-misfit plus first-/second-derivative regularization, solved with
  [Optimization.jl](https://github.com/SciML/Optimization.jl) via NLopt's SLSQP algorithm;
- a reduced, log-spaced **node parameterization** of the response function (`set_nodes`) that keeps
  the optimization tractable on long records, interpolated with
  [PCHIPInterpolation.jl](https://github.com/gerlero/PCHIPInterpolation.jl);
- a small **root-mean-square** helper (`rms`) used throughout for reporting fit residuals.

`ThermalResponseDeconvolution.jl` is not a Julia package dependency of `GroundHeatExchanger.jl`
(or vice versa): its `[deps]` lists neither `GroundHeatExchanger.jl`, `BoreholeResistance.jl` nor
`GroundResponse.jl`. The relationship in the diagram above is conceptual and data-flow only: it
consumes the same `T_in`/`T_out`/load data shape that a TRT or a GSHP produces, and its
`convolution` independently reimplements the same non-circular FFT convolution as
`GroundHeatExchanger.jl`'s internal `convolutionf`, so the two packages can validate against one
another without either depending on the other.

→ [Documentation](https://GHE-jl.github.io/ThermalResponseDeconvolution.jl)

### GroundSourceHeatPumpDesign.jl *(early / in development)*

The *heat pump* layer, a standalone sibling of `GroundHeatExchangerSizing.jl` and
`ThermalResponseTest.jl` rather than a package built on top of them, it does not depend on either.
Today it provides heat pump performance interpolation (`heat_pump_performance`, 1D/2D on
source/load entering fluid temperature) and building-to-ground load conversion (`Q_COP`,
`ground_load_from_heat_pump`). Its public API may change without notice.

!!! note "`Q_COP` also exists in `GroundHeatExchangerSizing.jl`"
    Both packages provide their own `Q_COP`, with identical logic. This is intentional: the two
    packages are independent by design, so each carries the small building-to-ground load
    conversion helper it needs rather than depending on the other for it. Loading both together in
    the same session would still hit a Julia export collision on the shared name, so use one or the
    other's `Q_COP` qualified (`GroundHeatExchangerSizing.Q_COP`) if you ever need both packages at
    once.

→ [Repository](https://github.com/GHE-jl/GroundSourceHeatPumpDesign.jl) (documentation not yet
published)

## Shared conventions

The packages agree on units and notation so values pass between them without surprises:

| Symbol | Meaning | Unit |
|---|---|---|
| ``R_b^*`` | Effective borehole resistance | m·K/W |
| ``g`` | Ground thermal response | °C·m/W |
| ``q`` / ``Q`` | Heat load per unit length / total | W/m, W |
| ``k_s`` / ``C_s`` | Ground conductivity / volumetric heat capacity | W/m·K, J/m³·K |
| ``T_f, T_{in}, T_{out}`` | Mean / inlet / outlet fluid temperature | °C |

!!! warning "The heat-capacity boundary"
    `BoreholeResistance.jl` works with the **mass-specific** heat ``c_f`` [J/kg·K] (and density
    ``\rho_f`` separately), while the inlet/outlet routines in `GroundHeatExchanger.jl` need the
    **volumetric** specific heat ``C_f = c_f\,\rho_f`` [J/m³·K]. Convert explicitly —
    `Cf = cf * ρf`, with `cf, ρf` from `fluid_property(T, :water)` — when crossing that boundary.
    Each package's documentation flags this at the relevant functions.

## Extensibility

`GroundResponse.jl` exposes `AbstractGroundModel` as an extension point: subtype it and add one
`_borehole_response` method and a new ground model becomes usable everywhere `ground_response` is, 
including inside `GroundHeatExchanger.jl`'s simulation, without changes to either package.
