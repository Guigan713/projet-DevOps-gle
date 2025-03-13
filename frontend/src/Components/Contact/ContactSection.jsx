import React from 'react';
import { MdEmail } from 'react-icons/md';
import ContactInfoItem from './ContactInfoItem';
import ContactForm from './ContactForm';
// import SectionTitle from '../SectionTitle';

import './ContactSection.css';

function ContactSection() {
    return (
        <div className="contact-section-general">
            <div className="contact-container">
                <h1 className="contact-heading">Contact</h1>
                <div className="contact-section-wrapper">
                    <div className="left">
                        <ContactInfoItem
                            icon={<MdEmail />} 
                            text="guillaume.lequin713@gmail.com" />
                        <ContactInfoItem text="Burgundy, France" />
                    </div>
                    <div className="right">
                        <ContactForm />
                    </div>
                </div>
            </div>
        </div>
    )
}

export default ContactSection
