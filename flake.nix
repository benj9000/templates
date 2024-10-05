{
  description = "A collection of templates";

  outputs = { self }: {
    templates = {

      flake-for-all-default-systems = {
        path = ./flake-for-all-default-systems;
        description = "A flake skeleton with flake-utils for all default systems";
      };

    };
  };
}
