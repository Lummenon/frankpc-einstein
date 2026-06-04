-- ================================================================
-- FRANK PC EINSTEIN — ampliar_componentes.sql
-- 1. UPDATE: añadir MHz a RAM y VRAM+TDP a GPU
-- 2. INSERT: llevar cada tabla a ~10 componentes por tier
-- ================================================================
USE componentes_pc;

-- ================================================================
-- 1. ACTUALIZACIONES
-- ================================================================

-- RAM: añadir unidad MHz a todas las frecuencias que no la tienen
UPDATE ram SET modelo = REGEXP_REPLACE(modelo, '(\\d{3,4})$', '\\1MHz')
WHERE modelo NOT LIKE '%MHz';

-- GPU: añadir VRAM y TDP al campo chipset
UPDATE gpu SET chipset = CONCAT(chipset, ' ', vram_gb, 'GB · ', tdp_w, 'W')
WHERE chipset NOT LIKE '%GB%' AND id_gpu != 1; -- id 1 = iGPU placeholder, lo dejamos

-- ================================================================
-- 2. CPU  (de 4 → ~10 por tier)
-- ================================================================

-- TIER 1 (+6)
INSERT INTO cpu VALUES
  (DEFAULT,'Intel Core i3-13100',      2,1, 4, 8,3400, 60,4800,1),
  (DEFAULT,'Intel Core i3-12100F',     2,1, 4, 8,3300, 58,4800,0),
  (DEFAULT,'AMD Ryzen 3 3300X',        1,1, 4, 8,3800, 65,3200,0),
  (DEFAULT,'AMD Ryzen 3 3100',         1,1, 4, 8,3600, 65,3200,0),
  (DEFAULT,'AMD Ryzen 3 PRO 4350G',    1,1, 4, 8,3800, 65,3200,1),
  (DEFAULT,'Intel Core i3-12300',      2,1, 4, 8,3500, 60,4800,1);

-- TIER 2 (+6)
INSERT INTO cpu VALUES
  (DEFAULT,'AMD Ryzen 5 5500',         1,2, 6,12,3600, 65,3200,0),
  (DEFAULT,'AMD Ryzen 5 5600G',        1,2, 6,12,3900, 65,3200,1),
  (DEFAULT,'AMD Ryzen 5 7600X',        3,2, 6,12,4700,105,5200,0),
  (DEFAULT,'Intel Core i5-12400',      2,2, 6,12,2500, 65,4800,1),
  (DEFAULT,'Intel Core i5-13400F',     2,2,10,16,2500, 65,4800,0),
  (DEFAULT,'AMD Ryzen 5 4600G',        1,2, 6,12,3700, 65,3200,1);

-- TIER 3 (+6)
INSERT INTO cpu VALUES
  (DEFAULT,'AMD Ryzen 7 5700',         1,3, 8,16,3700, 65,3200,0),
  (DEFAULT,'AMD Ryzen 7 5700G',        1,3, 8,16,3800, 65,3200,1),
  (DEFAULT,'Intel Core i5-13600K',     2,3,14,20,3500,125,5600,1),
  (DEFAULT,'Intel Core i5-13600KF',    2,3,14,20,3500,125,5600,0),
  (DEFAULT,'AMD Ryzen 7 5700X3D',      1,3, 8,16,3000,105,3200,0),
  (DEFAULT,'Intel Core i7-12700F',     2,3,12,20,2700, 65,4800,0);

-- TIER 4 (+7)
INSERT INTO cpu VALUES
  (DEFAULT,'Intel Core i9-13900K',     2,4,24,32,3000,125,5600,1),
  (DEFAULT,'Intel Core i7-13700K',     2,4,16,24,3400,125,5600,1),
  (DEFAULT,'AMD Ryzen 9 7950X3D',      3,4,16,32,4200,120,5200,0),
  (DEFAULT,'Intel Core i7-14700KF',    2,4,20,28,3400,125,5600,0),
  (DEFAULT,'AMD Ryzen 9 7900X3D',      3,4,12,24,4400,120,5200,0),
  (DEFAULT,'Intel Core i9-14900KF',    2,4,24,32,3200,125,5600,0),
  (DEFAULT,'AMD Ryzen 9 9700X',        3,4, 8,16,3800, 65,6400,0);

-- TIER 5 (+5)
INSERT INTO cpu VALUES
  (DEFAULT,'Intel Core i9-14900KS',    2,5,24,32,3200,150,5600,1),
  (DEFAULT,'Intel Core i9-13900KS',    2,5,24,32,3200,150,5600,1),
  (DEFAULT,'Intel Core Ultra 9 285K',  2,5,24,24,3700,125,5600,1),
  (DEFAULT,'AMD Ryzen 9 9900',         3,5,12,24,3500, 65,6400,0),
  (DEFAULT,'AMD Ryzen 9 9950X3D',      3,5,16,32,4000,170,6400,0);

-- ================================================================
-- 3. MOTHERBOARD  (de 4 → ~10 por tier)
-- ================================================================

-- TIER 1 (+6)
INSERT INTO motherboard VALUES
  (DEFAULT,'ASUS PRIME A320M-K',          1,2,1,'A320', 'DDR4',2,0,1,3),
  (DEFAULT,'ASRock A520M Pro4',           1,2,1,'A520', 'DDR4',4,0,1,3),
  (DEFAULT,'MSI PRO H610M-E DDR4',        2,2,1,'H610', 'DDR4',2,0,1,3),
  (DEFAULT,'Gigabyte H510M H',            2,2,1,'H510', 'DDR4',2,0,1,3),
  (DEFAULT,'ASUS PRIME H610M-K D4',       2,2,1,'H610', 'DDR4',2,0,1,3),
  (DEFAULT,'Gigabyte A620M H',            3,2,1,'A620', 'DDR5',2,0,1,3);

-- TIER 2 (+6)
INSERT INTO motherboard VALUES
  (DEFAULT,'Gigabyte B660 Gaming X AX',   2,1,2,'B660', 'DDR4',4,1,2,3),
  (DEFAULT,'MSI MAG B450M MORTAR MAX',    1,2,2,'B450', 'DDR4',4,0,1,3),
  (DEFAULT,'Gigabyte B450M DS3H V2',      1,2,2,'B450', 'DDR4',4,0,1,3),
  (DEFAULT,'MSI PRO B560M-A',             2,2,2,'B560', 'DDR4',2,0,1,3),
  (DEFAULT,'ASRock B650M Pro RS WiFi',    3,2,2,'B650', 'DDR5',4,1,1,3),
  (DEFAULT,'Gigabyte B760M DS3H DDR4',    2,2,2,'B760', 'DDR4',4,0,2,3);

-- TIER 3 (+6)
INSERT INTO motherboard VALUES
  (DEFAULT,'ASUS TUF Gaming B650-PLUS WiFi', 3,1,3,'B650', 'DDR5',4,1,3,3),
  (DEFAULT,'MSI MAG B760 Tomahawk WiFi',     2,1,3,'B760', 'DDR5',4,1,2,3),
  (DEFAULT,'Gigabyte B650 AORUS Pro AX',     3,1,3,'B650', 'DDR5',4,1,3,3),
  (DEFAULT,'MSI PRO Z690-A DDR4 WiFi',       2,1,3,'Z690', 'DDR4',4,1,4,3),
  (DEFAULT,'ASUS PRIME Z690-P D4',           2,1,3,'Z690', 'DDR4',4,0,3,3),
  (DEFAULT,'ASRock B650E PG Riptide WiFi',   3,1,3,'B650E','DDR5',4,1,3,3);

-- TIER 4 (+6)
INSERT INTO motherboard VALUES
  (DEFAULT,'Gigabyte Z790 AORUS Elite AX',       2,1,4,'Z790', 'DDR5',4,1,5,3),
  (DEFAULT,'MSI MAG X670E Tomahawk WiFi',        3,1,4,'X670E','DDR5',4,1,4,3),
  (DEFAULT,'ASUS ProArt X670E-Creator WiFi',     3,1,4,'X670E','DDR5',4,1,5,3),
  (DEFAULT,'ASRock Z790 Taichi',                 2,1,4,'Z790', 'DDR5',4,1,5,3),
  (DEFAULT,'ASUS ROG Crosshair X670E Hero',      3,1,4,'X670E','DDR5',4,1,5,3),
  (DEFAULT,'Gigabyte X870 AORUS Elite WiFi7',    3,1,4,'X870', 'DDR5',4,1,5,3);

-- TIER 5 (+6)
INSERT INTO motherboard VALUES
  (DEFAULT,'ASUS ROG Maximus Z790 Extreme',      2,1,5,'Z790', 'DDR5',4,1,5,3),
  (DEFAULT,'Gigabyte Z790 AORUS Xtreme X',       2,1,5,'Z790', 'DDR5',4,1,6,3),
  (DEFAULT,'MSI MEG X870E ACE',                  3,1,5,'X870E','DDR5',4,1,5,3),
  (DEFAULT,'ASUS ROG Crosshair X870E Extreme',   3,1,5,'X870E','DDR5',4,1,6,3),
  (DEFAULT,'ASRock X870E Taichi Lite',           3,1,5,'X870E','DDR5',4,1,5,3),
  (DEFAULT,'Gigabyte X870E AORUS Master',        3,1,5,'X870E','DDR5',4,1,6,3);

-- ================================================================
-- 4. RAM  (a ~9-10 por tier)
-- ================================================================

-- TIER 1 (+4)
INSERT INTO ram VALUES
  (DEFAULT,'Patriot Signature 8GB DDR4-2666MHz',  'DDR4',1, 8,1,2666,19,31.0),
  (DEFAULT,'Corsair ValueSelect 8GB DDR4-2666MHz','DDR4',1, 8,1,2666,18,31.0),
  (DEFAULT,'G.Skill Value 8GB DDR4-2133MHz',      'DDR4',1, 8,1,2133,15,31.0),
  (DEFAULT,'Kingston HyperX Fury 8GB DDR4-3200MHz','DDR4',1,8,1,3200,16,34.0);

-- TIER 2 (+4)
INSERT INTO ram VALUES
  (DEFAULT,'Patriot Viper Steel 16GB DDR4-3600MHz','DDR4',2, 8,2,3600,20,38.0),
  (DEFAULT,'Crucial Ballistix 16GB DDR4-3200MHz',  'DDR4',2, 8,2,3200,16,34.0),
  (DEFAULT,'Corsair Vengeance 16GB DDR5-4800MHz',  'DDR5',2, 8,2,4800,40,35.0),
  (DEFAULT,'SK Hynix Platinum P41 16GB DDR5-5200MHz','DDR5',2,8,2,5200,38,38.0);

-- TIER 3 (+4)
INSERT INTO ram VALUES
  (DEFAULT,'Crucial Ballistix MAX 32GB DDR4-4000MHz','DDR4',3,16,2,4000,18,34.0),
  (DEFAULT,'Patriot Viper 4 Blackout 32GB DDR4-3600MHz','DDR4',3,16,2,3600,18,40.0),
  (DEFAULT,'G.Skill Trident Z Neo 32GB DDR5-6000MHz',  'DDR5',3,16,2,6000,30,44.0),
  (DEFAULT,'Kingston Fury Beast 32GB DDR5-5200MHz',    'DDR5',3,16,2,5200,40,35.0);

-- TIER 4 (+4)
INSERT INTO ram VALUES
  (DEFAULT,'Corsair Dominator Platinum RGB 32GB DDR5-6400MHz','DDR5',4,16,2,6400,32,52.0),
  (DEFAULT,'G.Skill Trident Z5 32GB DDR5-6400MHz',            'DDR5',4,16,2,6400,32,44.0),
  (DEFAULT,'TeamGroup T-Force Delta 32GB DDR5-6200MHz',        'DDR5',4,16,2,6200,38,38.0),
  (DEFAULT,'Patriot Viper Venom 32GB DDR5-6600MHz',           'DDR5',4,16,2,6600,34,41.0);

-- TIER 5 (+4)
INSERT INTO ram VALUES
  (DEFAULT,'TeamGroup Xtreem ARGB 64GB DDR5-7200MHz', 'DDR5',5,32,2,7200,34,49.0),
  (DEFAULT,'G.Skill Trident Z5 Royal 64GB DDR5-7200MHz','DDR5',5,32,2,7200,32,44.0),
  (DEFAULT,'Kingston Fury Beast 64GB DDR5-6400MHz',    'DDR5',5,32,2,6400,32,42.0),
  (DEFAULT,'Patriot Viper Venom 64GB DDR5-7200MHz',   'DDR5',5,32,2,7200,34,41.0);

-- ================================================================
-- 5. GPU  (de 3 → ~10 por tier)
-- gpu(DEFAULT, chipset, id_tier, vram_gb, longitud_mm, tdp_w, req_8pin, req_12vhpwr)
-- ================================================================

-- TIER 1 (+4, total 7)
INSERT INTO gpu VALUES
  (DEFAULT,'NVIDIA GeForce GT 710 2GB · 25W',      1, 2,165, 25,0,0),
  (DEFAULT,'Intel Arc A380 6GB · 75W',              1, 6,195, 75,0,0),
  (DEFAULT,'AMD Radeon RX 6400 4GB · 53W',          1, 4,140, 53,0,0),
  (DEFAULT,'NVIDIA GeForce GTX 1650 4GB · 75W',     1, 4,151, 75,0,0);

-- TIER 2 (+7, total 10)
INSERT INTO gpu VALUES
  (DEFAULT,'AMD Radeon RX 5500 XT 8GB · 130W',     2, 8,189,130,1,0),
  (DEFAULT,'NVIDIA GeForce RTX 3060 12GB · 170W',  2,12,242,170,1,0),
  (DEFAULT,'AMD Radeon RX 6600 8GB · 132W',         2, 8,190,132,1,0),
  (DEFAULT,'AMD Radeon RX 6700 XT 12GB · 230W',    2,12,267,230,2,0),
  (DEFAULT,'Intel Arc A770 16GB · 225W',            2,16,272,225,1,0),
  (DEFAULT,'NVIDIA GeForce RTX 3060 Ti 8GB · 200W',2, 8,240,200,2,0),
  (DEFAULT,'AMD Radeon RX 6650 XT 8GB · 180W',     2, 8,240,180,1,0);

-- TIER 3 (+7, total 10)
INSERT INTO gpu VALUES
  (DEFAULT,'NVIDIA GeForce RTX 3070 8GB · 220W',       3, 8,242,220,2,0),
  (DEFAULT,'AMD Radeon RX 6800 16GB · 250W',            3,16,267,250,2,0),
  (DEFAULT,'NVIDIA GeForce RTX 4070 12GB · 200W',      3,12,244,200,0,1),
  (DEFAULT,'AMD Radeon RX 6800 XT 16GB · 300W',        3,16,267,300,2,0),
  (DEFAULT,'NVIDIA GeForce RTX 3080 10GB · 320W',      3,10,320,320,2,0),
  (DEFAULT,'AMD Radeon RX 7700 12GB · 190W',           3,12,240,190,1,0),
  (DEFAULT,'NVIDIA GeForce RTX 4070 Super 12GB · 220W',3,12,285,220,0,1);

-- TIER 4 (+9, total 12 — hay muchos buenos productos en T4)
INSERT INTO gpu VALUES
  (DEFAULT,'NVIDIA GeForce RTX 4070 Ti 12GB · 285W',      4,12,336,285,0,1),
  (DEFAULT,'AMD Radeon RX 7900 XT 20GB · 315W',           4,20,287,315,3,0),
  (DEFAULT,'NVIDIA GeForce RTX 3090 24GB · 350W',         4,24,336,350,3,0),
  (DEFAULT,'NVIDIA GeForce RTX 4070 Ti Super 16GB · 285W',4,16,336,285,0,1),
  (DEFAULT,'AMD Radeon RX 7900 GRE 16GB · 260W',          4,16,267,260,2,0),
  (DEFAULT,'NVIDIA GeForce RTX 3080 Ti 12GB · 350W',      4,12,336,350,3,0),
  (DEFAULT,'AMD Radeon RX 6900 XT 16GB · 300W',           4,16,267,300,2,0),
  (DEFAULT,'NVIDIA GeForce RTX 5070 Ti 16GB · 300W',      4,16,285,300,0,1),
  (DEFAULT,'AMD Radeon RX 9070 16GB · 220W',              4,16,267,220,2,0);

-- TIER 5 (+4, total 7)
INSERT INTO gpu VALUES
  (DEFAULT,'NVIDIA GeForce RTX 3090 Ti 24GB · 450W', 5,24,336,450,0,1),
  (DEFAULT,'NVIDIA GeForce RTX 5080 16GB · 360W',    5,16,336,360,0,1),
  (DEFAULT,'NVIDIA GeForce RTX 4080 16GB · 320W',    5,16,336,320,0,1),
  (DEFAULT,'AMD Radeon Pro W7900 48GB · 295W',        5,48,355,295,2,0);

-- ================================================================
-- 6. STORAGE  (de 3 → ~9 por tier)
-- storage(DEFAULT, modelo, tipo ENUM, id_tier, formato, interfaz_version, lectura_mb_s)
-- ================================================================

-- TIER 1 (+5)
INSERT INTO storage VALUES
  (DEFAULT,'Crucial BX500 240GB',    'SATA_SSD',1,'2.5',3, 540),
  (DEFAULT,'Verbatim Vi550 S3 240GB','SATA_SSD',1,'2.5',3, 550),
  (DEFAULT,'Samsung 870 EVO 250GB',  'SATA_SSD',1,'2.5',3, 560),
  (DEFAULT,'Seagate BarraCuda 2TB',  'HDD',     1,'3.5',3, 210),
  (DEFAULT,'WD Blue 1TB HDD',        'HDD',     1,'3.5',3, 200);

-- TIER 2 (+5)
INSERT INTO storage VALUES
  (DEFAULT,'WD Blue SN570 NVMe Gen3',   'NVME',2,'M.2',3,3500),
  (DEFAULT,'Seagate FireCuda 520 Gen4', 'NVME',2,'M.2',4,5000),
  (DEFAULT,'Sabrent Rocket 4.0 Gen4',   'NVME',2,'M.2',4,5000),
  (DEFAULT,'Lexar NM790 NVMe Gen4',     'NVME',2,'M.2',4,7400),
  (DEFAULT,'Samsung 980 NVMe Gen3 1TB', 'NVME',2,'M.2',3,3500);

-- TIER 3 (+5)
INSERT INTO storage VALUES
  (DEFAULT,'Seagate FireCuda 530 Gen4',  'NVME',3,'M.2',4,7300),
  (DEFAULT,'WD Black SN850X 1TB',        'NVME',3,'M.2',4,7300),
  (DEFAULT,'Samsung 980 Pro NVMe Gen4',  'NVME',3,'M.2',4,7000),
  (DEFAULT,'Sabrent Rocket 4 Plus Gen4', 'NVME',3,'M.2',4,7100),
  (DEFAULT,'Crucial P5 Plus 1TB Gen4',   'NVME',3,'M.2',4,6600);

-- TIER 4 (+5)
INSERT INTO storage VALUES
  (DEFAULT,'WD Black SN850X 2TB Gen4',   'NVME',4,'M.2',4,7300),
  (DEFAULT,'Seagate FireCuda 540 Gen5',  'NVME',4,'M.2',5,10000),
  (DEFAULT,'Sabrent Rocket 5 Gen5',      'NVME',4,'M.2',5,12000),
  (DEFAULT,'Kingston Fury Renegade 2TB', 'NVME',4,'M.2',4,7300),
  (DEFAULT,'Crucial T705 1TB Gen5',      'NVME',4,'M.2',5,12400);

-- TIER 5 (+5)
INSERT INTO storage VALUES
  (DEFAULT,'Samsung 990 Pro 4TB Gen4',   'NVME',5,'M.2',4,7450),
  (DEFAULT,'Crucial T700 4TB Gen5',      'NVME',5,'M.2',5,12400),
  (DEFAULT,'Seagate IronWolf Pro 16TB',  'HDD',  5,'3.5',3, 280),
  (DEFAULT,'WD Gold 18TB Enterprise',    'HDD',  5,'3.5',3, 272),
  (DEFAULT,'Sabrent Rocket 5 Pro 4TB',   'NVME',5,'M.2',5,14000);

-- ================================================================
-- 7. PSU  (de 3 → ~9 por tier)
-- psu(DEFAULT, modelo, id_tier, potencia_w, longitud_mm, conn_8pin, conn_12vhpwr)
-- ================================================================

-- TIER 1 (+4)
INSERT INTO psu VALUES
  (DEFAULT,'Corsair CV450 Bronze',           1, 450,140,0,0),
  (DEFAULT,'EVGA N1 500W',                   1, 500,140,0,0),
  (DEFAULT,'Cooler Master MWE 450 Bronze',   1, 450,140,0,0),
  (DEFAULT,'Thermaltake Smart 500W Bronze',  1, 500,140,0,0);

-- TIER 2 (+5)
INSERT INTO psu VALUES
  (DEFAULT,'EVGA 650 GQ 80+ Gold',           2, 650,140,2,0),
  (DEFAULT,'Corsair RM650 Gold',              2, 650,140,3,0),
  (DEFAULT,'DeepCool PQ650M Gold',            2, 650,140,2,0),
  (DEFAULT,'be quiet! Pure Power 12M 650W',  2, 650,140,2,0),
  (DEFAULT,'Thermaltake Toughpower GF1 650W',2, 650,140,2,0);

-- TIER 3 (+5)
INSERT INTO psu VALUES
  (DEFAULT,'Seasonic Focus GX-750 Gold',          3, 750,140,4,1),
  (DEFAULT,'be quiet! Straight Power 12 750W',    3, 750,160,3,1),
  (DEFAULT,'Fractal Design Ion Gold 750W',         3, 750,140,3,1),
  (DEFAULT,'Corsair HX750 Platinum',               3, 750,160,4,1),
  (DEFAULT,'Cooler Master V750 Gold',              3, 750,150,3,1);

-- TIER 4 (+5)
INSERT INTO psu VALUES
  (DEFAULT,'Seasonic Focus PX-1000 Platinum',     4,1000,150,4,1),
  (DEFAULT,'be quiet! Dark Power 12 1000W Plat',  4,1000,160,4,1),
  (DEFAULT,'Fractal Design Ion Platinum 1000W',   4,1000,140,4,1),
  (DEFAULT,'Thermaltake Toughpower GF3 1000W',    4,1000,140,4,1),
  (DEFAULT,'MSI MEG Ai1000P PCIe5',               4,1000,140,4,2);

-- TIER 5 (+4)
INSERT INTO psu VALUES
  (DEFAULT,'Seasonic Prime TX-1300 Titanium',         5,1300,160,6,3),
  (DEFAULT,'be quiet! Dark Power Pro 13 1200W Ti',    5,1200,160,6,3),
  (DEFAULT,'Corsair AX1600i Titanium',                5,1600,160,6,3),
  (DEFAULT,'Thermaltake Toughpower iRGB PLUS 1650W',  5,1650,160,6,3);

-- ================================================================
-- 8. COOLER  (a ~7-8 por tier)
-- cooler(DEFAULT, modelo, tipo ENUM('AIRE','AIO'), id_tier, altura_mm, tamano_rad_mm, tdp_max_w)
-- IDs nuevos: 17-36
-- ================================================================

-- TIER 1 (+4, total 8) — IDs 17-20
INSERT INTO cooler VALUES
  (DEFAULT,'Cooler Master Hyper T20',    'AIRE',1, 58,  0, 95),
  (DEFAULT,'be quiet! Pure Rock Slim 2', 'AIRE',1, 74,  0, 85),
  (DEFAULT,'Arctic Alpine AM4/AM5',      'AIRE',1, 74,  0, 75),
  (DEFAULT,'ID-COOLING SE-802-SD',       'AIRE',1, 60,  0, 90);

-- TIER 2 (+4, total 7) — IDs 21-24
INSERT INTO cooler VALUES
  (DEFAULT,'Thermalright Assassin X 120 SE','AIRE',2,155,  0,200),
  (DEFAULT,'ID-COOLING SE-214-XT',          'AIRE',2,155,  0,180),
  (DEFAULT,'Cooler Master Hyper 212 Black', 'AIRE',2,159,  0,180),
  (DEFAULT,'Arctic Freezer 34 eSports',     'AIRE',2,157,  0,200);

-- TIER 3 (+4, total 7) — IDs 25-28
INSERT INTO cooler VALUES
  (DEFAULT,'Scythe Fuma 3',                  'AIRE',3,155,   0,250),
  (DEFAULT,'Thermalright Phantom Spirit 120', 'AIRE',3,157,   0,220),
  (DEFAULT,'NZXT Kraken 240',                 'AIO', 3, 55, 240,250),
  (DEFAULT,'Corsair iCUE H100i Elite 240mm',  'AIO', 3, 55, 240,250);

-- TIER 4 (+4, total 7) — IDs 29-32
INSERT INTO cooler VALUES
  (DEFAULT,'DeepCool LT720 360mm',              'AIO',4, 55,360,300),
  (DEFAULT,'Fractal Design Celsius+ S36',       'AIO',4, 55,360,300),
  (DEFAULT,'Thermalright Frozen Prism 360',     'AIO',4, 55,360,290),
  (DEFAULT,'Cooler Master MasterLiquid 360L',   'AIO',4, 55,360,280);

-- TIER 5 (+4, total 7) — IDs 33-36
INSERT INTO cooler VALUES
  (DEFAULT,'EKWB Nucleus AIO CR360',         'AIO',5, 55,360,350),
  (DEFAULT,'Arctic Liquid Freezer III 420',  'AIO',5, 55,420,350),
  (DEFAULT,'Thermaltake TOUGHLIQUID 420',    'AIO',5, 55,420,350),
  (DEFAULT,'Thermalright Aqua Elite 360',    'AIO',5, 55,360,320);

-- ================================================================
-- 9. PC_CASE  (de 4 → ~9 por tier)
-- pc_case(DEFAULT, modelo, id_form_factor_max, id_tier, max_gpu, max_cooler_h, max_psu)
-- ================================================================

-- TIER 1 (+5)
INSERT INTO pc_case VALUES
  (DEFAULT,'Sharkoon VS4-V',          1,1,350,160,200),
  (DEFAULT,'Antec VSK3000U3',         2,1,300,155,160),
  (DEFAULT,'DeepCool Matrexx 30',     2,1,320,155,180),
  (DEFAULT,'Thermaltake Versa H26',   1,1,360,165,200),
  (DEFAULT,'Cougar MX340',            1,1,380,165,200);

-- TIER 2 (+4)
INSERT INTO pc_case VALUES
  (DEFAULT,'Cooler Master Q300L',      2,2,360,157,200),
  (DEFAULT,'Antec P10 FLUX',           1,2,380,170,200),
  (DEFAULT,'Thermaltake View 51 ARGB', 1,2,400,170,200),
  (DEFAULT,'be quiet! Pure Base 500',  1,2,369,190,220);

-- TIER 3 (+4)
INSERT INTO pc_case VALUES
  (DEFAULT,'Lian Li LANCOOL 216',       1,3,400,178,200),
  (DEFAULT,'Fractal Design Pop Air',    1,3,360,172,200),
  (DEFAULT,'be quiet! Pure Base 500DX', 1,3,369,190,220),
  (DEFAULT,'Phanteks Eclipse G360A',    1,3,420,180,200);

-- TIER 4 (+4)
INSERT INTO pc_case VALUES
  (DEFAULT,'Phanteks Eclipse P600S',         1,4,430,180,250),
  (DEFAULT,'Lian Li O11 Dynamic EVO XL',     1,4,446,167,320),
  (DEFAULT,'HYTE Y70 Touch',                 1,4,390,170,220),
  (DEFAULT,'Fractal Design Define 7',        1,4,465,185,250);

-- TIER 5 (+4)
INSERT INTO pc_case VALUES
  (DEFAULT,'Corsair 7000D Airflow',           1,5,510,200,280),
  (DEFAULT,'Lian Li V3000 Plus ARGB',         1,5,480,200,250),
  (DEFAULT,'Fractal Design Meshify 2 XL',     1,5,481,188,250),
  (DEFAULT,'be quiet! Dark Base Pro 901',     1,5,490,200,300);

-- ================================================================
-- 10. COOLER_SOCKET_SUPPORT para los nuevos coolers (IDs 17-36)
-- Sockets: 1=AM4  2=LGA1700  3=AM5
-- ================================================================

-- ID 17: Cooler Master Hyper T20 → AM4, LGA1700
INSERT INTO cooler_socket_support VALUES (17,1),(17,2);
-- ID 18: be quiet! Pure Rock Slim 2 → AM4, LGA1700
INSERT INTO cooler_socket_support VALUES (18,1),(18,2);
-- ID 19: Arctic Alpine AM4/AM5 → AM4, AM5
INSERT INTO cooler_socket_support VALUES (19,1),(19,3);
-- ID 20: ID-COOLING SE-802-SD → AM4, LGA1700
INSERT INTO cooler_socket_support VALUES (20,1),(20,2);
-- ID 21-36: compatibles con todos los sockets
INSERT INTO cooler_socket_support VALUES
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
