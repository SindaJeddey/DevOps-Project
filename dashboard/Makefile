image := grafana-devops
build:
	docker build . -t $(image)
push: build
	docker push $(image)
run: build
	docker run -p 3000:3000 --network="host"  $(image)
