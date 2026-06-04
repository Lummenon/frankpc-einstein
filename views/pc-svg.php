<!-- ================================================================
   Plano SVG del PC (Capa 3 — visor derecha).
   Cada <g id="svg-KEY"> es un componente independiente controlado
   por JS (clases: .active para resaltar, .done cuando se elige).
   Las clases .comp-fill / .comp-stroke / .comp-label son sobreescritas
   por CSS para el estilo blueprint navy/naranja.
   ================================================================ -->
<div id="pc-viewer">
  <div id="pc-viewer-title">PLANO TÉCNICO</div>
  <svg id="pc-svg" viewBox="0 0 260 425" xmlns="http://www.w3.org/2000/svg">

    <g id="svg-case" class="svg-comp">
      <rect class="comp-fill"   x="5"  y="5"  width="250" height="415" rx="8" fill="white"/>
      <rect class="comp-stroke" x="5"  y="5"  width="250" height="415" rx="8" fill="none" stroke="white" stroke-width="2"/>
      <rect x="5" y="5" width="24" height="415" rx="8" fill="rgba(255,255,255,0.03)"/>
      <line x1="29" y1="5"  x2="29" y2="420" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
      <circle cx="17" cy="30" r="6" fill="none" stroke="rgba(255,255,255,0.28)" stroke-width="1.5"/>
      <rect x="11" y="50" width="12" height="4" rx="1" fill="none" stroke="rgba(255,255,255,0.18)" stroke-width="1"/>
      <rect x="11" y="59" width="12" height="4" rx="1" fill="none" stroke="rgba(255,255,255,0.18)" stroke-width="1"/>
      <text class="comp-label" x="130" y="419" text-anchor="middle" fill="white" font-size="7">CHASIS</text>
    </g>

    <g id="svg-mobo" class="svg-comp">
      <rect class="comp-fill"   x="36" y="18" width="168" height="300" rx="4" fill="#0099ff"/>
      <rect class="comp-stroke" x="36" y="18" width="168" height="300" rx="4" fill="none" stroke="#0099ff" stroke-width="1.5"/>
      <line x1="36"  y1="160" x2="204" y2="160" stroke="rgba(0,153,255,0.18)" stroke-width="0.5"/>
      <line x1="36"  y1="230" x2="204" y2="230" stroke="rgba(0,153,255,0.18)" stroke-width="0.5"/>
      <line x1="120" y1="18"  x2="120" y2="318" stroke="rgba(0,153,255,0.18)" stroke-width="0.5"/>
      <text class="comp-label" x="78" y="314" text-anchor="middle" fill="#0099ff" font-size="7">PLACA BASE</text>
    </g>

    <g id="svg-cooler" class="svg-comp">
      <rect class="comp-fill"   x="40" y="20" width="94" height="38" rx="3" fill="#00ffff"/>
      <rect class="comp-stroke" x="40" y="20" width="94" height="38" rx="3" fill="none" stroke="#00ffff" stroke-width="1.5"/>
      <?php foreach([50,62,74,86,98,110,122] as $lx): ?>
      <line x1="<?=$lx?>" y1="28" x2="<?=$lx?>" y2="52" stroke="rgba(0,255,255,0.28)" stroke-width="1"/>
      <?php endforeach; ?>
      <text class="comp-label" x="87" y="50" text-anchor="middle" fill="#00ffff" font-size="6.5">COOLER</text>
    </g>

    <g id="svg-cpu" class="svg-comp">
      <rect class="comp-fill"   x="50" y="60" width="74" height="72" rx="3" fill="#ff0055"/>
      <rect class="comp-stroke" x="50" y="60" width="74" height="72" rx="3" fill="none" stroke="#ff0055" stroke-width="1.5"/>
      <rect x="58" y="68" width="58" height="56" rx="2" fill="none" stroke="rgba(255,0,85,0.35)" stroke-width="1"/>
      <?php
        foreach([[64,74],[80,74],[96,74],[64,89],[80,89],[64,104],[80,104],[96,104]] as [$cx,$cy]):
          $w = ($cx===80 && $cy===89) ? 26 : 12; $h=10;
          $op = ($cx===80 && $cy===89) ? '0.38' : '0.28';
      ?>
      <rect x="<?=$cx?>" y="<?=$cy?>" width="<?=$w?>" height="<?=$h?>" fill="rgba(255,0,85,<?=$op?>)"/>
      <?php endforeach; ?>
      <text class="comp-label" x="87" y="148" text-anchor="middle" fill="#ff0055" font-size="7">CPU</text>
    </g>

    <g id="svg-ram" class="svg-comp">
      <?php foreach([[148,167],[167,169]] as [$rx,$rx2]): ?>
      <rect class="comp-fill"   x="<?=$rx?>" y="20" width="15" height="115" rx="2" fill="#ffff00"/>
      <rect class="comp-stroke" x="<?=$rx?>" y="20" width="15" height="115" rx="2" fill="none" stroke="#ffff00" stroke-width="1.5"/>
      <?php foreach([30,40,50,60,70] as $ry): ?>
      <rect x="<?=$rx+2?>" y="<?=$ry?>" width="11" height="5" fill="rgba(255,255,0,0.32)"/>
      <?php endforeach; ?>
      <?php endforeach; ?>
      <text class="comp-label" x="162" y="148" text-anchor="middle" fill="#ffff00" font-size="7">RAM</text>
    </g>

    <g id="svg-storage" class="svg-comp">
      <rect class="comp-fill"   x="45" y="168" width="98" height="15" rx="2" fill="#bd00ff"/>
      <rect class="comp-stroke" x="45" y="168" width="98" height="15" rx="2" fill="none" stroke="#bd00ff" stroke-width="1.5"/>
      <?php foreach([50,66,82,98,114] as $sx): ?>
      <rect x="<?=$sx?>" y="171" width="12" height="9" fill="rgba(189,0,255,0.42)"/>
      <?php endforeach; ?>
      <text class="comp-label" x="94" y="197" text-anchor="middle" fill="#bd00ff" font-size="7">NVMe</text>
    </g>

    <g id="svg-gpu" class="svg-comp">
      <rect class="comp-fill"   x="36" y="228" width="168" height="52" rx="3" fill="#00ff00"/>
      <rect class="comp-stroke" x="36" y="228" width="168" height="52" rx="3" fill="none" stroke="#00ff00" stroke-width="1.5"/>
      <?php foreach([80,116] as $gc): ?>
      <circle cx="<?=$gc?>" cy="254" r="18" fill="none" stroke="rgba(0,255,0,0.38)" stroke-width="1.5"/>
      <circle cx="<?=$gc?>" cy="254" r="8"  fill="rgba(0,255,0,0.15)"/>
      <?php endforeach; ?>
      <?php foreach([150,157,164,171,178,185,192,199] as $gx): ?>
      <line x1="<?=$gx?>" y1="230" x2="<?=$gx?>" y2="278" stroke="rgba(0,255,0,0.28)" stroke-width="1.2"/>
      <?php endforeach; ?>
      <text class="comp-label" x="90" y="295" text-anchor="middle" fill="#00ff00" font-size="7">GPU</text>
    </g>

    <g id="svg-psu" class="svg-comp">
      <rect class="comp-fill"   x="36" y="330" width="218" height="80" rx="3" fill="#ffaa00"/>
      <rect class="comp-stroke" x="36" y="330" width="218" height="80" rx="3" fill="none" stroke="#ffaa00" stroke-width="1.5"/>
      <circle cx="84" cy="370" r="28" fill="none" stroke="rgba(255,170,0,0.38)" stroke-width="1.5"/>
      <circle cx="84" cy="370" r="11" fill="rgba(255,170,0,0.18)"/>
      <line x1="84"  y1="342" x2="84"  y2="398" stroke="rgba(255,170,0,0.28)" stroke-width="0.8"/>
      <line x1="56"  y1="370" x2="112" y2="370" stroke="rgba(255,170,0,0.28)" stroke-width="0.8"/>
      <line x1="64"  y1="350" x2="104" y2="390" stroke="rgba(255,170,0,0.28)" stroke-width="0.8"/>
      <line x1="104" y1="350" x2="64"  y2="390" stroke="rgba(255,170,0,0.28)" stroke-width="0.8"/>
      <?php foreach([126,141,156,171,186,201] as $px): ?>
      <rect x="<?=$px?>" y="338" width="10" height="12" rx="1"
            fill="rgba(255,170,0,0.32)" stroke="rgba(255,170,0,0.5)" stroke-width="0.5"/>
      <?php endforeach; ?>
      <text class="comp-label" x="145" y="403" text-anchor="middle" fill="#ffaa00" font-size="7">FUENTE DE ALIMENTACIÓN</text>
    </g>

  </svg>
</div>
