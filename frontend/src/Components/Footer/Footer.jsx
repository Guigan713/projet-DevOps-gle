import React from 'react';
import FooterCol from './FooterCol';
import {
    AiOutlineFacebook,
    AiOutlineInstagram,
    AiOutlineTwitter,
} from 'react-icons/ai';

import './Footer.css';

function Footer() {
    return (
        <div className="footer-wrapper">
            <div className="footer-container">
                <div className="footer-col1">
                    <h1 className="footer-col1-title">Guigan713</h1>
                    <p className="footer-title-p">
                        Hit me up!
                    </p>
                    <p className="footer-col1-text">
                        guillaume.lequin713@gmail.com
                    </p>
                </div>
                <div className="footer-col2">
                    <FooterCol
                        heading= "Links"
                        links={[
                            {
                                title: "HomePage",
                                path: '/',
                                type: 'Link',
                            },
                            {
                                title: "About Me",
                                path: '/about',
                                type: 'Link',
                            },
                            {
                                title: "My Pics",
                                path: '/mypics',
                                type: 'Link',
                            },
                            {
                                title: "Contact",
                                path: '/contact',
                                type: 'Link',
                            }
                        ]}
                    />
                </div>
                <div className="footer-col3">
                    <h2 className="footer-col3-title">Social Links</h2>
                    <ul className="footer-ul">
                        <li className="footer-li">
                            <a 
                                href="https://www.facebook.com/riley.macfadden" 
                                className="footer-fb"
                                target="_blank"
                                rel="noreferrer"
                            >
                                <AiOutlineFacebook />
                            </a>
                        </li>
                        <li className="footer-li">
                            <a 
                                href="https://www.instagram.com/Guigan713" 
                                className="footer-insta"
                                target="_blank"
                                rel="noreferrer"
                            >
                                <AiOutlineInstagram />
                            </a>
                        </li>
                        <li className="footer-li">
                            <a 
                                href="https://www.twitter.com/Guigan713" 
                                className="footer-twitter"
                                target="_blank"
                                rel="noreferrer"
                            >
                                <AiOutlineTwitter />
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
            {/* <div className="copyright">
                <div className="copyright-container">
                    <p className="copyright-text">
                        Design inspired By Ayan Kahn
                    </p>
                </div>
            </div> */}
        </div>
    )
}

export default Footer
