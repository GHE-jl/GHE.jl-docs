# GHE.jl

*A composable Julia ecosystem for modelling vertical ground heat exchangers — from borehole
thermal resistance to ground response to full fluid-temperature simulation.*

GHE.jl is a family of small, focused Julia packages for the thermal analysis of
**ground-source heat pump** systems. Each package solves one physical layer of the problem and is
useful on its own; together they form an end-to-end simulation pipeline. The packages share
conventions and re-export one another, so you can reach for exactly the layer you need.

```@raw html
<table>
  <thead><tr><th>Package</th><th>What it does</th><th>Docs</th></tr></thead>
  <tbody>
  <tr>
    <td><b>BoreholeResistance.jl</b></td>
    <td>Water properties and the fluid-to-ground thermal resistance network inside the borehole
        (multipole method, fluid convection, pipe conduction, effective resistance).</td>
    <td><a href="https://GHE-jl.github.io/BoreholeResistance.jl">docs</a> ·
        <a href="https://github.com/GHE-jl/BoreholeResistance.jl">repo</a></td>
  </tr>
  <tr>
    <td><b>GroundResponse.jl</b></td>
    <td>Analytical ground thermal response (<i>g</i>-functions): ILS, ICS, FLS and the moving
        (groundwater-advection) variants, plus borefield spatial superposition.</td>
    <td><a href="https://GHE-jl.github.io/GroundResponse.jl">docs</a> ·
        <a href="https://github.com/GHE-jl/GroundResponse.jl">repo</a></td>
  </tr>
  <tr>
    <td><b>GroundHeatExchanger.jl</b></td>
    <td>The integration layer: temporal superposition (FFT convolution) and mean / inlet / outlet
        fluid-temperature simulation. Depends on and re-exports the two packages above.</td>
    <td><a href="https://GHE-jl.github.io/GroundHeatExchanger.jl">docs</a> ·
        <a href="https://github.com/GHE-jl/GroundHeatExchanger.jl">repo</a></td>
  </tr>
  <tr>
    <td><b>GroundHeatExchangerSizing.jl</b></td>
    <td>Sizing layer: borehole length from ground thermal loads, via the alternative ASHRAE
        equation or borehole-outlet transfer-function sizing, at three load-resolution levels.</td>
    <td><a href="https://GHE-jl.github.io/GroundHeatExchangerSizing.jl">docs</a> ·
        <a href="https://github.com/GHE-jl/GroundHeatExchangerSizing.jl">repo</a></td>
  </tr>
  <tr>
    <td><b>ThermalResponseTest.jl</b></td>
    <td>Interpretation layer: infers ground conductivity and effective borehole resistance from a
        measured thermal response test, via first-order approximation or full model inversion.</td>
    <td><a href="https://GHE-jl.github.io/ThermalResponseTest.jl">docs</a> ·
        <a href="https://github.com/GHE-jl/ThermalResponseTest.jl">repo</a></td>
  </tr>
  </tbody>
</table>
```

`GroundSourceHeatPumpDesign.jl`, the heat pump layer — a standalone sibling of the sizing and
interpretation packages above, not built on top of them — is early / in development. See
[Ecosystem](ecosystem.md) for its current scope.

## How the pieces fit

A vertical ground heat exchanger simulation decomposes into three physically distinct layers, one
per package:

```
        BoreholeResistance.jl                 GroundResponse.jl
   fluid → borehole-wall resistance        borehole-wall → ground response
          (steady-state R_b*)                  (transient g-function)
                    ↘                                  ↙
                          GroundHeatExchanger.jl
              load history  →  fluid / inlet / outlet temperatures
                   (temporal superposition, FFT convolution)
```

- **BoreholeResistance.jl** answers *how big is the temperature drop across the grout and pipes?*
- **GroundResponse.jl** answers *how does the surrounding ground warm up under a unit load?*
- **GroundHeatExchanger.jl** convolves a time-varying load with the ground response and adds the
  resistance drop to produce the fluid temperatures an engineer actually designs against.

Because `GroundHeatExchanger.jl` re-exports the other two, a single `using GroundHeatExchanger`
gives you the entire stack.

## A taste

```julia
using GroundHeatExchanger          # pulls in BoreholeResistance + GroundResponse

H, D, rb, s, ro, ri = 150.0, 2.0, 0.08, 0.05, 0.022, 0.017
ks, Cs, kg, kp      = 3.0, 2.11e6, 1.6, 0.4
T0, V               = 10.0, 30/6e4
t = collect(3600.0:3600:3600*24*365)              # 1 year, hourly

kf = water_k(T0); cf = water_cp(T0); ρf = water_ρ(T0); μf = water_μ(T0)
Cf = cf * ρf

Rb    = resistance_ULoop_effective(V, H, s, rb, ro, ri, ks, kg, kp, kf, cf, ρf, μf)
model = FLSModel(H, D, ks, Cs)
Q     = ground_load_profile(t ./ 3600)

Tf   = fluid_temperature(t, Q ./ H, model, rb, T0, ks, Rb)
Tout = outlet_temperature(Tf, Q, V, Cf)
Tin  = inlet_temperature(Tf, Q, V, Cf)
```

## Where to next

- **[Ecosystem](ecosystem.md)** — a closer look at each package and how they interoperate.
- **[Comparison to other tools](comparison.md)** — how GHE.jl relates to pygfunction, GHEtool,
  GHEDesigner, GSHPsDesigner, and other open-source alternatives.
- **[Getting started](@ref)** — installing the packages and running a first simulation.
- Jump straight into a package's own manual:
  [BoreholeResistance.jl](https://GHE-jl.github.io/BoreholeResistance.jl) ·
  [GroundResponse.jl](https://GHE-jl.github.io/GroundResponse.jl) ·
  [GroundHeatExchanger.jl](https://GHE-jl.github.io/GroundHeatExchanger.jl) ·
  [GroundHeatExchangerSizing.jl](https://GHE-jl.github.io/GroundHeatExchangerSizing.jl) ·
  [ThermalResponseTest.jl](https://GHE-jl.github.io/ThermalResponseTest.jl).

!!! note "Project status"
    These packages are under active development. None are registered in the Julia General registry
    yet; `BoreholeResistance.jl` is the first one being prepared for registration. Until then,
    install any of them directly from their GitHub repositories (see [Getting started](@ref)).
    `GroundSourceHeatPumpDesign.jl` is an early, in-development sixth package — see
    [Ecosystem](ecosystem.md).
