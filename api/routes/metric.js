const client = require('prom-client');
const router = require("express").Router();

const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({ timeout: 5000 });

const counter = new client.Counter({
    name: 'node_request_operations_total',
    help: 'The total number of processed requests'
});

const histogram = new client.Histogram({
    name: 'node_request_duration_seconds',
    help: 'Histogram for the duration in seconds.',
    buckets: [1, 2, 5, 6, 10]
});

//CREATE

router.post("/", async (req, res) => {
    //Simulate a sleep
    var start = new Date()
    var simulateTime = 1000
    setTimeout(function(argument) {
        // execution time simulated with setTimeout function
        var end = new Date() - start
        histogram.observe(end / 1000); //convert to seconds
    }, simulateTime)
    counter.inc();
});
router.get('/', (req, res) => {
    res.set('Content-Type', client.register.contentType)
    res.end(client.register.metrics())
});


