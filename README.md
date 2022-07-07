# CoraAgent

## Setup 

1.
```shell
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools
pip install -r requirements.txt
```

2. In the Julia REPL package manager run `activate .` and then `instantiate`.

3. Run:
```shell
PYTHON=$(which python) PYCALL_JL_RUNTIME_PYTHON=$(which python) julia --project -e 'import Pkg; Pkg.build("Conda"); Pkg.build("PyCall")'
```

4. Demo:
```julia
julia> include("src/IntPhys.jl")
```