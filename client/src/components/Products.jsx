import { useEffect, useState } from "react";
import styled from "styled-components";
import Product from "./Product";
import axios from "axios";

const baseUrl = '15.188.127.86:5000'

const Container = styled.div`
  padding: 20px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
`;

const Products = ({ cat }) => {
  const [products, setProducts] = useState([])

  useEffect(() => {
    axios.get("http://"+baseUrl+"/api/products")
        .then(res => { setProducts(res.data) })
        .catch(err => console.log(err));
  }, [cat]);

  return (
    <Container>
      {products
            .slice(0, 8)
            .map((item) => <Product item={item} key={item.id} />)}
    </Container>
  );
};

export default Products;
