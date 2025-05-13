CREATE TABLE about (
    id INT AUTO_INCREMENT PRIMARY KEY,
    about_img TEXT NOT NULL
);

INSERT INTO about (about_img) VALUES ('/Guigan.jpg');

CREATE TABLE aboutme (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aboutme_img TEXT NOT NULL
);

INSERT INTO aboutme (aboutme_img) VALUES ('Guigan.jpg');

CREATE TABLE home (
    id INT AUTO_INCREMENT PRIMARY KEY,
    home_img TEXT NOT NULL,
    hello_title VARCHAR(255) NOT NULL,
    gui_title VARCHAR(255) NOT NULL
);

INSERT INTO home (home_img, hello_title, gui_title) VALUES ('ct2.jpg', 'Sneaker Portfolio', 'Guigan713');


CREATE TABLE pics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shoe_name VARCHAR(255) NOT NULL,
    shoe_brand VARCHAR(255) NOT NULL,
    photographer VARCHAR(255),
    model VARCHAR(255),
    shoe_img TEXT
);

INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte Speed San Fermin Sample', 'Asics', 'Guigan713', 'Guigan713', '24kts2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 252 Sample', 'Asics', 'Guigan713', 'Guigan713', '252s3.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Alvin Purple Sample', 'Asics', 'Anthonysuz', 'Guigan713', 'alvin1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 A.R.C Pigeon', 'Asics', 'AlexisTrch', 'Guigan713', 'arc1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('1500 BFR BlackBeard', 'New Balance', 'Anthonysuz', 'Guigan713', 'bfr4.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Blueberry', 'Asics', 'AlexisTrch', 'Guigan713', 'blueberryBridge.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Blue Sample', 'Asics', 'AlexisTrch', 'Guigan713', 'blueSample.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('GT 2 Brick Sample', 'Asics', 'AlexisTrch', 'Guigan713', 'bricks.jpg');

INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Cervidae Sample', 'Asics', 'Guigan713', 'Guigan713', 'cervidae1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 CultureShoq 1', 'Asics', 'Tcoolkicks', 'Guigan713', 'cs1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 CultureShoq 2', 'Asics', 'AlexisTrch', 'Guigan713', 'cs2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Crooked Tongue Sample', 'Asics', 'AlexisTrch', 'Guigan713', 'ct1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 A.R.C Curry', 'Asics', 'Guigan713', 'Guigan713', 'curry4.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 LaMjc', 'Asics', 'Tcoolkicks', 'Guigan713', 'LaMjc2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Mint', 'Asics', 'Guigan713', 'Guigan713', 'mint2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Mita Blueberry', 'Asics', 'AlexisTrch', 'Guigan713', 'mita1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 HAL Mortar', 'Asics', 'AlexisTrch', 'Guigan713', 'mortar.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Solefly Nighthaven', 'Asics', 'Guigan713', 'Guigan713', 'nighthaven2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Nicekicks 1.0', 'Asics', 'Guigan713', 'Guigan713', 'nk13.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Nicekicks 2.0', 'Asics', 'Guigan713', 'Guigan713', 'nk24.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Nicekicks 1.0', 'Asics', 'Guigan713', 'Guigan713', 'nk25.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Patta Coat of arms', 'Asics', 'AlexisTrch', 'Guigan713', 'patta1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Patta Coat of arms', 'Asics', 'AlexisTrch', 'Guigan713', 'patta2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 PATTA GR', 'Asics', 'Guigan713', 'Tcoolkicks', 'pattaex.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte Respector Sample', 'Asics', 'Sham Nizam', 'Guigan713', 'respector1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte Respector Sample', 'Asics', 'Sham Nizam', 'Guigan713', 'respector2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Salmon Toe', 'Asics', 'Guigan713', 'Guigan713', 'salmon3.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Solebox Carpenter bee Sample', 'Asics', 'AlexisTrch', 'Guigan713', 'sb1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Solebox Carpenter bee Sample', 'Asics', 'AlexisTrch', 'Guigan713', 'sb2.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Super Blue Sample', 'Asics', 'Tcoolkicks', 'Guigan713', 'sbs1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Slamjam 5th Dimension', 'Asics', 'Guigan713', 'Guigan713', 'sj5th.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Kith Super red', 'Asics', 'Sham Nizam', 'Guigan713', 'sr1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Kith Super red', 'Asics', 'AlexisTrch', 'Guigan713', 'sr3.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Woei Vintage Nylon', 'Asics', 'Guigan713', 'Guigan713', 'vintage1.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Woei Vintage Nylon', 'Asics', 'Guigan713', 'Guigan713', 'vintage3.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Woei Vintage Nylon', 'Asics', 'Guigan713', 'Guigan713', 'vintage4.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Woei Vintage Nylon', 'Asics', 'Guigan713', 'Tcoolkicks', 'vintagewoei.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Hanon Wildcats', 'Asics', 'Guigan713', 'Guigan713', 'wildcats3.jpg');
INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES ('Gel Lyte 3 Cervidae Sample', 'Asics', 'Guigan713', 'Guigan713', 'woei4.jpg');

CREATE TABLE snaps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shoe_name VARCHAR(255) NOT NULL,
    shoe_brand VARCHAR(255) NOT NULL,
    photographer VARCHAR(255),
    model VARCHAR(255),
    shoe_img TEXT
);
