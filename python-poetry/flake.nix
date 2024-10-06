{
  description = "My Python project with Poetry";

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
          python310 = pkgs.python310;
          python311 = pkgs.python311;
          python312 = pkgs.python312;
          python313 = pkgs.python313;
        };
        mkPythonShell = devShellName: pythonPackage: pkgs.mkShell {
          name = "python-poetry-development-environment";
          nativeBuildInputs = [ pythonPackage pkgs.poetry ];
          shellHook = ''
            if [ ! -f "pyproject.toml" ]; then
              echo "pyproject.toml not found. Initialize project."
              poetry init
            fi
            poetry install
            poetry env use ${pythonPackage}/bin/python
            source $(poetry env info --path)/bin/activate

            echo "Python development environment with Poetry"
            [ -n "$SHELL" ] && exec "$SHELL"
          '';
        };
      in
      {
        devShells = builtins.mapAttrs mkPythonShell pythonVersions;
      }
    );
}
