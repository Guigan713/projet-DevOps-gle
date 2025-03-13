import React from 'react';

import './WorkPage.css';

function WorkPage({snap}) {
    return (
        <div className="workpage-container">
            <img
                className="workpage-img"
                src={`${process.env.REACT_APP_URL_API}/images/${snap.shoe_img}`}
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
