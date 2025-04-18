# GitOps with ArgoCD

This repository implements a GitOps workflow using ArgoCD and Kustomize for managing Kubernetes applications across different environments.

## Repository Structure

- **`argocd/`**: Contains ArgoCD configuration files for different environments.
  - `base/`: Base configurations for applications.
  - `production/`: Production environment configurations, including `app-of-apps.yaml`.
  - `staging/`: Staging environment configurations, including `app-of-apps.yaml`.
- **`build/`**: Holds the generated Kubernetes manifests for each environment.
  - `production/`: Manifests for production apps.
  - `staging/`: Manifests for staging apps.
- **`scripts/`**: Contains automation scripts.
  - `build.sh`: Script to generate manifests using Kustomize with Helm support.
- **`src/`**: Source directory for Kubernetes configurations using Kustomize.
  - `base/`: Base configurations for apps.
  - `production/`: Production overlays with environment-specific customizations.
  - `staging/`: Staging overlays with environment-specific customizations.

## Branches

- **`main` (trunk)**: Contains the full repository structure with source and configuration files.
- **`deploy/staging`**: Contains rendered manifests for the staging environment.
- **`deploy/production`**: Contains rendered manifests for the production environment.

## Workflow

1. **Define Applications**: Apps are defined using `kustomization.yaml` files in `src/<env>/<appName>` directories. `staging` and `production` act as overlays to the `base` configurations.
2. **Generate Manifests**: Use the `build.sh` script to generate Kubernetes manifests for a specific environment.
   ```bash
   ./scripts/build.sh <BUILD_ENV> <KUBE_VERSION>
   # Example: ./scripts/build.sh staging 1.32.1
   ```
   This script cleans the build directory for the specified environment and generates manifests using `kustomize build --enable-helm`.
3. **Deployment**: ArgoCD uses the manifests in the `deploy/staging` and `deploy/production` branches to deploy to the respective environments.

## Customizations

- **Port Changes**: For example, in `production`, `app-one` has been patched to use port `8080` instead of the default `80`.

## Notes

- The `build/` directory is ignored in Git via `.gitignore` to prevent tracking generated files.
- Kustomize supports Helm charts with the `--enable-helm` flag in the build process.

For further assistance or modifications, refer to the repository maintainers.
