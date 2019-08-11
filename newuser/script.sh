# User identifier
export USER="ramesh"

rm -rf  $PWD/$USER.*
openssl genrsa -out $USER.key 4096
openssl req -config ./csr.conf -new -key $USER.key -nodes -out $USER.csr
export BASE64_CSR=$(cat ./$USER.csr | base64 | tr -d '\n')
kubectl delete certificatesigningrequests $USER
cat csr.yaml | envsubst | kubectl apply -f -
kubectl certificate approve $USER
kubectl get csr  $USER -o jsonpath=’{.status.certificate}’  | base64  -di >$USER.crt
openssl x509 -in  $USER.crt  -noout -text | grep 'Subject:'

cat cluserrole.yaml | envsubst | kubectl apply -f -
cat  rolebuind.yaml | envsubst | kubectl apply -f -

# Cluster Name (get it from the current context)
export CLUSTER_NAME=$(kubectl config view --minify -o jsonpath={.current-context})
# Client certificate
export CLIENT_CERTIFICATE_DATA=$(kubectl get csr $USER -o jsonpath='{.status.certificate}')
# Cluster Certificate Authority
export CLUSTER_CA=$(kubectl config view --raw -o json | jq -r '.clusters[] | .cluster."certificate-authority-data"')
# API Server endpoint
export CLUSTER_ENDPOINT=$(kubectl config view --raw -o json | jq -r '.clusters[] | .cluster."server"')

cat kubeconfig.tpl | envsubst > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"
kubectl config set-credentials ramesh   --client-key=$PWD/ramesh.key  --embed-certs=true
