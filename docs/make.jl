using Documenter

# This is a documentation hub: it has no Julia package of its own. Alongside its own overview pages
# it aggregates the narrative documentation (tutorials + modeling theory) copied in from each member
# package. The API/docstring reference for each package still lives in that package's own deployed
# site, so `makedocs` here runs without any `modules` and without docstring checks.
makedocs(;
    sitename = "GHE.jl",
    authors = "Gabriel-Dion <dion.gabriel100@gmail.com>",
    format = Documenter.HTML(;
        canonical = "https://GHE-jl.github.io/GHE.jl-docs",
        edit_link = "main",
        assets = String[],
        mathengine = Documenter.KaTeX(),
        sidebar_sitename = false,
        # No package Project.toml backs this hub, so give the search inventory an explicit version.
        inventory_version = "",
    ),
    # The aggregated pages carry prose that originally cross-referenced each package's own API pages
    # (not present here). Those links were neutralised on copy; `warnonly` keeps any residual
    # cross-reference or duplicate-anchor issue from failing the hub build.
    warnonly = true,
    pages = [
        "Home" => "index.md",
        "Ecosystem" => "ecosystem.md",
        "Comparison to other tools" => "comparison.md",
        "Getting started" => "getting_started.md",
        "BoreholeResistance.jl" => [
            "Overview" => "boreholeresistance/index.md",
            "Tutorial" => "boreholeresistance/tutorial.md",
            "Modeling theory" => [
                "Resistance network" => "boreholeresistance/theory/overview.md",
                "Fluid convective resistance" => "boreholeresistance/theory/fluid.md",
                "Pipe conductive resistance" => "boreholeresistance/theory/pipe.md",
                "Borehole (grout) resistance" => "boreholeresistance/theory/borehole.md",
                "Effective resistance" => "boreholeresistance/theory/effective.md",
            ],
            "Water properties" => "boreholeresistance/properties.md",
            "References" => "boreholeresistance/references.md",
        ],
        "GroundResponse.jl" => [
            "Overview" => "groundresponse/index.md",
            "Tutorial" => "groundresponse/tutorial.md",
            "Modeling theory" => [
                "Overview" => "groundresponse/theory/overview.md",
                "Line-source models" => "groundresponse/theory/line_source.md",
                "Moving-source models" => "groundresponse/theory/moving_source.md",
                "Spatial superposition" => "groundresponse/theory/superposition.md",
            ],
            "Borefields" => "groundresponse/borefield.md",
            "References" => "groundresponse/references.md",
        ],
        "GroundHeatExchanger.jl" => [
            "Overview" => "groundheatexchanger/index.md",
            "Tutorial" => "groundheatexchanger/tutorial.md",
            "Modeling theory" => [
                "Simulation pipeline" => "groundheatexchanger/theory/overview.md",
                "Temporal superposition" => "groundheatexchanger/theory/superposition.md",
                "Fluid temperature" => "groundheatexchanger/theory/temperature.md",
                "g-function compression" => "groundheatexchanger/theory/compression.md",
            ],
            "Utilities" => "groundheatexchanger/utilities.md",
            "References" => "groundheatexchanger/references.md",
        ],
        "GroundHeatExchangerSizing.jl" => [
            "Overview" => "groundheatexchangersizing/index.md",
            "Tutorial" => "groundheatexchangersizing/tutorial.md",
            "Sizing theory" => [
                "Overview" => "groundheatexchangersizing/theory/overview.md",
                "Alternative ASHRAE equation" => "groundheatexchangersizing/theory/alternative_equation.md",
                "Outlet transfer function" => "groundheatexchangersizing/theory/outlet_transfer_function.md",
                "Optimisation" => "groundheatexchangersizing/theory/optimization.md",
            ],
            "References" => "groundheatexchangersizing/references.md",
        ],
        "ThermalResponseTest.jl" => [
            "Overview" => "thermalresponsetest/index.md",
            "Tutorial" => "thermalresponsetest/tutorial.md",
            "Data & utilities" => "thermalresponsetest/data_utilities.md",
            "Interpretation theory" => [
                "Overview" => "thermalresponsetest/theory/overview.md",
                "First-order approximation" => "thermalresponsetest/theory/first_order_approximation.md",
                "Model inversion" => "thermalresponsetest/theory/model_inversion.md",
            ],
            "References" => "thermalresponsetest/references.md",
        ],
    ],
)

deploydocs(;
    repo = "github.com/GHE-jl/GHE.jl-docs",
    devbranch = "main",
)
