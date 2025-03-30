{
  description = "My Python project with uv2nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pyproject-nix, uv2nix, pyproject-build-systems }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;

        src = ./.;
        pyproject = pyproject-nix.lib.project.loadUVPyproject { projectRoot = src; };
        projectName = pyproject.pyproject.project.name;

        pkgs = nixpkgs.legacyPackages.${system};
        defaultPythonPackage = pkgs.python3; # TODO Set the default Python version.
        pythonPackages = {
          default = defaultPythonPackage;
          "${projectName}" = defaultPythonPackage;
          "${projectName}-py3" = pkgs.python3;
          "${projectName}-py313" = pkgs.python313;
          "${projectName}-py314" = pkgs.python314;
          # TODO Add Python versions as you like but compatible to with your `pyproject.toml`.
        };

        workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = src; };
        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };
        pyprojectOverrides = final: prev: {
          # Add build fixups, if needed, see
          # https://pyproject-nix.github.io/pyproject.nix/builders/overriding.html#wheels.
        };
        mkPythonSet = pythonPackage:
          let
            baseSet = pkgs.callPackage pyproject-nix.build.packages { python = pythonPackage; };
          in
          baseSet.overrideScope (lib.composeManyExtensions [
            pyproject-build-systems.overlays.default
            overlay
            pyprojectOverrides
          ]);

        mkPythonPackage = packageName: pythonPackage:
          let
            inherit (pkgs.callPackages pyproject-nix.build.util { }) mkApplication;
            pythonSet = mkPythonSet pythonPackage;
          in
          mkApplication {
            venv = pythonSet.mkVirtualEnv projectName workspace.deps.default;
            package = pythonSet."${projectName}";
          };

        mkApp = packageName: package:
          lib.nameValuePair
            (if packageName == "default" then packageName else "${packageName}-${package.meta.mainProgram}")
            { type = "app"; program = lib.getExe package; };

        mkPythonShell = devShellName: pythonPackage:
          let
            pyprojectToml = "./pyproject.toml";
            venvDirectory = "./venv";
          in
          pkgs.mkShell {
            name = "${projectName}-development-environment";

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
              [ -f "${pyprojectToml}" ] && uv sync
              [ -d "${venvDirectory}" ] && source "${venvDirectory}/bin/activate"
            '';
          };
      in
      {
        # packages = lib.mapAttrs mkPythonPackage pythonPackages;
        # apps = lib.mapAttrs' mkApp self.packages.${system};
        # devShells = lib.mapAttrs mkPythonShell pythonPackages;

        # TODO If this flake is for a new project, run `nix run .#init` to initialize a Python
        #   project with uv. Afterwards, or if this flake is for an exisiting project, remove the
        #   init app below and comment the packages, apps, and devShells above back in.

        apps.init =
          let
            initScript = pkgs.writeShellApplication {
              name = "init";
              runtimeInputs = [ defaultPythonPackage pkgs.uv pkgs.git ];
              runtimeEnv = {
                UV_PYTHON = defaultPythonPackage.interpreter;
                UV_PYTHON_DOWNLOADS = "never";
              };
              text = ''
                # Initialize Python project.
                uv init --package
                uv lock
                # We define the default Python version with `defaultPythonVersion` in this flake,
                # and do not want to maintain `.python-version`.
                rm .python-version
                # Add everything to the index, such that the flake has access right away.
                git add .

                echo "Initialized Python project. Adjust \`pyproject.toml\` to your needs."
              '';
            };
          in
          { type = "app"; program = lib.getExe initScript; };
      }
    );
}
