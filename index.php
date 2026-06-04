<?php
/* ================================================================
   FRANK PC EINSTEIN — index.php
   Punto de entrada principal. Gestiona la lógica POST del
   diagnóstico de compatibilidad y renderiza la one-page.
   ================================================================ */
require 'config/db.php';
require 'config/components.php'; /* $map + $diag_msgs */

/* ── Lógica POST: diagnóstico ── */
$res = []; $names = []; $post_ids = []; $showRes = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $showRes = true;
  foreach ($map as $key => $cfg) {
    $id = $_POST[$key] ?? null;
    $post_ids[$key] = $id;
    if ($id) {
      try {
        $st = $pdo->prepare("SELECT {$cfg['c']} FROM {$cfg['t']} WHERE {$cfg['pk']}=?");
        $st->execute([$id]);
        $names[$key] = $st->fetchColumn() ?: "ID:$id";
      } catch (Exception $e) { $names[$key] = 'Error DB'; }
    } else { $names[$key] = '---'; }
  }

  /* 12 checks de compatibilidad mediante UNION ALL.
     $p = array con los IDs en el orden que espera cada SELECT. */
  $p = [
    $_POST['cpu'],    $_POST['mobo'],
    $_POST['ram'],    $_POST['mobo'],   $_POST['ram'],   $_POST['mobo'],
    $_POST['gpu'],    $_POST['case'],
    $_POST['cooler'], $_POST['case'],
    $_POST['psu'],    $_POST['cpu'],    $_POST['gpu'],
    $_POST['psu'],    $_POST['gpu'],
    $_POST['psu'],    $_POST['gpu'],
    $_POST['cooler'], $_POST['cpu'],
    $_POST['storage'], $_POST['mobo'],
    $_POST['psu'],    $_POST['gpu'],
    $_POST['cpu'],    $_POST['gpu'],
  ];
  $sql = "
SELECT '1. SOCKET'    as C, CASE WHEN c.id_socket=m.id_socket THEN '✅ OK' ELSE '❌ ERR' END as R
  FROM cpu c, motherboard m WHERE c.id_cpu=? AND m.id_mobo=?
UNION ALL SELECT '2. RAM TIPO',  CASE WHEN r.tipo=m.tipo_ram THEN '✅ OK' ELSE '❌ ERR' END
  FROM ram r, motherboard m WHERE r.id_ram=? AND m.id_mobo=?
UNION ALL SELECT '3. RAM SLOTS', CASE WHEN m.ranuras_ram>=r.modulos_pack THEN '✅ OK' ELSE '❌ ERR' END
  FROM ram r, motherboard m WHERE r.id_ram=? AND m.id_mobo=?
UNION ALL SELECT '4. GPU LEN',   CASE WHEN ca.max_gpu_len_mm>=g.longitud_mm THEN '✅ OK' ELSE '❌ ERR' END
  FROM gpu g, pc_case ca WHERE g.id_gpu=? AND ca.id_case=?
UNION ALL SELECT '5. COOLER H',  CASE WHEN ca.max_cpu_cooler_height_mm>=co.altura_mm THEN '✅ OK' ELSE '❌ ERR' END
  FROM cooler co, pc_case ca WHERE co.id_cooler=? AND ca.id_case=?
UNION ALL SELECT '6. WATTS',     CASE WHEN p.potencia_w>=(c.tdp_w+g.tdp_w+50) THEN '✅ OK' ELSE '❌ ERR' END
  FROM psu p, cpu c, gpu g WHERE p.id_psu=? AND c.id_cpu=? AND g.id_gpu=?
UNION ALL SELECT '7. CABLES 8p', CASE WHEN p.conn_8pin_pcie>=g.req_8pin_pcie THEN '✅ OK' ELSE '❌ ERR' END
  FROM psu p, gpu g WHERE p.id_psu=? AND g.id_gpu=?
UNION ALL SELECT '8. 12VHPWR',   CASE WHEN g.req_12vhpwr=0 THEN '✅ OK'
  WHEN p.conn_12vhpwr>=g.req_12vhpwr THEN '✅ OK' ELSE '❌ ERR' END
  FROM psu p, gpu g WHERE p.id_psu=? AND g.id_gpu=?
UNION ALL SELECT '9. ANCLAJE',   CASE WHEN EXISTS(
  SELECT 1 FROM cooler_socket_support css WHERE css.id_cooler=? AND css.id_socket=c.id_socket)
  THEN '✅ OK' ELSE '❌ ERR' END FROM cpu c WHERE c.id_cpu=?
UNION ALL SELECT '10. M.2',      CASE WHEN st.tipo='NVME' AND m.m2_slots_total=0 THEN '❌ ERR' ELSE '✅ OK' END
  FROM storage st, motherboard m WHERE st.id_storage=? AND m.id_mobo=?
UNION ALL SELECT '11. TIER PSU', CASE WHEN p.id_tier>=g.id_tier THEN '✅ OK' ELSE '⚠️ WARN' END
  FROM psu p, gpu g WHERE p.id_psu=? AND g.id_gpu=?
UNION ALL SELECT '12. BOTELLA',  CASE WHEN ABS(c.id_tier-g.id_tier)<=1 THEN '✅ OK' ELSE '⚠️ WARN' END
  FROM cpu c, gpu g WHERE c.id_cpu=? AND g.id_gpu=?";
  try {
    $st = $pdo->prepare($sql); $st->execute($p);
    $res = $st->fetchAll(PDO::FETCH_ASSOC);
  } catch (Exception $e) { $res = [['C'=>'Error','R'=>$e->getMessage()]]; }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>Frank PC Einstein — Configurador</title>
  <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>

<canvas id="factory-canvas"></canvas>

<!-- Stepper de progreso (izquierda, fijo) -->
<nav id="progress-nav" aria-label="Progreso de configuración">
  <?php foreach (array_keys($map) as $i => $key): ?>
    <div class="progress-step" id="nav-<?=$key?>" data-comp="<?=$key?>"
         data-tip="<?=htmlspecialchars($map[$key]['label'])?>"
         onclick="scrollToSection('<?=$key?>')">
      <div class="step-dot">
        <span class="step-num"><?=$i+1?></span>
        <i class="fa-solid fa-check step-check" style="display:none;"></i>
      </div>
    </div>
    <?php if ($i < count($map)-1): ?><div class="progress-vline"></div><?php endif; ?>
  <?php endforeach; ?>
</nav>

<header id="main-header">
  <button class="btn-nuevo-mini" onclick="resetConfigurator()">
    <i class="fa-solid fa-rotate-left"></i> NUEVO PC
  </button>
  <h1>FRANK PC EINSTEIN</h1>
  <div style="width:110px;"></div>
</header>

<?php require 'views/pc-svg.php'; ?>

<!-- Cinta transportadora + contenido scrollable -->
<div id="page-wrap">
  <div id="belt-column">

    <section class="hero-section">
      <h2>Configura tu<br>PC Ideal</h2>
      <p>Desplázate por la cinta. Cada estación te presenta un componente, explica su función y te permite elegirlo. Al llegar al final, el sistema validará automáticamente la compatibilidad de tu montaje.</p>
      <div class="scroll-hint">
        <span>DESLIZA PARA INICIAR</span>
        <i class="fa-solid fa-chevron-down"></i>
      </div>
    </section>

    <?php foreach (array_keys($map) as $i => $key):
      $cfg = $map[$key]; ?>

    <div class="belt-connector">
      <div class="belt-connector-line"></div>
      <span class="belt-connector-label">
        <?= $i===0 ? 'INICIO DE LÍNEA' : "ESTACIÓN {$i} / ".count($map) ?>
      </span>
      <div class="belt-connector-line"></div>
    </div>

    <section class="comp-section"
             data-comp="<?=$key?>"
             data-step="<?=sprintf('%02d',$i+1)?>"
             data-label="<?=htmlspecialchars($cfg['label'])?>"
             data-desc="<?=htmlspecialchars($cfg['desc'])?>">
      <i class="fa-solid <?=$cfg['icon']?> comp-icon-big"></i>
      <h2><?=$cfg['label']?></h2>
      <p><?=$cfg['desc']?></p>
      <div class="comp-selection-status" id="status-<?=$key?>">
        <i class="fa-solid fa-circle-question"></i>
        <span>SIN SELECCIONAR</span>
      </div>
      <button class="btn-select" id="btn-<?=$key?>"
              data-label="ELEGIR <?=htmlspecialchars(strtoupper($cfg['label']))?>"
              onclick="openSelect('<?=$key?>')">
        ELEGIR <?=strtoupper($cfg['label'])?>
      </button>
    </section>

    <?php endforeach; ?>

    <div class="belt-connector">
      <div class="belt-connector-line"></div>
      <span class="belt-connector-label">FIN DE LÍNEA — ESTACIÓN 8 / 8</span>
      <div class="belt-connector-line"></div>
    </div>

    <section class="final-section">
      <h2>SISTEMA ENSAMBLADO</h2>
      <div class="config-preview">
        <?php foreach ($map as $key => $cfg): ?>
        <div class="config-preview-row">
          <span class="lbl"><?=$cfg['label']?></span>
          <span class="val pending" id="preview-val-<?=$key?>">—</span>
        </div>
        <?php endforeach; ?>
      </div>
      <div style="display:flex;gap:16px;flex-wrap:wrap;align-items:center;">
        <button class="btn-check" onclick="submitForm()">DIAGNOSTICAR SISTEMA</button>
        <button class="btn-nuevo-pc" onclick="resetConfigurator()">
          <i class="fa-solid fa-rotate-left"></i> ARMAR NUEVO PC
        </button>
      </div>
    </section>

  </div>
</div>

<!-- Formulario oculto (envía los IDs al servidor vía POST) -->
<form id="engine" method="POST" style="display:none;">
  <?php foreach ($map as $key => $cfg): ?>
    <select name="<?=$key?>" id="h-<?=$key?>">
      <?php foreach (getOptions($pdo,$cfg['t'],$cfg['c'],$cfg['pk']) as $o): ?>
        <option value="<?=$o['id']?>"
                <?=($showRes&&($post_ids[$key]??'')==$o['id'])?'selected':''?>
                data-name="<?=htmlspecialchars($o['nombre'])?>"
                data-tier="<?=htmlspecialchars($o['tier'])?>">
          <?=htmlspecialchars($o['nombre'])?>
        </option>
      <?php endforeach; ?>
    </select>
  <?php endforeach; ?>
</form>

<!-- Modal de selección de componente -->
<div id="overlay" class="overlay">
  <div class="modal">
    <div id="m-title" class="m-head"></div>
    <div id="m-body"  class="m-body"></div>
    <button class="modal-cancel-btn" onclick="closeModal()">CANCELAR</button>
  </div>
</div>

<?php if ($showRes): ?>
<!-- Script de restauración: JS lee las selecciones previas tras el POST -->
<script>
window.__restoredSelections = Object.fromEntries(
  <?=json_encode(array_keys($map))?>.map((k,i) => [k, {
    id:   <?=json_encode(array_values(array_map(fn($k)=>$post_ids[$k]??null,array_keys($map))))?>[i],
    name: <?=json_encode(array_values($names))?>[i]
  }])
);
</script>

<!-- Modal de resultados -->
<div id="res-modal" class="overlay" style="display:flex;z-index:2000;">
  <div class="modal" style="width:640px;">
    <div class="m-head">
      <div class="modal-comp-title">INFORME DE COMPATIBILIDAD</div>
      <div class="modal-comp-desc">Revisión técnica de los 12 parámetros del montaje seleccionado.</div>
    </div>
    <div class="m-body">
      <p style="font-family:var(--font-title);font-size:0.72rem;color:var(--navy-60);letter-spacing:2px;margin-bottom:14px;">COMPONENTES SELECCIONADOS</p>
      <div class="summary-box">
        <?php foreach ($map as $key => $cfg):
          $v = htmlspecialchars($names[$key]??'---'); ?>
          <div class="sum-item">
            <span class="sum-label"><?=strtoupper($key)?></span>
            <span class="sum-val" title="<?=$v?>"><?=$v?></span>
          </div>
        <?php endforeach; ?>
      </div>
      <p style="font-family:var(--font-title);font-size:0.72rem;color:var(--navy-60);letter-spacing:2px;margin-bottom:14px;">ANÁLISIS TÉCNICO</p>
      <?php foreach ($res as $r):
        $cls  = strpos($r['R'],'❌')!==false ? 'err' : (strpos($r['R'],'⚠️')!==false ? 'warn' : 'ok');
        $icon = $cls==='err' ? 'fa-circle-xmark' : ($cls==='warn' ? 'fa-triangle-exclamation' : '');
        $msg  = $diag_msgs[$r['C']] ?? '';
      ?>
        <div class="res-row">
          <span><?=$r['C']?></span>
          <span class="<?=$cls?>"><?=$r['R']?></span>
        </div>
        <?php if ($cls!=='ok' && $msg): ?>
        <div class="diag-msg diag-msg-<?=$cls?>">
          <?php if($icon): ?><i class="fa-solid <?=$icon?>"></i><?php endif; ?>
          <?=htmlspecialchars($msg)?>
        </div>
        <?php endif; ?>
      <?php endforeach; ?>
    </div>
    <button class="btn-cerrar-informe"
            onclick="document.getElementById('res-modal').style.display='none'">
      CERRAR INFORME
    </button>
  </div>
</div>
<?php endif; ?>

<script src="assets/js/main.js"></script>
</body>
</html>
