package main

import (
	"fmt"
	"log"
	"net/http"

	"k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"

	"github.com/gorilla/mux"
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

	r := mux.NewRouter()
	r.HandleFunc("/namespace/{namespace}", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Received a request!\n")
		vars := mux.Vars(r)
		ns := vars["namespace"]
		serviceList, err := clientset.Core().Services(ns).List(v1.ListOptions{})
		if err != nil {
			fmt.Printf("Error getting services:  %v!\n", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusOK)
		for _, service := range serviceList.Items {
			fmt.Printf("Found service %s!\n", service.Name)
			w.Write([]byte(fmt.Sprintf("%s\n", service.Name)))
		}
	})
	http.Handle("/", r)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
