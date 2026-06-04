-- ================================================================
-- FRANK PC EINSTEIN — Base de datos completa
-- data_base_components.sql
--
-- Contenido:
--   1. DDL — Creación de la base de datos y sus tablas
--   2. DML — Datos de referencia (diccionarios)
--   3. DML — Componentes por tier (Gama Entrada → Entusiasta)
--   4. DML — Soporte de sockets por refrigeración
--
-- Ejecución: mariadb -u root -p < data_base_components.sql
-- ================================================================

-- DROP DATABASE IF EXISTS componentes_pc;
CREATE DATABASE componentes_pc;
USE componentes_pc;

-- ================================================================
-- 1. DDL — TABLAS DE REFERENCIA (diccionarios)
-- ================================================================

-- Sockets de procesador soportados
CREATE TABLE ref_socket (
  id_socket INT PRIMARY KEY AUTO_INCREMENT,
  nombre    VARCHAR(20) UNIQUE NOT NULL
);

-- Factores de forma de placa base / caja
CREATE TABLE ref_form_factor (
  id_form_factor INT PRIMARY KEY AUTO_INCREMENT,
  nombre         VARCHAR(20) UNIQUE NOT NULL
);

-- Gamas de rendimiento (tiers 1-5)
CREATE TABLE ref_tier (
  id_tier        INT PRIMARY KEY AUTO_INCREMENT,
  nombre         VARCHAR(60) UNIQUE NOT NULL,
  nivel_numerico INT NOT NULL,
  descripcion    VARCHAR(255)
);

-- ================================================================
-- 2. DDL — TABLAS DE COMPONENTES
-- ================================================================

CREATE TABLE cpu (
  id_cpu             INT PRIMARY KEY AUTO_INCREMENT,
  modelo             VARCHAR(100) NOT NULL,
  id_socket          INT NOT NULL,
  id_tier            INT NOT NULL,
  nucleos            INT NOT NULL,
  hilos              INT NOT NULL,
  frecuencia_base_mhz INT NOT NULL,
  tdp_w              INT NOT NULL,
  max_ram_freq_mhz   INT NOT NULL,
  graficos_integrados TINYINT(1) DEFAULT 0,
  FOREIGN KEY (id_socket) REFERENCES ref_socket(id_socket),
  FOREIGN KEY (id_tier)   REFERENCES ref_tier(id_tier)
);

CREATE TABLE motherboard (
  id_mobo          INT PRIMARY KEY AUTO_INCREMENT,
  modelo           VARCHAR(100) NOT NULL,
  id_socket        INT NOT NULL,
  id_form_factor   INT NOT NULL,
  id_tier          INT NOT NULL,
  chipset          VARCHAR(20) NOT NULL,
  tipo_ram         VARCHAR(10) CHECK (tipo_ram IN ('DDR4','DDR5')),
  ranuras_ram      INT NOT NULL,
  wifi_integrado   TINYINT(1) DEFAULT 0,
  m2_slots_total   INT NOT NULL,
  sata_version_max INT DEFAULT 3,
  FOREIGN KEY (id_socket)      REFERENCES ref_socket(id_socket),
  FOREIGN KEY (id_form_factor) REFERENCES ref_form_factor(id_form_factor),
  FOREIGN KEY (id_tier)        REFERENCES ref_tier(id_tier)
);

CREATE TABLE ram (
  id_ram           INT PRIMARY KEY AUTO_INCREMENT,
  modelo           VARCHAR(100),
  tipo             VARCHAR(10) CHECK (tipo IN ('DDR4','DDR5')),
  id_tier          INT NOT NULL,
  capacidad_modulo_gb INT NOT NULL,
  modulos_pack     INT DEFAULT 1,   -- 1=Single, 2=Kit Dual Channel
  frecuencia_mhz   INT NOT NULL,
  latencia_cl      INT,
  altura_mm        DECIMAL(4,1),
  FOREIGN KEY (id_tier) REFERENCES ref_tier(id_tier)
);

CREATE TABLE storage (
  id_storage       INT PRIMARY KEY AUTO_INCREMENT,
  modelo           VARCHAR(100),
  tipo             ENUM('HDD','SATA_SSD','NVME') NOT NULL,
  id_tier          INT NOT NULL,
  formato          VARCHAR(20),       -- '2.5', '3.5', 'M.2'
  interfaz_version INT,              -- SATA:3 / NVMe Gen:3,4,5
  lectura_mb_s     INT,
  FOREIGN KEY (id_tier) REFERENCES ref_tier(id_tier)
);

CREATE TABLE gpu (
  id_gpu           INT PRIMARY KEY AUTO_INCREMENT,
  chipset          VARCHAR(80) NOT NULL,  -- incluye VRAM y TDP en el nombre
  id_tier          INT NOT NULL,
  vram_gb          INT NOT NULL,
  longitud_mm      INT NOT NULL,
  tdp_w            INT NOT NULL,
  req_8pin_pcie    INT DEFAULT 0,    -- nº de conectores PCIe 8-pin necesarios
  req_12vhpwr      INT DEFAULT 0,    -- nº de conectores 12VHPWR (PCIe 5.0) necesarios
  FOREIGN KEY (id_tier) REFERENCES ref_tier(id_tier)
);

CREATE TABLE psu (
  id_psu           INT PRIMARY KEY AUTO_INCREMENT,
  modelo           VARCHAR(100),
  id_tier          INT NOT NULL,
  potencia_w       INT NOT NULL,
  longitud_mm      INT,
  conn_8pin_pcie   INT DEFAULT 0,    -- conectores PCIe 8-pin disponibles
  conn_12vhpwr     INT DEFAULT 0,    -- conectores 12VHPWR disponibles
  FOREIGN KEY (id_tier) REFERENCES ref_tier(id_tier)
);

CREATE TABLE pc_case (
  id_case               INT PRIMARY KEY AUTO_INCREMENT,
  modelo                VARCHAR(100),
  id_form_factor_max    INT,          -- mayor placa base que admite
  id_tier               INT NOT NULL,
  max_gpu_len_mm        INT NOT NULL,
  max_cpu_cooler_height_mm INT NOT NULL,
  max_psu_len_mm        INT,
  FOREIGN KEY (id_form_factor_max) REFERENCES ref_form_factor(id_form_factor),
  FOREIGN KEY (id_tier)            REFERENCES ref_tier(id_tier)
);

CREATE TABLE cooler (
  id_cooler        INT PRIMARY KEY AUTO_INCREMENT,
  modelo           VARCHAR(100),
  tipo             ENUM('AIRE','AIO') NOT NULL,
  id_tier          INT NOT NULL,
  altura_mm        INT,           -- altura del disipador / bomba AIO
  tamano_radiador_mm INT,         -- 0=aire, 240/360/420=AIO
  tdp_max_w        INT,
  FOREIGN KEY (id_tier) REFERENCES ref_tier(id_tier)
);

-- Tabla pivote: qué coolers son compatibles con qué sockets
CREATE TABLE cooler_socket_support (
  id_cooler INT,
  id_socket INT,
  PRIMARY KEY (id_cooler, id_socket),
  FOREIGN KEY (id_cooler) REFERENCES cooler(id_cooler),
  FOREIGN KEY (id_socket) REFERENCES ref_socket(id_socket)
);

-- ================================================================
-- 3. DML — DATOS DE REFERENCIA
-- ================================================================

INSERT INTO ref_socket (nombre) VALUES ('AM4'),('LGA1700'),('AM5');
-- IDs resultantes: 1=AM4  2=LGA1700  3=AM5

INSERT INTO ref_form_factor (nombre) VALUES ('ATX'),('mATX'),('ITX');
-- IDs resultantes: 1=ATX  2=mATX  3=ITX

INSERT INTO ref_tier (id_tier, nombre, nivel_numerico, descripcion) VALUES
  (1,'Gama de Entrada',                 1,'Ofimática y multimedia. i3/Ryzen3, 8GB RAM, SSD SATA.'),
  (2,'Gama Media',                      2,'Gaming 1080p. i5/Ryzen5, 16GB RAM, RTX 4060.'),
  (3,'Alto Rendimiento',                3,'Gaming 1440p raster. Ryzen 7 5000, 32GB DDR4, Gen4 NVMe.'),
  (4,'Gama Alta Moderna',               4,'Gaming 4K entry. Ryzen 7000X3D, 32GB DDR5, RTX 4080.'),
  (5,'Gama Entusiasta',                 5,'God Mode 2026. Ryzen 9000, 64GB DDR5, RTX 5090.');

-- ================================================================
-- 4. DML — CPU
-- Criterio de tier: T1=≤4c  T2=6c moderno  T3=8c ant./6c top
--                  T4=8-12c moderno alto rendimiento  T5=16+c/flagship
-- ================================================================

INSERT INTO cpu (modelo,id_socket,id_tier,nucleos,hilos,frecuencia_base_mhz,tdp_w,max_ram_freq_mhz,graficos_integrados) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Intel Core i3-12100',         2,1, 4, 8,3300, 60,3200,1),
('AMD Ryzen 3 4100',            1,1, 4, 8,3800, 65,3200,0),
('AMD Athlon 3000G',            1,1, 2, 4,3500, 35,2667,1),
('Intel Pentium Gold G7400',    2,1, 2, 4,3700, 46,4800,1),
('Intel Core i3-13100',         2,1, 4, 8,3400, 60,4800,1),
('Intel Core i3-12100F',        2,1, 4, 8,3300, 58,4800,0),
('AMD Ryzen 3 3300X',           1,1, 4, 8,3800, 65,3200,0),
('AMD Ryzen 3 3100',            1,1, 4, 8,3600, 65,3200,0),
('AMD Ryzen 3 PRO 4350G',       1,1, 4, 8,3800, 65,3200,1),
('Intel Core i3-12300',         2,1, 4, 8,3500, 60,4800,1),
-- ── TIER 2 ──────────────────────────────────────────────────────
('AMD Ryzen 5 7600',            3,2, 6,12,3800, 65,5200,1),
('Intel Core i5-12400F',        2,2, 6,12,2500, 65,4800,0),
('AMD Ryzen 5 5600',            1,2, 6,12,3500, 65,3200,0),
('AMD Ryzen 5 7500F',           3,2, 6,12,3700, 65,5200,0),
('AMD Ryzen 5 5500',            1,2, 6,12,3600, 65,3200,0),
('AMD Ryzen 5 5600G',           1,2, 6,12,3900, 65,3200,1),
('AMD Ryzen 5 7600X',           3,2, 6,12,4700,105,5200,0),
('Intel Core i5-12400',         2,2, 6,12,2500, 65,4800,1),
('Intel Core i5-13400F',        2,2,10,16,2500, 65,4800,0),
('AMD Ryzen 5 4600G',           1,2, 6,12,3700, 65,3200,1),
-- ── TIER 3 ──────────────────────────────────────────────────────
('AMD Ryzen 7 5800X',           1,3, 8,16,3800,105,3200,0),
('Intel Core i5-12600K',        2,3,10,16,3700,125,4800,1),
('AMD Ryzen 7 5800X3D',         1,3, 8,16,3400,105,3200,0),
('AMD Ryzen 7 5700',            1,3, 8,16,3700, 65,3200,0),
('AMD Ryzen 7 5700G',           1,3, 8,16,3800, 65,3200,1),
('Intel Core i5-13600K',        2,3,14,20,3500,125,5600,1),
('Intel Core i5-13600KF',       2,3,14,20,3500,125,5600,0),
('AMD Ryzen 7 5700X3D',         1,3, 8,16,3000,105,3200,0),
('Intel Core i7-12700F',        2,3,12,20,2700, 65,4800,0),
-- ── TIER 4 ──────────────────────────────────────────────────────
('AMD Ryzen 7 7800X3D',         3,4, 8,16,4200,120,5200,1),
('Intel Core i7-14700K',        2,4,20,28,3400,125,5600,1),
('AMD Ryzen 9 7900X',           3,4,12,24,4700,170,5200,0),
('AMD Ryzen 9 7900',            3,4,12,24,3700, 65,5200,0),
('Intel Core i9-13900K',        2,4,24,32,3000,125,5600,1),
('Intel Core i7-13700K',        2,4,16,24,3400,125,5600,1),
('AMD Ryzen 9 7950X3D',         3,4,16,32,4200,120,5200,0),
('Intel Core i7-14700KF',       2,4,20,28,3400,125,5600,0),
('AMD Ryzen 9 7900X3D',         3,4,12,24,4400,120,5200,0),
('Intel Core i9-14900KF',       2,4,24,32,3200,125,5600,0),
('AMD Ryzen 9 9700X',           3,4, 8,16,3800, 65,6400,0),
-- ── TIER 5 ──────────────────────────────────────────────────────
('AMD Ryzen 9 9950X',           3,5,16,32,4500,170,6400,1),
('Intel Core i9-14900K',        2,5,24,32,3200,125,5600,1),
('AMD Ryzen 9 7950X',           3,5,16,32,4500,170,5200,0),
('AMD Ryzen 9 9900X',           3,5,12,24,4400,120,6400,0),
('Intel Core i9-14900KS',       2,5,24,32,3200,150,5600,1),
('Intel Core i9-13900KS',       2,5,24,32,3200,150,5600,1),
('Intel Core Ultra 9 285K',     2,5,24,24,3700,125,5600,1),
('AMD Ryzen 9 9900',            3,5,12,24,3500, 65,6400,0),
('AMD Ryzen 9 9950X3D',         3,5,16,32,4000,170,6400,0);

-- ================================================================
-- 5. DML — MOTHERBOARD
-- Criterio de tier: T1=H/A series  T2=B básica  T3=B premium/Z ant.
--                  T4=Z/X actual  T5=Flagship
-- ================================================================

INSERT INTO motherboard (modelo,id_socket,id_form_factor,id_tier,chipset,tipo_ram,ranuras_ram,wifi_integrado,m2_slots_total,sata_version_max) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Gigabyte H610M S2H',              2,2,1,'H610','DDR4',2,0,1,3),
('ASRock H510M-HDV',                2,2,1,'H510','DDR4',2,0,1,3),
('Gigabyte A520M K',                1,2,1,'A520','DDR4',2,0,1,3),
('MSI A520M-A PRO',                 1,2,1,'A520','DDR4',2,0,1,3),
('ASUS PRIME A320M-K',              1,2,1,'A320','DDR4',2,0,1,3),
('ASRock A520M Pro4',               1,2,1,'A520','DDR4',4,0,1,3),
('MSI PRO H610M-E DDR4',            2,2,1,'H610','DDR4',2,0,1,3),
('Gigabyte H510M H',                2,2,1,'H510','DDR4',2,0,1,3),
('ASUS PRIME H610M-K D4',           2,2,1,'H610','DDR4',2,0,1,3),
('Gigabyte A620M H',                3,2,1,'A620','DDR5',2,0,1,3),
-- ── TIER 2 ──────────────────────────────────────────────────────
('MSI PRO B650M-A WiFi',            3,2,2,'B650','DDR5',4,1,2,3),
('ASUS PRIME B660M-K D4',           2,2,2,'B660','DDR4',2,0,1,3),
('Gigabyte B450M DS3H V2',          1,2,2,'B450','DDR4',4,0,1,3),
('ASUS PRIME B650-PLUS WiFi',       3,1,2,'B650','DDR5',4,1,2,3),
('Gigabyte B660 Gaming X AX',       2,1,2,'B660','DDR4',4,1,2,3),
('MSI MAG B450M MORTAR MAX',        1,2,2,'B450','DDR4',4,0,1,3),
('MSI PRO B560M-A',                 2,2,2,'B560','DDR4',2,0,1,3),
('ASRock B650M Pro RS WiFi',        3,2,2,'B650','DDR5',4,1,1,3),
('Gigabyte B760M DS3H DDR4',        2,2,2,'B760','DDR4',4,0,2,3),
-- ── TIER 3 ──────────────────────────────────────────────────────
('MSI MAG B550 Tomahawk Max WiFi',  1,1,3,'B550','DDR4',4,1,2,3),
('ASUS TUF Gaming B550-PLUS WiFi',  1,1,3,'B550','DDR4',4,1,2,3),
('MSI B660 Gaming Plus WiFi',       2,1,3,'B660','DDR4',4,1,2,3),
('Gigabyte B650 Aorus Elite AX',    3,1,3,'B650','DDR5',4,1,3,3),
('ASUS TUF Gaming B650-PLUS WiFi',  3,1,3,'B650','DDR5',4,1,3,3),
('MSI MAG B760 Tomahawk WiFi',      2,1,3,'B760','DDR5',4,1,2,3),
('Gigabyte B650 AORUS Pro AX',      3,1,3,'B650','DDR5',4,1,3,3),
('MSI PRO Z690-A DDR4 WiFi',        2,1,3,'Z690','DDR4',4,1,4,3),
('ASUS PRIME Z690-P D4',            2,1,3,'Z690','DDR4',4,0,3,3),
('ASRock B650E PG Riptide WiFi',    3,1,3,'B650E','DDR5',4,1,3,3),
-- ── TIER 4 ──────────────────────────────────────────────────────
('ASUS ROG Strix X670E-F',          3,1,4,'X670E','DDR5',4,1,4,3),
('ASUS ROG Strix Z790-E Gaming WiFi II',2,1,4,'Z790','DDR5',4,1,5,3),
('Gigabyte X670E Aorus Master',     3,1,4,'X670E','DDR5',4,1,5,3),
('MSI MEG Z790 Ace',                2,1,4,'Z790','DDR5',4,1,5,3),
('Gigabyte Z790 AORUS Elite AX',    2,1,4,'Z790','DDR5',4,1,5,3),
('MSI MAG X670E Tomahawk WiFi',     3,1,4,'X670E','DDR5',4,1,4,3),
('ASUS ProArt X670E-Creator WiFi',  3,1,4,'X670E','DDR5',4,1,5,3),
('ASRock Z790 Taichi',              2,1,4,'Z790','DDR5',4,1,5,3),
('ASUS ROG Crosshair X670E Hero',   3,1,4,'X670E','DDR5',4,1,5,3),
('Gigabyte X870 AORUS Elite WiFi7', 3,1,4,'X870','DDR5',4,1,5,3),
-- ── TIER 5 ──────────────────────────────────────────────────────
('MSI MEG X870E GODLIKE',           3,1,5,'X870E','DDR5',4,1,5,3),
('ASUS ROG Maximus Z790 Apex',      2,1,5,'Z790','DDR5',4,1,5,3),
('Gigabyte X870E Aorus Tarus',      3,1,5,'X870E','DDR5',4,1,5,3),
('MSI MEG Z790 Godlike',            2,1,5,'Z790','DDR5',4,1,6,3),
('ASUS ROG Maximus Z790 Extreme',   2,1,5,'Z790','DDR5',4,1,5,3),
('Gigabyte Z790 AORUS Xtreme X',    2,1,5,'Z790','DDR5',4,1,6,3),
('MSI MEG X870E ACE',               3,1,5,'X870E','DDR5',4,1,5,3),
('ASUS ROG Crosshair X870E Extreme',3,1,5,'X870E','DDR5',4,1,6,3),
('ASRock X870E Taichi Lite',        3,1,5,'X870E','DDR5',4,1,5,3),
('Gigabyte X870E AORUS Master',     3,1,5,'X870E','DDR5',4,1,6,3);

-- ================================================================
-- 6. DML — RAM
-- Criterio: T1=8GB single  T2=16GB dual  T3=32GB  T4=32GB DDR5≥6000
--           T5=64GB+  o  frecuencias extremas >7200MHz
-- ================================================================

INSERT INTO ram (modelo,tipo,id_tier,capacidad_modulo_gb,modulos_pack,frecuencia_mhz,latencia_cl,altura_mm) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Crucial Basics 8GB DDR4-2666MHz',        'DDR4',1,8,1,2666,19,31.0),
('Kingston ValueRAM 8GB DDR4-2666MHz',     'DDR4',1,8,1,2666,19,31.3),
('Corsair Vengeance LPX 8GB DDR4-3200MHz', 'DDR4',1,8,1,3200,16,31.3),
('Patriot Signature 8GB DDR4-2666MHz',     'DDR4',1,8,1,2666,19,31.0),
('Corsair ValueSelect 8GB DDR4-2666MHz',   'DDR4',1,8,1,2666,18,31.0),
('G.Skill Value 8GB DDR4-2133MHz',         'DDR4',1,8,1,2133,15,31.0),
('Kingston HyperX Fury 8GB DDR4-3200MHz',  'DDR4',1,8,1,3200,16,34.0),
-- ── TIER 2 ──────────────────────────────────────────────────────
('Kingston Fury Beast 16GB DDR5-5200MHz',  'DDR5',2,8,2,5200,40,35.0),
('Corsair Vengeance LPX 16GB DDR4-3200MHz','DDR4',2,8,2,3200,16,31.3),
('G.Skill Aegis 16GB DDR4-3600MHz',        'DDR4',2,8,2,3600,18,37.0),
('Kingston Fury Beast 16GB DDR5-5200MHz',  'DDR5',2,8,2,5200,40,35.0),
('Patriot Viper Steel 16GB DDR4-3600MHz',  'DDR4',2,8,2,3600,20,38.0),
('Crucial Ballistix 16GB DDR4-3200MHz',    'DDR4',2,8,2,3200,16,34.0),
('Corsair Vengeance 16GB DDR5-4800MHz',    'DDR5',2,8,2,4800,40,35.0),
('SK Hynix Platinum P41 16GB DDR5-5200MHz','DDR5',2,8,2,5200,38,38.0),
-- ── TIER 3 ──────────────────────────────────────────────────────
('G.Skill Ripjaws V 32GB DDR4-3600MHz',        'DDR4',3,16,2,3600,16,42.0),
('Corsair Vengeance DDR4 32GB DDR4-3600MHz',   'DDR4',3,16,2,3600,18,34.0),
('Kingston Fury Beast 32GB DDR4-3600MHz',      'DDR4',3,16,2,3600,18,35.0),
('Corsair Vengeance DDR5 32GB DDR5-5200MHz',   'DDR5',3,16,2,5200,40,35.0),
('Crucial Ballistix MAX 32GB DDR4-4000MHz',    'DDR4',3,16,2,4000,18,34.0),
('Patriot Viper 4 Blackout 32GB DDR4-3600MHz', 'DDR4',3,16,2,3600,18,40.0),
('G.Skill Trident Z Neo 32GB DDR5-6000MHz',    'DDR5',3,16,2,6000,30,44.0),
('Kingston Fury Beast 32GB DDR5-5200MHz',      'DDR5',3,16,2,5200,40,35.0),
-- ── TIER 4 ──────────────────────────────────────────────────────
('G.Skill Trident Z5 Neo RGB 32GB DDR5-6000MHz',  'DDR5',4,16,2,6000,30,44.0),
('Corsair Dominator Platinum 32GB DDR5-6200MHz',  'DDR5',4,16,2,6200,36,52.0),
('Kingston Fury Renegade 32GB DDR5-6400MHz',      'DDR5',4,16,2,6400,32,42.0),
('G.Skill Trident Z5 RGB 32GB DDR5-6000MHz',      'DDR5',4,16,2,6000,30,44.0),
('Corsair Dominator Platinum RGB 32GB DDR5-6400MHz','DDR5',4,16,2,6400,32,52.0),
('G.Skill Trident Z5 32GB DDR5-6400MHz',          'DDR5',4,16,2,6400,32,44.0),
('TeamGroup T-Force Delta 32GB DDR5-6200MHz',     'DDR5',4,16,2,6200,38,38.0),
('Patriot Viper Venom 32GB DDR5-6600MHz',         'DDR5',4,16,2,6600,34,41.0),
-- ── TIER 5 ──────────────────────────────────────────────────────
('Corsair Dominator Titanium 64GB DDR5-7200MHz',  'DDR5',5,32,2,7200,34,57.0),
('G.Skill Trident Z5 RGB 64GB DDR5-6400MHz',      'DDR5',5,32,2,6400,32,44.0),
('Kingston Fury Renegade 64GB DDR5-7200MHz',      'DDR5',5,32,2,7200,38,42.0),
('G.Skill Trident Z5 Neo 64GB DDR5-7600MHz',      'DDR5',5,32,2,7600,36,52.0),
('TeamGroup Xtreem ARGB 64GB DDR5-7200MHz',       'DDR5',5,32,2,7200,34,49.0),
('G.Skill Trident Z5 Royal 64GB DDR5-7200MHz',    'DDR5',5,32,2,7200,32,44.0),
('Kingston Fury Beast 64GB DDR5-6400MHz',         'DDR5',5,32,2,6400,32,42.0),
('Patriot Viper Venom 64GB DDR5-7200MHz',         'DDR5',5,32,2,7200,34,41.0);

-- ================================================================
-- 7. DML — GPU  (chipset incluye VRAM y TDP para el desplegable)
-- Criterio: T1=básica/iGPU  T2=1080p  T3=1440p  T4=4K entry  T5=4K/PT
-- Conectores: req_8pin_pcie = nº conectores PCIe 8-pin
--             req_12vhpwr   = nº conectores 12VHPWR (PCIe 5.0)
-- ================================================================

INSERT INTO gpu (chipset,id_tier,vram_gb,longitud_mm,tdp_w,req_8pin_pcie,req_12vhpwr) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Intel UHD Graphics 730 (Integrada)',    1, 0,  0,  0,0,0),
('NVIDIA GeForce GT 1030 2GB · 30W',     1, 2,170, 30,0,0),
('AMD Radeon RX 550 4GB · 50W',          1, 4,170, 50,0,0),
('NVIDIA GeForce GT 710 2GB · 25W',      1, 2,165, 25,0,0),
('Intel Arc A380 6GB · 75W',             1, 6,195, 75,0,0),
('AMD Radeon RX 6400 4GB · 53W',         1, 4,140, 53,0,0),
('NVIDIA GeForce GTX 1650 4GB · 75W',    1, 4,151, 75,0,0),
-- ── TIER 2 ──────────────────────────────────────────────────────
('NVIDIA GeForce RTX 4060 8GB · 115W',   2, 8,240,115,1,0),
('AMD Radeon RX 7600 8GB · 165W',        2, 8,241,165,1,0),
('NVIDIA GeForce RTX 4060 Ti 8GB · 165W',2, 8,240,165,0,1),
('AMD Radeon RX 5500 XT 8GB · 130W',     2, 8,189,130,1,0),
('NVIDIA GeForce RTX 3060 12GB · 170W',  2,12,242,170,1,0),
('AMD Radeon RX 6600 8GB · 132W',        2, 8,190,132,1,0),
('AMD Radeon RX 6700 XT 12GB · 230W',    2,12,267,230,2,0),
('Intel Arc A770 16GB · 225W',           2,16,272,225,1,0),
('NVIDIA GeForce RTX 3060 Ti 8GB · 200W',2, 8,240,200,2,0),
('AMD Radeon RX 6650 XT 8GB · 180W',     2, 8,240,180,1,0),
-- ── TIER 3 ──────────────────────────────────────────────────────
('ASUS Dual RTX 2070 Super 8GB · 215W',  3, 8,267,215,1,0),
('NVIDIA GeForce RTX 3070 Ti 8GB · 290W',3, 8,240,290,2,0),
('AMD Radeon RX 7700 XT 12GB · 245W',    3,12,267,245,2,0),
('NVIDIA GeForce RTX 3070 8GB · 220W',   3, 8,242,220,2,0),
('AMD Radeon RX 6800 16GB · 250W',       3,16,267,250,2,0),
('NVIDIA GeForce RTX 4070 12GB · 200W',  3,12,244,200,0,1),
('AMD Radeon RX 6800 XT 16GB · 300W',    3,16,267,300,2,0),
('NVIDIA GeForce RTX 3080 10GB · 320W',  3,10,320,320,2,0),
('AMD Radeon RX 7700 12GB · 190W',       3,12,240,190,1,0),
('NVIDIA GeForce RTX 4070 Super 12GB · 220W',3,12,285,220,0,1),
-- ── TIER 4 ──────────────────────────────────────────────────────
('MSI RTX 4090 Gaming X Trio 24GB · 450W',4,24,337,450,0,1),
('NVIDIA GeForce RTX 4080 Super 16GB · 320W',4,16,336,320,0,1),
('AMD Radeon RX 7900 XTX 24GB · 355W',   4,24,287,355,3,0),
('NVIDIA GeForce RTX 4070 Ti 12GB · 285W',4,12,336,285,0,1),
('AMD Radeon RX 7900 XT 20GB · 315W',    4,20,287,315,3,0),
('NVIDIA GeForce RTX 3090 24GB · 350W',  4,24,336,350,3,0),
('NVIDIA GeForce RTX 4070 Ti Super 16GB · 285W',4,16,336,285,0,1),
('AMD Radeon RX 7900 GRE 16GB · 260W',   4,16,267,260,2,0),
('NVIDIA GeForce RTX 3080 Ti 12GB · 350W',4,12,336,350,3,0),
('AMD Radeon RX 6900 XT 16GB · 300W',    4,16,267,300,2,0),
('NVIDIA GeForce RTX 5070 Ti 16GB · 300W',4,16,285,300,0,1),
('AMD Radeon RX 9070 16GB · 220W',       4,16,267,220,2,0),
-- ── TIER 5 ──────────────────────────────────────────────────────
('NVIDIA GeForce RTX 5090 32GB · 575W',  5,32,340,575,0,2),
('NVIDIA GeForce RTX 4090 Founders Edition 24GB · 450W',5,24,336,450,0,1),
('AMD Radeon RX 9070 XT 16GB · 304W',    5,16,290,304,2,0),
('NVIDIA GeForce RTX 3090 Ti 24GB · 450W',5,24,336,450,0,1),
('NVIDIA GeForce RTX 5080 16GB · 360W',  5,16,336,360,0,1),
('NVIDIA GeForce RTX 4080 16GB · 320W',  5,16,336,320,0,1),
('AMD Radeon Pro W7900 48GB · 295W',     5,48,355,295,2,0);

-- ================================================================
-- 8. DML — STORAGE
-- Criterio: T1=SATA/HDD básico  T2=NVMe Gen3  T3=NVMe Gen4 rendimiento
--           T4=NVMe Gen5 entrada  T5=Gen5 extremo / gran capacidad
-- ================================================================

INSERT INTO storage (modelo,tipo,id_tier,formato,interfaz_version,lectura_mb_s) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Kingston A400 SSD',    'SATA_SSD',1,'2.5',3, 500),
('Crucial BX500 240GB',  'SATA_SSD',1,'2.5',3, 540),
('Verbatim Vi550 240GB', 'SATA_SSD',1,'2.5',3, 550),
('Samsung 870 EVO 250GB','SATA_SSD',1,'2.5',3, 560),
('Seagate BarraCuda 2TB','HDD',      1,'3.5',3, 210),
('WD Blue 1TB HDD',      'HDD',      1,'3.5',3, 200),
('WD Blue SA510 SSD',    'SATA_SSD',1,'2.5',3, 560),
('Seagate BarraCuda 1TB HDD','HDD',  1,'3.5',3, 190),
-- ── TIER 2 ──────────────────────────────────────────────────────
('Crucial P3 NVMe Gen3',     'NVME',2,'M.2',3,3500),
('WD Blue SN570 NVMe Gen3',  'NVME',2,'M.2',3,3500),
('Seagate FireCuda 520 Gen4','NVME',2,'M.2',4,5000),
('Sabrent Rocket 4.0 Gen4',  'NVME',2,'M.2',4,5000),
('Lexar NM790 NVMe Gen4',    'NVME',2,'M.2',4,7400),
('Samsung 980 NVMe Gen3 1TB','NVME',2,'M.2',3,3500),
('Crucial BX500 480GB SATA', 'SATA_SSD',2,'2.5',3, 540),
('Samsung 980 NVMe Gen3',    'NVME',2,'M.2',3,3500),
-- ── TIER 3 ──────────────────────────────────────────────────────
('WD_BLACK SN770 Gen4',           'NVME',3,'M.2',4,5150),
('Kingston KC3000 NVMe Gen4',     'NVME',3,'M.2',4,7000),
('Samsung 970 Evo Plus NVMe Gen3','NVME',3,'M.2',3,3500),
('Seagate FireCuda 530 Gen4',     'NVME',3,'M.2',4,7300),
('WD Black SN850X 1TB Gen4',      'NVME',3,'M.2',4,7300),
('Samsung 980 Pro NVMe Gen4',     'NVME',3,'M.2',4,7000),
('Sabrent Rocket 4 Plus Gen4',    'NVME',3,'M.2',4,7100),
('Crucial P5 Plus 1TB Gen4',      'NVME',3,'M.2',4,6600),
-- ── TIER 4 ──────────────────────────────────────────────────────
('Corsair MP700 NVMe Gen5',          'NVME',4,'M.2',5,10000),
('WD Black SN850X 2TB Gen4',         'NVME',4,'M.2',4, 7300),
('Seagate FireCuda 540 Gen5',        'NVME',4,'M.2',5,10000),
('Sabrent Rocket 5 Gen5',            'NVME',4,'M.2',5,12000),
('Kingston Fury Renegade 2TB Gen4',  'NVME',4,'M.2',4, 7300),
('Crucial T700 1TB Gen5',            'NVME',4,'M.2',5,12400),
('Samsung 990 Pro NVMe Gen4',        'NVME',4,'M.2',4, 7450),
('Crucial T700 NVMe Gen5',           'NVME',4,'M.2',5,12400),
-- ── TIER 5 ──────────────────────────────────────────────────────
('Samsung 990 Pro Gen5',    'NVME',5,'M.2',5,14500),
('Samsung 990 Pro 4TB Gen4','NVME',5,'M.2',4, 7450),
('Crucial T700 4TB Gen5',   'NVME',5,'M.2',5,12400),
('Seagate IronWolf Pro 16TB','HDD', 5,'3.5',3,  280),
('WD Gold 18TB Enterprise', 'HDD',  5,'3.5',3,  272),
('Sabrent Rocket 5 Pro 4TB','NVME',5,'M.2',5,14000),
('WD Black SN850X 4TB Gen4','NVME',5,'M.2',4, 7300),
('Corsair MP700 Pro 4TB Gen5','NVME',5,'M.2',5,12400);

-- ================================================================
-- 9. DML — PSU
-- Criterio: T1=<500W sin cert  T2=500-650W Bronze  T3=750W Gold
--           T4=1000W Gold/Plat + ATX3  T5=>1200W Titanium
-- conn_8pin_pcie = conectores PCIe 8-pin disponibles
-- conn_12vhpwr   = conectores 12VHPWR disponibles
-- ================================================================

INSERT INTO psu (modelo,id_tier,potencia_w,longitud_mm,conn_8pin_pcie,conn_12vhpwr) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Mars Gaming MPIII 500W',          1, 500,140,0,0),
('Seasonic S12III 500W Bronze',     1, 500,140,0,0),
('be quiet! System Power 10 400W',  1, 400,140,0,0),
('Corsair CV450 Bronze',            1, 450,140,0,0),
('EVGA N1 500W',                    1, 500,140,0,0),
('Cooler Master MWE 450 Bronze',    1, 450,140,0,0),
('Thermaltake Smart 500W Bronze',   1, 500,140,0,0),
-- ── TIER 2 ──────────────────────────────────────────────────────
('Corsair CV650 Bronze',                2, 650,125,2,0),
('be quiet! System Power 10 650W Bronze',2,650,140,2,0),
('Seasonic Focus GX-650 Gold',          2, 650,140,3,0),
('EVGA 650 GQ 80+ Gold',               2, 650,140,2,0),
('Corsair RM650 Gold',                  2, 650,140,3,0),
('DeepCool PQ650M Gold',               2, 650,140,2,0),
('be quiet! Pure Power 12M 650W',       2, 650,140,2,0),
('Thermaltake Toughpower GF1 650W',    2, 650,140,2,0),
-- ── TIER 3 ──────────────────────────────────────────────────────
('MSI MAG A750GL PCIe5 Gold',       3, 750,140,3,1),
('Corsair RM750e Gold',             3, 750,140,3,1),
('be quiet! Pure Power 12M 750W Gold',3,750,140,3,1),
('Seasonic Focus GX-750 Gold',      3, 750,140,4,1),
('be quiet! Straight Power 12 750W',3, 750,160,3,1),
('Fractal Design Ion Gold 750W',    3, 750,140,3,1),
('Corsair HX750 Platinum',          3, 750,160,4,1),
('Cooler Master V750 Gold',         3, 750,150,3,1),
-- ── TIER 4 ──────────────────────────────────────────────────────
('Corsair RM1000e ATX 3.0',              4,1000,140,4,1),
('be quiet! Dark Power 13 1000W Platinum',4,1000,160,4,2),
('Corsair HX1000i Platinum ATX 3.0',     4,1000,160,4,1),
('Seasonic Focus PX-1000 Platinum',      4,1000,150,4,1),
('be quiet! Dark Power 12 1000W Plat',   4,1000,160,4,1),
('Fractal Design Ion Platinum 1000W',    4,1000,140,4,1),
('Thermaltake Toughpower GF3 1000W',     4,1000,140,4,1),
('MSI MEG Ai1000P PCIe5',               4,1000,140,4,2),
-- ── TIER 5 ──────────────────────────────────────────────────────
('Seasonic Vertex PX-1200 ATX 3.1',         5,1200,160,0,2),
('be quiet! Dark Power Pro 13 1600W Ti',    5,1600,160,6,3),
('Corsair HX1500i Platinum',                5,1500,160,6,2),
('Seasonic Prime TX-1300 Titanium',         5,1300,160,6,3),
('be quiet! Dark Power Pro 13 1200W Ti',    5,1200,160,6,3),
('Corsair AX1600i Titanium',                5,1600,160,6,3),
('Thermaltake Toughpower iRGB PLUS 1650W',  5,1650,160,6,3);

-- ================================================================
-- 10. DML — COOLER
-- Criterio: T1=stock/<90W  T2=torre 120/<180W  T3=doble torre o AIO 240
--           T4=AIO 360 alto rendimiento  T5=AIO 420 / componentes premium
-- altura_mm = altura del disipador aire / bomba AIO
-- tamano_radiador_mm = 0 para aire, 240/360/420 para AIO
-- ================================================================

INSERT INTO cooler (modelo,tipo,id_tier,altura_mm,tamano_radiador_mm,tdp_max_w) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Intel Laminar RM1 (Stock)',        'AIRE',1, 47,  0, 65),
('AMD Wraith Stealth',               'AIRE',1, 54,  0, 65),
('Cooler Master 110R',               'AIRE',1, 62,  0, 95),
('Noctua NH-L9i chromax.black',      'AIRE',1, 37,  0, 65),
('Cooler Master Hyper T20',          'AIRE',1, 58,  0, 95),
('be quiet! Pure Rock Slim 2',       'AIRE',1, 74,  0, 85),
('Arctic Alpine AM4/AM5',            'AIRE',1, 74,  0, 75),
('ID-COOLING SE-802-SD',             'AIRE',1, 60,  0, 90),
-- ── TIER 2 ──────────────────────────────────────────────────────
('Cooler Master Hyper 212 Halo',     'AIRE',2,154,  0,180),
('DeepCool AK400',                   'AIRE',2,155,  0,220),
('be quiet! Pure Rock 2',            'AIRE',2,155,  0,150),
('Thermalright Assassin X 120 SE',   'AIRE',2,155,  0,200),
('ID-COOLING SE-214-XT',             'AIRE',2,155,  0,180),
('Cooler Master Hyper 212 Black',    'AIRE',2,159,  0,180),
('Arctic Freezer 34 eSports',        'AIRE',2,157,  0,200),
-- ── TIER 3 ──────────────────────────────────────────────────────
('Deepcool AG400 Plus',              'AIRE',3,150,  0,220),
('Noctua NH-D15',                    'AIRE',3,165,  0,250),
('be quiet! Dark Rock 4',            'AIRE',3,162,  0,200),
('Scythe Fuma 3',                    'AIRE',3,155,  0,250),
('Thermalright Phantom Spirit 120',  'AIRE',3,157,  0,220),
('NZXT Kraken 240',                  'AIO', 3, 55,240,250),
('Corsair iCUE H100i Elite 240mm',   'AIO', 3, 55,240,250),
-- ── TIER 4 ──────────────────────────────────────────────────────
('NZXT Kraken Elite 360',            'AIO', 4, 55,360,300),
('Arctic Liquid Freezer III 360',    'AIO', 4, 55,360,300),
('Corsair iCUE H150i Elite LCD 360', 'AIO', 4, 55,360,300),
('DeepCool LT720 360mm',             'AIO', 4, 55,360,300),
('Fractal Design Celsius+ S36',      'AIO', 4, 55,360,300),
('Thermalright Frozen Prism 360',    'AIO', 4, 55,360,290),
('Cooler Master MasterLiquid 360L',  'AIO', 4, 55,360,280),
-- ── TIER 5 ──────────────────────────────────────────────────────
('Corsair iCUE H170i Elite (420mm)', 'AIO', 5, 55,420,350),
('EK-AIO Elite 420 D-RGB',           'AIO', 5, 55,420,350),
('Noctua NH-D15S chromax.black',     'AIRE',5,165,  0,250),
('EKWB Nucleus AIO CR360',           'AIO', 5, 55,360,350),
('Arctic Liquid Freezer III 420',    'AIO', 5, 55,420,350),
('Thermaltake TOUGHLIQUID 420',      'AIO', 5, 55,420,350),
('Thermalright Aqua Elite 360',      'AIO', 5, 55,360,320);

-- ================================================================
-- 11. DML — PC_CASE
-- Criterio: T1=flujo básico  T2=flujo decente  T3=mesh front + filtros
--           T4=premium modular  T5=super tower / doble sistema
-- ================================================================

INSERT INTO pc_case (modelo,id_form_factor_max,id_tier,max_gpu_len_mm,max_cpu_cooler_height_mm,max_psu_len_mm) VALUES
-- ── TIER 1 ──────────────────────────────────────────────────────
('Tacens Anima AC5',        2,1,250,140,150),
('Aerocool Cylon',          2,1,310,155,160),
('Kolink Rocket mATX',      2,1,300,150,170),
('BitFenix Nova ATX',       1,1,330,165,200),
('Sharkoon VS4-V',          1,1,350,160,200),
('Antec VSK3000U3',         2,1,300,155,160),
('DeepCool Matrexx 30',     2,1,320,155,180),
('Thermaltake Versa H26',   1,1,360,165,200),
('Cougar MX340',            1,1,380,165,200),
-- ── TIER 2 ──────────────────────────────────────────────────────
('Nfortec Krater',          1,2,320,160,200),
('Fractal Design Focus 2',  1,2,340,168,200),
('NZXT H5 Flow',            1,2,355,165,175),
('Sharkoon MS-Y1000',       1,2,360,170,200),
('Cooler Master Q300L',     2,2,360,157,200),
('Antec P10 FLUX',          1,2,380,170,200),
('Thermaltake View 51 ARGB',1,2,400,170,200),
('be quiet! Pure Base 500', 1,2,369,190,220),
-- ── TIER 3 ──────────────────────────────────────────────────────
('Phanteks Eclipse P300',   1,3,330,160,160),
('Corsair 4000D Airflow',   1,3,360,170,180),
('Fractal Design Meshify C',1,3,315,172,200),
('NZXT H510 Flow',          1,3,381,165,200),
('Lian Li LANCOOL 216',     1,3,400,178,200),
('Fractal Design Pop Air',  1,3,360,172,200),
('be quiet! Pure Base 500DX',1,3,369,190,220),
('Phanteks Eclipse G360A',  1,3,420,180,200),
-- ── TIER 4 ──────────────────────────────────────────────────────
('Lian Li O11 Dynamic Evo', 1,4,426,167,280),
('Fractal Design Torrent',  1,4,461,188,200),
('Lian Li PC-O11 Air Evo',  1,4,420,167,320),
('Corsair 5000D Airflow',   1,4,420,170,200),
('Phanteks Eclipse P600S',  1,4,430,180,250),
('Lian Li O11 Dynamic EVO XL',1,4,446,167,320),
('HYTE Y70 Touch',          1,4,390,170,220),
('Fractal Design Define 7', 1,4,465,185,250),
-- ── TIER 5 ──────────────────────────────────────────────────────
('Cooler Master HAF 700 Evo',   1,5,490,166,200),
('Phanteks Enthoo 719',         1,5,500,200,250),
('Corsair 9000D',               1,5,500,190,260),
('Thermaltake Level 20 HT',     1,5,490,200,250),
('Corsair 7000D Airflow',       1,5,510,200,280),
('Lian Li V3000 Plus ARGB',     1,5,480,200,250),
('Fractal Design Meshify 2 XL', 1,5,481,188,250),
('be quiet! Dark Base Pro 901', 1,5,490,200,300);

-- ================================================================
-- 12. DML — COOLER_SOCKET_SUPPORT
-- Mapea cada refrigeración con los sockets que soporta.
-- Sockets: 1=AM4  2=LGA1700  3=AM5
-- ================================================================

INSERT INTO cooler_socket_support (id_cooler, id_socket) VALUES
-- T1: Laminar solo LGA1700 (viene en caja Intel)
(1,2),
-- T1: Wraith solo AM4 (viene en caja AMD)
(2,1),
-- T1: 110R → AM4 + LGA1700
(3,1),(3,2),
-- T1: NH-L9i → solo LGA1700 (perfil bajo Intel)
(4,2),
-- T1: Hyper T20
(5,1),(5,2),
-- T1: Pure Rock Slim 2
(6,1),(6,2),
-- T1: Alpine AM4/AM5
(7,1),(7,3),
-- T1: SE-802-SD
(8,1),(8,2),
-- Los coolers T2-T5 soportan todos los sockets disponibles
(9,1),(9,2),(9,3),
(10,1),(10,2),(10,3),
(11,1),(11,2),(11,3),
(12,1),(12,2),(12,3),
(13,1),(13,2),(13,3),
(14,1),(14,2),(14,3),
(15,1),(15,2),(15,3),
(16,1),(16,2),(16,3),
(17,1),(17,2),(17,3),
(18,1),(18,2),(18,3),
(19,1),(19,2),(19,3),
(20,1),(20,2),(20,3),
(21,1),(21,2),(21,3),
(22,1),(22,2),(22,3),
(23,1),(23,2),(23,3),
(24,1),(24,2),(24,3),
(25,1),(25,2),(25,3),
(26,1),(26,2),(26,3),
(27,1),(27,2),(27,3),
(28,1),(28,2),(28,3),
(29,1),(29,2),(29,3),
(30,1),(30,2),(30,3),
(31,1),(31,2),(31,3),
(32,1),(32,2),(32,3),
(33,1),(33,2),(33,3),
(34,1),(34,2),(34,3),
(35,1),(35,2),(35,3),
(36,1),(36,2),(36,3);
