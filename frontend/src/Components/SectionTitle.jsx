import React from 'react';

import './SectionTitle.css';

function SectionTitle({
    subheading = 'this is subheading',
    heading = 'this is heading',
}) {
    return (
        <div className="section-title">
            <p id="title-p">{subheading}</p>
            <h2 id="title-h2">{heading}</h2>
        </div>
    )
}

export default SectionTitle
