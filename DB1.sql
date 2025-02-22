create Database link DBL_Centrale connect to ebachet identified by MDPORACLE using 'DB1';
create Database link DBL_EdN connect to ebachet identified by MDPORACLE using 'DB2';
create Database link DBL_EdS connect to ebachet identified by MDPORACLE using 'DB3';

CREATE TABLE Clients_A AS (select * From Ryori.clients @DBL_Centrale where PAYS='Antigua-et-Barbuda' OR PAYS='Argentine' OR PAYS='Bahamas' OR PAYS='Barbade' OR PAYS='Belize' OR PAYS='Bolivie' OR PAYS='Bresil' OR PAYS='Canada' 
OR PAYS='Chili' OR PAYS='Colombie' OR PAYS='Costa Rica' OR PAYS='Cuba' OR PAYS='Republique dominicaine' OR PAYS='Dominique' OR PAYS='Equateur' OR PAYS='Etats-Unis' OR PAYS='Grenade' OR PAYS='Guatemala' 
OR PAYS='Guyana' OR PAYS='Haiti' OR PAYS='Honduras' OR PAYS='Jamaique' OR PAYS='Mexique' OR PAYS='Nicaragua' OR PAYS='Panama' OR PAYS='Paraguay' OR PAYS='Perou' OR PAYS='Saint-Christophe-et-Nieves' 
OR PAYS='Sainte-Lucie' OR PAYS='Saint-Vincent-et-les-Grenadines' OR PAYS='Salvador' OR PAYS='Suriname' OR PAYS='Trinite-et-Tobago' OR PAYS='Uruguay' OR PAYS='Venezuela') ; 

CREATE TABLE Commandes_A AS (select * from Ryori.Commandes @DBL_Centrale natural join clients_a);
ALTER TABLE commandes_A DROP COLUMN SOCIETE;
ALTER TABLE commandes_A DROP COLUMN VILLE;
ALTER TABLE commandes_A DROP COLUMN SOCIETE;
ALTER TABLE commandes_A DROP COLUMN adresse;
ALTER TABLE commandes_A DROP COLUMN code_postal;
ALTER TABLE commandes_A DROP COLUMN pays;
ALTER TABLE commandes_A DROP COLUMN telephone;
ALTER TABLE commandes_A DROP COLUMN fax;

CREATE TABLE D_Commandes_A AS (SELECT * FROM Ryori.Details_commandes @DBL_Centrale NATURAL JOIN (select NO_Commande from Commande_a));

CREATE TABLE Stock_A AS (select * From Ryori.Stock @DBL_Centrale where PAYS='Antigua-et-Barbuda' OR PAYS='Argentine' OR PAYS='Bahamas' OR PAYS='Barbade' OR PAYS='Belize' OR PAYS='Bolivie' OR PAYS='Bresil' OR PAYS='Canada' 
OR PAYS='Chili' OR PAYS='Colombie' OR PAYS='Costa Rica' OR PAYS='Cuba' OR PAYS='Republique dominicaine' OR PAYS='Dominique' OR PAYS='Equateur' OR PAYS='Etats-Unis' OR PAYS='Grenade' OR PAYS='Guatemala' 
OR PAYS='Guyana' OR PAYS='Haiti' OR PAYS='Honduras' OR PAYS='Jamaique' OR PAYS='Mexique' OR PAYS='Nicaragua' OR PAYS='Panama' OR PAYS='Paraguay' OR PAYS='Perou' OR PAYS='Saint-Christophe-et-Nieves' 
OR PAYS='Sainte-Lucie' OR PAYS='Saint-Vincent-et-les-Grenadines' OR PAYS='Salvador' OR PAYS='Suriname' OR PAYS='Trinite-et-Tobago' OR PAYS='Uruguay' OR PAYS='Venezuela') ;

CREATE TABLE Employes AS (SELECT * FROM Ryori.Employes @DBL_Centrale);

ALTER TABLE Clients_A MODIFY code_client CHAR (7 byte);
ALTER TABLE Commandes_A MODIFY code_client CHAR (7 byte);

UPDATE CLIENTS_A SET code_client=CONCAT('A', SUBSTR(code_client, 0, 5));
UPDATE Commandes_A SET code_client=CONCAT('A', SUBSTR(code_client, 0, 5));
ALTER TABLE Clients_A ADD CHECK (SUBSTR(code_client, 0, 1)='A'); 
ALTER TABLE Commande_A ADD CHECK (SUBSTR(code_client, 0, 1)='A'); 

ALTER TABLE Clients_A ADD CONSTRAINT pkCodeClient PRIMARY KEY (CODE_CLIENT);
ALTER TABLE Commandes_A ADD CONSTRAINT pkNoCommande PRIMARY KEY (NO_COMMANDE);
ALTER TABLE D_Commandes_A ADD CONSTRAINT pkNoCommandeRef PRIMARY KEY (NO_COMMANDE,REF_PRODUIT);
ALTER TABLE EMPLOYES ADD CONSTRAINT pkNoEmployes PRIMARY KEY (NO_EMPLOYE);

GRANT SELECT,UPDATE,INSERT,DELETE ON Employes TO mlemseffer;
GRANT SELECT,UPDATE,INSERT,DELETE ON Clients_A TO mlemseffer;
GRANT SELECT,UPDATE,INSERT,DELETE ON Commandes_A TO mlemseffer;
GRANT SELECT,UPDATE,INSERT,DELETE ON D_Commandes_A TO mlemseffer;
GRANT SELECT,UPDATE,INSERT,DELETE ON Stock_A TO mlemseffer;
GRANT SELECT,UPDATE,INSERT,DELETE ON Employes TO helkarchou;
GRANT SELECT,UPDATE,INSERT,DELETE ON Clients_A TO helkarchou;
GRANT SELECT,UPDATE,INSERT,DELETE ON Commandes_A TO helkarchou;
GRANT SELECT,UPDATE,INSERT,DELETE ON D_Commandes_A TO helkarchou;
GRANT SELECT,UPDATE,INSERT,DELETE ON Stock_A TO helkarchou;

ALTER TABLE EMPLOYES ADD CONSTRAINT fkNoEmployes FOREIGN KEY(rend_compte) REFERENCES EMPLOYES(NO_EMPLOYE);
ALTER TABLE COMMANDE_A ADD CONSTRAINT fkCodeClient FOREIGN KEY(CODE_CLIENT) REFERENCES CLIENTS_A(CODE_CLIENT);
ALTER TABLE COMMANDE_A ADD CONSTRAINT fkNOEMPLOYE FOREIGN KEY (NO_EMPLOYE) REFERENCES EMPLOYES (NO_EMPLOYE);
ALTER TABLE D_COMMANDE_A ADD CONSTRAINT fkNOCOMMANDE FOREIGN KEY (NO_COMMANDE) REFERENCES COMMANDE_A(NO_COMMANDE);

CREATE OR REPLACE TRIGGER fk_D_Commandes_A_Produits
before INSERT OR UPDATE ON D_Commandes_A
for each row
DECLARE
   nbProd number;
BEGIN
    Select count(*)
    into nbProd
    FROM helkarchou.Produits@DBL_EdS
    where REF_PRODUIT = :NEW.REF_PRODUIT;
    IF nbProd = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_Produit invalide');
    END IF;
END;

CREATE OR REPLACE TRIGGER fk_STOCK_A
before INSERT OR UPDATE ON STOCK_A
for each row
DECLARE
   nbProd number;
BEGIN
    Select count(*)
    into nbProd
    FROM helkarchou.Produits@DBL_EdS
    where REF_PRODUIT = :NEW.REF_PRODUIT;
    IF nbProd = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'NO_Produit invalide');
    END IF;
END;

CREATE OR REPLACE TRIGGER Commandes_Employes
before DELETE ON EMPLOYES
for each row
DECLARE
   nbComEdS number;
   nbComEdN number;
   nbComO number;
   nbComF number;
   nbTotCom number;
BEGIN
    Select count(*)
    into nbComEdS
    FROM helkarchou.COMMANDES_EDS@DBL_EdS
    where NO_Employe = :OLD.NO_EMPLOYE;
    
    Select count(*)
    into nbComF
    FROM helkarchou.Commandes_F@DBL_EdS
    where NO_Employe = :OLD.NO_EMPLOYE;
    
    Select count(*)
    into nbComEdN
    FROM mlemseffer.Commandes_EdN@DBL_EdN
    where NO_Employe = :OLD.NO_EMPLOYE;
    
    Select count(*)
    into nbComO
    FROM mlemseffer.Commandes_O@DBL_EdN
    where NO_Employe = :OLD.NO_EMPLOYE;
    
    nbTotCom:=nbComEdS+nbComEdN+nbComO+nbComF;
    IF nbTotCom> 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'Employe qui s_occupe d_une commande');
    END IF;
END;
/

CREATE VIEW Clients AS
Select *
FROM Clients_A UNION ALL (Select * from mlemseffer.Clients_O@DBL_EdN UNION ALL (Select * from mlemseffer.Clients_EdN@DBL_EdN UNION ALL(Select * from helkarchou.Clients_F@DBL_EdS UNION ALL(Select * from helkarchou.Clients_EdS@DBL_EdS))));

CREATE VIEW D_Commandes AS
Select *
FROM D_Commandes_A UNION ALL (Select * from mlemseffer.D_Commandes_O@DBL_EdN UNION ALL (Select * from mlemseffer.D_Commandes_EdN@DBL_EdN UNION ALL(Select * from helkarchou.D_Commandes_F@DBL_EdS UNION ALL(Select * from helkarchou.D_Commandes_EdS@DBL_EdS))));

CREATE VIEW Commandes AS
Select *
FROM Commandes_A UNION ALL (Select * from mlemseffer.Commandes_O@DBL_EdN UNION ALL (Select * from mlemseffer.Commandes_EdN@DBL_EdN UNION ALL(Select * from helkarchou.Commandes_F@DBL_EdS UNION ALL(Select * from helkarchou.Commandes_EdS@DBL_EdS))));

CREATE VIEW Stock AS
Select *
FROM Stock_A UNION ALL (Select * from mlemseffer.Stock_O@DBL_EdN UNION ALL (Select * from mlemseffer.Stock_EdN@DBL_EdN UNION ALL(Select * from helkarchou.Stock_F@DBL_EdS UNION ALL(Select * from helkarchou.Stock_EdS@DBL_EdS))));

CREATE MATERIALIZED VIEW LOG ON Employes; 
