# DevOps-Project
This repository contains a sample E-commerce application developed with ReactJS, Express.JS and uses DynamoDB as a database.

The E-Commerce website can be reached on : http://insat-devops.s3-website.eu-west-3.amazonaws.com/ .

---

## Tools
* AWS ECS
* AWS DynamoDB
* Docker
* Prometheus
* Grafana
* Github Actions 

---

## Architecture & Deployment
![architecture](https://user-images.githubusercontent.com/47459995/149981220-4bdfbf3c-da4e-4e96-a1ab-caa470e80a51.png)

The frontend is hosted on an S3 bucket.
The backend, Grafana and Prometheus are deployed on a container in an ECS cluster.

---

## CI/CD Pipline
![pipeline](https://user-images.githubusercontent.com/47459995/149981211-65e17f1a-5762-40db-81d7-8dc822591e5e.png)

---

## Endpoints
Method     | Endpoint                                 | Description
---------- | ---------------------------------------- | ---------------------------
**GET**    | 15.188.127.86:5000/api/products          | Fetch all products
**GET**    | 15.188.127.86:5000/api/products/find/:id | Fetch product by ID
**GET**    | 15.188.127.86:5000/metrics               | Display application metrics

---

## Monitoring Dashboard with Grafana
A monitoring dashboard is setup to track custom metrics on [Grafana](35.180.79.167:3000).
![grafana](https://user-images.githubusercontent.com/47459995/149982448-c79eece2-8288-448d-81d9-a229a9e9645d.png)
