CREATE DATABASE LINK DB1_Centrale
CONNECT TO mlemseffer 
IDENTIFIED BY MDPORACLE 
USING 'DB1';

CREATE DATABASE LINK DB3_EdS
CONNECT TO mlemseffer 
IDENTIFIED BY MDPORACLE 
USING 'DB3';

CREATE DATABASE LINK DB4_A
CONNECT TO mlemseffer 
IDENTIFIED BY MDPORACLE 
USING 'DB4';


//Modifier code client
ALTER TABLE Clients_EDN MODIFY code_client CHAR (7 byte);
UPDATE Clients_EDN SET CODE_CLIENT = CONCAT('N', SUBSTR(code_client, 0 ,5));

ALTER TABLE Clients_O MODIFY code_client CHAR (7 byte);
UPDATE Clients_O SET CODE_CLIENT = CONCAT('O', SUBSTR(code_client, 0 ,5));

ALTER TABLE Commandes_EDN MODIFY code_client CHAR (7 byte);
UPDATE Commandes_EDN SET CODE_CLIENT = CONCAT('N', SUBSTR(code_client, 0 ,5));

ALTER TABLE commandes_O MODIFY code_client CHAR (7 byte);
UPDATE commandes_O SET CODE_CLIENT = CONCAT('O', SUBSTR(code_client, 0 ,5));

//Creation de Clients_EDN
CREATE TABLE Clients_EdN AS
Select * 
from Ryori.clients@DB1_Centrale
Where PAYS IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne');


//Creation de Commandes_EDN
CREATE TABLE Commandes_EdN AS
Select *
FROM Ryori.commandes@DB1_Centrale
NATURAL JOIN
(Select CODE_CLIENT
from clients_EdN);

//Creation de D_Commandes_EDN
CREATE TABLE D_Commandes_EdN AS
Select *
FROM Ryori.DETAILS_COMMANDES@DB1_Centrale
Natural JOIN
(Select NO_COMMANDE
from Commandes_EdN);

//Creation de Stock_EdN
CREATE TABLE Stock_EdN AS
Select * 
from Ryori.stock@DB1_Centrale
Where PAYS IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne');

//Importation de la table fournisseurs

CREATE TABLE FOURNISSEURS AS
Select * 
from Ryori.fournisseurs@DB1_Centrale;

//On cree les tables pour les pays de type "Other"

//Creation de Clients_O
CREATE TABLE Clients_O AS
Select * 
from Ryori.clients@DB1_Centrale
Where PAYS NOT IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 
'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine', 
'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela');

//Creation de Commandes_O
CREATE TABLE Commandes_O AS
Select *
FROM Ryori.commandes@DB1_Centrale
NATURAL JOIN
(Select CODE_CLIENT
from clients_O);

//Creation de D_Commandes_O
CREATE TABLE D_Commandes_O AS
Select *
FROM Ryori.DETAILS_COMMANDES@DB1_Centrale
Natural JOIN
(Select NO_COMMANDE
from Commandes_O);

//Creation de Stock_O
CREATE TABLE Stock_O AS
Select * 
from Ryori.stock@DB1_Centrale
Where PAYS NOT IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 
'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine', 
'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela');

//Cles primaires

ALTER TABLE CLIENTS_EDN ADD CONSTRAINT pk_Clients_EdN
PRIMARY KEY (Code_Client);

ALTER TABLE CLIENTS_O ADD CONSTRAINT pk_Clients_O
PRIMARY KEY (Code_Client);

ALTER TABLE COMMANDES_EDN ADD CONSTRAINT pk_Commandes_EdN
PRIMARY KEY (NO_COMMANDE);

ALTER TABLE COMMANDES_O ADD CONSTRAINT pk_Commandes_O
PRIMARY KEY (NO_COMMANDE);

ALTER TABLE D_COMMANDES_EDN ADD CONSTRAINT pk_D_Commandes_EdN
PRIMARY KEY (NO_COMMANDE, REF_PRODUIT);

ALTER TABLE D_COMMANDES_O ADD CONSTRAINT pk_D_Commandes_O
PRIMARY KEY (NO_COMMANDE, REF_PRODUIT);

ALTER TABLE FOURNISSEURS ADD CONSTRAINT pk_Fournisseurs
PRIMARY KEY (NO_FOURNISSEUR);

ALTER TABLE STOCK_EDN ADD CONSTRAINT pk_STOCK_EDN
PRIMARY KEY (REF_PRODUIT, PAYS);

ALTER TABLE STOCK_O ADD CONSTRAINT pk_STOCK_O
PRIMARY KEY (REF_PRODUIT, PAYS);

//Ajout des cles etrangeres
ALTER TABLE COMMANDES_EDN ADD CONSTRAINT fk_Commandes_Clients_EdN
FOREIGN KEY (CODE_CLIENT) REFERENCES Clients_EdN(CODE_CLIENT);

ALTER TABLE COMMANDES_O ADD CONSTRAINT fk_Commandes_Clients_O
FOREIGN KEY (CODE_CLIENT) REFERENCES Clients_O(CODE_CLIENT);

//Pour la fk sur commande-employe, faire un trigger sur l'insetion et update

CREATE OR REPLACE TRIGGER fk_commande_employe_EDN
before INSERT OR UPDATE ON COMMANDES_EDN
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

CREATE OR REPLACE TRIGGER fk_commande_employe_O
before INSERT OR UPDATE ON COMMANDES_O
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

ALTER TABLE D_COMMANDES_EDN ADD CONSTRAINT fk_D_Commandes_Commandes_EdN
FOREIGN KEY (NO_COMMANDE) REFERENCES COMMANDES_EDN(NO_COMMANDE);

ALTER TABLE D_COMMANDES_O ADD CONSTRAINT fk_D_Commandes_Commandes_O
FOREIGN KEY (NO_COMMANDE) REFERENCES COMMANDES_O(NO_COMMANDE);

//Trigger pour la fk d_Commandes_EDN_Produits
CREATE OR REPLACE TRIGGER fk_D_Commandes_EDN_Produits
before INSERT OR UPDATE ON D_Commandes_EDN
for each row
DECLARE
   nbProd number;
BEGIN
    Select count(*)
    into nbProd
    FROM helkarchou.Produits@DB3_EdS
    where REF_PRODUIT = :NEW.REF_PRODUIT;
    IF nbProd = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_Produit invalide');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER fk_D_Commandes_O_Produits
before INSERT OR UPDATE ON D_Commandes_O
for each row
DECLARE
   nbProd number;
BEGIN
    Select count(*)
    into nbProd
    FROM helkarchou.Produits@DB3_EdS
    where REF_PRODUIT = :NEW.REF_PRODUIT;
    IF nbProd = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_Produit invalide');
    END IF;
END;
/
//Trigger pour les tables stock

CREATE OR REPLACE TRIGGER fk_D_Stock_EdN_Produits
before INSERT OR UPDATE ON Stock_EdN
for each row
DECLARE
   nbProd number;
BEGIN
    Select count(*)
    into nbProd
    FROM helkarchou.Produits@DB3_EdS
    where REF_PRODUIT = :NEW.REF_PRODUIT;
    IF nbProd = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_Produit invalide');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER fk_D_Stock_EdN_Produits
before INSERT OR UPDATE ON Stock_EdN
for each row
DECLARE
   nbProd number;
BEGIN
    Select count(*)
    into nbProd
    FROM helkarchou.Produits@DB3_EdS
    where REF_PRODUIT = :NEW.REF_PRODUIT;
    IF nbProd = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_Produit invalide');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER fk_D_Stock_O_Produits
before INSERT OR UPDATE ON Stock_O
for each row
DECLARE
   nbProd number;
BEGIN
    Select count(*)
    into nbProd
    FROM helkarchou.Produits@DB3_EdS
    where REF_PRODUIT = :NEW.REF_PRODUIT;
    IF nbProd = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_Produit invalide');
    END IF;
END;
/

//Check pays EdN
ALTER TABLE CLIENTS_EdN ADD CONSTRAINT Pays_EdN
CHECK (PAYS IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne'));

ALTER TABLE CLIENTS_O ADD CONSTRAINT Pays_O
CHECK (PAYS NOT IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 
'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine', 
'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'));

//Trigger suppression FOURNISSEURS

CREATE OR REPLACE TRIGGER supp_FOURNISSEURS
BEFORE DELETE ON FOURNISSEURS
for each row
DECLARE
    nbF number;
BEGIN 
    select count(*)
    Into nbF
    from helkarchou.produits@DB3_EDS
    where NO_FOURNISSEUR = :OLD.NO_FOURNISSEUR;
    IF nbF = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'On ne peut supprimr un fournisseur qui vend encore des produits');
    END IF;
END;
/

//Trigger Code_Client contient la bonne lettre

CREATE OR REPLACE TRIGGER insertion_code_cle_client_EDN
BEFORE INSERT OR UPDATE ON CLIENTS_EDN
for each row
BEGIN
    IF SUBSTR(:NEW.code_client, 1, 1) != 'N' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le code client doit commencer par "N".');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER insertion_code_cle_client_O
BEFORE INSERT OR UPDATE ON CLIENTS_O
for each row
BEGIN
    IF SUBSTR(:NEW.code_client, 1, 1) != 'O' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le code client doit commencer par "O".');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER insertion_code_cle_commandes_EDN
BEFORE INSERT OR UPDATE ON COMMANDES_EDN
for each row
BEGIN
    IF SUBSTR(:NEW.code_client, 1, 1) != 'N' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le code client doit commencer par "N".');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER insertion_code_cle_commandes_O
BEFORE INSERT OR UPDATE ON COMMANDES_O
for each row
BEGIN
    IF SUBSTR(:NEW.code_client, 1, 1) != 'O' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le code client doit commencer par "O".');
    END IF;
END;
/

//GRANT

GRANT SELECT ON CLIENTS_EDN TO ebachet;
GRANT SELECT ON CLIENTS_O TO ebachet;
GRANT SELECT ON COMMANDES_EDN TO ebachet;
GRANT SELECT ON COMMANDES_O TO ebachet;
GRANT SELECT ON D_COMMANDES_EDN TO ebachet;
GRANT SELECT ON D_COMMANDES_O TO ebachet;
GRANT SELECT ON FOURNISSEURS TO ebachet;
GRANT SELECT ON STOCK_EDN TO ebachet;
GRANT SELECT ON STOCK_O TO ebachet;

GRANT SELECT ON CLIENTS_EDN TO helkarchou;
GRANT SELECT ON CLIENTS_O TO helkarchou;
GRANT SELECT ON COMMANDES_EDN TO helkarchou;
GRANT SELECT ON COMMANDES_O TO helkarchou;
GRANT SELECT ON D_COMMANDES_EDN TO helkarchou;
GRANT SELECT ON D_COMMANDES_O TO helkarchou;
GRANT SELECT ON FOURNISSEURS TO helkarchou;
GRANT SELECT ON STOCK_EDN TO helkarchou;
GRANT SELECT ON STOCK_O TO helkarchou;



CREATE OR REPLACE SYNONYM Commandes_EDS for helkarchou.Commandes_EDS@DB3_EdS;
CREATE OR REPLACE SYNONYM Commandes_F for helkarchou.Commandes_F@DB3_EdS;
CREATE OR REPLACE SYNONYM Commandes_A for ebachet.Commandes_A@DB4_A;

CREATE OR REPLACE SYNONYM D_Commandes_EDS for helkarchou.D_Commandes_EDS@DB3_EdS;
CREATE OR REPLACE SYNONYM D_Commandes_F for helkarchou.D_Commandes_F@DB3_EdS;
CREATE OR REPLACE SYNONYM D_Commandes_A for ebachet.D_Commandes_A@DB4_A;

CREATE OR REPLACE SYNONYM Clients_EDS for helkarchou.Clients_EDS@DB3_EdS;
CREATE OR REPLACE SYNONYM Clients_F for helkarchou.Clients_F@DB3_EdS;
CREATE OR REPLACE SYNONYM Clients_A for ebachet.Clients_A@DB4_A;

CREATE OR REPLACE SYNONYM STOCK_EDS for helkarchou.STOCK_EDS@DB3_EdS;
CREATE OR REPLACE SYNONYM STOCK_F for helkarchou.STOCK_F@DB3_EdS;
CREATE OR REPLACE SYNONYM STOCK_A for ebachet.STOCK_A@DB4_A;

CREATE OR REPLACE SYNONYM EMPLOYES for ebachet.employes@DB4_A;
CREATE OR REPLACE SYNONYM CATEGORIES for helkarchou.categories@DB3_EDS;
CREATE OR REPLACE SYNONYM PRODUITS for helkarchou.Produits@DB3_EDS;


//Requetes avec vues optimisees


CREATE OR REPLACE VIEW COMMANDES AS
(
    (SELECT Commandes_EDN.*
    from Commandes_EDN, Clients_EDN
    where Commandes_EDN.Code_Client = Clients_EDN.Code_Client
    AND Clients_EDN.Pays IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne'))
    UNION ALL
    (SELECT Commandes_O.*
    from Commandes_O, Clients_O
    where Commandes_O.Code_Client = Clients_O.Code_Client
    AND Clients_O.Pays NOT IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 
'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine', 
'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    UNION ALL
    (SELECT Commandes_EdS.*
    FROM Commandes_EdS, Clients_EdS
    where Commandes_EdS.Code_Client = Clients_EdS.Code_Client
    AND Clients_EDS.Pays IN ('Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie',
'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie',  'Bulgarie'))
    UNION ALL
    (SELECT Commandes_F.*
    FROM Commandes_F, Clients_F
    where Commandes_F.Code_Client = Clients_F.Code_Client
    AND Clients_F.Pays = 'France')
    UNION ALL
    (SELECT Commandes_A.*
    FROM Commandes_A, Clients_A
    where Commandes_A.Code_Client = Clients_A.Code_Client
    AND Clients_A.Pays IN ('Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    );

//Test de la View : Même nombre de tuples (830)

Select * 
From Commandes;
SELECT * 
FROM Ryori.Commandes@DB1_Centrale;

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

//Test de la View : Même nombre de tuples (2155)

Select * 
From D_Commandes;
SELECT * 
FROM Ryori.DETAILS_Commandes@DB1_Centrale;    

CREATE OR REPLACE VIEW STOCK AS
(
    (SELECT *
    FROM STOCK_EDN
    where Pays IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne'))
    UNION ALL
    (SELECT *
    from STOCK_O
    where Pays NOT IN ('Norvege', 'Suede', 'Danemark', 'Islande', 'Finlande', 'Royaume-Uni',
'Irlande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Allemagne', 'Pologne', 'Espagne', 'Portugal', 
'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzégovine', 
'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    UNION ALL
    (SELECT *
    FROM STOCK_EDS
    where Pays IN ('Espagne', 'Portugal', 'Andorre', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie',
'Bosnie-Herzégovine', 'Croatie', 'Grèce', 'Macédoine', 'Monténégro', 'Serbie', 'Slovénie',  'Bulgarie'))
    UNION ALL
    (SELECT *
    FROM STOCK_F
    where Pays = 'France')
    UNION ALL
    (SELECT *
    FROM STOCK_A
    where Pays IN ('Antigua-et-Barbuda', 'Argentine', 
'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'République dominicaine', 'Dominique',
'Équateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haïti', 'Honduras', 'Jamaïque', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 
'Saint-Christophe-et-Niévès', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinité-et-Tobago', 'Uruguay', 'Venezuela'))
    );

//Test de la View : Même nombre de tuples (231)

Select * 
From STOCK;
SELECT * 
FROM Ryori.STOCK@DB1_Centrale;

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
    
//Test de la View : Même nombre de tuples (91)

Select * 
From CLIENTS;
SELECT * 
FROM Ryori.CLIENTS@DB1_Centrale;

//Replication (complete, fast CREATE MATERIALIZED VIEW ou CREAT MATERIALIZED LOG)

CREATE MATERIALIZED VIEW LOG ON fournisseurs;
GRANT SELECT ON MLOG$_fournisseurs TO helkarchou;
GRANT SELECT ON MLOG$_fournisseurs TO ebachet;

//Pas bcp de catégories, refresh complete
CREATE MATERIALIZED VIEW MV_Categories
REFRESH COMPLETE
NEXT sysdate +(1)
AS SELECT * FROM CATEGORIES;

//BCP de tuples, refresh fast
CREATE MATERIALIZED VIEW MV_Produits
REFRESH FAST
NEXT sysdate +(1/24)
AS SELECT * FROM PRODUITS;

//Pas bcp d'employés, refresh complete
CREATE MATERIALIZED VIEW MV_Employes
REFRESH COMPLETE
NEXT sysdate +(1)
AS SELECT * FROM EMPLOYES;



//Plans d'execution
select * from clients;
select * from clients where pays in ('Allemagne', 'Suede', 'Belgique');
select * from clients_edn;
