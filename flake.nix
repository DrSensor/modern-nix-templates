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

      lib.no-self.overlays = with builtins; mapAttrs (_: fn: inputs: fn (removeAttrs inputs [ "self" ])) lib.overlays;
      lib.overlays = with nixpkgs.lib; rec {
        # Get `overlays` List from all inputs.overlay.
        # overlayFrom :: AttrSet -> [Any]
        overlayFrom = inputs: attrValues (overlayAttrFrom inputs);

        # Get `overlays` Attribute Set from all inputs.overlay.
        # overlayAttrFrom :: AttrSet -> AttrSet
        overlayAttrFrom = let
          condition = _: a: a ? overlay;
          getOverlay = _: a: a.overlay;
        in
          inputs: mapAttrs getOverlay (filterAttrs condition inputs);


        # Get `overlays` List from both all inputs.overlay and inputs.overlays.
        # overlayAllFrom :: AttrSet -> [Any]
        overlayAllFrom = inputs: flatten (attrValues (overlayAttrAllFrom inputs));

        # Get `overlays` Attribute Set from both all inputs.overlay and inputs.overlays.
        # overlayAttrAllFrom :: AttrSet -> AttrSet
        overlayAttrAllFrom = let
          condition = _: a: (a ? overlay) || (a ? overlays);
          getOverlay = _: { overlay ? final: prev: {}, overlays ? {}, ... }: (
            if isList overlays
            then overlays
            else attrValues overlays
          ) ++ [ overlay ];
        in
          inputs: mapAttrs getOverlay (filterAttrs condition inputs);
      };

      flattenAttrs = with nixpkgs.lib; attrs: fold (l: r: l // r) {} (mapAttrsToList (_: a: a) attrs);
    in
      templates
      // flattenAttrs (removeAttrs lib [ "no-self" ])
      // { no-self = flattenAttrs lib.no-self; }
  ;
}
