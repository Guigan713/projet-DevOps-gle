import React from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

const ButtonStyle = styled.div`
    margin-top: 2rem;
    .button {
    font-size: 2.2rem;
    font-family: 'Audiowide', cursive;
    background-color: ${(props) =>
        props.outline ? 'transparent' : '#C7D1DF'};
    padding: 0.7em 2em;
    border-radius: 8px;
    display: inline-block;
    border: 2px solid var(--gray-1);
    color: ${(props) => (props.outline ? 'var(--gray-1)' : 'black')};
    }
    @media only screen and (max-width: 768px) {
        .button {
        font-size: 1.8rem;
    }
    }
`;

function Button({ btnLink, btnText, outline }) {
return (
    <ButtonStyle outline={outline} className="button-wrapper">
        <Link className="button" to={btnLink}>
            {btnText}
        </Link>
    </ButtonStyle>
);
}

export default Button;