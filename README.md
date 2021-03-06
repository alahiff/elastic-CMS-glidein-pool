# Elastic CMS glidein pool
Here we create CVMFS/Frontier squids as well as a pool of CMS glideins which scales elastically. It has been tested with CRAB3 jobs on the following platforms:
* local bare-metal clusters (Kubernetes deployed using kubeadm)
* Google Container Engine
* Azure Container Service 
* Amazon AWS (Kubernetes deployed using https://stackpoint.io/)

Note that currently we need to use privileged containers in order for CVMFS to work. This should be resolved once https://github.com/kubernetes/kubernetes/pull/31504 is sorted out, i.e. CVMFS could be separated out and run in different containers to the jobs. Installing CVMFS on hosts using other means is not an option as this would break portability between different platforms.

Firstly deploy the squids:
```
$ kubectl create -f squids.yaml
service "squid" created
deployment "squid" created
```
You should see:
```
$ kubectl get deployments,pods
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/squid   2         2         2            2           57s
NAME                        READY     STATUS    RESTARTS   AGE
po/squid-2537263375-4hnz8   1/1       Running   0          57s
po/squid-2537263375-koisq   1/1       Running   0          57s
```
In order to run the glidein pods a proxy must be stored as a Secret - this will be used for authenticating with the glideinWMS HTCondor pool. In addition 3 ConfigMaps are required for storing the glidein arguments as well as the the files `site-local-config.xml` and `storage.xml`.
```
$ kubectl create secret generic proxy --from-file=proxy
$ kubectl create configmap glideinargs --from-file=glideinargs
$ kubectl create configmap site-local-config.xml --from-file=site-local-config.xml
$ kubectl create configmap storage.xml --from-file=storage.xml
```
The file `site-local-config.xml` is made available inside the glidein container in `/etc/cms/JobConfig` and `storage.xml` is made available in `/etc/cms/PhEDEx` (alternatively these files could be obtained from CVMFS, but for testing providing the files directly is simpler). `glideinargs` should be a text file containing the arguments for `glidein_startup.sh` in a single line.

Now create the glidein deployment:
```
$ kubectl create -f glideins.yaml
```
and you should now see:
```
$ kubectl get deployments,pods
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/glidein   1         1         1            1           1m
deploy/squid     2         2         2            2           28m
NAME                          READY     STATUS    RESTARTS   AGE
po/glidein-1922292197-981ut   1/1       Running   0          1m
po/squid-2537263375-4hnz8     1/1       Running   0          28m
po/squid-2537263375-koisq     1/1       Running   0          28m
```
We use a horizontal pod autoscaler to scale the number of glidein pods depending on how much work there is:
```
$ kubectl autoscale deployment glideins --min=1 --max=400 --cpu-percent=60
```
Here the minimum and maximum numbers of pods should be adjusted as appropriate.
