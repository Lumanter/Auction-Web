INSERT INTO AuctionParameter (improvementPercent, minIncrement, dateT) VALUES
(3, 3000,CURRENT_TIMESTAMP);
select * from auctionparameter
INSERT ALL
    Into Category (name) values('Antig�edades')
    Into Category (name) values('Arte')
    Into Category (name) values('Beb�s') 
    Into Category (name) values('Libros')
    Into Category (name) values('Equipo y maquinaria industrial')
    Into Category (name) values('C�maras y fotograf�a') 
    Into Category (name) values('Tel�fonos celulares y accesorios') 
    Into Category (name) values('Ropa, zapatos y accesorios') 
    Into Category (name) values('Monedas y billetes') 
    Into Category (name) values('Art�culos de colecci�n')
    Into Category (name) values('Computadoras, tablets y redes') 
    Into Category (name) values('Art�culos electr�nicos') 
    Into Category (name) values('Artesan�as') 
    Into Category (name) values('Mu�ecas y osos') 
    Into Category (name) values('Pel�culas y DVD')
    Into Category (name) values('Veh�culos') 
    Into Category (name) values('Memorabilia de entretenimiento') 
    Into Category (name) values('Tarjetas de regalo y cupones') 
    Into Category (name) values('Belleza y salud') 
    Into Category (name) values('Casa y jard�n') 
    Into Category (name) values('Joyer�a y relojes') 
    Into Category (name) values('M�sica') 
    Into Category (name) values('Instrumentos y equipos musicales') 
    Into Category (name) values('Productos para mascotas') 
    Into Category (name) values('Cer�mica y vidrio') 
    Into Category (name) values('Bienes ra�ces') 
    Into Category (name) values('Servicios especiales') 
    Into Category (name) values('Art�culos deportivos') 
    Into Category (name) values('Memorabilia de deporte, tarjetas, fans') 
    Into Category (name) values('Estampillas') 
    Into Category (name) values('Boletos y experiencias')
    Into Category (name) values('Juguetes y pasatiempos') 
    Into Category (name) values('Viaje') 
    Into Category (name) values('Videojuegos y consolas') 
    Into Category (name) values('Todo lo dem�s')
SELECT * FROM dual


INSERT ALL 
    INTO SubCategory (categoryId, name) VALUES(1, 'Antig�edades')
    INTO SubCategory (categoryId, name) VALUES(1, 'Arquitect�nico y jard�n') 
    INTO SubCategory (categoryId, name) VALUES(2, 'Directo del artista')
    INTO SubCategory (categoryId, name) VALUES(2, 'Lotes al por mayor') 
    INTO SubCategory (categoryId, name) VALUES(3, 'Asientos de seguridad para autos') 
    INTO SubCategory (categoryId, name) VALUES(3, 'Art�culos para beb�') 
    INTO SubCategory (categoryId, name) VALUES(4, 'Libros de textos, educaci�n') 
    INTO SubCategory (categoryId, name) VALUES(4, 'Ficci�n y literatura') 
    INTO SubCategory (categoryId, name) VALUES(5, 'Construcci�n')
    INTO SubCategory (categoryId, name) VALUES(5, 'Agricultura y silvicultura') 
    INTO SubCategory (categoryId, name) VALUES(6, 'Drones con c�maras')
    INTO SubCategory (categoryId, name) VALUES(6, 'Binoculares y telescopios')
    INTO SubCategory (categoryId, name) VALUES(7, 'Relojes inteligentes') 
    INTO SubCategory (categoryId, name) VALUES(7, 'Celulares y smartphones')
    INTO SubCategory (categoryId, name) VALUES(8, 'Ropa para hombre') 
    INTO SubCategory (categoryId, name) VALUES(8, 'Ropa para mujer')
    INTO SubCategory (categoryId, name) VALUES(9, 'En lingotes') 
    INTO SubCategory (categoryId, name) VALUES(9, 'Monedas: EE. UU.') 
    INTO SubCategory (categoryId, name) VALUES(10, 'C�mics') 
    INTO SubCategory (categoryId, name) VALUES(10, 'Relojes')
    INTO SubCategory (categoryId, name) VALUES(11, 'Laptops y netbooks')
    INTO SubCategory (categoryId, name) VALUES(11, 'iPads, tablets y lectores electr�nicos') 
    INTO SubCategory (categoryId, name) VALUES(12, 'Audio port�til y aud�fonos') 
    INTO SubCategory (categoryId, name) VALUES(12, 'Televisor, video y audio para el hogar') 
    INTO SubCategory (categoryId, name) VALUES(13, 'Materiales para arte')
    INTO SubCategory (categoryId, name) VALUES(13, 'Artes y artesan�as para el hogar') 
    INTO SubCategory (categoryId, name) VALUES(14, 'Mu�ecas')
    INTO SubCategory (categoryId, name) VALUES(14, 'Osos')
    INTO SubCategory (categoryId, name) VALUES(15, 'Cintas VHS') 
    INTO SubCategory (categoryId, name) VALUES(15, 'DVD y Blu-ray') 
    INTO SubCategory (categoryId, name) VALUES(16, 'Motocicletas') 
    INTO SubCategory (categoryId, name) VALUES(16, 'Veh�culos y camionetas') 
    INTO SubCategory (categoryId, name) VALUES(17, 'Memorabilia de pel�culas') 
    INTO SubCategory (categoryId, name) VALUES(17, 'Aut�grafos-original') 
    INTO SubCategory (categoryId, name) VALUES(18, 'Tarjetas de regalo de eBay') 
    INTO SubCategory (categoryId, name) VALUES(18, 'Tarjetas de regalo') 
    INTO SubCategory (categoryId, name) VALUES(19, 'Suplementos alimenticios, nutrici�n') 
    INTO SubCategory (categoryId, name) VALUES(19, 'Cuerpo y ba�o') 
    INTO SubCategory (categoryId, name) VALUES(20, 'Ropa de cama') 
    INTO SubCategory (categoryId, name) VALUES(20, 'Ba�o') 
    INTO SubCategory (categoryId, name) VALUES(21, 'Diamantes y gemas sueltos') 
    INTO SubCategory (categoryId, name) VALUES(21, 'Joyas de moda') 
    INTO SubCategory (categoryId, name) VALUES(22, 'CD') 
    INTO SubCategory (categoryId, name) VALUES(22, 'Casetes')
    INTO SubCategory (categoryId, name) VALUES(23, 'Equipo') 
    INTO SubCategory (categoryId, name) VALUES(23, 'Guitarra')
    INTO SubCategory (categoryId, name) VALUES(24, 'Gatos')
    INTO SubCategory (categoryId, name) VALUES(24, 'Aves')
    INTO SubCategory (categoryId, name) VALUES(25, 'Cer�mica y porcelana')
    INTO SubCategory (categoryId, name) VALUES(25, 'Vidrio')
    INTO SubCategory (categoryId, name) VALUES(26, 'Terreno')
    INTO SubCategory (categoryId, name) VALUES(26, 'Comerciales')
    INTO SubCategory (categoryId, name) VALUES(27, 'Servicios de subastas de eBay')
    INTO SubCategory (categoryId, name) VALUES(27, 'Servicios art�sticos')
    INTO SubCategory (categoryId, name) VALUES(28, 'Pesca')
    INTO SubCategory (categoryId, name) VALUES(28, 'Ciclismo')
    INTO SubCategory (categoryId, name) VALUES(29, 'Tarjetas')
    INTO SubCategory (categoryId, name) VALUES(29, 'Aut�grafos (original)')
    INTO SubCategory (categoryId, name) VALUES(30, 'Canad�')
    INTO SubCategory (categoryId, name) VALUES(30, 'Estados Unidos')
    INTO SubCategory (categoryId, name) VALUES(31, 'Boletos para conciertos')
    INTO SubCategory (categoryId, name) VALUES(31, 'Boletos para deportes')
    INTO SubCategory (categoryId, name) VALUES(32, 'Juguetes cl�sicos')
    INTO SubCategory (categoryId, name) VALUES(32, 'Figuras de acci�n')
    INTO SubCategory (categoryId, name) VALUES(33, 'Alquiler de autom�viles')
    INTO SubCategory (categoryId, name) VALUES(33, 'L�nea a�rea')
    INTO SubCategory (categoryId, name) VALUES(34, 'Consolas de videojuego')
    INTO SubCategory (categoryId, name) VALUES(34, 'Videojuegos')
    INTO SubCategory (categoryId, name) VALUES(35, 'Otros')
    INTO SubCategory (categoryId, name) VALUES(35, 'Solo para adultos')
SELECT * FROM dual
Select * from Users

INSERT all
    INTO Users VALUES (201480645, 'T', 'the_admin', cryptf('12345678'), 'admin@gmail.com', 'Admin', 'The First', NULL, NULL)
    INTO Users VALUES(201620611, 'F', 'the_buyer', cryptf('12345678'), 'buyer@gmail.com', 'Buyer', 'The First', '89887432', '24538546')
    INTO Users VALUES(202720532, 'F', 'the_seller', cryptf('12345678'), 'selller@gmail.com', 'Seller', 'The First', '87847211', '24576310')
    INTO Users VALUES(201620622, 'F', 'the_buyer2', cryptf('12345678'), 'buyer2@gmail.com', 'Buyer', 'The Second', '85867211', '24437733')
SELECT * FROM dual


-------/////////////////
-----//////////// Encryption and decryption functions
-----///////////////
create or replace function cryptf( p_str in varchar2 ) return varchar2
  as
      l_data  varchar2(255);
  begin
     l_data := rpad( p_str, (trunc(length(p_str)/8)+1)*8, chr(0) );
  
      dbms_obfuscation_toolkit.DESEncrypt
          ( input_string => l_data,
            key_string   => 'DBAKey03',
           encrypted_string=> l_data );
 
      return l_data;
  end;


create or replace
  function decryptf( p_str in varchar2 ) return varchar2
  as
      l_data  varchar2(255);
  begin
      dbms_obfuscation_toolkit.DESDecrypt
          ( input_string => p_str,
            key_string   => 'DBAKey03',
            decrypted_string=> l_data );
  
      return rtrim( l_data, chr(0) );
  end;

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------



INSERT all
    INTO Auction (itemName, subCategoryId, userId, bestBidId, basePrice, startDate, endDate, itemDescription, deliveryDetails, itemPhoto, isClosed, itemWasSold) VALUES
    ('Nintendo Wii', 67, 202720532, NULL, 30000, '22-01-2020 00:00:00,06', '22-05-2020 00:00:00,06', 'Bought in 2008, excellent state', 'To deliver in San Jos�', NULL, 'T', 'T')
    INTO Auction (itemName, subCategoryId, userId, bestBidId, basePrice, startDate, endDate, itemDescription, deliveryDetails, itemPhoto, isClosed, itemWasSold) VALUES
    ('Lady Datejust Rolex', 10, 202720532, NULL, 350000, CURRENT_TIMESTAMP, '22-05-2021 00:00:00,06', 'Limited edition deluxe watch', 'To deliver in San Jos�', NULL, 'F', NULL)
SELECT * FROM dual

select * from users
select CURRENT_TIMESTAMP from dual
select * from Auction 

DELETE FROM AUCTION; 
delete from bid;

SELECT * FROM USERS

INSERT INTO Bid (auctionId, userId, amount, dateT) VALUES (1, 201480645, 40000, '10-02-2020 11:00:00,06');

SELECT * FROM BID



INSERT INTO SellerReview (auctionId, commentt, rating, dateT) VALUES
(1, 'Recommended, item as described.', 5, '24-05-2020 00:00:00,06');

INSERT INTO BuyerReview (auctionId, commentt, rating, dateT) VALUES
(1, 'Recommended buyer, paid the agreed price.', 5, '25-05-2020 00:00:00,06');






UPDATE Auction SET bestBidId = 1 WHERE id = 1;














select sysdate, dump(sysdate) as date_bytes from dual;

Select TO_TIMESTAMP_TZ
    (CURRENT_TIMESTAMP, 'DD-MON-RR HH.MI.SSXFF PM TZH:TZM') from dual



Select * from AuctionParameter;
select * from category
SELECT * FROM SubCategory 