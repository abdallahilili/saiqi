#!/usr/bin/env node
// Génère les icônes d'application (Android mipmap-* + iOS AppIcon) des 3 apps, sans dépendance :
// un volant blanc sur fond dégradé, avec une couleur propre à chaque app.
//   node scripts/generate_icons.mjs
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const apps = {
  saiqi_client: { top: [11, 122, 90], bottom: [6, 78, 59], accent: [255, 255, 255] }, // vert
  saiqi_driver: { top: [11, 122, 90], bottom: [6, 78, 59], accent: [227, 160, 8] }, // vert + moyeu or
  saiqi_admin: { top: [55, 65, 81], bottom: [17, 24, 39], accent: [227, 160, 8] }, // ardoise + or
};

// ---- encodeur PNG minimal (RGBA 8 bits) -----------------------------------------
const crcTable = new Uint32Array(256).map((_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});
const crc32 = (buf) => {
  let c = 0xffffffff;
  for (const b of buf) c = crcTable[(c ^ b) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
};
const chunk = (type, data) => {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const td = Buffer.concat([Buffer.from(type), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(td));
  return Buffer.concat([len, td, crc]);
};
function png(size, rgba) {
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(size, 0);
  ihdr.writeUInt32BE(size, 4);
  ihdr[8] = 8; // profondeur
  ihdr[9] = 6; // RGBA
  const raw = Buffer.alloc((size * 4 + 1) * size);
  for (let y = 0; y < size; y++) {
    raw[y * (size * 4 + 1)] = 0;
    rgba.copy(raw, y * (size * 4 + 1) + 1, y * size * 4, (y + 1) * size * 4);
  }
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

// ---- dessin : volant -------------------------------------------------------------
function render(size, cfg, { rounded }) {
  const buf = Buffer.alloc(size * size * 4);
  const ss = 3; // suréchantillonnage 3x3
  const cx = 0.5, cy = 0.5;
  const inRoundedSquare = (x, y) => {
    if (!rounded) return true;
    const r = 0.2;
    const dx = Math.max(Math.abs(x - 0.5) - (0.5 - r), 0);
    const dy = Math.max(Math.abs(y - 0.5) - (0.5 - r), 0);
    return dx * dx + dy * dy <= r * r;
  };
  const wheel = (x, y) => {
    const dx = x - cx, dy = y - cy;
    const d = Math.hypot(dx, dy);
    if (d >= 0.27 && d <= 0.34) return 'ring';
    if (d <= 0.075) return 'hub';
    // rayons : gauche, droite, bas
    const ang = Math.atan2(dy, dx);
    const near = (a) => Math.abs(Math.atan2(Math.sin(ang - a), Math.cos(ang - a))) < 0.04 / Math.max(d, 0.05);
    if (d > 0.07 && d < 0.28 && (near(0) || near(Math.PI) || near(Math.PI / 2))) return 'spoke';
    return null;
  };
  for (let py = 0; py < size; py++) {
    for (let px = 0; px < size; px++) {
      let r = 0, g = 0, b = 0, a = 0;
      for (let sy = 0; sy < ss; sy++) {
        for (let sx = 0; sx < ss; sx++) {
          const x = (px + (sx + 0.5) / ss) / size;
          const y = (py + (sy + 0.5) / ss) / size;
          if (!inRoundedSquare(x, y)) continue;
          const t = (x + y) / 2;
          let col = cfg.top.map((c, i) => c + (cfg.bottom[i] - c) * t);
          const w = wheel(x, y);
          if (w === 'hub') col = cfg.accent;
          else if (w) col = [255, 255, 255];
          r += col[0]; g += col[1]; b += col[2]; a += 255;
        }
      }
      const n = ss * ss;
      const i = (py * size + px) * 4;
      const cov = a / (255 * n);
      buf[i] = cov ? Math.round(r / (cov * n)) : 0;
      buf[i + 1] = cov ? Math.round(g / (cov * n)) : 0;
      buf[i + 2] = cov ? Math.round(b / (cov * n)) : 0;
      buf[i + 3] = Math.round(cov * 255);
    }
  }
  return png(size, buf);
}

const androidSizes = { 'mipmap-mdpi': 48, 'mipmap-hdpi': 72, 'mipmap-xhdpi': 96, 'mipmap-xxhdpi': 144, 'mipmap-xxxhdpi': 192 };

for (const [app, cfg] of Object.entries(apps)) {
  const base = path.join(root, 'apps', app);
  if (!fs.existsSync(base)) continue;

  for (const [dir, size] of Object.entries(androidSizes)) {
    const out = path.join(base, 'android', 'app', 'src', 'main', 'res', dir);
    fs.mkdirSync(out, { recursive: true });
    fs.writeFileSync(path.join(out, 'ic_launcher.png'), render(size, cfg, { rounded: true }));
  }

  const iconSet = path.join(base, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');
  const contentsFile = path.join(iconSet, 'Contents.json');
  if (fs.existsSync(contentsFile)) {
    const contents = JSON.parse(fs.readFileSync(contentsFile, 'utf8'));
    const cache = new Map();
    for (const img of contents.images) {
      const px = Math.round(parseFloat(img.size) * parseInt(img.scale, 10));
      if (!cache.has(px)) cache.set(px, render(px, cfg, { rounded: false })); // iOS : plein cadre, sans alpha utile
      fs.writeFileSync(path.join(iconSet, img.filename), cache.get(px));
    }
  }
  console.log(`icônes générées : ${app}`);
}
