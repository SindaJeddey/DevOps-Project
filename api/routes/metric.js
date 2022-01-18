const client = require('prom-client');
const router = require("express").Router();

const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics({timeout: 5000});


const histogram = new client.Histogram({
    name: 'product_page_observation_second',
    help: 'Histogram for the duration in seconds of the product visualization and if they are purchased.',
    labelNames: ['productID', 'purchase'],
    buckets: [1, 2, 5, 6, 10]
});

//CREATE

router.post("/", async (req, res) => {
    //Simulate a sleep
    const {productID, duration, purchase} = req.body
    console.log(duration / 1000)
    histogram.observe({'productID': productID, 'purchase': purchase || 'false'}, duration / 1000)

    res.send('Done')
});
router.get('/', async (req, res) => {
    res.set('Content-Type', client.register.contentType)
    const metrics = await client.register.metrics()
    res.end(metrics)
});


module.exports = router;
