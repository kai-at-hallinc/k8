#!/bin/bash

echo "cleaning test resources.."

# deploy services
kubectl delete -f ../../templates/allocation-svc.yaml -n test
kubectl delete -f ../../templates/timetable-svc.yaml -n test
kubectl delete -f ../../templates/optimization-svc.yaml -n test

# deploy applications
kubectl delete -f ../../templates/allocation-deploy.yaml -n test
kubectl delete -f ../../templates/timetable-deploy.yaml -n test
kubectl delete -f ../../templates/optimization-deploy.yaml -n test
kubectl delete -f ../../templates/rabbitmq-deploy.yaml -n test
kubectl delete -f ../../templates/celery-deploy.yaml -n test

echo "test resources removed."