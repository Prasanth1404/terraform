#!/bin/bash
# Installs in-cluster components after `terraform apply`.
# Order: kubeconfig -> sealed-secrets -> ingress-nginx -> mysql-operator -> argocd
set -euo pipefail

REGION="${REGION:-ap-south-1}"
CLUSTER="${CLUSTER:-lwp-eks-cluster}"
WORKDIR="$(mktemp -d)"
cd "$WORKDIR"

#================================================================================

echo ">> kubeconfig"
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
kubectl get nodes

#================================================================================

echo ">> Sealed Secrets controller"
curl -fL --retry 5 -o sealed-secrets.yaml \
  https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.37.0/controller.yaml
kubectl apply -f sealed-secrets.yaml --validate=false

#================================================================================

echo ">> ingress-nginx (AWS NLB)"
curl -fL --retry 5 -o ingress-nginx-aws.yaml \
  https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
kubectl apply -f ingress-nginx-aws.yaml --validate=false

#================================================================================

echo ">> MySQL Operator"
helm repo add mysql-operator https://mysql.github.io/mysql-operator/ >/dev/null
helm repo update >/dev/null
helm upgrade --install mysql-operator mysql-operator/mysql-operator \
  -n mysql-operator --create-namespace

#================================================================================

echo ">> Argo CD"
curl -fL --retry 5 -o argocd-install.yaml \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f argocd-install.yaml --server-side --validate=false

#================================================================================

echo ">> Waiting for the load balancer hostname..."
for i in $(seq 1 30); do
  LB=$(kubectl get svc -n ingress-nginx ingress-nginx-controller \
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
  [ -n "$LB" ] && break
  sleep 10
done

echo
echo "Done."
echo "Load balancer (use for CNAME records): ${LB:-not ready yet, run: kubectl get svc -n ingress-nginx}"
echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo "(not ready yet)"
echo
echo "Next: kubeseal --fetch-cert > sealed-secrets-cert.pem, push it, then apply the ClusterIssuer and Argo CD ingress."
