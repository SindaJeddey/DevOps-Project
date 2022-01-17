const dynamoose = require("dynamoose");

// Create new DynamoDB instance
const ddb = new dynamoose.aws.sdk.DynamoDB({
    "region": process.env.region,
    "profile": "sandbox"
});

// Set DynamoDB instance to the Dynamoose DDB instance
dynamoose.aws.ddb.set(ddb);

const ProductSchema = new dynamoose.Schema(
    {
        id: {type: String},
        title: {type: String},
        desc: {type: String},
        img: {type: String},
        price: {type: Number},
        inStock: {type: Boolean},
    },
    {timestamps: true}
);

module.exports = dynamoose.model("Product", ProductSchema);
