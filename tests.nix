#! echo :p | cat - tests.nix | nix repl
# TODO: refactor as flake then try `nix eval path:./tests.nix`
with builtins; let
  lib = import <nixpkgs/lib>;

  flakeURIs = with lib.lists; rec {
    of.non.overlay.templates = [
      "path:./simple"
    ];
    of.non.overlays.templates = [
      "path:./simple"
    ];

    # flake that doesn't contain
    # both `overlay` function and `overlays` attributes
    # in it's outputs
    of.non.anykind-overlays.templates = [
        "path:./simple"
    ];
  };
  flake = with lib.attrsets; let
    getFlake' = uri:
      if isString uri then getFlake uri
      else if isList uri then map getFlake' uri
      else uri;
  in
    mapAttrsRecursive (_: getFlake') flakeURIs;

  flakeAttr = with lib; let
    mergeBy' = attr: flakes: let
      merge' = next: prev:
        if attr == "outputs" then rec {
          inputs = next.inputs // prev.inputs;
          outputs = next.outputs // prev.outputs // {
            args = inputs // {
              self = removeAttrs outputs [ "args" ];
            };
          };
        }
        else { ${attr} = next.${attr} // prev.${attr}; };
    in
      fold merge' (head flakes) flakes;

    into' = attr: path: val: let
      flake' = getAttrFromPath path flake;
    in
      if isList val then (mergeBy' attr flake').${attr}
      else if isString val then flake'.${attr}
      else val;
  in
    attr: mapAttrsRecursive (into' attr) flakeURIs;

  inputs = flakeAttr "inputs";
  outputs = flakeAttr "outputs";

  on = with (getFlake "path:./."); {

    "overlay vs overlayAll" = let
      tests = prefix: inputs: {
        "test ${prefix} overlayFrom/overlayAllFrom inputs" = {
          expr = overlayFrom inputs;
          expected = overlayAllFrom inputs;
        };
        "test ${prefix} overlayAttrFrom/overlayAttrAllFrom inputs" = {
          expr = overlayAttrFrom inputs;
          expected = overlayAttrAllFrom inputs;
        };
      };

      no-self.inputs = inputs.of.non.overlays.templates;
      inputs' = outputs.of.non.overlays.templates.args;
    in
      {}
      // (tests "" inputs')
      // (tests "(no-self)" no-self.inputs)
    ;

    "another test suite" = {};

  };
  inherit (lib.debug) runTests;
in
runTests (
  on."overlay vs overlayAll"
)
