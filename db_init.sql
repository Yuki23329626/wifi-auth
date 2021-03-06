-- 用來初始化 mysql database 並輸入資料的 SQL
SHOW DATABASE;
CREATE DATABASE wifi_auth;
USE wifi_auth;
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 匯入使用者跟密碼到 'user' 這個 table
INSERT INTO `user` (`id`, `name`, `password`) VALUES
(1,	'user001',	'001001'),
(2,	'user002',	'002002'),
(3,	'user003',	'003003'),
(4,	'user004',	'004004'),
(5,	'user005',	'005005'),
(6,	'user006',	'006006');

