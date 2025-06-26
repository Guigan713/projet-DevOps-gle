import axios from 'axios';
import React from 'react';
import {
    AiOutlineFacebook,
    AiOutlineInstagram,
    AiFillTwitterSquare,
    AiOutlineLinkedin,
    AiOutlineGithub,
} from 'react-icons/ai';
import SocialMediaArrow from '../../images/social-media-arrow.svg'
import { useState, useEffect } from 'react';

import './HomeSection.css'

// const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000"
const API_URL = window._env_?.API_URL || "http://localhost:5000";

function HomeSection() {
    console.log("HomeSection chargé !");
    const [, setPics] = useState([])
    const [home, setHome] = useState([])
    useEffect(() => {
        const getPics = () => {
            axios
            .get(`${API_URL}/pics`)
            .then(res => setPics(res.data))
        }
        getPics()
    },[])
    useEffect(() => {
        const getHome = () => {
            axios
                .get(`${API_URL}/home`)
                // .then(res => setHome(res.data[0]))
                .then(res => {
                    if (res.data[0] && res.data[0].home_img) {
                        setHome(res.data[0]);
                    } else {
                        setHome({ ...res.data[0], home_img: 'Guigan.jpg' }); // image par défaut
                    }
                });
        }
        getHome()
    },[])

    console.log("API_URL=", API_URL)
    console.log('home=', home);
    console.log('home.home_img=', home.home_img);

    return (
        <div className="home-section">
            <div className="home">
                <div className="container">
                    <h1 className="home-heading">
                        <span className="home-hello">{home.hello_title}</span>
                        <span className="home-name">{home.gui_title}</span>
                    </h1>
                    <div className="home-img">
                        {/* <img src={`${API_URL}/images/${home.home_img}`}
                        alt="homepic"
                        /> */}
                        {home.home_img && (
                            <img
                                src={`${API_URL}/images/${home.home_img}`}
                                alt="homepic"
                            />
                        )}
                    </div>
                    <div className="home-infos">
                        <p>
                            Welcome To My Sneakers Portfolio
                        </p>
                    </div>
                    <div className="home-social">
                        <div className="home-social-indicator">
                            <p id="social-arrow">Follow</p>
                            <img className="arrow" src={SocialMediaArrow} alt="arrow" />
                        </div>
                        <div className="home-social-text">
                            <ul className="ul">
                                <li className="li">
                                    <a
                                        className="logo-fb"
                                        href="https://www.facebook.com/riley.macfadden"
                                        target="_blank"
                                        rel="noreferrer"
                                    >
                                    <AiOutlineFacebook />
                                    </a>
                                </li>
                                <li className="li">
                                    <a
                                        className="logo-insta"
                                        href="https://www.instagram.com/Guigan713"
                                        target="_blank"
                                        rel="noreferrer"
                                    >
                                    <AiOutlineInstagram />
                                    </a>
                                </li>
                                <li className="li">
                                    <a
                                        className="logo-twitter"
                                        href="https://www.twitter.com/Guigan713"
                                        target="_blank"
                                        rel="noreferrer"
                                    >
                                    <AiFillTwitterSquare />
                                    </a>
                                </li>
                                <li className="li">
                                    <a
                                        className="logo-git"
                                        href="https://www.github.com/Guigan713"
                                        target="_blank"
                                        rel="noreferrer"
                                    >
                                    <AiOutlineGithub />
                                    </a>
                                </li>
                                <li className="li">
                                    <a
                                        className="logo-linkedin"
                                        href="https://www.linkedin.com/in/guillaume-lequin/"
                                        target="_blank"
                                        rel="noreferrer"
                                    >
                                    <AiOutlineLinkedin />
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default HomeSection
