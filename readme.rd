## Set the default namespace into different namespace
kubectl config set-context $(kubectl config current-context) --namespace=dev

## service connnection with internal cluster with difference namespace 
<service name>.<namespace name>.svc.cluster.local

####Create an NGINX Pod
kubectl run nginx --image=nginx
kubectl run nginx --image=nginx --dry-run=client -o yaml

####Create a deployment
kubectl create deployment --image=nginx nginx
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --replicas=4

#####You can also scale a deployment using the
kubectl scale
kubectl scale deployment nginx--replicas=4
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml

#####Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml
kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml 

#####Create a Service named nginx of type NodePort to expose pod nginx’s port 80 on port 30080 on the nodes:
kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml

#####Both the above commands have their own challenges. While one of them cannot accept a selector, the other cannot accept a node port. I would recommend going with the
kubectl expose

##Manual scheduling the pod By using of Binding 
In yaml script added nodeName: <nodename> under spec section

##Taints and tolerations
kubectl describe node controlplane | grep -i taints
kubectl taints node nodes app=dev:NoSchdeule
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule-

##Node selector
kubectl label node <node name> size=large

## nodeaffinity
four types -> requiredSchedulingDuringIgonedExecution, preferedSchedulingDuringIgonedExecution, requiredSchedulingRequiredDuringExecution, prefferedSchedulingRequiredDuringExecution

##Limitrange
limitrange set into namespace

##Resource and required
resource and required in pod

##static pod
staticPod: /etc/kubernetes/mainfest

##scheduling pod we can set the priorityClass: high we need create an yaml file for this

##admission controller is used to make pod,deployment yaml file restriction 
kube-apiserver -h | grep enable-admission-plugin
kubectl -n webhook-demo create secret tls webhook-server-tls \
    --cert "/root/keys/webhook-server-tls.crt" \
    --key "/root/keys/webhook-server-tls.key"

##Create config map in imperative ways
kubectl create config app-config --from-literal=<key>=<value>

## create an initcontainer
kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx.yaml

## horizontal pod autoscaling
Inplacepodverticalscaling=true
In this way, if we have replaced the resource in the existing pods it will recreate one more time but if we have enabled the kubernetes level it won't recreate the pods it will differently replace the resources

## Vertical pod
Install vpa in cluster level then only it will work

# os upgrade if the pod is already exists 
kubectl drain node-1 -> it won't schedule the pod if the pod is exists it will delete 
kubectl cordon node-1 -> it won't schedule the pod if the pod is exists it will not delete the pod
kubectl uncordon node-1 -> Back to normal

#upgrade plan
kubeadm upgrade plan
apt-get upgrade kubeadm=<one version up>
kubeadm upgrade apply <version>

## check the os linux
cat /etc/*release*
kubectl describe nodes  node01 | grep -i taint
kubeadm upgrade plan
vim /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
apt update
apt-cache madison kubeadm
apt-get install kubeadm=1.32.0-1.1
kubeadm upgrade apply v1.32.0
apt-get install kubelet=1.32.0-1.1
systemctl daemon-reload
systemctl restart kubelet

## etcd backup
ETCDCTL_API=3 etcdctl snapshot save snapshot.db
ETCDCTL_API=3 etcdctl snapshot status snapshot.db

## Stop the api server
systemctl kube-apiserver stop

## Restore the backup
ETCDCTL_API=3 etcdctl snapshot save snapshot.db --data-dir=/var/lib/etcd-from-backup

#check the version 
kubectl -n kube-system describe pod etcd-controlplane | grep Image:

# tls certificate creations
openssl genrsa -out my-bank 1024
openssl rsa -in my-bank -pubout > mybank.pem

#cerfiticate signed validation
openssl req -new my-bank.key -out my-bank.csr -subj "/C=US/ST=CA/O=MyOrg, Inc./CN=my-bank.com"

#public key
*.crt, *.pem

#private key 
*.key, -key.pem

#generate CA certificate
openssl genrsa out admin.key 2048
openssl req new -key admin.key -subj "/CN=kube-admin" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAKey ca.key -out admin.crt

#decode the certificate
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout

##etcd server port 
2379

## cerfiticate commands
k get csr 
k certificate approve jane
k get csr jane -o yaml

#base64 encoded
cat akshay.csr | base64 -w 0
kubectl certificate deny agent-smith
kubectl delete csr agent-smith

#kubeconfig file
--server my-kube-playground:6443
--client-key admin.key
--client-certificate admin.crt
--certificate-authority ca.crt

##kube config
kubectl config view
kubectl config use-context <use name>
kubectl config current-context --kubeconfig my-kube-config

## RBAC
k get roles
k get rolebindings

#check our permission
kubectl auth can-i create deployment 

##cluster scope
node,pv,clusterrole,clusterrolebinding,certificateapproval,namespace
kubectl api-resources --namespace=true

## service account
k create serviceaccount ser-accept
k get seviceaccount

## Docker Register
kubectl create secret docker-registry private-reg-cred --docker-username=dock_user --docker-password=dock_password --docker-server=myprivateregistry.com:5000 --docker-email=dock_user@myprivateregistry.com
kubectl exec ubuntu-sleeper -- whoami
  securityContext:
    runAsUser: 1010

## Networking configuration
Linux networking basic
ip link -> eth0
ip addr add
route -> will display routing configuration
ip route addr <cidr> via private ip address
ip route default via 192.168.2.1

# Eth0 forward the network eth1 private network connected forward into eth0 configuration
cat /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/
cat /etc/sysctl.config

## list of command
ip link -> list and modified
ip addr
ip addr add
ip route
ip route add 
cat /etc/resolv.conf
cat /etc/nsswitch.conf

#network namespaces
ip netns add red
ip netns add blue
ip netns
ip link add veth-red type veth peer name veth-blue
ip link set veth-red netns red
ip link show eth0
ip route show default
netstat -nplt
ip address show type bridge
ps -aux | grep kubelet | grep --color container-runtime-endpoint
cat /etc/kubernetes/manifests/kube-controller-manager.yaml   | grep cluster-cidr

##ingress requiredSchedulingDuringIgonedExecution
kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"**
Ingress controller -> nginx
ingress resource -> kubernetes yaml files
## ingress deployment 
kubectl create configmap ingress-nginx-controller --namespace ingress-nginx
## ingress service account
kubectl create serviceaccount ingress-nginx --namespace ingress-nginx
kubectl create serviceaccount ingress-nginx-admission --namespace ingress-nginx

## helm
repo for helm artifacthub.io
helm structure -> template, values.yaml.charts.yaml, charts, License 
Under charets.yaml -> apiVersion, appVersion, type: application (which used for application) or libery (which is used for utillies)
dependenties, home, icons, emails id
helm pull --untar bitnami/wordpress
helm install my-release ./wordpress