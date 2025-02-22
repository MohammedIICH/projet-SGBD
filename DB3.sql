CREATE DATABASE LINK DB1_Centrale
CONNECT TO helkarchou
IDENTIFIED BY MDPORACLE
USING 'DB1'
;

CREATE DATABASE LINK DB2_EdN
CONNECT TO helkarchou
IDENTIFIED BY MDPORACLE
USING 'DB2'
;

CREATE DATABASE LINK DB4_A
CONNECT TO helkarchou
IDENTIFIED BY MDPORACLE
USING 'DB4'
;
//Modifier code client
ALTER TABLE Clients_EDS MODIFY code_client CHAR (7 byte);
UPDATE Clients_EDS SET CODE_CLIENT = CONCAT('S', SUBSTR(code_client, 0 ,5));

ALTER TABLE Clients_F MODIFY code_client CHAR (7 byte);
UPDATE Clients_F SET CODE_CLIENT = CONCAT('F', SUBSTR(code_client, 0 ,5));

ALTER TABLE Commandes_EDS MODIFY code_client CHAR (7 byte);
UPDATE Commandes_EDS SET CODE_CLIENT = CONCAT('S', SUBSTR(code_client, 0 ,5));

ALTER TABLE Commandes_F MODIFY code_client CHAR (7 byte);
UPDATE Commandes_F
SET CODE_CLIENT = 'F' || SUBSTR(CODE_CLIENT, 1, 5);

CREATE TABLE Clients_EdS AS
Select * 
from Ryori.clients@DB1_Centrale
Where PAYS IN ('Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie',
'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie',  'Bulgarie');

CREATE TABLE Commandes_EdS AS
Select *
FROM Ryori.commandes@DB1_Centrale
NATURAL JOIN
(Select CODE_CLIENT
from clients_EdS);


CREATE TABLE D_Commandes_EdS AS
Select *
FROM Ryori.DETAILS_COMMANDES@DB1_Centrale
Natural JOIN
(Select NO_COMMANDE
from Commandes_EdS);

CREATE TABLE Stock_EdS AS
Select * 
from Ryori.stock@DB1_Centrale
Where PAYS IN ('Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie',
'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie',  'Bulgarie');

CREATE TABLE Clients_F AS
Select * 
from Ryori.clients@DB1_Centrale
Where PAYS IN ('France');

CREATE TABLE Commandes_F AS
Select *
FROM Ryori.commandes@DB1_Centrale
NATURAL JOIN
(Select CODE_CLIENT
from clients_F);


CREATE TABLE D_Commandes_F AS
Select *
FROM Ryori.DETAILS_COMMANDES@DB1_Centrale
Natural JOIN
(Select NO_COMMANDE
from Commandes_F);

CREATE TABLE Stock_F AS
Select * 
from Ryori.stock@DB1_Centrale
Where PAYS IN ('France');

CREATE TABLE Produits AS
Select * 
from Ryori.produits@DB1_Centrale;

CREATE TABLE Categories AS
Select * 
from Ryori.categories@DB1_Centrale;

ALTER TABLE Categories
ADD PRIMARY KEY ( Code_categorie );

ALTER TABLE Produits
ADD PRIMARY KEY ( Ref_produit );

ALTER TABLE Clients_EdS ADD CONSTRAINT pk_Clients_EDS
PRIMARY KEY ( Code_client );



ALTER TABLE Commandes_EdS
ADD PRIMARY KEY ( no_commande );

ALTER TABLE D_Commandes_EdS
ADD PRIMARY KEY (No_commande , Ref_produit );

ALTER TABLE Stock_EdS
ADD PRIMARY KEY (Pays , Ref_produit );

ALTER TABLE Clients_F ADD CONSTRAINT PK_Clients_F
PRIMARY KEY ( Code_client );

ALTER TABLE Commandes_F ADD CONSTRAINT PK_Commandes_F
PRIMARY KEY ( no_commande );

ALTER TABLE D_Commandes_F
ADD PRIMARY KEY (No_commande , Ref_produit );

ALTER TABLE Stock_F
ADD PRIMARY KEY (Pays , Ref_produit );

ALTER TABLE Commandes_EdS
ADD CONSTRAINT FK_Commandes_Clients_EdS
FOREIGN KEY (CODE_CLIENT)
REFERENCES Clients_EdS (CODE_CLIENT);


ALTER TABLE D_Commandes_EdS
ADD CONSTRAINT FK_D_Commandes_Commandes_EdS
FOREIGN KEY (NO_COMMANDE)
REFERENCES Commandes_EdS (NO_COMMANDE);


ALTER TABLE D_Commandes_EdS
ADD CONSTRAINT FK_D_Commandes_Produits
FOREIGN KEY (REF_PRODUIT)
REFERENCES Produits (REF_PRODUIT);

ALTER TABLE Stock_EdS
ADD CONSTRAINT FK_Stock_Produits_EdS
FOREIGN KEY (REF_PRODUIT)
REFERENCES Produits (REF_PRODUIT);

ALTER TABLE Commandes_F
ADD CONSTRAINT FK_Commandes_Clients_F
FOREIGN KEY (CODE_CLIENT)
REFERENCES Clients_F (CODE_CLIENT);


ALTER TABLE D_Commandes_F
ADD CONSTRAINT FK_D_Commandes_Commandes_F
FOREIGN KEY (NO_COMMANDE)
REFERENCES Commandes_F (NO_COMMANDE);


ALTER TABLE D_Commandes_F
ADD CONSTRAINT FK_D_Commandes_Produits_F
FOREIGN KEY (REF_PRODUIT)
REFERENCES Produits (REF_PRODUIT);

ALTER TABLE Stock_F
ADD CONSTRAINT FK_Stock_Produits_F
FOREIGN KEY (REF_PRODUIT)
REFERENCES Produits (REF_PRODUIT);

ALTER TABLE Produits
ADD CONSTRAINT FK_Produits_Categories
FOREIGN KEY (CODE_CATEGORIE)
REFERENCES Categories (CODE_CATEGORIE);

GRANT SELECT ON Produits TO ebachet;
GRANT SELECT ON Categories TO ebachet;
GRANT SELECT ON Stock_F TO ebachet;
GRANT SELECT ON D_Commandes_F TO ebachet;
GRANT SELECT ON Commandes_F TO ebachet;
GRANT SELECT ON Clients_F TO ebachet;
GRANT SELECT ON Stock_EdS TO ebachet;
GRANT SELECT ON D_Commandes_EdS TO ebachet;
GRANT SELECT ON Commandes_EdS TO ebachet;
GRANT SELECT ON Clients_EdS TO ebachet;


GRANT SELECT ON Produits TO mlemseffer;
GRANT SELECT ON Categories TO mlemseffer;
GRANT SELECT ON Stock_F TO mlemseffer;
GRANT SELECT ON D_Commandes_F TO mlemseffer;
GRANT SELECT ON Commandes_F TO mlemseffer;
GRANT SELECT ON Clients_F TO mlemseffer;
GRANT SELECT ON Stock_EdS TO mlemseffer;
GRANT SELECT ON D_Commandes_EdS TO mlemseffer;
GRANT SELECT ON Commandes_EdS TO mlemseffer;
GRANT SELECT ON Clients_EdS TO mlemseffer;

CREATE OR REPLACE TRIGGER fk_commande_employe_EDS
before INSERT OR UPDATE ON COMMANDES_EDS
for each row
DECLARE
   nbEmp number;
BEGIN
    Select count(*)
    into nbEmp
    FROM ebachet.employes@DB4_A
    where NO_EMPLOYE = :NEW.NO_EMPLOYE;
    IF nbEMP = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_EMPLOYE invalide');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER fk_commande_employe_F
before INSERT OR UPDATE ON COMMANDES_F
for each row
DECLARE
   nbEmp number;
BEGIN
    Select count(*)
    into nbEmp
    FROM ebachet.employes@DB4_A
    where NO_EMPLOYE = :NEW.NO_EMPLOYE;
    IF nbEMP = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_EMPLOYE invalide');
    END IF;
END;
/ 

CREATE OR REPLACE TRIGGER fk_produits_fournisseurs
BEFORE INSERT OR UPDATE ON Produits
FOR EACH ROW
DECLARE
   nbFournisseurs NUMBER;
BEGIN
   SELECT COUNT(*)
   INTO nbFournisseurs
   FROM mlemseffer.fournisseurs@DB2_EdN
   WHERE NO_FOURNISSEUR = :NEW.NO_FOURNISSEUR;

   IF nbFournisseurs = 0 THEN
      RAISE_APPLICATION_ERROR(-20005, 'NO_FOURNISSEUR invalide.');
   END IF;
END;
/

ALTER TABLE CLIENTS_EdS ADD CONSTRAINT Pays_EdS
CHECK (PAYS IN ('Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie',
'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie',  'Bulgarie'));

ALTER TABLE CLIENTS_F ADD CONSTRAINT Pays_F
CHECK (PAYS ='France');

CREATE OR REPLACE TRIGGER Produits_Commandes_Dist BEFORE DELETE ON Produits
FOR EACH ROW
DECLARE
nbA number;
nbEDN number;
nbO number;
nbTot number;
BEGIN
SELECT COUNT(*)
INTO nbA
FROM ebachet.D_Commandes_A@DB4_A
where ref_produit = :OLD.ref_produit;
select count(*)
into nbEDN
from mlemseffer.D_Commandes_EDN@DB2_EDN
where ref_produit = :OLD.ref_produit ;
select count(*)
into nbO
from mlemseffer.D_Commandes_O@DB2_EDN
where ref_produit = :OLD.ref_produit ;

nbTot := nbA + nbEDN+nbO;
If nbTot > 0
then
RAISE_APPLICATION_ERROR ( -20009 , 'Commande using this product');
END IF;
END;
/

CREATE OR REPLACE TRIGGER Produits_Stock_Dist BEFORE DELETE ON Produits
FOR EACH ROW
DECLARE
    nbA number;
    nbEDN number;
    nbO number;
    nbTot number;
BEGIN
    SELECT COUNT(*)
    INTO nbA
    FROM ebachet.Stock_A@DB4_A
    where ref_produit = :OLD.ref_produit;
    
    select count(*)
    into nbEDN
    from mlemseffer.Stock_EDN@DB2_EDN
    where ref_produit = :OLD.ref_produit ;
    
    select count(*)
    into nbO
    from mlemseffer.Stock_O@DB2_EDN
    where ref_produit = :OLD.ref_produit ;

nbTot := nbA+nbEDN+nbO;
If nbTot > 0
then
RAISE_APPLICATION_ERROR ( -20010 , 'Commande using this product');
END IF;
END;
/


CREATE OR REPLACE SYNONYM Commandes_EDN for mlemseffer.Commandes_EDN@DB2_EdN;
CREATE OR REPLACE SYNONYM Commandes_O for mlemseffer.Commandes_O@DB2_EdN;
CREATE OR REPLACE SYNONYM Commandes_A for ebachet.Commandes_A@DB4_A;

CREATE OR REPLACE SYNONYM D_Commandes_EDN for mlemseffer.D_Commandes_EDN@DB2_EdN;
CREATE OR REPLACE SYNONYM D_Commandes_O for mlemseffer.D_Commandes_O@DB2_EdN;
CREATE OR REPLACE SYNONYM D_Commandes_A for ebachet.D_Commandes_A@DB4_A;

CREATE OR REPLACE SYNONYM Clients_EDN for mlemseffer.Clients_EDN@DB2_EdN;
CREATE OR REPLACE SYNONYM Clients_O for mlemseffer.Clients_O@DB2_EdN;
CREATE OR REPLACE SYNONYM Clients_A for ebachet.Clients_A@DB4_A;

CREATE OR REPLACE SYNONYM STOCK_EDN for mlemseffer.STOCK_EDN@DB2_EdN;
CREATE OR REPLACE SYNONYM STOCK_O for mlemseffer.STOCK_O@DB2_EdN;
CREATE OR REPLACE SYNONYM STOCK_A for ebachet.STOCK_A@DB4_A;




CREATE OR REPLACE VIEW Stock AS
(SELECT *
FROM Stock_EDS
WHERE Pays IN (
    'Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte',
    'Albanie', 'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie',
    'Slovénie', 'Bulgarie'
))
UNION ALL
(SELECT *
FROM Stock_F
WHERE Pays = 'France')
UNION ALL
(SELECT *
FROM mlemseffer.Stock_EDN@DB2_EDN
WHERE Pays IN (
    'Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni', 'Irlande', 'Belgique',
    'Luxembourg', 'Pays-Bas', 'Pologne', 'Allemagne'
))
UNION ALL
(SELECT *
FROM mlemseffer.Stock_O@DB2_EDN
WHERE Pays NOT IN (
    'Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni', 'Irlande', 'Belgique',
    'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 'Andorre', 'France',
    'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine',
    'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 
    'Antigua-et-Barbuda', 'Argentine', 'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil',
    'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
    'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque',
    'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 'Saint-Christophe-et-Niévès',
    'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname',
    'Trinité-et-Tobago', 'Uruguay', 'Venezuela'
))
UNION ALL
(SELECT *
FROM ebachet.Stock_A@DB4_A
WHERE Pays IN (
    'Antigua-et-Barbuda', 'Argentine', 'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil',
    'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
    'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque',
    'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 'Saint-Christophe-et-Niévès',
    'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname',
    'Trinité-et-Tobago', 'Uruguay', 'Venezuela'
));
// TEST DE LA VUE 
Select * 
From STOCK;
SELECT * 
FROM Ryori.STOCK@DB1_Centrale;
// MÊME NOMBRES DE TUPLES ( 231 ) 




CREATE OR REPLACE VIEW Commandes AS
(SELECT Commandes_EdS.*
FROM Commandes_EDS, Clients_EDS
where Commandes_EdS.Code_Client = Clients_EdS.Code_Client
AND Clients_EDS.Pays  IN (
    'Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte',
    'Albanie', 'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie',
    'Slovénie', 'Bulgarie'
))
UNION ALL
(SELECT Commandes_F.*
FROM Commandes_F, Clients_F
where Commandes_F.Code_Client = Clients_F.Code_Client
AND Clients_F.Pays ='France')
UNION ALL
(SELECT Commandes_EDN.*
FROM Commandes_EDN, Clients_EDN
where Commandes_EDN.Code_Client = Clients_EDN.Code_Client
AND Clients_EDN.Pays IN (
    'Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni', 'Irlande', 'Belgique',
    'Luxembourg', 'Pays-Bas', 'Pologne', 'Allemagne'
))
UNION ALL
(SELECT Commandes_O.*
FROM Commandes_O, Clients_O
where Commandes_O.Code_Client = Clients_O.Code_Client
AND Clients_O.Pays NOT IN (
    'Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni', 'Irlande', 'Belgique',
    'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 'Andorre', 'France',
    'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine',
    'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 
    'Antigua-et-Barbuda', 'Argentine', 'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil',
    'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
    'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque',
    'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 'Saint-Christophe-et-Niévès',
    'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname',
    'Trinité-et-Tobago', 'Uruguay', 'Venezuela'
))
UNION ALL
(SELECT Commandes_A.*
FROM Commandes_A, Clients_A
where Commandes_A.Code_Client = Clients_A.Code_Client
AND Clients_A.Pays IN (
    'Antigua-et-Barbuda', 'Argentine', 'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil',
    'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
    'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque',
    'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 'Saint-Christophe-et-Niévès',
    'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname',
    'Trinité-et-Tobago', 'Uruguay', 'Venezuela'
));

Select * 
From Commandes;
SELECT * 
FROM Ryori.Commandes@DB1_Centrale;
// 830 tuples pour les 2 


CREATE OR REPLACE VIEW CLIENTS AS
(
    (SELECT *
    FROM CLIENTS_EDN
    where Pays IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne'))
    UNION ALL
    (SELECT *
    from CLIENTS_O
    where Pays NOT IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 
'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine', 
'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    UNION ALL
    (SELECT *
    FROM CLIENTS_EDS
    where Pays IN ('Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie',
'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie',  'Bulgarie'))
    UNION ALL
    (SELECT *
    FROM CLIENTS_F
    where Pays = 'France')
    UNION ALL
    (SELECT *
    FROM CLIENTS_A
    where Pays IN ('Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    );


Select * 
From CLIENTS;
SELECT * 
FROM Ryori.CLIENTS@DB1_Centrale;
// 91 tuples 

CREATE OR REPLACE VIEW D_COMMANDES AS
(
    (SELECT D_Commandes_EDN.*
    from Commandes_EDN, Clients_EDN, D_Commandes_EDN
    where Commandes_EDN.Code_Client = Clients_EDN.Code_Client
    AND Commandes_EDN.no_commande = D_Commandes_EDN.no_commande
    AND Clients_EDN.Pays IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne'))
    UNION ALL
    (SELECT D_Commandes_O.*
    from Commandes_O, Clients_O, D_Commandes_O
    where Commandes_O.Code_Client = Clients_O.Code_Client
    AND Commandes_O.no_commande = D_Commandes_O.no_commande
    AND Clients_O.Pays NOT IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 
'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine', 
'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    UNION ALL
    (SELECT D_Commandes_EdS.*
    FROM Commandes_EdS, Clients_EdS, D_Commandes_EdS
    where Commandes_EdS.Code_Client = Clients_EdS.Code_Client
    AND Commandes_EDS.no_commande = D_Commandes_EDS.no_commande
    AND Clients_EDS.Pays IN ('Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie',
'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie',  'Bulgarie'))
    UNION ALL
    (SELECT D_Commandes_F.*
    FROM Commandes_F, Clients_F, D_Commandes_F
    where Commandes_F.Code_Client = Clients_F.Code_Client
    AND Commandes_F.no_commande = D_Commandes_F.no_commande
    AND Clients_F.Pays = 'France')
    UNION ALL
    (SELECT D_Commandes_A.*
    FROM Commandes_A, Clients_A, D_Commandes_A
    where Commandes_A.Code_Client = Clients_A.Code_Client
    AND Commandes_A.no_commande = D_Commandes_A.no_commande
    AND Clients_A.Pays IN ('Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    );

Select * 
From D_Commandes;
SELECT * 
FROM Ryori.DETAILS_Commandes@DB1_Centrale;
//2155 tuples 

CREATE MATERIALIZED VIEW LOG ON Produits;
GRANT SELECT ON MLOG$_Produits TO mlemseffer;
GRANT SELECT On MLOG$_Produits TO ebachet;

CREATE MATERIALIZED VIEW MV_Employes
REFRESH COMPLETE
NEXT sysdate + (1)
AS
SELECT * FROM ebachet.Employes@DB4_A;


CREATE MATERIALIZED VIEW MV_Fournisseurs
REFRESH FAST
NEXT sysdate +(1/24)
AS SELECT * FROM mlemseffer.Fournisseurs@DB2_EDN;