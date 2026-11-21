# %% CONFIGURATION AND IMPORTS
import numpy as np
import matplotlib.pyplot as plt
from typing import Dict, Any

# Toggle language here ("EN" or "ES")
LANG: str = "EN"

plot_text: Dict[str, Dict[str, str]] = {
    "EN": {
        "title": "Thermal Damping: Ambient vs. Cave/Masonry Interior",
        "xlabel": "Time (Hours)",
        "ylabel": "Temperature (°C)",
        "legend_out": "Outdoor Ambient (High Fluctuation)",
        "legend_in": "Indoor Yposkafa / Thick Masonry (Stabilized)",
    },
    "ES": {
        "title": "Amortiguamiento Termico: Exterior vs. Cueva/Mamposteria",
        "xlabel": "Tiempo (Horas)",
        "ylabel": "Temperatura (°C)",
        "legend_out": "Exterior Ambiente (Alta Fluctuacion)",
        "legend_in": "Interior Yposkafa / Muro Grueso (Estabilizado)",
    },
}


# %% DATA GENERATION
def generate_thermal_data() -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Generates synthetic temperature data simulating a 48-hour cycle."""
    time: np.ndarray = np.linspace(0, 48, 200)

    # Outdoor temp fluctuates wildly between 20C (night) and 35C (day)
    temp_outdoor: np.ndarray = 27.5 + 7.5 * np.sin((time - 8) * (2 * np.pi / 24))

    # Indoor temp is dampened (lower amplitude) and phase-shifted (delayed peak)
    # representing a thick stone wall or yposkafa cave house
    temp_indoor: np.ndarray = 26.0 + 1.5 * np.sin((time - 14) * (2 * np.pi / 24))

    return time, temp_outdoor, temp_indoor


# %% PLOTTING
def plot_thermal_response(lang_code: str) -> None:
    """Plots the generated data using the selected language dictionary."""
    time, temp_out, temp_in = generate_thermal_data()
    texts: Dict[str, str] = plot_text[lang_code]

    plt.figure(figsize=(10, 6))
    plt.plot(time, temp_out, color="#ff7f0e", linestyle="--", label=texts["legend_out"])
    plt.plot(time, temp_in, color="#1f77b4", linewidth=2.5, label=texts["legend_in"])

    # Formatting
    plt.title(texts["title"], fontsize=14, fontweight="bold")
    plt.xlabel(texts["xlabel"], fontsize=12)
    plt.ylabel(texts["ylabel"], fontsize=12)

    # Day/Night shading for visual context
    for day in range(2):
        plt.axvspan(day * 24 + 18, day * 24 + 30, color="gray", alpha=0.1)

    plt.xlim(0, 48)
    plt.xticks(np.arange(0, 49, 6))
    plt.grid(True, alpha=0.3)
    plt.legend(loc="upper right")
    plt.tight_layout()
    plt.savefig(f"thermal_res_{lang_code}ponse.png", dpi=300, bbox_inches="tight")
    plt.show()


if __name__ == "__main__":
    plot_thermal_response(LANG)
