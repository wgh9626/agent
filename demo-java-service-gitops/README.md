# demo-java-service-gitops

This repository stores deployment state for `demo-java-service`.
It is intended to be watched by Argo CD.

## Layout

- `apps/test/deployment.yaml`: target deployment manifest updated by CI
- `apps/test/service.yaml`: service definition
- `apps/test/namespace.yaml`: namespace declaration
- `apps/test/kustomization.yaml`: Kustomize entry
- `apps/test/application.yaml`: Argo CD Application example

## Update Rule

CI should update only the image reference in `apps/test/deployment.yaml`.
Do not mix application source code into this repository.

## Typical Flow

1. Jenkins builds the JAR.
2. Kaniko pushes the image to Harbor.
3. Jenkins updates `apps/test/deployment.yaml`.
4. Jenkins pushes the GitOps commit.
5. Argo CD reconciles the new desired state.
