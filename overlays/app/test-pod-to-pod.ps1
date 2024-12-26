# Function to check if the HTML contains a specific string
function Test-HTMLContent {
    param (
        [string]$htmlContent,
        [string]$expectedString
    )
    return $htmlContent.Contains($expectedString)
}

# allocation to optimization
$res1 = (kubectl exec allocation-be-69657c6b64-xm5pt -n test --  curl -s optimization-svc.test.svc.cluster.local:80)
$string =  "optimization"
if (-not (Test-HTMLContent -htmlContent $res1 -expectedString $string)){
    Write-Error "Error: allocation-optimization returned unexpected HTML content"
    return
}

# allocation to rabbitmq
$res2 = (kubectl exec allocation-be-69657c6b64-xm5pt -n test --  curl -s rabbitmq-svc.test.svc.cluster.local:80)
$string =  "rabbitmq"
if (-not (Test-HTMLContent -htmlContent $res2 -expectedString $string)){
    Write-Error "Error: allocation-rabbitmq returned unexpected HTML content"
    return
}

# allocation to celery
$res3 = (kubectl exec allocation-be-69657c6b64-xm5pt -n test --  curl -s celery-svc.test.svc.cluster.local:80)
$string =  "celery"
if (-not (Test-HTMLContent -htmlContent $res3 -expectedString $string)){
    Write-Error "Error: allocation-celery returned unexpected HTML content"
    return
}

# optimization to rabbitmq
$res4 = (kubectl exec optimization-86bc7cc685-76pgc -n test --  curl -s rabbitmq-svc.test.svc.cluster.local:80)
$string =  "rabbitmq"
if (-not (Test-HTMLContent -htmlContent $res4 -expectedString $string)){
    Write-Error "Error: optimization-rabbitmq returned unexpected HTML content"
    return
}
# optimization to celery
$res5 = (kubectl exec optimization-86bc7cc685-76pgc -n test --  curl -s celery-svc.test.svc.cluster.local:80)
$string =  "celery"
if (-not (Test-HTMLContent -htmlContent $res5 -expectedString $string)){
    Write-Error "Error: optimization-celery returned unexpected HTML content"
    return
}
# rabbitmq to celery
$res6 = (kubectl exec rabbitmq-7d6bcdb78b-hbbgh -n test --  curl -s celery-svc.test.svc.cluster.local:80)
$string =  "celery"
if (-not (Test-HTMLContent -htmlContent $res6 -expectedString $string)){
    Write-Error "Error: rabbitmq-celery returned unexpected HTML content"
    return
}
# allocation frontend to backend
$res7 = (kubectl exec allocation-fe-56c4fc98b-p4bxl -n test --  curl -s allocation-be-svc.test.svc.cluster.local:80)
$string =  "Backend"
if (-not (Test-HTMLContent -htmlContent $res7 -expectedString $string)){
    Write-Error "Error: allocation fe-be returned unexpected HTML content"
    return
}
# timetable frontend to backend
$res8 = (kubectl exec timetable-fe-8cb49558f-bgnl8 -n test --  curl -s timetable-be-svc.test.svc.cluster.local:80)
$string =  "Backend"
if (-not (Test-HTMLContent -htmlContent $res8 -expectedString $string)){
    Write-Error "Error: timetable fe-be returned unexpected HTML content"
    return
}

# write-out success message
Write-Output "No errors: All endpoints returned the expected HTML"