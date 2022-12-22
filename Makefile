help :
	@echo "Usage:"
	@echo "   make capi-visualizer              - deploy cluster api visualizer app"

capi-visualizer :
	helm install capi-visualizer --repo https://jont828.github.io/cluster-api-visualizer/charts cluster-api-visualizer
	kubectl apply -f deploy/capi-visualizer-nodeport.yaml
