{
  description = "A collection of templates";

  outputs = { self }: {
    templates = {

      envrc = {
        path = ./envrc;
        description = "A .envrc file for Nix flake-based projects.";
      };

      flake-for-all-default-systems = {
        path = ./flake-for-all-default-systems;
        description = "A flake skeleton with flake-utils for all default systems";
      };

      python-poetry = {
        path = ./python-poetry;
        description = "A Python project with Poetry";
        welcomeText = ''
          # Initialized a Python project with Poetry.

          Poetry: <https://python-poetry.org/>
        '';
      };

      python-uv = {
        path = ./python-uv;
        description = "A Python project with uv";
        welcomeText = ''
          # Initialized a Python project with uv.

          uv: <https://docs.astral.sh/uv/>
        '';
      };

      python-uv2nix = {
        path = ./python-uv2nix;
        description = "A Python project with uv2nix";
        welcomeText = ''
          # Initialized a Python project with uv2nix.

          Resolve the `TODO`s in the flake to finish initialization.

          - uv: <https://docs.astral.sh/uv/>
          - uv2nix: <https://github.com/pyproject-nix/uv2nix>
        '';
      };

      readme-and-licence = {
        path = ./readme-and-licence;
        description = "Basic README and LICENSE skeletons";
        welcomeText = ''
          # Initialized basic README.md and LICENSE.md skeletons.

          - Choose a license (compare <https://choosealicense.com/>),
          - update the `Licence` section in `README.md`, and
          - add the licence text to `LICENSE.md`.
        '';
      };

      revealjs = {
        path = ./revealjs;
        description = "A reveal.js presentation";
        welcomeText = ''
          # Initialized a reveal.js presentation.

          reveal.js: <https://revealjs.com/>.
        '';
      };
    };
  };
}
