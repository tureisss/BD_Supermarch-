-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mar. 12 nov. 2024 à 13:57
-- Version du serveur : 8.2.0
-- Version de PHP : 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mydb`
--

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

DROP TABLE IF EXISTS `client`;
CREATE TABLE IF NOT EXISTS `client` (
  `ID_Client` int NOT NULL,
  `Nom` varchar(50) DEFAULT NULL,
  `Prénom` varchar(50) DEFAULT NULL,
  `Adresse` varchar(100) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL,
  `Téléphone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`ID_Client`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`ID_Client`, `Nom`, `Prénom`, `Adresse`, `Email`, `Téléphone`) VALUES
(1, 'Dupont', 'Jean', '123 Rue A, Paris', 'jean.dupont@example.com', '0102030405'),
(2, 'Martin', 'Marie', '456 Rue B, Lyon', 'marie.martin@example.com', '0607080910');

-- --------------------------------------------------------

--
-- Structure de la table `employé`
--

DROP TABLE IF EXISTS `employé`;
CREATE TABLE IF NOT EXISTS `employé` (
  `ID_Employé` int NOT NULL,
  `Nom` varchar(50) DEFAULT NULL,
  `Prénom` varchar(50) DEFAULT NULL,
  `Poste` varchar(50) DEFAULT NULL,
  `Salaire` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`ID_Employé`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `employé`
--

INSERT INTO `employé` (`ID_Employé`, `Nom`, `Prénom`, `Poste`, `Salaire`) VALUES
(501, 'Bernard', 'Alice', 'Caissière', 1500.00),
(502, 'Leroy', 'Pierre', 'Manager', 3000.00);

-- --------------------------------------------------------

--
-- Structure de la table `facture`
--

DROP TABLE IF EXISTS `facture`;
CREATE TABLE IF NOT EXISTS `facture` (
  `ID_Facture` int NOT NULL,
  `ID_Panier` int DEFAULT NULL,
  `Total` decimal(10,2) DEFAULT NULL,
  `Date_Facture` date DEFAULT NULL,
  PRIMARY KEY (`ID_Facture`),
  KEY `fk_Facture_Panier` (`ID_Panier`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `facture`
--

INSERT INTO `facture` (`ID_Facture`, `ID_Panier`, `Total`, `Date_Facture`) VALUES
(501, 101, 100.50, '2024-01-03'),
(502, 102, 200.75, '2024-01-04');

-- --------------------------------------------------------

--
-- Structure de la table `fournisseur`
--

DROP TABLE IF EXISTS `fournisseur`;
CREATE TABLE IF NOT EXISTS `fournisseur` (
  `ID_Fournisseur` int NOT NULL,
  `Nom` varchar(50) DEFAULT NULL,
  `Adresse` varchar(100) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL,
  `Téléphone` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`ID_Fournisseur`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `fournisseur`
--

INSERT INTO `fournisseur` (`ID_Fournisseur`, `Nom`, `Adresse`, `Email`, `Téléphone`) VALUES
(401, 'Fournisseur A', '789 Rue C, Marseille', 'contact@fournisseura.com', '0708091011'),
(402, 'Fournisseur B', '101 Rue D, Nice', 'contact@fournisseurb.com', '0506070809');

-- --------------------------------------------------------

--
-- Structure de la table `panier`
--

DROP TABLE IF EXISTS `panier`;
CREATE TABLE IF NOT EXISTS `panier` (
  `ID_Panier` int NOT NULL,
  `ID_Client` int DEFAULT NULL,
  `Date_Ajout` date DEFAULT NULL,
  `Statut` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID_Panier`),
  KEY `fk_Panier_Client` (`ID_Client`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `panier`
--

INSERT INTO `panier` (`ID_Panier`, `ID_Client`, `Date_Ajout`, `Statut`) VALUES
(102, 2, '2024-01-02', 'Completé'),
(104, 1, '2024-05-30', 'En attente'),
(105, 1, '2024-05-30', 'En attente');

-- --------------------------------------------------------

--
-- Structure de la table `panier_produit`
--

DROP TABLE IF EXISTS `panier_produit`;
CREATE TABLE IF NOT EXISTS `panier_produit` (
  `ID_Panier` int NOT NULL,
  `ID_Produit` int NOT NULL,
  `Quantité` int DEFAULT NULL,
  PRIMARY KEY (`ID_Panier`,`ID_Produit`),
  KEY `fk_Panier_Produit_Produit` (`ID_Produit`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `panier_produit`
--

INSERT INTO `panier_produit` (`ID_Panier`, `ID_Produit`, `Quantité`) VALUES
(101, 201, 2),
(101, 202, 1),
(102, 202, 3),
(103, 201, 5),
(105, 201, 5);

--
-- Déclencheurs `panier_produit`
--
DROP TRIGGER IF EXISTS `update_stock_after_delete`;
DELIMITER $$
CREATE TRIGGER `update_stock_after_delete` AFTER DELETE ON `panier_produit` FOR EACH ROW BEGIN
  -- Met à jour le stock du produit en rajoutant la quantité supprimée
  UPDATE produit
  SET Stock = Stock + OLD.Quantité
  WHERE ID_Produit = OLD.ID_Produit;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `update_stock_after_insert`;
DELIMITER $$
CREATE TRIGGER `update_stock_after_insert` AFTER INSERT ON `panier_produit` FOR EACH ROW BEGIN
  -- Met à jour le stock du produit en déduisant la quantité achetée
  UPDATE produit
  SET Stock = Stock - NEW.Quantité
  WHERE ID_Produit = NEW.ID_Produit;
  
  -- Vérifie que le stock ne devient pas négatif
  IF (SELECT Stock FROM produit WHERE ID_Produit = NEW.ID_Produit) < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Le stock ne peut pas être négatif.';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

DROP TABLE IF EXISTS `produit`;
CREATE TABLE IF NOT EXISTS `produit` (
  `ID_Produit` int NOT NULL,
  `Nom` varchar(50) DEFAULT NULL,
  `Prix` decimal(10,2) DEFAULT NULL,
  `Stock` int DEFAULT NULL,
  `Date_Ajout` date DEFAULT NULL,
  `Date_Expire` date DEFAULT NULL,
  PRIMARY KEY (`ID_Produit`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`ID_Produit`, `Nom`, `Prix`, `Stock`, `Date_Ajout`, `Date_Expire`) VALUES
(201, 'Lait', 1.50, 95, '2024-01-01', '2024-06-01'),
(202, 'Pain', 2.00, 50, '2024-01-01', '2024-01-31');

-- --------------------------------------------------------

--
-- Structure de la table `produit_fournisseur`
--

DROP TABLE IF EXISTS `produit_fournisseur`;
CREATE TABLE IF NOT EXISTS `produit_fournisseur` (
  `ID_Produit` int NOT NULL,
  `ID_Fournisseur` int NOT NULL,
  PRIMARY KEY (`ID_Produit`,`ID_Fournisseur`),
  KEY `fk_Produit_Fournisseur_Fournisseur` (`ID_Fournisseur`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `produit_fournisseur`
--

INSERT INTO `produit_fournisseur` (`ID_Produit`, `ID_Fournisseur`) VALUES
(201, 401),
(202, 402);

-- --------------------------------------------------------

--
-- Structure de la table `produit_promotion`
--

DROP TABLE IF EXISTS `produit_promotion`;
CREATE TABLE IF NOT EXISTS `produit_promotion` (
  `ID_Produit` int NOT NULL,
  `ID_Promotion` int NOT NULL,
  PRIMARY KEY (`ID_Produit`,`ID_Promotion`),
  KEY `fk_Produit_Promotion_Promotion` (`ID_Promotion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `produit_promotion`
--

INSERT INTO `produit_promotion` (`ID_Produit`, `ID_Promotion`) VALUES
(201, 601),
(202, 602);

-- --------------------------------------------------------

--
-- Structure de la table `produit_rayon`
--

DROP TABLE IF EXISTS `produit_rayon`;
CREATE TABLE IF NOT EXISTS `produit_rayon` (
  `ID_Produit` int NOT NULL,
  `ID_Rayon` int NOT NULL,
  PRIMARY KEY (`ID_Produit`,`ID_Rayon`),
  KEY `fk_Produit_Rayon_Rayon` (`ID_Rayon`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `produit_rayon`
--

INSERT INTO `produit_rayon` (`ID_Produit`, `ID_Rayon`) VALUES
(201, 301),
(202, 302);

-- --------------------------------------------------------

--
-- Structure de la table `promotion`
--

DROP TABLE IF EXISTS `promotion`;
CREATE TABLE IF NOT EXISTS `promotion` (
  `ID_Promotion` int NOT NULL,
  `Réduction` decimal(5,2) DEFAULT NULL,
  `Date_Début` date DEFAULT NULL,
  `Date_Fin` date DEFAULT NULL,
  PRIMARY KEY (`ID_Promotion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `promotion`
--

INSERT INTO `promotion` (`ID_Promotion`, `Réduction`, `Date_Début`, `Date_Fin`) VALUES
(601, 0.20, '2024-01-10', '2024-01-20'),
(602, 0.15, '2024-01-15', '2024-01-25');

-- --------------------------------------------------------

--
-- Structure de la table `rayon`
--

DROP TABLE IF EXISTS `rayon`;
CREATE TABLE IF NOT EXISTS `rayon` (
  `ID_Rayon` int NOT NULL,
  `Nom` varchar(50) DEFAULT NULL,
  `Employé_ID_Employé` int NOT NULL,
  PRIMARY KEY (`ID_Rayon`),
  KEY `fk_Rayon_Employé` (`Employé_ID_Employé`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

--
-- Déchargement des données de la table `rayon`
--

INSERT INTO `rayon` (`ID_Rayon`, `Nom`, `Employé_ID_Employé`) VALUES
(301, 'Produits laitiers', 501),
(302, 'Boulangerie', 502);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
