# trabalho-uece-terraform-k8s
## Requisitos
Deve ser configurado na máquina as seguites ferramentas 
- azure cli
- kubectl
- terraform

Após clonar esse repositório, primeiramente deve ser realizado o provisionamento do cluster AKS.
Para isso, na pasta do do repositório, entre na pasta terraform-aks-cluster e proviosione com o terraform.
```
cd terraform-aks-cluster
terraform init
terraform plan
terraform apply
```
