#!/bin/bash

# TEST WATCH APP

app="testwatch"
# get the pod to check the logs of
pod=$(kubectl get pod -l app="${app}" -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "${pod}" ]; then
    echo "Testing ${app} app..."
    # get current number of "add" events
    adds=$(kubectl logs $pod -c "${app}" | grep "add event" | wc -l)
    desired=$((adds+1))

    # create the test service
    kubectl create --save-config -f ../test-svc.yaml

    # get new number of "add" events
    newAdds=$(kubectl logs $pod -c "${app}" | grep "add event" | wc -l)

    if [ "$newAdds" -ne "$desired" ]; then
        echo "FAIL: Service \"add\" event not received in ${app} app"
        echo "    OLD: $adds NEW: $newAdds"
    else
        echo "PASS: ${app} app received service \"add\" event!"
    fi

    # delete the service
    kubectl delete -f ../test-svc.yaml
else
    echo "SKIP: ${app} app not deployed."
fi

# TEST LIST APP
app="testlist"
# get the pod to check the logs of
pod=$(kubectl get pod -l app="${app}" -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "${pod}" ]; then
    echo "Testing ${app} app..."
    IP=$(kubectl get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    val=$(curl -s --header "Host: testlist-service.default.svc.cluster.local" http://${IP}/namespace/default)
    if [[ "$val" != *"kubernetes"* ]]; then
        echo "FAIL: Failed to list services in default namespace (or kubernetes service is missing...)"
    else
        echo "PASS: ${app} successfully listed the services in the default namespace!"
    fi
else
    echo "SKIP: ${app} app not deployed."
fi
