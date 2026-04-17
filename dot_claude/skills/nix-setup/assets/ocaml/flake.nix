{
  description = "OCaml development environment (OCaml 5 + dune + LSP)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        apm = import ./apm.nix { inherit pkgs; };

        # Pick an OCaml version. `pkgs.ocamlPackages` tracks the nixpkgs
        # default (today OCaml 5.x). For a specific version:
        #   ocamlPackages = pkgs.ocaml-ng.ocamlPackages_5_2;
        ocamlPackages = pkgs.ocamlPackages;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with ocamlPackages; [
            ocaml
            dune_3
            findlib             # ocamlfind
            merlin              # editor support (used by ocaml-lsp)
            ocaml-lsp           # language server
            ocamlformat         # formatter
            utop                # REPL
          ] ++ [
            # Package manager — keep it if you mix opam and nix, drop if you
            # want pure-Nix project management.
            pkgs.opam

            # Common tooling (included in every template)
            pkgs.just
            pkgs.ast-grep
            apm
          ];

          shellHook = ''
            # dune discovers ocamlc via PATH; nothing to configure.
            # If mixing with opam, `opam init --bare -n` once per machine
            # (outside the shell).
          '';
        };
      });
}
