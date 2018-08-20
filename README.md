# Introduction

This shows the problem that AKS has with watching resources.

It is expected that these scripts will run from Git Bash on Windows, and Minikube will use hyperv as the vm-driver.

Also, I created a symlink to az.cmd called just "az", so I can run the CLI commands from Git Bash.

# Setting up Minikube

**NOTE**: This is currently a WIP, as I have not made the changes necessary to the minikube scripts. You can still set up on Minikube by creating a minikube cluster (similarly to how it's done in the script now), make sure that that is your current kubectl context, then run the `./aks-setup.sh` script, selecting "n" when prompted to create the AKS cluster. Also, you must change your `hyperv-virtual-switch` to whatever yours is called. This is assuming you're testing from Windows with hyperv. 

**OLD**: `cd` into `./minikube`, and run `./mini-setup.sh`. Then deploy one of the apps (either via `./mini-deploy-watch-app.sh` or `./mini-deploy-list-app.sh`). Then run `./mini-test.sh`. It will output either `PASS`, `FAIL` or `SKIP`.

# Setting up AKS

**NOTE**: You should modify `vars.sh` to name the ACR something different - it has to be unique or the command will fail.

`cd` into `./aks`, and run `source ./vars.sh`, then `./aks-setup.sh`. Follow the prompts to create an AKS cluster, create an ACR, build and push the apps to the ACR, and deploy Istio (for testing, choose `yes` for all of them). Then run `./aks-test.sh`. It will output either `PASS`, `FAIL` or `SKIP`. Run `./clean.sh` to clean up the aks resources after.

# Istio Workaround

There is a problem installing Istio on AKS right now. It results in the `helm install` command returning `watch closed before Until timeout`, but we found a way to get it installed by first creating a DaemonSet with the hyperkube image. This makes the postinstall command complete within the 1-minute timeframe, so it no longer fails to watch.

There are two files, `istio/install-istio-workaround.sh` and `istio/install-istio.sh`. The former is what we need to do, and the latter is what we would ideally do if AKS didn't have the watch closing issue.

# Problems

With Istio enabled, we see the following output from our service, causing it to crash repeatedly:

```
$ kubectl logs testwatch-deploy-58d654854-zwf6w testwatch
Subscribed to k8s events for services!
E0814 19:33:41.597614       1 reflector.go:205] github.com/andrew-dinunzio/watch-examples/stateListener.go:58: Failed to list *v1.Service: an error on the server ("") has prevented the request from succeeding (get services)
E0814 19:33:41.597614       1 reflector.go:205] github.com/andrew-dinunzio/watch-examples/stateListener.go:58: Failed to list *v1.Service: an error on the server ("") has prevented the request from succeeding (get services)
log: exiting because of error: log: cannot create log: open /tmp/testwatch.testwatch-deploy-58d654854-zwf6w.unknownuser.log.ERROR.20180814-193341.1: no such file or directory
```
