# Ansible repository

## Содержит роли для максимальной автоматизации и упрощения процесса деплоя всех необходимых компонентов.

### Роли разделены на 2ва плейбука

1. Используется непосредственно для разворачивания среды контейнеркой аркестрации Kubernetes (master-0, worker-0)

```
ansible-playbook playbooks/playbook_kube.yaml -i inventory/kube-master.yml -t deploy_master -v 
```

2. Ипользуется непосредственно для разворачивания среды содержащей все необходимые компоненты для работы (vm-srv-0).

```
ansible-playbook playbooks/playbook_srv.yaml -i inventory/srv_host.yml -t deploy_srv -v
```
### Ручная донастройка Kubernetes

Ansible помог нам установить большинство компонентов автоматически, но для полноценной эксплуатации, как на хостах Kubernetes так и на хосте Srv-0 требуется провести ручные донастройки среды с которой в дальнейшем будем работать.

### 1. Требуется выполнить подготовку к установки на хостах master-0, worker-0

```
sudo nano /etc/hosts
```
```
IP_ADDRESS master-0 

IP_ADDRESS worker-0
```
Где IP_ADDRESS — IP-адрес каждого узла.

### 2. Включить модули ядра и изменить настройки в sysctl
Включите модули overlay и br_netfliter:
```
sudo modprobe overlay
```
```
sudo modprobe br_netfilter
```
Теперь измените настройки sysctl. Откройте файл kubernetes.conf:
```
sudo nano /etc/sysctl.d/kubernetes.conf
```
Вставьте в него следующие строки:
```
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
```
Выполните команду:
```
sudo sysctl --system
```
### 3. Инициализация мастер ноды kubernetes

```
sudo kubeadm config images pull
```
Инициализируйте кластер при помощи команды:
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```
Копируем его и используем на нашем worker-0. После завершения работы команды, мы должны увидеть:

Пример:
```
kubeadm join 192.168.10.15:6443 --token f7sihu.wmgzwxkvbr8500al \
    --discovery-token-ca-cert-hash sha256:6746f66b2197ef496192c9e240b31275747734cf74057e04409c33b1ad280321

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

```

Создайте директорию для кластера на мастер-ноде с помощью следующих команд:
```
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Присвойте узлу worker-0 роль worker при помощи команды (команду нужно вводить в мастер-ноде):
```
sudo kubectl label node kube-worker node-role.kubernetes.io/worker=worker
```
Проверьте что получилось:
```
kubectl get nodes
```
В случае успеха мы должны увидеть master-0 и worker-0 в Статусе Ready
на этом наша подготовка Kubernetes кластера считается завершоной. 

### О донастройке Srv-0 будет написано в следующих спринтах.
