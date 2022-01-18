import { useEffect, useState } from "react";
import styled from "styled-components";
import Product from "./Product";
import axios from "axios";

const Container = styled.div`
  padding: 20px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
`;

const Products = ({ cat }) => {
  const [products, setProducts] = useState([])

  useEffect(() => {
    axios.get("http://13.37.222.37:5000/api/products")
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
