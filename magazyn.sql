-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Wrz 19, 2023 at 12:10 PM
-- Wersja serwera: 10.4.28-MariaDB
-- Wersja PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `magazyn`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `PrzydzielUprawnienia` ()   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE rola VARCHAR(255);

    -- Deklaruj kursor do iteracji przez rekordy w tabeli Uzytkownicy
    DECLARE cur CURSOR FOR SELECT Rola FROM Uzytkownicy;

    -- Obsługuje wyjątek, jeśli kursor jest pusty
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO rola;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Przydziel uprawnienia w zależności od roli
        CASE
            WHEN rola = 'Kierownik' THEN
                -- Przydziel uprawnienia dla roli Kierownik
                GRANT SELECT, INSERT, UPDATE, DELETE ON magazyn TO CURRENT_USER;
            WHEN rola = 'Klient' THEN
                -- Przydziel uprawnienia dla roli Klient
                GRANT SELECT ON magazyn.produkty TO CURRENT_USER;
            -- Dodaj inne przypadki, jeśli istnieją inne role
        END CASE;

    END LOOP;

    CLOSE cur;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `klienci`
--

CREATE TABLE `klienci` (
  `ID` int(11) NOT NULL,
  `Imie` varchar(255) NOT NULL,
  `Nazwisko` varchar(255) NOT NULL,
  `Adres` varchar(255) NOT NULL,
  `NumerTelefonu` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `klienci`
--

INSERT INTO `klienci` (`ID`, `Imie`, `Nazwisko`, `Adres`, `NumerTelefonu`) VALUES
(1, 'Jan', 'Kowalski', 'ul. Prosta 1 Warszawa', '123456789'),
(2, 'Anna', 'Nowk', 'ul. Kwiatowa 2 Kraków', '987654322'),
(3, 'Tomasz', 'Lis', 'ul. Leśna 3 Gdańsk', '555666777'),
(4, 'Magdalena', 'Wójcik', 'ul. Zielona 4 Poznań', '111222333'),
(5, 'Piotr', 'Zawisza', 'ul. Wesoła 5 Wrocław', '999888777');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `produkty`
--

CREATE TABLE `produkty` (
  `ID` int(11) NOT NULL,
  `NazwaProduktu` varchar(255) NOT NULL,
  `Opis` text DEFAULT NULL,
  `Cena` decimal(10,2) NOT NULL,
  `IloscDostepna` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `produkty`
--

INSERT INTO `produkty` (`ID`, `NazwaProduktu`, `Opis`, `Cena`, `IloscDostepna`) VALUES
(1, 'Telewizor LCD 42\"', 'Telewizor o rozmiarze 42 cali', 1499.99, 10),
(2, 'Laptop Dell XPS', 'Laptop z procesorem Intel i7', 1999.99, 5),
(3, 'Smartphone iPhone 13', 'Smartphone Apple z aparatem 12 MP', 999.99, 20),
(4, 'Tablet Samsung Galaxy Tab', 'Tablet z systemem Android', 499.99, 15),
(5, 'Kamera Canon EOS 80D', 'Lustrzanka cyfrowa z obiektywem', 1299.99, 8);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `szczegolyzamowienia`
--

CREATE TABLE `szczegolyzamowienia` (
  `ID` int(11) NOT NULL,
  `Zamowienie` int(11) DEFAULT NULL,
  `Produkt` int(11) DEFAULT NULL,
  `Ilosc` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `szczegolyzamowienia`
--

INSERT INTO `szczegolyzamowienia` (`ID`, `Zamowienie`, `Produkt`, `Ilosc`) VALUES
(1, 1, 1, 2),
(2, 1, 3, 3),
(3, 2, 2, 1),
(4, 3, 5, 2),
(5, 4, 4, 4);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `uzytkownicy`
--

CREATE TABLE `uzytkownicy` (
  `ID` int(11) NOT NULL,
  `NazwaUzytkownika` varchar(255) NOT NULL,
  `Haslo` varchar(255) NOT NULL,
  `Rola` enum('Kierownik','Klient') NOT NULL,
  `Klient_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `uzytkownicy`
--

INSERT INTO `uzytkownicy` (`ID`, `NazwaUzytkownika`, `Haslo`, `Rola`, `Klient_id`) VALUES
(2, 'klient1', 'klient123', 'Klient', 3),
(4, 'Kierownik1', 'kierownik123', 'Kierownik', NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `zamowienia`
--

CREATE TABLE `zamowienia` (
  `ID` int(11) NOT NULL,
  `DataZamowienia` date NOT NULL,
  `Klient` int(11) DEFAULT NULL,
  `StatusZamowienia` enum('Oczekujące','Zrealizowane') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `zamowienia`
--

INSERT INTO `zamowienia` (`ID`, `DataZamowienia`, `Klient`, `StatusZamowienia`) VALUES
(1, '2023-09-15', 1, 'Oczekujące'),
(2, '2023-09-16', 2, 'Oczekujące'),
(3, '2023-09-17', 3, 'Zrealizowane'),
(4, '2023-09-18', 4, 'Oczekujące'),
(5, '2023-09-19', 5, 'Zrealizowane');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `klienci`
--
ALTER TABLE `klienci`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `produkty`
--
ALTER TABLE `produkty`
  ADD PRIMARY KEY (`ID`);

--
-- Indeksy dla tabeli `szczegolyzamowienia`
--
ALTER TABLE `szczegolyzamowienia`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `Zamowienie` (`Zamowienie`),
  ADD KEY `Produkt` (`Produkt`);

--
-- Indeksy dla tabeli `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `Klient` (`Klient_id`);

--
-- Indeksy dla tabeli `zamowienia`
--
ALTER TABLE `zamowienia`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `Klient` (`Klient`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `klienci`
--
ALTER TABLE `klienci`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `produkty`
--
ALTER TABLE `produkty`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `szczegolyzamowienia`
--
ALTER TABLE `szczegolyzamowienia`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `zamowienia`
--
ALTER TABLE `zamowienia`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `szczegolyzamowienia`
--
ALTER TABLE `szczegolyzamowienia`
  ADD CONSTRAINT `szczegolyzamowienia_ibfk_1` FOREIGN KEY (`Zamowienie`) REFERENCES `zamowienia` (`ID`),
  ADD CONSTRAINT `szczegolyzamowienia_ibfk_2` FOREIGN KEY (`Produkt`) REFERENCES `produkty` (`ID`);

--
-- Constraints for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD CONSTRAINT `uzytkownicy_ibfk_1` FOREIGN KEY (`Klient_id`) REFERENCES `klienci` (`ID`);

--
-- Constraints for table `zamowienia`
--
ALTER TABLE `zamowienia`
  ADD CONSTRAINT `zamowienia_ibfk_1` FOREIGN KEY (`Klient`) REFERENCES `klienci` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
