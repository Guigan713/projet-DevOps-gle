import React from 'react';
import Button from '../Button';

import './ContactBanner.css';

function ContactBanner() {
    return (
        <div className="contact-banner-wrapper">
            <div className="contact-banner-container">
                <div className="banner-wrapper">
                    <p className="banner-p">Wanna go shoot some pairs?</p>
                    <h3 className="contact-banner-heading">Let's talk</h3>
                    <Button btnText="Contact Me" btnLink="/contact" />
                </div>
            </div>
        </div>
    )
}

export default ContactBanner
