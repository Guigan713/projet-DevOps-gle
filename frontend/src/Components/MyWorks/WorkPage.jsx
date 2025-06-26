import React from 'react';

import './WorkPage.css';

// const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000"
const API_URL = window._env_?.API_URL || "http://localhost:5000";

function WorkPage({snap}) {
    return (
        <div className="workpage-container">
            <img
                className="workpage-img"
                src={`${API_URL}/images/${snap.shoe_img}`}
                alt="pics"
            />
            <div className="workpage-item-info">
                <h3 className="workpage-item-brand">{snap.shoe_brand}</h3>
                <h4 className="workpage-item-title">{snap.shoe_name}</h4>
                <p className="workpage-item-p">Photographer: {snap.photographer}</p>
                <p className="workpage-item-m">Model: {snap.model}</p>
            </div>
        </div>
    )
}

export default WorkPage
