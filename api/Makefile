include .env
export
image := backend-devops

ecr_connect:
	aws ecr get-login-password --region $(region) | docker login --username AWS --password-stdin $(account_id).dkr.ecr.$(region).amazonaws.com
build:
	docker build . -t $(image)
push: build
	docker push $(image)
run: build
	docker run -p 5000:5000 $(image)