package main

import (
	"fmt"
	"time"

	apiv1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
)

// StateListenerClient defines the interface used for state listeners
type StateListenerClient interface {
	listenSvcEvents()
}

// NewStateListenerClient for StateListener
func NewStateListenerClient(clientset *kubernetes.Clientset) StateListenerClient {
	listener := &StateListener{}

	listener.clientset = clientset
	listener.watchLabels = make(map[string]string, 0)
	listener.watchLabels["app"] = "testapp"

	return listener
}

// StateListener is used to add watches on services
type StateListener struct {
	watchLabels map[string]string
	clientset   *kubernetes.Clientset
}

func (listener *StateListener) getServiceListWatch(optionsModifier func(options *metav1.ListOptions)) *cache.ListWatch {
	return cache.NewFilteredListWatchFromClient(listener.clientset.CoreV1().RESTClient(), "services", "default", optionsModifier)
}

func (listener *StateListener) listenSvcEvents() {
	optionsModifier := func(options *metav1.ListOptions) {
		options.LabelSelector = labels.Set(listener.watchLabels).AsSelector().String()
	}

	watchlist := listener.getServiceListWatch(optionsModifier)
	_, controller := cache.NewInformer(
		watchlist,
		&apiv1.Service{},
		time.Second*0,
		cache.ResourceEventHandlerFuncs{ // TODO: might run into this issue? https://groups.google.com/forum/#!topic/golang-nuts/LTxXOgX3LWk
			AddFunc:    listener.handleSvcAddEvent,
			UpdateFunc: listener.handleSvcUpdateEvent,
			DeleteFunc: listener.handleSvcDeleteEvent,
		},
	)
	fmt.Printf("Subscribed to k8s events for services!\n")
	stop := make(chan struct{})
	go controller.Run(stop)
}

func (listener *StateListener) handleSvcAddEvent(obj interface{}) {
	fmt.Printf("Received service add event!\n")
}

func (listener *StateListener) handleSvcUpdateEvent(oldObj, newObj interface{}) {
	fmt.Printf("Received service update event!\n")
}

func (listener *StateListener) handleSvcDeleteEvent(obj interface{}) {
	fmt.Printf("Received service delete event!\n")
}
