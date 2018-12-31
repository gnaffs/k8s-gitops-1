#!/bin/bash

kseal() {
    name=$(basename -s .txt "$@")
    envsubst < "$@" > values.yaml | kubectl -n kube-system create secret generic "$name" --from-file=values.yaml --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem && rm  values.yaml
}

#################
# secrets
#################
kubectl create secret generic fluxcloud --from-literal=slack_url="$SLACK_WEBHOOK_URL" --namespace flux --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/fluxcloud.yaml
kubectl create secret generic traefik-basic-auth-jeff --from-literal=auth="$TRAEFIK_AUTH" --namespace kube-system --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/basic-auth-jeff-kube-system.yaml
kubectl create secret generic traefik-basic-auth-jeff --from-literal=auth="$TRAEFIK_AUTH" --dry-run -o json | kubeseal --format=yaml --cert=../pub-cert.pem > ../secrets/basic-auth-jeff.yaml

#################
# helm chart values
#################
kseal values-to-encrypt/consul-values.txt > ../secrets/consul-values.yaml
kseal values-to-encrypt/traefik-values.txt > ../secrets/traefik-values.yaml
kseal values-to-encrypt/kubernetes-dashboard-values.txt > ../secrets/kubernetes-dashboard-values.yaml
kseal values-to-encrypt/kured-values.txt > ../secrets/kured-values.yaml