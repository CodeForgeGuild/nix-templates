{
  description = "Nix flake templates for bootstrapping new repos";

  outputs =
    { self }:
    {
      templates = {
        basic = {
          path = ./basic;
          description = "Minimal dev shell with git and direnv";
        };
        go = {
          path = ./go;
          description = "Go development environment";
        };
        python = {
          path = ./python;
          description = "Python 3 environment with uv";
        };
        tofu-terragrunt = {
          path = ./tofu-terragrunt;
          description = "IaC environment with OpenTofu and Terragrunt";
        };
        github-actions = {
          path = ./github-actions;
          description = "Bootstrap shared GitHub Actions workflows from CodeForgeGuild/ci-actions";
        };
        infra = {
          path = ./infra;
          description = "Terraform/OpenTofu module skeleton (GCP + GCS backend)";
        };
        sonar = {
          path = ./sonar;
          description = "SonarQube project config and CI workflows";
        };
      };
      templates.default = self.templates.basic;
    };
}
