import React from 'react';
import AboutSection from '../About/AboutSection';
import ContactBanner from '../Contact/ContactBanner';
import HomeSection from '../Home/HomeSection';
import MyWorksSection from '../MyWorks/MyWorksSection';

function Home() {
    return (
        <div>
            <HomeSection />
            <AboutSection />
            <MyWorksSection />
            <ContactBanner />
        </div>
    )
}

export default Home
