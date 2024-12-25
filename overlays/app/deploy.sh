#!/bin/bash
kubectl apply -f ../../../k8s/cluster-issuer.yaml
kubectl apply -f ../../../k8s/stage/frontend-ingress-tls.yaml

