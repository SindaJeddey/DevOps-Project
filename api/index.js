const express = require("express");
const app = express();
const dotenv = require("dotenv");
dotenv.config();
const productRoute = require("./routes/product");
const metricRoute = require("./routes/metric");
const cors = require("cors");

app.use(cors());
app.use(express.json());
app.use("/api/products", productRoute);
app.use("/metrics", metricRoute);

app.listen(process.env.PORT || 5000, () => {
  console.log("Backend server is running!");
});
