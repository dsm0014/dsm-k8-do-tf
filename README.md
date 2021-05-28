# dsm-k8-do-tf
Terrform for provisioning a Digital Ocean kubernetes cluster for personal projects.

# Setup
Initialize using the following command:
```
terraform init -backend-config="access_key=$DO_SPACES_ACCESS_KEY" -backend-config="secret_key=$DO_SPACES_SECRET_KEY"
```