# sample-k8s-demo
Demo for k8s with [mediawiki](https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Red_Hat_Linux) using helm.

# Installation
```sh
# Create a Docker image for MediaWiki app bypassing MEDIAWIKI_VERSION as a build-args
docker build -t cthakar/demo-app:1.36.1 --build-arg MEDIAWIKI_VERSION=1.36.1 . --no-cache

# No need to build mysql docker image which I have used directly from the official MySQL docker hub and integrated with values.yaml

# pushed the image to hub.docker.com public repo cthakar/demo-app in mycase
docker push cthakar/demo-app:1.36.1

# Deploy it to kubernetes using helm(must be installed in your system)
minikube status (Deploy k8s in local machine using minikube)
minikube start 
# Syntax 
helm install <full name override> <chart name>/ --values <chart name>/values.yaml
# example
helm install media-wiki media-wiki-demo  --values media-wiki-demo/values.yaml 
# If mediawiki is already deployed and you want to upgrade with new version then either update image.tag in values.yaml or you can pass directly like --set=image.tag=1.36.2
helm upgrade media-wiki media-wiki-demo  --values media-wiki-demo/values.yaml --set=image.tag=1.36.2

```

# Update Strategy
```sh
# I have used RollingUpdate Strategy

kubectl set image deployment media-wiki-chart media-wiki-demo=cthakar/demo-app:1.36.2 --record
kubectl rollout status deployment media-wiki-chart

# This will one by one update pod with the new version so let's say replicaCount=2 then it will first rollout changes to 1 pod based on maxSurge and maxUnavailable.
ex. maxSurge: 1 means that there will be at most 4 pods during the update process if replicas are 3
ex. maxUnavailable: 1 means that there will be at most 1 pod unavailable during the update process


```