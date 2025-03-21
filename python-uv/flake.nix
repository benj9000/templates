{
  description = "My Python project with uv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonVersions = {
          default = pkgs.python3;
          python3 = pkgs.python3;
          python310 = pkgs.python310;
          python311 = pkgs.python311;
          python312 = pkgs.python312;
          python313 = pkgs.python313;
          python314 = pkgs.python314;
        };
        mkPythonShell = devShellName: pythonPackage:
          let
            venvDirectory = "./venv";
          in
          pkgs.mkShell {
            name = "python-uv-development-environment";

            nativeBuildInputs = [
              pythonPackage
              pkgs.uv
              pkgs.basedpyright
              pkgs.ruff
            ];

            env = {
              UV_PROJECT_ENVIRONMENT = venvDirectory;
              UV_PYTHON = pythonPackage.interpreter;
              UV_PYTHON_DOWNLOADS = "never";
            };

            shellHook = ''
              unset PYTHONPATH
              uv sync
              [ -d ${venvDirectory} ] && source ${venvDirectory}/bin/activate
            '';
          };
      in
      {
        devShells = builtins.mapAttrs mkPythonShell pythonVersions;
      }
    );
}
