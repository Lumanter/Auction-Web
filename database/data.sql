INSERT INTO AuctionParameter (improvementPercent, minIncrement, date) VALUES
(0.05, 5000, NOW());

INSERT INTO Category (name) VALUES
('Antigüedades'), ('Arte'), ('Bebés'), ('Libros'), ('Equipo y maquinaria industrial'), ('Cámaras y fotografía'), 
('Teléfonos celulares y accesorios'), ('Ropa, zapatos y accesorios'), ('Monedas y billetes'), ('Artículos de colección'), 
('Computadoras, tablets y redes'), ('Artículos electrónicos'), ('Artesanías'), ('Muñecas y osos'), ('Películas y DVD'), 
('Vehículos'), ('Memorabilia de entretenimiento'), ('Tarjetas de regalo y cupones'), ('Belleza y salud'), ('Casa y jardín'), 
('Joyería y relojes'), ('Música'), ('Instrumentos y equipos musicales'), ('Productos para mascotas'), ('Cerámica y vidrio'), 
('Bienes raíces'), ('Servicios especiales'), ('Artículos deportivos'), ('Memorabilia de deporte, tarjetas, fans'), ('Estampillas'), 
('Boletos y experiencias'), ('Juguetes y pasatiempos'), ('Viaje'), ('Videojuegos y consolas'), ('Todo lo demás');

INSERT INTO SubCategory (categoryId, name) VALUES
(1, 'Antigüedades'), (1, 'Arquitectónico y jardín'), (2, 'Directo del artista'), (2, 'Lotes al por mayor'), 
(3, 'Asientos de seguridad para autos'), (3, 'Artículos para bebé'), (4, 'Libros de textos, educación'), (4, 'Ficción y literatura'), 
(5, 'Construcción'), (5, 'Agricultura y silvicultura'), (6, 'Drones con cámaras'), (6, 'Binoculares y telescopios'), 
(7, 'Relojes inteligentes'), (7, 'Celulares y smartphones'), (8, 'Ropa para hombre'), (8, 'Ropa para mujer'), 
(9, 'En lingotes'), (9, 'Monedas: EE. UU.'), (10, 'Cómics'), (10, 'Relojes'), (11, 'Laptops y netbooks'), (11, 'iPads, tablets y lectores electrónicos'), 
(12, 'Audio portátil y audífonos'), (12, 'Televisor, video y audio para el hogar'), (13, 'Materiales para arte'), (13, 'Artes y artesanías para el hogar'), 
(14, 'Muñecas'), (14, 'Osos'), (15, 'Cintas VHS'), (15, 'DVD y Blu-ray'), 
(16, 'Motocicletas'), (16, 'Vehículos y camionetas'), (17, 'Memorabilia de películas'), (17, 'Autógrafos-original'), 
(18, 'Tarjetas de regalo de eBay'), (18, 'Tarjetas de regalo'), (19, 'Suplementos alimenticios, nutrición'), (19, 'Cuerpo y baño'), 
(20, 'Ropa de cama'), (20, 'Baño'), (21, 'Diamantes y gemas sueltos'), (21, 'Joyas de moda'), 
(22, 'CD'), (22, 'Casetes'),(23, 'Equipo'), (23, 'Guitarra'),
(24, 'Gatos'), (24, 'Aves'),(25, 'Cerámica y porcelana'), (25, 'Vidrio'),
(26, 'Terreno'), (26, 'Comerciales'),(27, 'Servicios de subastas de eBay'), (27, 'Servicios artísticos'),
(28, 'Pesca'), (28, 'Ciclismo'),(29, 'Tarjetas'), (29, 'Autógrafos (original)'),
(30, 'Canadá'), (30, 'Estados Unidos'), (31, 'Boletos para conciertos'), (31, 'Boletos para deportes'),
(32, 'Juguetes clásicos'), (32, 'Figuras de acción'), (33, 'Alquiler de automóviles'), (33, 'Línea aérea'),
(34, 'Consolas de videojuego'), (34, 'Videojuegos'), (35, 'Otros'), (35, 'Solo para adultos');

INSERT INTO Users VALUES
(201480645, TRUE, 'the_admin', crypt('12345678', gen_salt('bf')), 'admin@gmail.com', 'Admin', 'The First', NULL, NULL),
(201620611, FALSE, 'the_buyer', crypt('12345678', gen_salt('bf')), 'buyer@gmail.com', 'Buyer', 'The First', '89887432', '24538546'),
(202720532, FALSE, 'the_seller', crypt('12345678', gen_salt('bf')), 'selller@gmail.com', 'Seller', 'The First', '87847211', '24576310'),
(201620622, FALSE, 'the_buyer2', crypt('12345678', gen_salt('bf')), 'buyer2@gmail.com', 'Buyer', 'The Second', '85867211', '24437733');

INSERT INTO Auction (itemName, subCategoryId, userId, bestBidId, basePrice, startDate, endDate, itemDescription, deliveryDetails, itemPhoto, isClosed, itemWasSold) VALUES
('Nintendo Wii', 67, 202720532, NULL, 30000, '2020-01-22 00:00:00-06', '2020-05-22 00:00:00-06', 'Bought in 2008, excellent state', 'To deliver in San José', NULL, TRUE, TRUE),
('Lady Datejust Rolex', 20, 202720532, NULL, 350000, NOW(), '2021-05-22 00:00:00-06', 'Limited edition deluxe watch', 'To deliver in San José', NULL, FALSE, NULL);

INSERT INTO Bid (auctionId, userId, amount, date) VALUES
(1, 201620611, 40000, '2020-02-10 11:00:00-06');
UPDATE Auction SET bestBidId = 1 WHERE id = 1;

INSERT INTO SellerReview (auctionId, comment, rating, date) VALUES
(1, 'Recommended, item as described.', 5, '2020-05-24 00:00:00-06');

INSERT INTO BuyerReview (auctionId, comment, rating, date) VALUES
(1, 'Recommended buyer, paid the agreed price.', 5, '2020-05-25 00:00:00-06');
