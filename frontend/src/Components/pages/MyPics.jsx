import React, { useState, useEffect } from 'react';
import axios from 'axios';
import MyWorks from '../MyWorks/MyWorks'

import './MyPics.css'


function MyPics() {
    const [pics, setPics] = useState([]);
    useEffect(() => {
        const getPics = () => {
            axios
            .get(`${process.env.REACT_APP_URL_API}/pics`)
            .then(res => setPics(res.data))
        }
        getPics()
    },[])

    return (
        <div className="mypics-wrapper">
            <div className="mypics-container">
                <h2 className="mypics-title">My most recent Sneaker Snapshots</h2>
                <h3 className="mypics-heading">My Pictures</h3>
            </div>
                <div className="mypics-allitems">
                    {pics.map((pic, index) => {
                        return (
                            <MyWorks key={pic.id}
                                pic ={pic}
                            />
                        )
                    })}
                </div>
        </div>
    )
}

export default MyPics
