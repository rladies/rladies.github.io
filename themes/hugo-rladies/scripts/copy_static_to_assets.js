const fs = require('fs');
const path = require('path');

const themeRoot = path.resolve(__dirname, '..');
const staticJs = path.join(themeRoot, 'static', 'js');
const assetsJs = path.join(themeRoot, 'assets', 'js');

function ensureDir(dir) {
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function copyFile(src, dest) {
    fs.copyFileSync(src, dest);
    console.log('copied', path.relative(themeRoot, src), '->', path.relative(themeRoot, dest));
}

function sync() {
    ensureDir(assetsJs);
    if (!fs.existsSync(staticJs)) {
        console.log('No static/js directory found at', staticJs);
        return;
    }
    const files = fs.readdirSync(staticJs).filter(f => f.endsWith('.js') || f.endsWith('.map'));
    if (!files.length) {
        console.log('No JS files found in', staticJs);
        return;
    }
    for (const f of files) {
        const s = path.join(staticJs, f);
        const d = path.join(assetsJs, f);
        copyFile(s, d);
    }
    console.log('sync complete — copied', files.length, 'files');
}

sync();
