const express = require("express"); // import express
const productRoutes = require("../routes/product"); //import file we are testing
const request = require("supertest"); // supertest is a framework that allows to easily test web apis
const app = express(); //an instance of an express app, a 'fake' express app
app.use("/api/products", productRoutes); //routes
const AWS = require('aws-sdk-mock');

AWS.mock('DynamoDB', 'putItem', function (params, callback){
    callback(null, 'successfully put item in database');
});

describe("testing-products-routes", () => {
    it("GET / - success", async () => {
        const {body} = await request(app).get("/"); //uses the request function that calls on express app instance
        expect(body).toEqual([
            {
                state: "NJ",
                capital: "Trenton",
                governor: "Phil Murphy",
            },
            {
                state: "CT",
                capital: "Hartford",
                governor: "Ned Lamont",
            },
            {
                state: "NY",
                capital: "Albany",
                governor: "Andrew Cuomo",
            },
        ]);
    })
})