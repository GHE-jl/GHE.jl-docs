# Fluid temperature

This page documents the three temperature outputs of the simulation: the **mean** fluid temperature
``T_f`` and the **outlet** and **inlet** temperatures that bracket it. Together they are what a
sizing or control calculation actually consumes.

## Mean fluid temperature

`fluid_temperature` evaluates the master equation (see Simulation pipeline):

```math
T_f(t) = T_0 + q(t)\,R_b^* + \frac{(q \star g)(t)}{2\pi k_s}.
```

The first term is the undisturbed ground temperature, the second the instantaneous resistance drop
across the borehole, and the third the cumulative ground temperature rise from the
Temporal superposition of the load with the g-function.

The function comes in several overloads of increasing convenience:

```julia
# With a pre-computed g-function vector
fluid_temperature(t, q, g, T0, ks, Rb)          # q in W/m
fluid_temperature(t, Q, g, H, T0, ks, Rb)       # Q in W, divided by H internally

# With a ground model — g computed and PCHIP-compressed automatically
fluid_temperature(t, q, m, rb, T0, ks, Rb;        n_nodes=150)   # single borehole
fluid_temperature(t, q, m, rb, xy, T0, ks, Rb;    n_nodes=150)   # borefield (xy: nb×2)
fluid_temperature(t, Q, H, m, rb, T0, ks, Rb;     n_nodes=150)   # total load Q in W
```

The model overloads call the `ground_response` wrapper for you, so the g-function is
evaluated on a logarithmic node subset and reconstructed by PCHIP interpolation — pass `n_nodes=0`
to disable that and evaluate exactly. See g-function compression.

## Outlet and inlet temperatures

The mean temperature ``T_f`` is the depth-average of the fluid. The fluid actually *enters* the
borehole warmer (in injection) and *leaves* it cooler, split symmetrically about the mean by the
sensible heat it exchanges:

```math
T_{out} = T_f - \frac{Q}{2\,V\,C_f}, \qquad
T_{in}  = T_f + \frac{Q}{2\,V\,C_f},
```

where ``Q`` [W] is the total load, ``V`` [m³/s] the volumetric flow rate and ``C_f`` [J/m³·K] the
**volumetric** fluid heat capacity. `outlet_temperature` and `inlet_temperature`
each accept either the total load `Q` or the per-length load `q` together with the depth `H`:

```julia
Tout = outlet_temperature(Tf, Q, V, Cf)        # total load Q [W]
Tout = outlet_temperature(Tf, q, H, V, Cf)     # per-length load q [W/m]
Tin  = inlet_temperature(Tf, Q, V, Cf)
```

!!! warning "Use the volumetric heat capacity here"
    ``C_f`` in these formulas is the **volumetric** specific heat ``C_f = c_f\,\rho_f`` [J/m³·K],
    *not* the mass-specific ``c_f`` [J/kg·K] used by `resistance_ULoop_effective`. Compute it as
    `Cf = water_cp(T) * water_ρ(T)`.


