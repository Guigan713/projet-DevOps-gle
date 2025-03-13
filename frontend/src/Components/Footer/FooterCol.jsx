import React from 'react';
import { Link } from 'react-router-dom';

import './FooterCol.css'

function FooterCol({
    heading = 'Col Heading',
    links = [
        {
            type: 'Link',
            title: 'Home',
            path: '/home',
        },
        {
            type: 'Link',
            title: 'About',
            path: '/about',
        },
    ],
}) {
    return (
        <div className="footercol-container">
            <h2 className="footercol-heading">{heading}</h2>
            <ul className="footercol-ul">
                {links.map((item, index) => (
                    <li className="footercol-li" key={index}>
                        {item.type === 'Link' ? (
                            <Link className="footercol-link" to={item.path}>{item.title}</Link>
                        ) : (
                            <a className="footercol-a" href={item.path} target="_blank" rel="noreferrer">
                                {item.title}
                            </a>
                        )}
                    </li>
                ))}
            </ul>
        </div>
    )
}

export default FooterCol
