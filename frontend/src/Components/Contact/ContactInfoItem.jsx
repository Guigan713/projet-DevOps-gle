import React from 'react';
import { MdPlace } from 'react-icons/md';
import Ptext from '../Ptext';

import './ContactInfoItem.css';


export default function ContactInfoItem({
    icon = <MdPlace />,
    text = 'I need text ',
}) {
    return (
        <div className="contact-info-wrapper">
            <div className="icon">{icon}</div>
            <div className="info">
                <Ptext>{text}</Ptext>
            </div>
        </div>
    );
}