#!/bin/bash

# deploy tls cert issuer and frontend ingress
kubectl apply -f ../../k8s/cluster-issuer.yaml
kubectl apply -f ../../k8s/frontend-ingress-tls.yaml

# deploy services
kubectl apply -f ../../templates/allocation-svc.yaml -n test
kubectl apply -f ../../templates/timetable-svc.yaml -n test
kubectl apply -f ../../templates/optimization-svc.yaml -n test

# deploy applications
kubectl apply -f ../../templates/allocation-deploy.yaml -n test
kubectl apply -f ../../templates/timetable-deploy.yaml -n test
kubectl apply -f ../../templates/optimization-deploy.yaml -n test
kubectl apply -f ../../templates/rabbitmq-deploy.yaml -n test
kubectl apply -f ../../templates/celery-deploy.yaml -n test
