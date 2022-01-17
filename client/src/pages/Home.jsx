import React from "react";
import Announcement from "../components/Announcement";
import Categories from "../components/Categories";
import Navbar from "../components/Navbar";
import Products from "../components/Products";

const Home = () => {
  return (
    <div>
      <Announcement />
      <Navbar />
      <Categories />
      <Products/>
    </div>
  );
};

export default Home;
