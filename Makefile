.PHONY: up down argocd get-password proxy-argo-ui proxy-kibana-ui list

up:
	kind create cluster
argocd:
	kubectl create namespace argocd
	kubectl create namespace monitoring
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s
	kubectl apply -f https://raw.githubusercontent.com/argoproj/argo/master/manifests/base/crds/workflow-crd.yaml
	kubectl apply -f applications/
get-password:
	kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
proxy-argo-ui:
	kubectl port-forward svc/argocd-server -n argocd 8080:443
proxy-kibana-ui:
	kubectl port-forward svc/kibana-kibana -n monitoring 5601:5601
down:
	kind delete cluster
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
