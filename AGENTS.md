# Antigravity Workspace Guidelines

This repository serves as a workspace template for Python projects developed with **Google Antigravity** and **Marimo**.

---

## 1. Project Architecture & Directory Layout

```
.
├── .agents/                 # Workspace-scoped Antigravity rules and skills
│   ├── rules/               # Coding style and framework rules
│   └── skills/              # Workspace runbooks and custom workflows
├── .vscode/                 # IDE configurations (ported & optimized)
│   ├── settings.json        # Python interpreter, analysis extraPaths, autocomplete
│   ├── launch.json          # Debuggers for Python scripts and Marimo apps
│   ├── tasks.json           # Tasks for Marimo edit/run and pytest
│   └── extensions.json      # Recommended extensions (Marimo, Python, Ruff)
├── data/                    # Project datasets and inputs
├── docs/                    # Project documentation
├── examples/                # Example scripts and usage demonstrations
├── img/                     # Graphics and diagrams
├── md/                      # Markdown notes and reports
├── nb/                      # Marimo interactive notebooks (.py) and Jupyter (.ipynb)
├── output/                  # Generated figures, exports, and outputs
├── priv/                    # Private configuration or credentials (gitignored)
├── queries/                 # SQL / data queries
├── src/                     # All custom Python packages and domain modules
│   ├── core/                # Core domain abstractions, units, and models
│   └── utils/               # General-purpose helper utilities
├── tests/                   # Pytest test suites
├── tex/                     # LaTeX documents, reports, and templates
├── .env                     # PYTHONPATH=src for terminal and test runs
├── pyrightconfig.json       # Type checker extraPaths ("src")
├── jupytext.toml            # Jupytext notebook pairing configuration
├── requirements.txt         # Package dependencies
└── setup.py                 # Setuptools config with dynamic src/ package discovery
```

---

## 2. Source Packages & Imports

- **Location:** All custom-made packages must reside in `src/` (e.g., `src/core`, `src/<project_module>`).
- **Import Style:** Import top-level packages directly (e.g., `import core`, `from core import ureg`).
- **Path Resolution:** The workspace is pre-configured with:
  - `.env`: `PYTHONPATH=src`
  - `.vscode/settings.json`: `"python.analysis.extraPaths": ["${workspaceFolder}/src"]`
  - `pyrightconfig.json`: `"extraPaths": ["src"]`
  - `pyTemplate-master.code-workspace`: `"terminal.integrated.env.windows": {"PYTHONPATH": "${workspaceFolder}/src"}`
- **Editable Install:** Run `pip install -e .` to link all packages in `src/` into the environment.

---

## 3. Working with Marimo

- Marimo files are pure Python files stored in `nb/` (e.g. `nb/template_marimo.py`).
- **Edit Mode:** Run `marimo edit nb/<notebook>.py` or use the Antigravity task/debugger `Marimo: Edit Current File`.
- **Run Mode:** Run `marimo run nb/<notebook>.py` to serve as a reactive web application.
- **Rules for Reactive Cells:**
  - Keep cell functions focused and pure where possible.
  - Avoid mutating shared global state inside cells; return values and pass them as cell arguments.
  - Use `mo.ui` for interactive inputs (`mo.ui.slider`, `mo.ui.dropdown`, etc.).
  - Lay out UI components using `mo.vstack`, `mo.hstack`, `mo.accordion`, and `mo.tabs`.

---

## 4. Testing & Verification

- Tests are in `tests/` and run with `pytest`.
- Run tests via terminal:
  ```powershell
  pytest
  ```
- Or run the setup check:
  ```powershell
  python tests/test_setup.py
  ```

---

## 5. Agent Instructions & Code Integrity

- **Preserve Comments:** Never delete or overwrite comments unless explicitly instructed.
- **Preserve Formatting:** Do not reformat unchanged code or alter author indentation conventions.
- **Type Annotations:** Use Python standard typing annotations (`Optional`, `Union`, `List`, `Dict`, `Tuple` or Python 3.10+ union `|`).
- **Clickable Links:** When referencing project files in chat, always provide clickable Markdown links (e.g., `[settings.json](file:///c:/dev/pyTemplate-master/.vscode/settings.json)`).
