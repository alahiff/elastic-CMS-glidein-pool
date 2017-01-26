# Elastic CMS glidein pool
Here we create CVMFS/Frontier squids as well as a pool of CMS glideins which scales elastically. It has been tested on local clusters (installed using kubeadm), Google Container Engine and Azure Container Service.

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
In order to run the glidein pods a proxy must be stored as a Secret - this will be used for authenticating with the glideinWMS HTCondor pool. In addition 3 ConfigMaps are required for storing the glidein arguments as well as the site-local-config.xml and storage.xml files.
```
$ kubectl create secret generic proxy --from-file=proxy
$ kubectl create configmap glideinargs --from-file=glideinargs
$ kubectl create configmap site-local-config.xml --from-file=site-local-config.xml
$ kubectl create configmap storage.xml --from-file=storage.xml
```
The file site-local-config.xml is made available inside the glidein container in /etc/cms/JobConfig and storage.xml is made available  in /etc/cms/PhEDEx (alternatively these files could be obtained from CVMFS, but for testing providing the files directly is simpler).

Now create the glidein deployment:
```
$ kubectl create -f glideins.yaml
```
We use a horizontal pod autoscaler to scale the number of glidein pods depending on how much work there is:
```
$ kubectl autoscale deployment glideins --min=1 --max=400 --cpu-percent=60
```
Here the maximum number of pods should be adjusted as appropriate. You should now see:
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
