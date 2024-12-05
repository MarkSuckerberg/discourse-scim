{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    scim2-cli.url = "github:hrenard/scim2-cli";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      scim2-cli,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        plugin = pkgs.discourse.mkDiscoursePlugin {
          name = "discourse-scim";
          src = ./.;
          bundlerEnvArgs.gemdir = ./.;
        };

        compliance = pkgs.testers.runNixOSTest {
          name = "compliance";
          nodes.machine =
            { config, pkgs, ... }:
            {
              virtualisation.cores = 2;
              virtualisation.memorySize = 4096;
              environment.systemPackages = [
                scim2-cli.packages.${system}.default
                config.services.discourse.package.rake
              ];
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              services.discourse = {
                enable = true;
                plugins = [ plugin ];
                database.ignorePostgresqlVersion = true;
                hostname = "localhost";
                enableACME = false;
                admin = {
                  username = "admin";
                  fullName = "Admin";
                  email = "admin@local.host";
                  passwordFile = "${(pkgs.writeText "adminpass" ''Sdf3R*EzeYJzNDxgRbgs%zMgS#$#525a'')}";
                };
              };
              system.stateVersion = "24.11";
            };

          testScript = ''
            machine.wait_for_unit("discourse.service")
            machine.wait_for_file("/run/discourse/sockets/unicorn.sock")
            machine.wait_until_succeeds("curl -sS -f http://localhost")
            machine.succeed("sudo -u discourse discourse-rake api_key:create_master[master] >api_key")
            result = machine.execute('scim2 --url http://localhost/scim_v2 --header "Authorization: Bearer $(<api_key)" test -v')
            if result[0] != 0 or "ERROR" in result[1]:
              raise Exception(result[1])
          '';
        };
      in
      {
        packages.default = plugin;
        checks.compliance = compliance;
        devShells.default = pkgs.mkShell {
          buildInputs =
            [
            ];
        };
      }
    );
}
