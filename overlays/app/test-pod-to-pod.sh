#!/bin/bash

# Function to check if the HTML contains a specific string
function Test_HTMLContent {
    local htmlContent="$1"
    local expectedString="$2"
    if [[ "$htmlContent" == *"$expectedString"* ]]; then
        return 0
    else
        return 1
    fi
}

# Loop until all pods are ready, checking every 30 seconds
while true; do
    if ! kubectl get pods -n test | grep -qE 'Pending|ContainerCreating'; then
        echo "All pods are ready. testing ingress.."
        break
    else
        echo "Waiting for pods to be ready..."
        sleep 30
    fi
done

# Get pod names containing 'allocation' in the 'test' namespace
allocation_pods=$(kubectl get pods -n test | grep 'allocation' | awk '{print $1}')

# allocation to optimization
res1=$(kubectl exec $(echo $allocation_pods | awk '{print $1}') -n test -- curl -s optimization-svc.test.svc.cluster.local:80)
string="optimization"
if ! Test_HTMLContent "$res1" "$string"; then
    echo "Error: allocation-optimization returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: allocation-optimization returned expected HTML content"

# allocation to rabbitmq
res2=$(kubectl exec $(echo $allocation_pods | awk '{print $1}') -n test -- curl -s rabbitmq-svc.test.svc.cluster.local:80)
string="rabbitmq"
if ! Test_HTMLContent "$res2" "$string"; then
    echo "Error: allocation-rabbitmq returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: allocation-rabbitmq returned expected HTML content"

# allocation to celery
res3=$(kubectl exec $(echo $allocation_pods | awk '{print $1}') -n test -- curl -s celery-svc.test.svc.cluster.local:80)
string="celery"
if ! Test_HTMLContent "$res3" "$string"; then
    echo "Error: allocation-celery returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: allocation-celery returned expected HTML content"

# Get pod names containing 'optimization' in the 'test' namespace
optimization_pods=$(kubectl get pods -n test | grep 'optimization' | awk '{print $1}')

# optimization to rabbitmq
res4=$(kubectl exec $(echo $optimization_pods | awk '{print $1}') -n test -- curl -s rabbitmq-svc.test.svc.cluster.local:80)
string="rabbitmq"
if ! Test_HTMLContent "$res4" "$string"; then
    echo "Error: optimization-rabbitmq returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: optimization-rabbitmq returned expected HTML content"

# optimization to celery
res5=$(kubectl exec $(echo $optimization_pods | awk '{print $1}') -n test -- curl -s celery-svc.test.svc.cluster.local:80)
string="celery"
if ! Test_HTMLContent "$res5" "$string"; then
    echo "Error: optimization-celery returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: optimization-celery returned expected HTML content"

# Get pod names containing 'rabbitmq' in the 'test' namespace
rabbitmq_pods=$(kubectl get pods -n test | grep 'rabbitmq' | awk '{print $1}')

# rabbitmq to celery
res6=$(kubectl exec $(echo $rabbitmq_pods | awk '{print $1}') -n test -- curl -s celery-svc.test.svc.cluster.local:80)
string="celery"
if ! Test_HTMLContent "$res6" "$string"; then
    echo "Error: rabbitmq-celery returned unexpected HTML content" >&2
    exit 1
fi
 echo "Success: rabbitmq-celery returned expected HTML content"

# Get pod names containing 'allocation-fe' in the 'test' namespace
allocation_fe_pods=$(kubectl get pods -n test | grep 'allocation-fe' | awk '{print $1}')
# allocation frontend to backend
res7=$(kubectl exec $(echo $allocation_fe_pods | awk '{print $1}') -n test -- curl -s allocation-be-svc.test.svc.cluster.local:80)
string="Backend"
if ! Test_HTMLContent "$res7" "$string"; then
    echo "Error: allocation fe-be returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: allocation fe-be returned expected HTML content"

# Get pod names containing 'timetable-fe' in the 'test' namespace
timetable_fe_pods=$(kubectl get pods -n test | grep 'timetable-fe' | awk '{print $1}')
# timetable frontend to backend
res8=$(kubectl exec $(echo $timetable_fe_pods | awk '{print $1}') -n test -- curl -s timetable-be-svc.test.svc.cluster.local:80)
string="Backend"
if ! Test_HTMLContent "$res8" "$string"; then
    echo "Error: timetable fe-be returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: timetable fe-be returned expected HTML content"

# add test for allocation fe using curl
# Get the public IP of the ingress
ingress_ip=$(kubectl get ingress -n test -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

# Test allocation frontend using the ingress public IP
res9=$(curl -s http://$ingress_ip/)
string="Frontend"
if ! Test_HTMLContent "$res9" "$string"; then
    echo "Error: allocation frontend using ingress returned unexpected HTML content" >&2
    exit 1
fi
 echo "Success: allocation frontend returned expected HTML content"

# Test lukkariapi using the ingress public IP
res10=$(curl -s http://$ingress_ip/lukkariapi/)
string="Backend"
if ! Test_HTMLContent "$res10" "$string"; then
    echo "Error: timetable backend returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: timetable backend returned expected HTML content"

# Test lukkarifrontend using the ingress public IP
res11=$(curl -s http://$ingress_ip/lukkarifrontend/)
string="Frontend"
if ! Test_HTMLContent "$res11" "$string"; then
    echo "Error: timetable frontend returned unexpected HTML content" >&2
    exit 1
fi
echo "Success: lukkarifrontend returned expected HTML content"

# write success message
echo "Test finished. All endpoints returned the expected HTML"