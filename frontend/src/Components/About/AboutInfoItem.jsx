import React from 'react';
import Ptext from '../Ptext';

import './AboutInfoItem.css'

function AboutInfoItem({ title = 'title', items =['', ''] }) {
    return (
        <div className="about-info-item-wrapper">
            <h1 className="about-info-title">{title}</h1>
            <div className="about-info-items-items">
                {items.map((item, index) => (
                    <div className="about-items-item" key={index}>
                        <Ptext>{item}</Ptext>
                    </div>
                ))}
            </div>
        </div>
    )
}

export default AboutInfoItem
