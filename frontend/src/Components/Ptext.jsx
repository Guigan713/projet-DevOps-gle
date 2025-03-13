import React from 'react';

import './Ptext.css';

function Ptext({ children }) {
    return (
        <div className="p-text-container">
            <p>{children}</p>
        </div>
    )
}

export default Ptext
