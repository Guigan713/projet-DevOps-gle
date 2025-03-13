import React from 'react';
import axios from 'axios';
import { Swiper, SwiperSlide } from 'swiper/react';
import SwiperCore, { Navigation } from 'swiper';
import MyWorks from './MyWorks';
import SectionTitle from '../SectionTitle';
import 'swiper/swiper-bundle.min.css';
import { useState, useEffect } from 'react'

import './MyWorksSection.css';

SwiperCore.use([Navigation]);

function MyWorksSection() {
    const [pics, setPics] = useState([])
    useEffect(() => {
        const getPics = () => {
            axios
            .get(`${process.env.REACT_APP_URL_API}/pics`)
            .then(res => setPics(res.data))
        }
        getPics()
    },[])
    return (
        <div className="myworks-section-wrapper">
            <div className="myworks-section-container">
                <SectionTitle heading="My Pics" subheading="My recent Pictures" />
                <div className="myworks-section-items-all">
                    <Swiper
                        spaceBetween={30}
                        slidesPerView={1}
                        navigation
                        breakpoints={{
                            // when window width is >= 640px
                            640: {
                                slidesPerView: 1,
                            },
                            // when window width is >= 768px
                            768: {
                                slidesPerView: 2,
                            },
                            // when window width is >= 1200px
                            1200: {
                                slidesPerView: 3,
                            },
                        }}
                    >
                        {pics.map((pic, index) => {
                            // eslint-disable-next-line array-callback-return
                            if (index >= 10);
                            return (
                                <SwiperSlide key={pic.id}>
                                    <MyWorks 
                                        pic = {pic}
                                    />
                                </SwiperSlide>
                            )
                        })}
                    </Swiper>
                </div>
            </div>
        </div>
    )
}

export default MyWorksSection
