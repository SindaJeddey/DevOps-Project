include .make_env
export
echo:
	@echo $(region)
build:
	npm run build
deploy: build
	aws s3 cp build/ s3://$(bucket_name)
	echo http://$(bucket_name).s3-website-eu-west-3.amazonaws.com/
