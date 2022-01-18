const Product = require("../models/Product");

const router = require("express").Router();

router.post("/", async (req, res) => {
    try {
        const newProduct = await Product.create(req.body);
        res.status(200).json(newProduct);
    } catch (err) {
        console.log(err)
        res.status(500).json(err);
    }
});


//DELETE
router.delete("/:id", async (req, res) => {
    try {
        await Product.delete(req.params.id);
        res.status(200).json("Product has been deleted...");
    } catch (err) {
        console.log(err)
        res.status(500).json(err);
    }
});

//GET PRODUCT
router.get("/find/:id", async (req, res) => {
    try {

        const product = await Product.get(req.params.id);
        res.status(200).json(product);
    } catch (err) {
        console.log(err)

        res.status(500).json(err);
    }
});

//GET ALL PRODUCTS
router.get("/", async (req, res) => {
    try {
        const products = await Product.scan().exec()
        res.status(200).json(products);
    } catch (err) {
        console.log(err)
        res.status(500).json(err);
    }
});

module.exports = router;
