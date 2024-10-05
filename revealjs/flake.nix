{
  description = "My reveal.js presentation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    reveal-js = {
      type = "github";
      owner = "hakimel";
      repo = "reveal.js";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, reveal-js }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        revealJsDirectory = "reveal.js";
        initRevealJs = pkgs.writeShellScript "init-reveal-js" ''
          if [ ! -d "${revealJsDirectory}" ]; then
            echo "Initializing reveal.js presentation…"
            cp -r ${reveal-js} ${revealJsDirectory}
            chmod -R u+w ${revealJsDirectory}
            ${pkgs.nodejs}/bin/npm install --prefix ${revealJsDirectory}
          fi
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          name = "reveal-js-development-environment";
          nativeBuildInputs = [ pkgs.nodejs ];
          shellHook = ''
            ${initRevealJs}
            echo
            echo "reveal.js development environment"
            echo "The presentation server can be started with"
            echo " - \`nix run\`, or"
            echo " - \`npm start --prefix ${revealJsDirectory}\`."
            [ -n "$SHELL" ] && exec "$SHELL"
          '';
        };

        packages.default = pkgs.writeShellApplication {
          name = "serve-reveal-js";
          runtimeInputs = [ pkgs.nodejs ];
          text = let presentationUrl = "http://localhost:8000"; in ''
            ${initRevealJs}
            echo "Starting reveal.js server…"
            if [ -n "$BROWSER" ]; then
                "$BROWSER" "${presentationUrl}"
            elif which xdg-open > /dev/null; then
                xdg-open "${presentationUrl}"
            else
                echo "Open ${presentationUrl} in your web browser."
            fi
            npm start --prefix ${revealJsDirectory}
          '';
        };
      }
    );
}
