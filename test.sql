-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 01, 2024 at 06:55 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `test`
--

-- --------------------------------------------------------

--
-- Table structure for table `results`
--

CREATE TABLE `results` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  `ies_result` varchar(255) NOT NULL,
  `amount_won` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `results`
--

INSERT INTO `results` (`id`, `username`, `amount`, `ies_result`, `amount_won`) VALUES
(1, 'udit', 100, 'Won', 200),
(2, 'udit', 100, 'Won', 200),
(3, 'udit', 100, 'Won', 200),
(4, 'udit', 100, 'Loss', -100),
(5, 'udit', 300, 'Won', 600),
(6, 'udit', 700, 'Loss', -700),
(7, 'udit', 20, 'Loss', -20),
(8, 'udit', 50, 'Loss', -50),
(9, 'udit', 50, 'Won', 100),
(10, 'udit', 110, 'Loss', -110),
(11, 'udit', 100, 'Loss', -100),
(12, 'udit', 100, 'Loss', -100),
(13, 'udit', 60, 'Loss', -60),
(14, 'udit', 60, 'Loss', -60),
(15, 'udit', 50, 'Loss', -50);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `balance` int(11) NOT NULL,
  `wins` int(11) DEFAULT 0,
  `losses` int(11) DEFAULT 0,
  `ties` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `balance`, `wins`, `losses`, `ties`) VALUES
(1, 'udit', 0, 17, 30, 1),
(2, 'user', 10, 32, 136, 2),
(3, 'samar', 10, 1, 10, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `results`
--
ALTER TABLE `results`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `results`
--
ALTER TABLE `results`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
