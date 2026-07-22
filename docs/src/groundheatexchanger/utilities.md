# Utilities

Beyond the simulation core, `GroundHeatExchanger.jl` ships a few helpers used throughout the
examples and for hydraulic (pump) sizing.

## Synthetic load profile

`ground_load_profile` generates a realistic **annual heat-load signal** for testing the
convolution — a smooth seasonal sine modulated by daily harmonics and a building on/off pattern,
following Eqs. 7–8 of Bernier et al. (2004). It takes time **in hours** and returns the load in
watts:

```julia
t = collect(3600.0:3600:3600*24*365)   # 1 year, hourly [s]
Q = ground_load_profile(t ./ 3600)        # [W]
```

All seven shape parameters (amplitude, phase, harmonics, …) have sensible defaults; override them to
change the amplitude or the heating/cooling balance.

## Head loss for pump sizing

`head_loss_Darcy_Weisbach` returns the **hydraulic head loss** of a pipe segment from the
Darcy–Weisbach equation:

```math
\Delta h = f \, \frac{L}{2r} \, \frac{\dot V^2}{2g},
```

with ``L`` the pipe length, ``r`` the inner radius, ``\dot V`` the mean fluid speed, ``g = 9.81``
m/s², and ``f`` the Darcy friction factor — which you obtain from the re-exported
`friction_factor_Colebrook_White` or `friction_factor_Tkachenko_Mileikovskyi` of
`BoreholeResistance.jl`:

```julia
V̇ = V / (π * ri^2)                              # mean fluid speed [m/s]
f = friction_factor_Colebrook_White(Reynolds(V̇, ri, ρf, μf), ri, 1e-5)
Δh = head_loss_Darcy_Weisbach(2H, ri, V̇, f)     # down + up the borehole
```

## Example parameter set

`GHE` returns a complete, named tuple of typical geometry, ground, grout, pipe and fluid
properties used by the package's validation scripts. It is a convenience for reproducing the
examples without re-typing two dozen parameters:

```julia
t, H, D, s, rb, ro, ri, T0, ks, kg, kp, kf, Cs, Cg, Cp, Cf, ρs, ρg, ρp, ρf, μf, ϵ, vD, V = GHE()
```


