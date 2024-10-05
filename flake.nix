{
  description = "A collection of templates";

  outputs = { self }: {
    templates = {

      flake-for-all-default-systems = {
        path = ./flake-for-all-default-systems;
        description = "A flake skeleton with flake-utils for all default systems";
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

    };
  };
}
