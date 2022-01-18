image := sindajeddey/insat-devops-prometheus 
build:
	docker build . -t $(image)
push: build
	docker push $(image)
run: build
	docker run -p 9090:9090 --network="host"  $(image)