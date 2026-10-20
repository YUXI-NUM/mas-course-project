# Multi-Agent Systems Course Project

Coursework for a Multi-Agent Systems class: second-order consensus among 5 agents
in 3D (position + velocity), simulated in Simulink, studying how damping and
communication delays affect convergence. Full writeup in [`MAS_YUXI.pdf`](MAS_YUXI.pdf).

## Setup

- 5 agents, state `(x_i, v_i) ∈ R^3 x R^3`, coupled through a fixed communication
  graph (Laplacian `L` built in [`init.m`](init.m)).
- Control law drives the agents to a common consensus trajectory under
  second-order dynamics with a damping term.
- Run [`init.m`](init.m) first to set constants, initial conditions, and the
  graph Laplacian, then open and run one of the `.slx` models below, then run
  [`visu_m.m`](visu_m.m) to plot the logged trajectories.

## Models

| File | Studies |
| --- | --- |
| `first_order.slx` | First-order consensus baseline |
| `Complete_dynamics.slx` | Full second-order consensus dynamics |
| `Absolute_or_Relative_damping.slx`, `absolute_relative_damping.slx` | Damping on absolute vs. relative velocity (`dampCase` in `init.m`) |
| `Input_delays.slx` | Consensus under delayed control input |
| `Measurement_delays.slx` | Consensus under delayed state measurements |
| `Measurement_and_input_delay.slx` | Combined measurement + input delay |
| `Diffusive_law.slx` | Diffusive (PDE-based) representation of delay |

## Requirements

MATLAB/Simulink (built with R2024b; `simu.slx.r2024b` is a version-converted
backup kept alongside the main files).
