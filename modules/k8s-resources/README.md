# ArgoCD resources

## <a name='TableofContents'></a>Table of Contents
<!-- vscode-markdown-toc -->
* [1. Requirements](#Requirements)
* [2. Resources](#Resources)
	* [2.1 ArgoCD resources](#ArgoCDresources)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


## <a name='Requirements'></a>1. Requirements

- EKS cluster

## <a name='Resources'></a>2. Resources
### <a name='ArgoCDresources'></a>2.1 ArgoCD resources
- `ArgoCD`: using manifest to create ArgoCD core resources. The manifest is in template folder -> [argocd-setup.yaml](./templates/argocd/common/01-argocd-setup.yaml)
- `Ingress for ArgoCD`: using manifest to create ingress for ArgoCD. The manifest is in template folder -> [argocd-ingress-config.yaml](./templates/argocd/common/02-argocd-ingress-config.yaml)
- `ArgoCD image updater`: using manifest to create ArgoCD image updater resources. The manifest is in template folder -> [argocd-image-updater.yaml](./templates/argocd/common/03-argocd-image-updater.yaml)
- `Config for gitlab repository`: using manifest to create config for gitlab repository. The manifest is in template folder -> [argocd-repo-config.yaml](./templates/argocd/common/04-argocd-repo-secret.yaml)
- `Master applicationset`: using manifest to create master applicationset. The manifest is in template folder -> [argocd-master-applicationset.yaml](./templates/argocd/common/05-argocd-master-applicationset.yaml)
- `ArgoCD vault plugin`: using manifest to create ArgoCD vault plugin resources. The manifest is in template folder -> [argocd-vault-plugin.yaml](./templates/argocd/common/06-argocd-vault-plugin.yaml)

### 2.2 ArgoCD master applicationset

This applicationset control all resources in the cluster. It will create application for each folder manifest in the gitops repository folder `manifests`.

