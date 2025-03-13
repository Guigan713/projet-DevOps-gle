import React from 'react'
import Lost from '../images/lost.png'
import Button from '../Components/Button'

import './error404.css'

function error404() {
    return (
        <div className="error-container">
            <h2 className="error-title">Oops!!</h2>
            <p className="error-text">404 - Page not found!</p>
            <img src={Lost} alt="lost" className="lost-img" />
            <Button btnLink="/" btnText="Take me to homepage" className="error-btn"></Button>
            <div className="fill-up"></div>
        </div>
    )
}

export default error404
