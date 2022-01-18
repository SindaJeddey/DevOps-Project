const client = require('prom-client');
const router = require("express").Router();

const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({timeout: 5000});

const counter = new client.Counter({
    name: 'product_purchase_total',
    help: 'The total number of purchased products'
});

const histogram = new client.Histogram({
    name: 'product_page_observation_second',
    help: 'Histogram for the duration in seconds of the .',
    buckets: [1, 2, 5, 6, 10]
});

//CREATE

router.post("/", async (req, res) => {
    //Simulate a sleep
    var start = new Date()
    var simulateTime = 1000
    await setTimeout(function (argument) {
        // execution time simulated with setTimeout function
        var end = new Date() - start
        histogram.observe(end / 1000); //convert to seconds
    }, simulateTime)
    counter.inc();
    res.send('Done')
});
router.get('/', async(req, res) =>  {
    res.set('Content-Type', client.register.contentType)
    const metrics = await client.register.metrics()
    res.end(metrics)
});


module.exports = router;
