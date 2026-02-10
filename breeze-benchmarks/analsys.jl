using JSON: JSON
using Plots: heatmap, savefig

benchmarks = filter(d -> startswith(basename(d), r"benchmark_results-\d+-\d+"), readdir(@__DIR__; join=true))

frequencies = parse.(Float64, getindex.(split.(first.(splitext.(basename.(benchmarks))), '-'), 2))
frequencies_t = sort!(unique(frequencies))
powers = parse.(Float64, getindex.(split.(first.(splitext.(basename.(benchmarks))), '-'), 3))
powers_t = sort!(unique(powers))

times = [JSON.parsefile(ben)[1]["total_time_seconds"] for ben in benchmarks]
energies = [JSON.parsefile("energy-$(Int(freq))-$(Int(pow)).json")["energy"] for (freq, pow) in zip(frequencies, powers)]
energy_fractions = energies ./ (powers ./ (3600 ./ times)) .* 100

times_plot = heatmap(
    frequencies_t, powers_t, reshape(times, length(powers_t), length(frequencies_t));
    title="Breeze.jl on Nvidia A100",
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
    title="Breeze.jl on Nvidia A100",
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
    title="Breeze.jl on Nvidia A100",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Time * energy usage (s⋅W⋅h)",
    size=(1000, 1000),
)

savefig(times_energies_plot, "times_energies.png")

times_over_energies_plot = heatmap(
    frequencies_t, powers_t, reshape(times ./ energies, length(powers_t), length(frequencies_t));
    title="Breeze.jl on Nvidia A100",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Time / energy usage (s/(W⋅h))",
    size=(1000, 1000),
)

savefig(times_over_energies_plot, "times_over_energies.png")

energy_fractions_plot = heatmap(
    frequencies_t, powers_t, reshape(energy_fractions, length(powers_t), length(frequencies_t));
    title="Breeze.jl on Nvidia A100",
    xlabel="GPU frequency (MHz)",
    xticks=frequencies_t,
    ylabel="Power cap (W)",
    yticks=powers_t,
    colorbar_title="Fraction of max energy usage (%)",
    size=(1000, 1000),
)

savefig(energy_fractions_plot, "energy_fractions.png")
