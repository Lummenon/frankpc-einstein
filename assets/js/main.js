/* ================================================================
   FRANK PC EINSTEIN — main.js
   ================================================================ */

const SVG_IDS = {
  cpu:'svg-cpu', mobo:'svg-mobo', ram:'svg-ram', gpu:'svg-gpu',
  storage:'svg-storage', psu:'svg-psu', cooler:'svg-cooler', case:'svg-case',
};

let scrollY     = 0;
let currentComp = null;
const selections = {};

/* ================================================================
   CAPA 2 — FÁBRICA (canvas, parallax 0.3×, fondo transparente)

   Tres tipos de elementos visuales relacionados con hardware + fábrica:
     A) Estructura industrial (vigas, columnas)
     B) Trazos de circuito impreso (PCB traces, vías)
     C) Siluetas de componentes (die CPU, módulos RAM, ranuras PCIe)
   ================================================================ */
const fCanvas = document.getElementById('factory-canvas');
const fCtx    = fCanvas.getContext('2d');
let FW = 0, FH = 0;

function resizeCanvas() {
  FW = fCanvas.width  = window.innerWidth;
  FH = fCanvas.height = window.innerHeight;
}
window.addEventListener('resize', resizeCanvas, { passive: true });
resizeCanvas();

/* Coordenadas de mundo para cada tipo de elemento */
/* Extendidos hasta wy ≈ 4000 para cubrir toda la página, incluidas
   las secciones de cooler, case y la pantalla final.
   Regla de cálculo: pY = scrollY × 0.3; viewport muestra [pY, pY+VH].
   Con página ~8800px y VH ~1080px → pY_max ≈ 2340 → necesitamos hasta ~3420. */
const WORLD_BEAMS = [
  60, 400, 800, 1200, 1600, 2000, 2400, 2800, 3200, 3600, 4000
];
const WORLD_GEARS = [
  { wx:0.07, wy:140,  r:74,  teeth:11 }, { wx:0.93, wy:260,  r:52,  teeth:9  },
  { wx:0.06, wy:700,  r:92,  teeth:13 }, { wx:0.94, wy:900,  r:68,  teeth:10 },
  { wx:0.08, wy:1360, r:80,  teeth:12 }, { wx:0.92, wy:1580, r:70,  teeth:10 },
  { wx:0.07, wy:2000, r:102, teeth:15 }, { wx:0.50, wy:2440, r:52,  teeth:8  },
  /* ── extensión para secciones cooler / case / final ── */
  { wx:0.93, wy:2800, r:66,  teeth:10 }, { wx:0.08, wy:3100, r:88,  teeth:13 },
  { wx:0.94, wy:3400, r:58,  teeth:9  }, { wx:0.06, wy:3700, r:96,  teeth:14 },
];
const WORLD_CPU_DIES = [
  { wx:0.82, wy:320  }, { wx:0.14, wy:720  },
  { wx:0.86, wy:1120 }, { wx:0.12, wy:1500 },
  { wx:0.84, wy:1900 }, { wx:0.14, wy:2300 },
  /* extensión */
  { wx:0.82, wy:2700 }, { wx:0.16, wy:3000 },
  { wx:0.84, wy:3300 }, { wx:0.14, wy:3600 },
];
const WORLD_RAM_ROWS = [
  { wx:0.12, wy:460,  n:4 }, { wx:0.86, wy:860,  n:2 },
  { wx:0.10, wy:1260, n:4 }, { wx:0.88, wy:1660, n:2 },
  { wx:0.12, wy:2060, n:4 },
  /* extensión */
  { wx:0.88, wy:2380, n:2 }, { wx:0.12, wy:2680, n:4 },
  { wx:0.86, wy:2980, n:2 }, { wx:0.14, wy:3280, n:4 },
  { wx:0.88, wy:3580, n:2 },
];
const WORLD_PCB = [
  { wx:0.20, wy:200,  a:40,  l:180 }, { wx:0.80, wy:380,  a:-35, l:140 },
  { wx:0.18, wy:580,  a:55,  l:160 }, { wx:0.82, wy:760,  a:-50, l:130 },
  { wx:0.22, wy:980,  a:30,  l:200 }, { wx:0.78, wy:1160, a:-40, l:150 },
  { wx:0.20, wy:1360, a:45,  l:170 }, { wx:0.80, wy:1540, a:-30, l:190 },
  { wx:0.18, wy:1740, a:60,  l:140 }, { wx:0.82, wy:1940, a:-55, l:120 },
  /* extensión */
  { wx:0.22, wy:2140, a:35,  l:165 }, { wx:0.78, wy:2320, a:-45, l:145 },
  { wx:0.20, wy:2520, a:50,  l:180 }, { wx:0.80, wy:2700, a:-35, l:160 },
  { wx:0.18, wy:2900, a:40,  l:175 }, { wx:0.82, wy:3080, a:-50, l:145 },
  { wx:0.22, wy:3280, a:55,  l:160 }, { wx:0.78, wy:3460, a:-40, l:155 },
  { wx:0.20, wy:3660, a:45,  l:170 },
];

let gAngle = 0;

/* ── Engranaje (dibujo técnico) ─────────────────────────────── */
function drawGear(x, y, r, angle, teeth) {
  const ir = r * 0.74;
  fCtx.beginPath();
  for (let i = 0; i < teeth; i++) {
    const s = Math.PI * 2 / teeth;
    const a1 = i*s+angle, a2 = a1+s*0.28, a3 = a1+s*0.72, a4 = (i+1)*s+angle;
    fCtx.lineTo(Math.cos(a1)*ir+x, Math.sin(a1)*ir+y);
    fCtx.lineTo(Math.cos(a2)*r +x, Math.sin(a2)*r +y);
    fCtx.lineTo(Math.cos(a3)*r +x, Math.sin(a3)*r +y);
    fCtx.lineTo(Math.cos(a4)*ir+x, Math.sin(a4)*ir+y);
  }
  fCtx.closePath();
  fCtx.stroke();
  fCtx.beginPath(); fCtx.arc(x, y, r*0.19, 0, Math.PI*2); fCtx.stroke();
}

/* ── Die de CPU (plano esquemático de encapsulado) ──────────── */
function drawCPUDie(x, y, size) {
  const s = size;
  /* Encapsulado exterior */
  fCtx.strokeRect(x - s/2, y - s/2, s, s);
  /* Die interior con cuadrícula de bloques (núcleos estilizados) */
  const cell = s * 0.22;
  const cols = 3, rows = 3;
  const ox = x - (cols*cell)/2 + cell*0.1;
  const oy = y - (rows*cell)/2 + cell*0.1;
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      fCtx.strokeRect(ox + c*cell, oy + r*cell, cell*0.82, cell*0.82);
    }
  }
  /* Pines en los bordes */
  const pinCount = 6, pinStep = s / (pinCount + 1), pinLen = 5;
  for (let p = 1; p <= pinCount; p++) {
    const px = x - s/2 + p * pinStep;
    fCtx.beginPath(); fCtx.moveTo(px, y - s/2 - pinLen); fCtx.lineTo(px, y - s/2); fCtx.stroke();
    fCtx.beginPath(); fCtx.moveTo(px, y + s/2);           fCtx.lineTo(px, y + s/2 + pinLen); fCtx.stroke();
  }
}

/* ── Módulo RAM (contorno de PCB con chips) ─────────────────── */
function drawRAMStick(x, y) {
  const w = 9, h = 52;
  fCtx.strokeRect(x - w/2, y - h/2, w, h);
  /* Chips de memoria */
  for (let i = 0; i < 4; i++) {
    fCtx.fillRect(x - w/2 + 1.5, y - h/2 + 5 + i * 11, w - 3, 7);
  }
  /* Conector inferior */
  fCtx.strokeRect(x - w/2 + 1, y + h/2 - 7, w - 2, 6);
}

/* ── Trazo de PCB con vía ────────────────────────────────────── */
function drawPCBTrace(x, y, angleDeg, len) {
  const a = angleDeg * Math.PI / 180;
  const ex = x + Math.cos(a) * len;
  const ey = y + Math.sin(a) * len;
  fCtx.beginPath(); fCtx.moveTo(x, y); fCtx.lineTo(ex, ey); fCtx.stroke();
  /* Vía (pad circular) en cada extremo */
  fCtx.beginPath(); fCtx.arc(x,  y,  3.5, 0, Math.PI*2); fCtx.stroke();
  fCtx.beginPath(); fCtx.arc(ex, ey, 3.5, 0, Math.PI*2); fCtx.stroke();
}

/* ── Bucle principal ─────────────────────────────────────────── */
function drawFactory() {
  fCtx.clearRect(0, 0, FW, FH); /* transparente: el grid CSS asoma */

  const pY = scrollY * 0.30;   /* cámara en el mundo virtual */

  /* ── A) Vigas estructurales (cotas punteadas) ── */
  fCtx.setLineDash([5, 9]);
  fCtx.strokeStyle = 'rgba(44,62,80,0.28)';
  fCtx.lineWidth = 1;
  WORLD_BEAMS.forEach(wy => {
    const vy = wy - pY;
    if (vy < -20 || vy > FH + 20) return;
    fCtx.beginPath(); fCtx.moveTo(0, vy); fCtx.lineTo(FW, vy); fCtx.stroke();
    fCtx.setLineDash([]);
    fCtx.strokeStyle = 'rgba(44,62,80,0.38)';
    fCtx.lineWidth = 1.5;
    [14, FW-14].forEach(x => {
      fCtx.beginPath(); fCtx.moveTo(x, vy-7); fCtx.lineTo(x, vy+7); fCtx.stroke();
    });
    fCtx.setLineDash([5, 9]);
    fCtx.strokeStyle = 'rgba(44,62,80,0.28)';
    fCtx.lineWidth = 1;
  });
  fCtx.setLineDash([]);

  /* ── A) Columnas estructurales ── */
  fCtx.strokeStyle = 'rgba(44,62,80,0.30)';
  fCtx.lineWidth = 10;
  [FW*0.055, FW*0.945].forEach(cx => {
    fCtx.beginPath(); fCtx.moveTo(cx, 0); fCtx.lineTo(cx, FH); fCtx.stroke();
  });

  /* ── B) Trazos de PCB ── */
  fCtx.strokeStyle = 'rgba(44,62,80,0.26)';
  fCtx.fillStyle   = 'rgba(44,62,80,0.13)';
  fCtx.lineWidth = 1;
  WORLD_PCB.forEach(p => {
    const vy = p.wy - pY;
    if (vy < -200 || vy > FH + 200) return;
    drawPCBTrace(p.wx * FW, vy, p.a, p.l);
  });

  /* ── C) Die de CPU ── */
  fCtx.strokeStyle = 'rgba(44,62,80,0.27)';
  fCtx.fillStyle   = 'rgba(44,62,80,0.11)';
  fCtx.lineWidth = 1;
  WORLD_CPU_DIES.forEach(d => {
    const vy = d.wy - pY;
    if (vy < -100 || vy > FH + 100) return;
    drawCPUDie(d.wx * FW, vy, 70);
  });

  /* ── C) Módulos RAM ── */
  fCtx.strokeStyle = 'rgba(44,62,80,0.25)';
  fCtx.fillStyle   = 'rgba(44,62,80,0.12)';
  fCtx.lineWidth = 1;
  WORLD_RAM_ROWS.forEach(row => {
    const vy = row.wy - pY;
    if (vy < -100 || vy > FH + 100) return;
    for (let i = 0; i < row.n; i++) {
      drawRAMStick(row.wx * FW + (i - (row.n-1)/2) * 16, vy);
    }
  });

  /* ── A) Engranajes (maquinaria industrial) ── */
  gAngle += 0.003;
  fCtx.strokeStyle = 'rgba(44,62,80,0.26)';
  fCtx.fillStyle   = 'rgba(0,0,0,0)';
  fCtx.lineWidth   = 1;
  WORLD_GEARS.forEach((g, i) => {
    const vy = g.wy - pY;
    if (vy < -(g.r+12) || vy > FH+(g.r+12)) return;
    drawGear(g.wx*FW, vy, g.r, gAngle*(i%2===0?1:-1)*(g.r/70), g.teeth);
  });

  requestAnimationFrame(drawFactory);
}
drawFactory();

/* ================================================================
   SCROLL
   ================================================================ */
const header = document.getElementById('main-header');

window.addEventListener('scroll', () => {
  scrollY = window.pageYOffset;
  header.style.opacity = scrollY < 80
    ? '1'
    : Math.max(0.80, 1 - (scrollY-80)/280).toFixed(2);
}, { passive: true });

/* ================================================================
   STEPPER DE PROGRESO
   ================================================================ */
function updateProgressNav(key) {
  document.querySelectorAll('.progress-step:not(.nav-done)')
    .forEach(s => s.classList.remove('nav-active'));
  const step = document.getElementById('nav-' + key);
  if (step && !step.classList.contains('nav-done'))
    step.classList.add('nav-active');
}

function navStepDone(key) {
  const step = document.getElementById('nav-' + key);
  if (!step) return;
  step.classList.remove('nav-active');
  step.classList.add('nav-done');
  step.querySelector('.step-num').style.display  = 'none';
  const check = step.querySelector('.step-check');
  if (check) check.style.display = '';
}

function navReset() {
  document.querySelectorAll('.progress-step').forEach(step => {
    step.classList.remove('nav-active', 'nav-done');
    step.querySelector('.step-num').style.display  = '';
    const c = step.querySelector('.step-check');
    if (c) c.style.display = 'none';
  });
}

function scrollToSection(key) {
  document.querySelector(`.comp-section[data-comp="${key}"]`)
    ?.scrollIntoView({ behavior:'smooth', block:'center' });
}

/* ================================================================
   VISOR PC
   ================================================================ */
function highlightComp(key) {
  if (currentComp === key) return;
  document.getElementById(SVG_IDS[currentComp])?.classList.remove('active');
  currentComp = key;
  if (key) {
    document.getElementById(SVG_IDS[key])?.classList.add('active');
    updateProgressNav(key);
  }
}

function markDone(key) {
  const el = document.getElementById(SVG_IDS[key]);
  if (el) { el.classList.remove('active'); el.classList.add('done'); }
}

/* IntersectionObserver con threshold reducido para secciones más cortas */
const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (!entry.isIntersecting) return;
    const sec = entry.target;
    const key = sec.dataset.comp;
    sec.classList.add('visible');
    document.querySelectorAll('.comp-section.section-active')
      .forEach(s => s.classList.remove('section-active'));
    sec.classList.add('section-active');
    highlightComp(key);
  });
}, { threshold: 0.35 });

document.querySelectorAll('.comp-section').forEach(s => observer.observe(s));

/* SVG del visor PC: hacer cada componente clickable → navega a su sección */
Object.entries(SVG_IDS).forEach(([key, svgId]) => {
  const el = document.getElementById(svgId);
  if (el) el.addEventListener('click', () => scrollToSection(key));
});

/* ================================================================
   APLICAR SELECCIÓN (guardar nueva O restaurar tras POST)
   fromRestore=true  → también sincroniza el <select> oculto con el id
   fromRestore=false → selección normal del usuario
   ================================================================ */
function applySelection(key, id, name, fromRestore = false) {
  selections[key] = { id, name };

  /* Solo en restauración: sincronizar el <select> oculto */
  if (fromRestore) {
    const sel = document.getElementById('h-' + key);
    const opt = sel && Array.from(sel.options).find(o => o.value == id);
    if (opt) sel.value = opt.value;
  }

  /* Actualizar indicador de estado */
  const statusEl = document.getElementById('status-' + key);
  if (statusEl) {
    statusEl.classList.add('selected');
    statusEl.innerHTML = `<i class="fa-solid fa-check-circle"></i><span>${name}</span>`;
  }

  /* Actualizar preview de la sección final */
  const previewVal = document.getElementById('preview-val-' + key);
  if (previewVal) { previewVal.textContent = name; previewVal.classList.remove('pending'); }

  /* Cambiar texto del botón */
  const btn = document.getElementById('btn-' + key);
  if (btn) { btn.textContent = 'MODIFICAR SELECCIÓN'; btn.classList.add('btn-modified'); }

  /* Marcar sección como completada */
  const sec = document.querySelector(`.comp-section[data-comp="${key}"]`);
  if (sec) sec.classList.add('section-done', ...(fromRestore ? ['visible'] : []));

  markDone(key);
  navStepDone(key);
}

/* Alias públicos para mantener llamadas existentes legibles */
const saveSelection = (k, id, n) => applySelection(k, id, n, false);

/* Restauración automática si PHP inyectó datos tras un POST */
document.addEventListener('DOMContentLoaded', () => {
  if (!window.__restoredSelections) return;
  Object.entries(window.__restoredSelections).forEach(([key, data]) => {
    if (data?.id && data?.name && data.name !== '---')
      applySelection(key, data.id, data.name, true);
  });
});

/* ================================================================
   MODAL DE SELECCIÓN (grupos por Tier)
   ================================================================ */
const overlay = document.getElementById('overlay');
const mTitle  = document.getElementById('m-title');
const mBody   = document.getElementById('m-body');

function openSelect(type) {
  const section = document.querySelector(`.comp-section[data-comp="${type}"]`);
  const desc    = section?.dataset.desc  ?? '';
  const label   = section?.dataset.label ?? type.toUpperCase();

  overlay.style.display = 'flex';
  mTitle.innerHTML = `
    <div class="modal-comp-title">${label}</div>
    <div class="modal-comp-desc">${desc}</div>
  `;
  mBody.innerHTML = '';

  const sel = document.getElementById('h-' + type);
  if (!sel) return;

  const groups = new Map();
  Array.from(sel.options).forEach((opt, idx) => {
    const tier = opt.getAttribute('data-tier');
    if (!groups.has(tier)) groups.set(tier, []);
    groups.get(tier).push({ opt, idx });
  });

  groups.forEach((items, tierName) => {
    const groupEl = document.createElement('div');
    groupEl.className = 'tier-group';
    groupEl.innerHTML = `
      <div class="tier-group-header">
        <span class="tier-group-name">${tierName}</span>
        <span class="tier-group-count">${items.length} opción${items.length!==1?'es':''}</span>
      </div>
      <div class="tier-group-body"></div>
    `;
    mBody.appendChild(groupEl);

    const body = groupEl.querySelector('.tier-group-body');
    items.forEach(({ opt, idx }) => {
      const card = document.createElement('div');
      card.className = 'opt-card';
      card.textContent = opt.getAttribute('data-name');
      if (sel.selectedIndex === idx) card.classList.add('selected');
      card.addEventListener('click', () => {
        sel.selectedIndex = idx;
        saveSelection(type, opt.value, opt.getAttribute('data-name'));
        closeModal();
      });
      body.appendChild(card);
    });
  });
}

function closeModal() { overlay.style.display = 'none'; }

/* ================================================================
   GUARDAR SELECCIÓN
   ================================================================ */
function saveSelection(key, id, name) {
  selections[key] = { id, name };

  const statusEl = document.getElementById('status-' + key);
  if (statusEl) {
    statusEl.classList.add('selected');
    statusEl.innerHTML = `<i class="fa-solid fa-check-circle"></i><span>${name}</span>`;
  }

  const previewVal = document.getElementById('preview-val-' + key);
  if (previewVal) { previewVal.textContent = name; previewVal.classList.remove('pending'); }

  const btn = document.getElementById('btn-' + key);
  if (btn) { btn.textContent = 'MODIFICAR SELECCIÓN'; btn.classList.add('btn-modified'); }

  document.querySelector(`.comp-section[data-comp="${key}"]`)
    ?.classList.add('section-done');

  markDone(key);
  navStepDone(key);
}

/* ================================================================
   RESETEAR CONFIGURADOR
   ================================================================ */
function resetConfigurator() {
  document.querySelectorAll('#engine select').forEach(s => s.selectedIndex = 0);
  Object.keys(selections).forEach(k => delete selections[k]);

  Object.keys(SVG_IDS).forEach(key => {
    const statusEl = document.getElementById('status-' + key);
    if (statusEl) {
      statusEl.classList.remove('selected');
      statusEl.innerHTML = '<i class="fa-solid fa-circle-question"></i><span>SIN SELECCIONAR</span>';
    }
    const previewVal = document.getElementById('preview-val-' + key);
    if (previewVal) { previewVal.textContent = '—'; previewVal.classList.add('pending'); }
    const btn = document.getElementById('btn-' + key);
    if (btn) { btn.textContent = btn.dataset.label; btn.classList.remove('btn-modified'); }
    document.querySelector(`.comp-section[data-comp="${key}"]`)
      ?.classList.remove('visible','section-active','section-done');
    document.getElementById(SVG_IDS[key])?.classList.remove('done','active');
  });

  currentComp = null;
  navReset();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

/* ================================================================
   FORMULARIO
   ================================================================ */
function submitForm() {
  document.querySelectorAll('#engine select').forEach(s => {
    if (s.value === '') s.selectedIndex = 0;
  });
  document.getElementById('engine').submit();
}
