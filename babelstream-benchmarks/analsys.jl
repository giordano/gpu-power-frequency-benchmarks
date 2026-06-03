if length(ARGS) != 2
    error(
        """
        Usage:
            julia --project $(PROGRAM_FILE) /path/to/directory/with/json/files gpu_name
        """)
end

using JSON: JSON
using Plots: heatmap, savefig

data_dir = ARGS[1]
gpu_name = ARGS[2]

benchmarks = filter(d -> startswith(basename(d), r"energy-time-\d+-\d+"), readdir(data_dir; join=true))

frequencies = parse.(Float64, getindex.(split.(first.(splitext.(basename.(benchmarks))), '-'), 3))
frequencies_t = sort!(unique(frequencies))
powers = parse.(Float64, getindex.(split.(first.(splitext.(basename.(benchmarks))), '-'), 4))
powers_t = sort!(unique(powers))

times = [JSON.parsefile(ben)["time"] for ben in benchmarks]
bandwidths = [JSON.parsefile(ben)["bandwidth"] for ben in benchmarks]
energies = [JSON.parsefile(ben)["energy"] for ben in benchmarks]
energy_fractions = energies ./ (powers ./ (3600 ./ times)) .* 100

name = "BabelStream"
bandwidths_plot = heatmap(
    frequencies_t, powers_t, reshape(bandwidths, length(powers_t), length(frequencies_t));
    title="$(name) on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Bandwidth (GB/s)",
    size=(1000, 1000),
)

savefig(bandwidths_plot, joinpath(data_dir, "bandwidths.png"))

energies_plot = heatmap(
    frequencies_t, powers_t, reshape(energies, length(powers_t), length(frequencies_t));
    title="$(name) on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Energy usage (W⋅h)",
    size=(1000, 1000),
)

savefig(energies_plot, joinpath(data_dir, "energies.png"))

bandwidths_energies_plot = heatmap(
    frequencies_t, powers_t, reshape(bandwidths .* energies, length(powers_t), length(frequencies_t));
    title="$(name) on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Bandwidth * energy usage (GB⋅W⋅h/s)",
    size=(1000, 1000),
)

savefig(bandwidths_energies_plot, joinpath(data_dir, "bandwidths_energies.png"))

bandwidths_over_energies_plot = heatmap(
    frequencies_t, powers_t, reshape(bandwidths ./ energies, length(powers_t), length(frequencies_t));
    title="$(name) on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Bandwidth / energy usage ((GB/s)/(W⋅h))",
    size=(1000, 1000),
)

savefig(bandwidths_over_energies_plot, joinpath(data_dir, "bandwidths_over_energies.png"))

energy_fractions_plot = heatmap(
    frequencies_t, powers_t, reshape(energy_fractions, length(powers_t), length(frequencies_t));
    title="$(name) on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Fraction of max energy usage (%)",
    size=(1000, 1000),
)

savefig(energy_fractions_plot, joinpath(data_dir, "energy_fractions.png"))
