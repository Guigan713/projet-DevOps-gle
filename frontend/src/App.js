import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import About from './Components/pages/About'
import Contact from './Components/pages/Contact'
import Home from './Components/pages/Home';
import MyPics from './Components/pages/MyPics';
import NavBar from './Components/NavBar/NavBar';
import Footer from './Components/Footer/Footer';
import ScrollToTop from './Components/ScrollToTop'
import './App.css';

function App() {
  return (
    <div className="App">
      <Router>
        <NavBar />
        <ScrollToTop />
        <Routes>
          <Route exact path='/' element={<Home/>}/>
          <Route path="/about" element={<About/>}/>
          <Route path="/mypics" element={<MyPics/>}/>
          <Route path="/contact" element={<Contact/>}/>
        </Routes>
        <Footer />
      </Router>
    </div>
  );
}

export default App;
