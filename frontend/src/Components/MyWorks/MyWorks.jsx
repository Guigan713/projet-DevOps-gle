import React from 'react';
import { Link } from 'react-router-dom';

import './MyWorks.css'

// const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000"
const API_URL = window._env_?.API_URL || "http://localhost:5000";

function MyWorks({ pic }) {

    return (
        <div className="my-works-container">
            <Link to="/mypics" className="myworks-item-img">
                <img
                    className="works-img"
                    src={`${API_URL}/api/images/${pic.shoe_img}`}
                    alt="pics"
                />
            </Link>
            <div className="myworks-item-info">
                <Link to="#">
                    <h3 className="myworks-item-brand">{pic.shoe_brand}</h3>
                    <h4 className="myworks-item-title">{pic.shoe_name}</h4>
                </Link>
                    <p className="myworks-item-p">Photographer: {pic.photographer}</p>
                    <p className="myworks-item-m">Model: {pic.model}</p>
            </div>
        </div>
    )
}

export default MyWorks
