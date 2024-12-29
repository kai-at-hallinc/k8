# Function to check if the HTML contains a specific string
function Test-HTMLContent {
    param (
        [string]$htmlContent,
        [string]$expectedString
    )
    return $htmlContent.Contains($expectedString)
}

# allocation to optimization
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("allocation-be")) | .metadata.name')
$res1 = (kubectl exec $cont -n test --  curl -s optimization-svc.test.svc.cluster.local:80)
$string =  "optimization"
if (-not (Test-HTMLContent -htmlContent $res1 -expectedString $string)){
    Write-Error "Error: allocation-optimization returned unexpected HTML content"
    return
}

# allocation to rabbitmq
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("allocation-be")) | .metadata.name')
$res2 = (kubectl exec $cont -n test --  curl -s rabbitmq-svc.test.svc.cluster.local:80)
$string =  "rabbitmq"
if (-not (Test-HTMLContent -htmlContent $res2 -expectedString $string)){
    Write-Error "Error: allocation-rabbitmq returned unexpected HTML content"
    return
}

# allocation to celery
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("allocation-be")) | .metadata.name')
$res3 = (kubectl exec $cont -n test --  curl -s celery-svc.test.svc.cluster.local:80)
$string =  "celery"
if (-not (Test-HTMLContent -htmlContent $res3 -expectedString $string)){
    Write-Error "Error: allocation-celery returned unexpected HTML content"
    return
}

# optimization to rabbitmq
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("optimization")) | .metadata.name')
$res4 = (kubectl exec $cont -n test --  curl -s rabbitmq-svc.test.svc.cluster.local:80)
$string =  "rabbitmq"
if (-not (Test-HTMLContent -htmlContent $res4 -expectedString $string)){
    Write-Error "Error: optimization-rabbitmq returned unexpected HTML content"
    return
}
# optimization to celery
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("optimization")) | .metadata.name')
$res5 = (kubectl exec $cont -n test --  curl -s celery-svc.test.svc.cluster.local:80)
$string =  "celery"
if (-not (Test-HTMLContent -htmlContent $res5 -expectedString $string)){
    Write-Error "Error: optimization-celery returned unexpected HTML content"
    return
}
# rabbitmq to celery
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("rabbitmq")) | .metadata.name')
$res6 = (kubectl exec $cont -n test --  curl -s celery-svc.test.svc.cluster.local:80)
$string =  "celery"
if (-not (Test-HTMLContent -htmlContent $res6 -expectedString $string)){
    Write-Error "Error: rabbitmq-celery returned unexpected HTML content"
    return
}
# allocation frontend to backend
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("allocation-fe")) | .metadata.name')
$res7 = (kubectl exec $cont -n test --  curl -s allocation-be-svc.test.svc.cluster.local:80)
$string =  "Backend"
if (-not (Test-HTMLContent -htmlContent $res7 -expectedString $string)){
    Write-Error "Error: allocation fe-be returned unexpected HTML content"
    return
}
# timetable frontend to backend
$cont = (kubectl get pods -n test -o json | jq -r '.items[] | select(.metadata.name | contains("timetable-fe")) | .metadata.name')
$res8 = (kubectl exec $cont -n test --  curl -s timetable-be-svc.test.svc.cluster.local:80)
$string =  "Backend"
if (-not (Test-HTMLContent -htmlContent $res8 -expectedString $string)){
    Write-Error "Error: timetable fe-be returned unexpected HTML content"
    return
}

# write-out success message
Write-Output "No errors: All endpoints returned the expected HTML"