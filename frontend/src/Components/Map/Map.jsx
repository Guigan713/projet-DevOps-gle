import React from 'react';
import styled from 'styled-components';
import MapImg from '../../images/mapimg.png';
// import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet'

const MapStyles = styled.div`
    background: url(${MapImg}) no-repeat;
    background-position: center;
    background-size: 90%;
    min-height: 400px;
    margin-bottom: 30px;
.container {
    position: relative;
    min-height: 400px;
}
.map-card {
    position: absolute;
    right: 10%;
    bottom: 10%;
    padding: 2rem;
    background: var(--deep-dark);
    width: 100%;
    max-width: 300px;
    border-radius: 12px;
    a {
        font-size: 2rem;
        color: #4a89f3;
    }
}
.map-card-heading {
    font-size: 3rem;
    margin-bottom: 1rem;
    color: #1ea362;
    font-family: 'Russo One', sans-serif;
}

.map-card-p {
    /* color: #ffe047; */
    font-size: 2rem;
    background: -webkit-linear-gradient(#d3d3d3, #ffe047);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-family: 'Architects Daughter', cursive;
}
.map-card-link {
    display: inline-block;
    font-size: 1.8rem;
    margin-top: 3rem;
    text-decoration: underline;
    font-family: 'Orbitron', sans-serif;
}
@media only screen and (max-width: 768px) {
    background-position: 80% center;
}
@media only screen and (max-width: 400px) {
    .map-card {
        max-width: none;
        right: auto;
    }
}
`;

function Map() {
    // const position = [46.6742744446, 4.36339521408]

    return (
        <MapStyles>
            <div className="container">
                <div id="map">

                </div>
                {/* <MapContainer
                    center={position}
                    zoom={13}
                    scrollWheelZoom={false}
                    style={{
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        width: '100%',
                        height: '100%',
                        boxShadow: '1px 1px 2px rgba(107, 107, 107, 0.9)'
                    }}
                >
                <TileLayer
                    attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                    url='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
                />
                <Marker position={position}>
                    <Popup>
                        A pretty CSS3 popup. <br /> Easily customizable.
                    </Popup>
                </Marker>
                </MapContainer> */}
                    <div className="map-card">
                        {/* <h3 className="map-card-heading">Here i am</h3> */}
                        <p className="map-card-p">Montceau Les Mines, Bourgogne, France</p>
                        <a
                            className="map-card-link"
                            href="https://www.google.fr/maps/@46.6714624,4.358144,14z"
                            target="_blank"
                            rel="noreferrer"
                        >
                        Ouvrir Google Maps
                        </a>
                    </div>
            </div>
        </MapStyles>
    );
}

export default Map;