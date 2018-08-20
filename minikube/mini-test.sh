#!/bin/bash

# get the pod to check the logs of
pod=$(kubectl get pod -l app=testwatch -o jsonpath='{.items[0].metadata.name}')

# get current number of "add" events
adds=$(kubectl logs $pod testwatch | grep "add event" | wc -l)
desired=$((adds+1))

# create the test service
kubectl create --save-config -f ../test-svc.yaml

# get new number of "add" events
newAdds=$(kubectl logs $pod testwatch | grep "add event" | wc -l)

if [ "$newAdds" -ne "$desired" ]; then
    echo "FAIL: Service \"add\" event not received in testwatch app"
    echo "    OLD: $adds NEW: $newAdds"
    exit 1
else
    echo "PASS: testwatch app received service \"add\" event!"
fi

kubectl delete -f ../test-svc.yaml

# TODO: WIP (after adding additional testlist app)
