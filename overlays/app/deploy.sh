#!/bin/bash
kubectl apply -f ../../k8s/cluster-issuer.yaml
kubectl apply -f ../../k8s/frontend-ingress-tls.yaml

