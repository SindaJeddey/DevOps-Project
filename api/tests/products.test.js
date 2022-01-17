const express = require("express"); // import express
const request = require("supertest"); // supertest is a framework that allows to easily test web apis
const app = express(); //an instance of an express app, a 'fake' express app
const dotenv = require("dotenv");
dotenv.config();
const AWS = require('aws-sdk-mock');

AWS.mock('DynamoDB', 'scan', function (params, callback) {
    callback(null, {
        'Items': [
            {
                "id": "khaled",
                "price": 1500,
                "title": "The Best"
            },
            {
                "id": "sinda",
                "price": 0,
                "title": "The Worst"
            }
        ]
    });
});
AWS.mock('DynamoDB', 'getItem', {
    'Item': {
        "id": "sinda",
        "price": 500,
        "title": "The Best"
    }
});
const productRoutes = require("../routes/product"); //import file we are testing
app.use("/api/products", productRoutes); //routes
describe("testing-products-routes", () => {
    it("GET All products - success", async () => {
        const {body} = await request(app).get("/api/products"); //uses the request function that calls on express app instance
        expect(body).toEqual([
            {
                "id": "khaled",
                "price": 1500,
                "title": "The Best"
            },
            {
                "id": "sinda",
                "price": 0,
                "title": "The Worst"
            }
        ]);
    })
    it("GET one product with success", async () => {
        const {body} = await request(app).get("/api/products/find/sinda"); //uses the request function that calls on express app instance
        expect(body).toEqual({
            "id": "sinda",
            "price": 500,
            "title": "The Best"
        });
    })
})