import React from 'react';
import axios from 'axios';
import ContactBanner from '../Contact/ContactBanner';
import { useState, useEffect } from 'react';
import SectionTitle from '../SectionTitle';

import './About.css';

function About() {
    const [aboutme, setAboutMe] = useState([])
    useEffect(() => {
        const getAboutMe = () => {
            axios
                .get(`${process.env.REACT_APP_URL_API}/aboutme`)
                .then(res => setAboutMe(res.data[0]))
        }
        getAboutMe()
    },[])
    return (
        <div className="about-general">
            <div className="aboutme-container">
                <SectionTitle 
                    heading="About Me"
                    subheading=""
                />
                <div className="aboutme-top-section">
                    <div className="aboutme-left">
                        <p className="aboutme-subheading">
                            I am <span className="aboutme-span">Guigan</span>
                        </p>
                        <h2 className="aboutme-heading">Sneaker collector and photographer</h2>
                        <div className="aboutme-infos">
                            <p className="aboutme-text">
                                I come From a Small city in the heart of Burgundy, France.
                                I collect Sneakers since High School so around 2004-2005. 
                                I used to collect every kinds of brands and silhouette but since 2015,
                                most of my collection is Asics Gel Lyte 3 or GT-2. I still have some other brands
                                like Nike, New Balance or Adidas.
                                <br />
                                <br />
                                I also have a passion for photography, so I mix it with sneakers. You can find here
                                pictures of Sneakers made with friends that share the same love for Sneakers and Photography.
                                Enjoy the visit here and don't hesitate to contact me if you want to shoot your favorite Sneakers.
                            </p>
                        </div>
                    </div>
                    <div className="aboutme-right">
                        <img 
                            className="aboutme-img"
                            src={`${process.env.REACT_APP_URL_API}/images/${aboutme.aboutme_img}`} 
                            alt="aboutme"
                        />
                    </div>
                </div>
            </div>
            <ContactBanner />
        </div>
    )
}

export default About
