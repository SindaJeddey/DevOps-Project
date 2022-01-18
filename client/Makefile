include .make_env
export
install:
	npm install
build: install
	npm run build
deploy: build
	aws s3 cp --recursive build/ s3://$(bucket_name)
	echo http://$(bucket_name).s3-website.eu-west-3.amazonaws.com/
