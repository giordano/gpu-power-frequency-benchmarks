using JSON: JSON
using Plots: heatmap, savefig

directories = filter(d -> startswith(basename(d), r"data-\d+-\d+"), readdir(@__DIR__; join=true))

frequencies = parse.(Float64, getindex.(split.(basename.(directories), '-'), 2))
frequencies_t = sort!(unique(frequencies))
powers = parse.(Float64, getindex.(split.(basename.(directories), '-'), 3))
powers_t = sort!(unique(powers))

times = [JSON.parsefile("$(dir)/benchmarks/cricket.rc.ucl.ac.uk_2d41ba1/sphere_6_50_Float32_GPU-NVIDIA_2d41ba1_1.12.4.json")[2][1][2]["data"]["GPU-NVIDIA"][2]["data"]["6"][2]["data"]["sim_step!"][2]["times"][1] for dir in directories] ./ 1e9

total_times = [JSON.parsefile("$(dir)/benchmarks/cricket.rc.ucl.ac.uk_2d41ba1/energy-time.json")["total_time"] for dir in directories]
energies = [JSON.parsefile("$(dir)/benchmarks/cricket.rc.ucl.ac.uk_2d41ba1/energy-time.json")["energy"] for dir in directories]

times_plot = heatmap(
    frequencies_t, powers_t, reshape(times, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on Nvidia A100",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Time (s)",
    size=(1000, 1000),
)

savefig(times_plot, "times.png")

energies_plot = heatmap(
    frequencies_t, powers_t, reshape(energies, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on Nvidia A100",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Energy usage (W⋅h)",
    size=(1000, 1000),
)

savefig(energies_plot, "energies.png")

times_energies_plot = heatmap(
    frequencies_t, powers_t, reshape(times .* energies, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on Nvidia A100",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Time * energy usage (s⋅W⋅h)",
    size=(1000, 1000),
)

savefig(times_energies_plot, "times_energies.png")

energy_fractions_plot = heatmap(
    frequencies_t, powers_t, reshape(energies ./ (powers ./ (3600 ./ total_times)) .* 100, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on Nvidia A100",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Fraction of max energy usage (%)",
    size=(1000, 1000),
)

savefig(energy_fractions_plot, "energy_fractions.png")
