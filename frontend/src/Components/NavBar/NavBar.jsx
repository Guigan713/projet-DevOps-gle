import { React, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { MdMenu, MdClose} from 'react-icons/md';

import './NavBar.css';

function NavBar() {
    const [showNav, SetShowNav] = useState(false);
    return (
        <div className="nav-container">
            <div 
                className="mobile-menu-icon"
                onClick={() => SetShowNav(!showNav)}
                role="button"
                onKeyDown={() => SetShowNav(!showNav)}
                tabIndex={0}
            >
                <MdMenu />
            </div>
            <ul className={!showNav ? 'navItems hide-item' : 'navItems'}>
                <div 
                    className="close-nav-icon"
                    onClick={() => SetShowNav(!showNav)}
                    role="button"
                    onKeyDown={() => SetShowNav(!showNav)}
                    tabIndex={0}
                >
                    <MdClose />
                </div>
                <li className="li-nav">
                    <NavLink 
                        className="titles"
                        to="/"
                        exact
                        onClick={() => SetShowNav(!showNav)}
                        role="button"
                        onKeyDown={() => SetShowNav(!showNav)}
                        tabIndex={0}
                    >
                        Home
                    </NavLink>
                </li>
                <li className="li-nav">
                    <NavLink
                        className="titles"
                        to="/about"
                        onClick={() => SetShowNav(!showNav)}
                        role="button"
                        onKeyDown={() => SetShowNav(!showNav)}
                        tabIndex={0}
                    >
                        About
                    </NavLink>
                </li>
                <li className="li-nav">
                    <NavLink
                        className="titles"
                        to="/mypics"
                        onClick={() => SetShowNav(!showNav)}
                        role="button"
                        onKeyDown={() => SetShowNav(!showNav)}
                        tabIndex={0}
                    >
                        My Pics
                    </NavLink>
                </li>
                <li className="li-nav">
                    <NavLink
                        className="titles"
                        to="/contact"
                        onClick={() => SetShowNav(!showNav)}
                        role="button"
                        onKeyDown={() => SetShowNav(!showNav)}
                        tabIndex={0}
                    >
                        Contact
                    </NavLink>
                </li>
            </ul>
        </div>
    )
}

export default NavBar
