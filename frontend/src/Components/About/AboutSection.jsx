import React from 'react';
import axios from 'axios';
import Button from '../Button';
import { useState, useEffect } from 'react';

import './AboutSection.css';

// const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000"
const API_URL = window._env_?.API_URL || "http://localhost:5000";

function AboutSection() {
    const [about, setAbout] = useState([])
    useEffect(() => {
        const getAbout = () => {
            axios
            .get(`${API_URL}/about`)
            .then(res => setAbout(res.data[0]))
        }
        getAbout()
    },[])
    return (
        <div className="about-general">
            <div className="about-container">
                <div className="about-section-left">
                    <div className="about-section-title">
                        <h1 className="about-section-subheading">Let Me introduce Myself</h1>
                        <p className="about-section-heading">About Me</p>
                    </div>
                    <p className="about-desc">
                        My name is Guillaume, a.k.a Guigan. I am a French Sneaker Collector from France.
                        I mostly collect Asics but i do have some other brands as Nike or New Balance. 
                        When i'm not coding, I spend my time with my Sneaker Friends from all over the world 
                        taking sneaker pictures. You are very welcome to see my works on this page. Enjoy your visit
                        and don't hesitate to contact me if you have any questions or if you want some dope sneaker pics.
                    </p>
                    <div className="about-section-buttons">
                        <Button btnLink="/mypics" btnText="Sneaker Snaps" />
                        <Button btnLink="/about" btnText="know more about me" />
                    </div>
                </div>
                <div className="about-section-right">
                    <img 
                        className="about-img"
                        src={`${API_URL}/images/${about.about_img}`}
                        alt="aboutpic"
                    />
                </div>
            </div>
        </div>
    )
}

export default AboutSection
