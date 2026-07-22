# g-function compression

Evaluating the analytical g-function (an integral or series, possibly with spatial superposition
over a field) at *every* time step is the dominant cost of a long hourly simulation. Because the
g-function is **smooth and slowly varying on a logarithmic time axis**, it can be evaluated at a
small subset of nodes and reconstructed almost exactly by interpolation. This page documents the
`ground_response` wrapper that does this and the interpolation helpers behind it.

## The wrapper

`GroundHeatExchanger.jl` defines its own `ground_response` on top of
`GroundResponse.ground_response`. When the time vector is longer than `n_nodes`, it:

1. picks `n_nodes` logarithmically spaced time indices with `set_nodes`;
2. evaluates the underlying `GroundResponse.ground_response` only at those nodes;
3. reconstructs the full-length g-function by PCHIP interpolation (`pchip_interpolation`).

```julia
g = ground_response(t, rb, xy, model)              # PCHIP compression, 150 nodes (default)
g = ground_response(t, rb, xy, model; n_nodes=0)   # exact — no compression
```

Passing `n_nodes=0` (or any value ``\ge`` `length(t)`) skips compression and evaluates exactly. The
same `n_nodes` keyword flows through the `fluid_temperature` overloads that take a ground
model, so compression is applied transparently in a full simulation.

## Why PCHIP

The reconstruction uses a **Piecewise Cubic Hermite Interpolating Polynomial**
([`PCHIPInterpolation.jl`](https://github.com/gerlero/PCHIPInterpolation.jl)). PCHIP is
**shape-preserving**: it does not overshoot or introduce spurious oscillations between nodes, which
matters because a g-function is monotone and an overshoot would inject unphysical wiggles into the
temperature response. On a logarithmic time grid a few hundred nodes reproduce the full g-function to
well within other modelling errors, at a fraction of the evaluation cost.

## Node placement

`set_nodes` returns the integer indices of the evaluation nodes, spaced evenly on a
``\log_{10}`` scale from the first to the last time step. The early (short-time) behaviour, where the
g-function changes fastest, therefore receives proportionally more nodes than the slowly varying
long-time tail. Duplicate indices from rounding are removed, and the node count is nudged up until
the requested number of distinct nodes is reached.

## Custom interpolation

`pchip_interpolation` is exposed directly for reuse outside the wrapper — for example, to
compress any other slowly-varying signal sampled on a node subset:

```julia
id = set_nodes(length(t), 150)         # node indices
gᵢ = expensive_function(t[id])         # evaluate only at the nodes
g  = pchip_interpolation(t[id], gᵢ, t) # reconstruct the full vector
```


