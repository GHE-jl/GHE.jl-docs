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
(ThermalResponseDeconvolution.jl)
```

`GroundResponse.jl` and `BoreholeResistance.jl` are independent leaves, neither depends on the
other. `GroundHeatExchanger.jl` depends on both and **re-exports their full public API**, so
downstream code only needs to import the integration package.

## The packages

### BoreholeResistance.jl

The *inside-the-borehole* layer. It computes the steady-state thermal resistances along the path
from the circulating fluid to the borehole wall:

- temperature-dependent **water properties** (`water_k`, `water_cp`, `water_ρ`, `water_μ`);
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
    `Cf = water_cp(T) * water_ρ(T)` — when crossing that boundary. Each package's documentation
    flags this at the relevant functions.

## Extensibility

`GroundResponse.jl` exposes `AbstractGroundModel` as an extension point: subtype it and add
`successive_flux` / `bloc_matrix` methods and a new ground model becomes usable everywhere
`ground_response` is — including inside `GroundHeatExchanger.jl`'s simulation, without changes to
either package.
