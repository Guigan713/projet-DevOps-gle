import React from 'react';
import { Link } from 'react-router-dom';


import './MyWorks.css'

function MyWorks({ pic }) {

    return (
        <div className="my-works-container">
            <Link to="/mypics" className="myworks-item-img">
                <img
                    className="works-img"
                    src={`${process.env.REACT_APP_URL_API}/images/${pic.shoe_img}`}
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
