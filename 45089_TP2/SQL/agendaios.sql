-- phpMyAdmin SQL Dump
-- version 3.4.11.1deb2+deb7u8
-- http://www.phpmyadmin.net
--
-- Máquina: localhost
-- Data de Criação: 28-Fev-2018 às 12:53
-- Versão do servidor: 5.5.57
-- versão do PHP: 5.4.45-0+deb7u11

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de Dados: `agendaios`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `contatos`
--

CREATE TABLE IF NOT EXISTS `contatos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(50) NOT NULL,
  `apelido` varchar(50) NOT NULL,
  `telemovel` int(11) NOT NULL,
  `localidade` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Extraindo dados da tabela `contatos`
--

INSERT INTO `contatos` (`id`, `nome`, `apelido`, `telemovel`, `localidade`) VALUES
(1, 'Serious', 'Jirengoku', 2726226, 'Porto'),
(2, 'Aluno', 'ISTEC', 213456765, 'Braga'),
(3, 'Andre', 'Marques', 965456876, 'BraganÃ§a');

-- --------------------------------------------------------

--
-- Estrutura da tabela `lembrete`
--

CREATE TABLE IF NOT EXISTS `lembrete` (
  `idlembrete` int(11) NOT NULL AUTO_INCREMENT,
  `idcontacto` int(11) NOT NULL,
  `titulo` varchar(50) NOT NULL,
  `conteudo` varchar(100) NOT NULL,
  PRIMARY KEY (`idlembrete`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Extraindo dados da tabela `lembrete`
--

INSERT INTO `lembrete` (`idlembrete`, `idcontacto`, `titulo`, `conteudo`) VALUES
(1, 2, 'Trabalho', 'Realizar o trabalho da escola');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
