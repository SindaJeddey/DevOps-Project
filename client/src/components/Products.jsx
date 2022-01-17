import { useEffect, useState } from "react";
import styled from "styled-components";
import { products } from "../data";
import Product from "./Product";
import axios from "axios";
import { PrintDisabled } from "@material-ui/icons";

const Container = styled.div`
  padding: 20px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
`;

const Products = ({ cat }) => {
  console.log(products);

  // useEffect(() => {
  //   const getProducts = async () => {
  //     try {
  //       const res = await axios.get(
  //         cat
  //           ? `http://localhost:5000/api/products?category=${cat}`
  //           : "http://localhost:5000/api/products"
  //       );
  //       setProducts(res.data);
  //     } catch (err) {}
  //   };
  //   getProducts();
  //   setProducts(products);
  // }, [cat]);

  return (
    <Container>
      {products
            .slice(0, 8)
            .map((item) => <Product item={item} key={item.id} />)}
    </Container>
  );
};

export default Products;
