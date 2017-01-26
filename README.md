# Elastic CMS glidein pool
Here we create CVMFS/Frontier squids as well as a pool of CMS glideins which scales elastically.

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
Create the glidein deployment:
```
kubectl create -f glideins.yaml
```
We use a horizontal pod autoscaler to scale the number of glidein pods depending on how much work there is:
```
kubectl autoscale deployment glideins --min=1 --max=400
```
(adjust the maximum number of pods as appropriate).

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
