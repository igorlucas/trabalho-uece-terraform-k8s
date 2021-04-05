# trabalho-uece-terraform-k8s
## Requisitos
Deve ser configurado na máquina as seguites ferramentas 
- azure cli
- kubectl
- terraform

### 1 Etapa (Provisionar um cluster kubernetes):
Após clonar esse repositório, primeiramente deve ser realizado o provisionamento do cluster AKS.
Para isso, na pasta do do repositório, entre na pasta terraform-aks-cluster.
```
cd terraform-aks-cluster
```

Crie uma conta principal do serviço Active Directory para se autenticar.
```
az ad sp create-for-rbac --skip-assignment
{
  "appId": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "displayName": "azure-cli-2019-04-11-00-46-05",
  "name": "http://azure-cli-2019-04-11-00-46-05",
  "password": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "tenant": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
}
```

Na raiz da pasta crie o arquivo terraform.tfvars e insira o appId e password
```
# terraform.tfvars
appId    = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
password = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
```

Proviosione com o terraform.
```
terraform init
terraform plan
terraform apply
```
Configure o kubectl remoto.
Execute o seguinte comando para recuperar as credenciais de acesso para o seu cluster e configure automaticamente .kubectl
```
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
Merged "light-eagle-aks" as current context in /Users/dos/.kube/config
```

Acesse o Painel Kubernetes.
Para verificar se seu cluster está configurado corretamente e em execução, você navegará até ele no seu navegador local.
```
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard --user=clusterUser
```

Finalmente, para acessar o painel Kubernetes, execute o seguinte comando, personalizado com seu nome de cluster em vez de ".". 
Isso continuará funcionando até que você pare o processo pressionando "light-eagle-CTRL + C".
```
az aks browse --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)
```
Será logado o endereço do painel do kubernetes que você poderá acessar.
Ex:
```
Proxy running on http://127.0.0.1:8001/
Press CTRL+C to close the tunnel...
```
Abra uma nova aba de terminal para autenticar no painel gerando o token de autorização (não feche o processo anterior).
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')
```
Feito isso, você receberá um token dentro do terminal. Selecione "Token" na interface do painel UI e copie e cole todo o token que você recebe no tela de autenticação do painel para entrar. 
Se nada der errado você estará conectado ao painel para o seu cluster Kubernetes.

### 2 Etapa (Publicando uma aplicação no cluster kubernetes):
Agora entre na pasta terraform-app. 
Nessa parte será provisionado o "deployment" e o "service" do wordpress, juntamente com seus outros recursos necessários.

Configurando as variáveis do banco de dados.
Na raiz da pasta crie o arquivo terraform.tfvars e as seguintes variáveis, preenchendo com os valores que você desejar:
```
# terraform.tfvars
MYSQL_ROOT_PASSWORD = ""
MYSQL_DATABASE = ""
MYSQL_USER = ""
MYSQL_PASSWORD=""
```

Inicie o terraform:
```
terraform init
terraform apply
```
Uma vez que o provisionamento esteja concluído, verifique se o serviço está em execução.
```
kubectl get services
```


Será logado os serviços em execução, precisaremos do serviço do tipo NodePort.
![image](https://user-images.githubusercontent.com/11475845/113636376-cb722800-9648-11eb-8af9-db868dca04b4.png)

Você poderá acessar a instância da sua aplicação navegando até o NodePort em. http://localhost:30201/

### Fontes
Links que me ajudaram a desenvolver esse trabalho:
- [Provisionando um cluster kubernetes com o terraform](https://learn.hashicorp.com/tutorials/terraform/aks?in=terraform/kubernetes)
- [Publicando o nginx em um cluster kubernetes com o terraform](https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider)
