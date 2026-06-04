<?php
/* ================================================================
   Mapa de componentes del configurador.
   Cada entrada define: tabla BD, clave primaria, columna nombre,
   icono FontAwesome, etiqueta visible y descripción educativa.
   ================================================================ */
$map = [
  'cpu'     => ['t'=>'cpu',         'pk'=>'id_cpu',     'c'=>'modelo',
                'icon'=>'fa-microchip',   'label'=>'PROCESADOR',
                'desc'=>'El cerebro del sistema. Define el rendimiento en cálculo, multitarea e IA. El socket determina qué placas base son compatibles con él.'],
  'mobo'    => ['t'=>'motherboard', 'pk'=>'id_mobo',    'c'=>'modelo',
                'icon'=>'fa-chess-board', 'label'=>'PLACA BASE',
                'desc'=>'La columna vertebral del PC. Conecta todos los componentes. El chipset define las capacidades de overclocking, los puertos M.2 y el soporte de RAM.'],
  'ram'     => ['t'=>'ram',         'pk'=>'id_ram',     'c'=>'modelo',
                'icon'=>'fa-memory',      'label'=>'MEMORIA RAM',
                'desc'=>'Memoria de trabajo del sistema. La velocidad y la latencia afectan directamente al rendimiento. DDR5 es el estándar moderno para sistemas actuales.'],
  'gpu'     => ['t'=>'gpu',         'pk'=>'id_gpu',     'c'=>'chipset',
                'icon'=>'fa-gamepad',     'label'=>'TARJETA GRÁFICA',
                'desc'=>'El motor gráfico. Procesa píxeles para gaming, diseño 3D e inteligencia artificial. La VRAM y el TDP son los factores más críticos de cara a la compatibilidad.'],
  'storage' => ['t'=>'storage',     'pk'=>'id_storage', 'c'=>'modelo',
                'icon'=>'fa-hard-drive',  'label'=>'ALMACENAMIENTO',
                'desc'=>'Almacenamiento del SO y aplicaciones. El estándar NVMe Gen4/5 ofrece velocidades extremas frente al SATA convencional.'],
  'psu'     => ['t'=>'psu',         'pk'=>'id_psu',     'c'=>'modelo',
                'icon'=>'fa-plug',        'label'=>'FUENTE DE ALIMENTACIÓN',
                'desc'=>'La fuente de energía de todo el sistema. Debe tener potencia suficiente para cubrir el TDP total con un margen mínimo del 20% de seguridad.'],
  'cooler'  => ['t'=>'cooler',      'pk'=>'id_cooler',  'c'=>'modelo',
                'icon'=>'fa-fan',         'label'=>'REFRIGERACIÓN',
                'desc'=>'Sistema de disipación térmica. Mantiene la CPU en temperaturas óptimas para un rendimiento consistente y una vida útil prolongada.'],
  'case'    => ['t'=>'pc_case',     'pk'=>'id_case',    'c'=>'modelo',
                'icon'=>'fa-box',         'label'=>'CHASIS',
                'desc'=>'La estructura que aloja todos los componentes. El flujo de aire, las dimensiones internas y el soporte de form-factors son más importantes que la estética.'],
];

/* Mensajes explicativos para cada check de compatibilidad */
$diag_msgs = [
  '1. SOCKET'      => 'El procesador y la placa base tienen sockets incompatibles (AM4 / AM5 / LGA1700 no coinciden).',
  '2. RAM TIPO'    => 'El tipo de RAM (DDR4 o DDR5) no coincide con los slots de la placa base.',
  '3. RAM SLOTS'   => 'El kit de RAM tiene más módulos que slots disponibles en la placa.',
  '4. GPU LEN'     => 'La tarjeta gráfica supera la longitud máxima permitida por el chasis.',
  '5. COOLER H'    => 'El disipador o AIO supera la altura máxima interior del chasis.',
  '6. WATTS'       => 'La fuente no cubre CPU TDP + GPU TDP + 50 W de margen de sistema.',
  '7. CABLES 8p'   => 'La fuente no dispone de suficientes conectores PCIe 8-pin para la GPU.',
  '8. 12VHPWR'     => 'La GPU requiere conector 12VHPWR (PCIe 5.0) que esta fuente no incluye.',
  '9. ANCLAJE'     => 'El sistema de refrigeración no tiene soporte oficial para el socket de este procesador.',
  '10. M.2'        => 'La placa base no dispone de ranura M.2 para el almacenamiento NVMe seleccionado.',
  '11. TIER PSU'   => 'Advertencia: la fuente es de gama inferior a la GPU — posible inestabilidad bajo carga máxima.',
  '12. BOTELLA'    => 'Advertencia: CPU y GPU difieren más de 1 tier — probable cuello de botella en rendimiento.',
];
