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

directories = filter(d -> startswith(basename(d), r"data-\d+-\d+"), readdir(data_dir; join=true))

frequencies = parse.(Float64, getindex.(split.(basename.(directories), '-'), 2))
frequencies_t = sort!(unique(frequencies))
powers = parse.(Float64, getindex.(split.(basename.(directories), '-'), 3))
powers_t = sort!(unique(powers))

bench_dir(dir) = only(readdir(joinpath(dir, "benchmarks"); join=true))
sphere_file(dir) = only(filter!(contains("sphere_6_50_Float32_"), readdir(bench_dir(dir); join=true)))

times = [JSON.parsefile(sphere_file(dir))[2][1][2]["data"]["GPU-NVIDIA"][2]["data"]["6"][2]["data"]["sim_step!"][2]["times"][1] for dir in directories] ./ 1e9

total_times = [JSON.parsefile("$(bench_dir(dir))/energy-time.json")["total_time"] for dir in directories]
energies = [JSON.parsefile("$(bench_dir(dir))/energy-time.json")["energy"] for dir in directories]
energy_fractions = energies ./ (powers ./ (3600 ./ total_times)) .* 100

times_plot = heatmap(
    frequencies_t, powers_t, reshape(times, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Time (s)",
    size=(1000, 1000),
)

savefig(times_plot, joinpath(data_dir, "times.png"))

energies_plot = heatmap(
    frequencies_t, powers_t, reshape(energies, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Energy usage (W⋅h)",
    size=(1000, 1000),
)

savefig(energies_plot, joinpath(data_dir, "energies.png"))

times_energies_plot = heatmap(
    frequencies_t, powers_t, reshape(times .* energies, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Time * energy usage (s⋅W⋅h)",
    size=(1000, 1000),
)

savefig(times_energies_plot, joinpath(data_dir, "times_energies.png"))

times_over_energies_plot = heatmap(
    frequencies_t, powers_t, reshape(times ./ energies, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Time / energy usage (s/(W⋅h))",
    size=(1000, 1000),
)

savefig(times_over_energies_plot, joinpath(data_dir, "times_over_energies.png"))

energy_fractions_plot = heatmap(
    frequencies_t, powers_t, reshape(energy_fractions, length(powers_t), length(frequencies_t));
    title="WaterLily.jl on $(gpu_name)",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Fraction of max energy usage (%)",
    size=(1000, 1000),
)

savefig(energy_fractions_plot, joinpath(data_dir, "energy_fractions.png"))
