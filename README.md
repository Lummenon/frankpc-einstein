# Frank PC Einstein 🖥️

**Configurador interactivo de hardware** desarrollado como proyecto de fin de módulo para DAM.

Guía al usuario por los 8 componentes principales de un PC, explica para qué sirve cada uno y valida automáticamente que la configuración final sea compatible.

---

## Demo en vivo

🔗 [https://frankpc-einstein.freehosting.dev]

---

## ¿Qué hace?

- Desplazamiento con **efecto parallax** en tres capas: fondo industrial, cinta transportadora y plano técnico del PC
- **Selección guiada** de CPU, placa base, RAM, GPU, almacenamiento, fuente, refrigeración y caja
- Componentes organizados por **gamas** (Entrada → Entusiasta) con más de 40 opciones por tipo
- **Diagnóstico de compatibilidad** con 12 comprobaciones técnicas (socket, vatios, longitud de GPU, conectores PCIe...)
- Explicación en lenguaje normal de cada error o aviso

---

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| Servidor | PHP 8 + PDO |
| Base de datos | MariaDB / MySQL |
| Frontend | HTML5, CSS3, JavaScript (vanilla) |
| Gráficos | Canvas API, SVG inline |
| Control de versiones | Git |

---

## Instalación local

### Requisitos
- PHP 8.0 o superior
- MariaDB / MySQL
- Servidor web (Apache, XAMPP, Laragon...)

### Pasos

**1. Clona el repositorio**
```bash
git clone https://github.com/TU_USUARIO/frankpc-einstein.git
cd frankpc-einstein
```

**2. Crea el archivo de configuración de la base de datos**
```bash
cp config/db.example.php config/db.php
```
Edita `config/db.php` y rellena tu usuario y contraseña de MySQL.

**3. Importa la base de datos**
```bash
mariadb -u root -p < config/data_base_components.sql
```
Esto crea la base de datos `componentes_pc` con todas las tablas y los datos.

**4. Sirve el proyecto**

Coloca la carpeta dentro de `htdocs` (XAMPP) o `www` (Laragon) y abre:
```
http://localhost/frankpc-einstein
```

---

## Estructura del proyecto

```
frankpc-einstein/
│
├── index.php                     # Punto de entrada: lógica PHP + HTML
├── views/
│   └── pc-svg.php                # Plano SVG del PC (capa 3 del parallax)
│
├── assets/
│   ├── css/style.css             # Diseño completo (tema blueprint)
│   └── js/main.js                # Animaciones, parallax, lógica del configurador
│
├── config/
│   ├── db.php                    # ¡! Credenciales reales — NO está en el repo
│   ├── db.example.php            # Plantilla para crear db.php
│   ├── components.php            # Mapa de componentes y mensajes de diagnóstico
│   └── data_base_components.sql  # Base de datos completa (DDL + datos)
│
├── .gitignore
└── README.md
```

---

## Base de datos

La base de datos contiene **~450 registros** de componentes reales del mercado 2024-2026 organizados en 5 gamas:

| Tier | Gama | Uso típico |
|------|------|-----------|
| 1 | Gama de Entrada | Ofimática, navegación |
| 2 | Gama Media | Gaming 1080p |
| 3 | Alto Rendimiento | Gaming 1440p |
| 4 | Gama Alta Moderna | Gaming 4K, creación |
| 5 | Gama Entusiasta | Máximo rendimiento |

---

## Autor

**Ismael** — Estudiante de DAM  
📧 ismarodri1@gmail.com

---

## Licencia

Proyecto educativo de uso libre. Si lo usas como base para algo, un crédito siempre se agradece.
