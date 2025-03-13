import React, { useState } from 'react';
// import axios from 'axios';

import './ContactForm.css';


function ContactForm() {
    const [status, setStatus] = useState('Submit')
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [message, setMessage] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
		setStatus('Sending...')
        const { name, email, message } = e.target.elements;
        let details = {
            name: name.value,
            email: email.value,
            message: message.value,
        };
		let response = await fetch("http://localhost:4000/contact", {
            method: "POST",
            headers: { 'Content-Type': 'application/json;charset=utf-8',
            },
            body: JSON.stringify(details),
        });
        setStatus('Submit');
        let result = await response.json();
        alert(result.status);
	}
    return (
        <>
            <div className="contact-form-container">
                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label htmlFor="name" className="form-name">
                            Your Name
                            <input
                                type="text"
                                id="name"
                                name="name"
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                            />
                        </label>
                    </div>
                    <div className="form-group">
                        <label htmlFor="email" className="form-name">
                            Your Email
                            <input
                                type="text"
                                id="email"
                                email="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                            />
                        </label>
                    </div>
                    <div className="form-group">
                        <label htmlFor="message" className="form-name">
                            Your Message
                            <textarea
                                type="text"
                                id="message"
                                message="message"
                                value={message}
                                onChange={(e) => setMessage(e.target.value)}
                            />
                        </label>
                    </div>
                        <button type="submit">{status}</button>
                </form>
            </div>
        </>
    )
}

export default ContactForm
