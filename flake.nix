{
  description = "Modern nix flake templates that only use both fastest and leanest toolchains";

  outputs = { self, nixpkgs }:
    let
      templates = let
        at = path: description: { inherit path description; };
      in
        rec {
          templates.simple = at ./simple ''
            A simple template just to streamline the developer toolchains.
            Both `nix build` and `nix run` command are not applicable.
            Only `nix develop` command is available.
            Another use case is to either try compile or run test an existing package.
          '';
        };
    in
      templates;
}
