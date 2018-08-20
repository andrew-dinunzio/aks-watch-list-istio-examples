package main

import (
	"time"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

func main() {

	// creates the in-cluster config
	config, err := rest.InClusterConfig()
	if err != nil {
		panic(err.Error())
	}
	// creates the clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}

	// listen for k8s events
	stateListener := NewStateListenerClient(clientset)
	stateListener.listenSvcEvents()
	for {
		time.Sleep(2 * time.Second)
	}
}
