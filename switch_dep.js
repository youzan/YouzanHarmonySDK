const fs = require('fs');
const path = require('path');

const mode = process.argv[2];

if (mode !== 'source' && mode !== 'remote') {
  console.error('Usage: node switch_dep.js [source|remote]');
  process.exit(1);
}

const buildProfilePath = path.join(__dirname, 'build-profile.json5');
const rootPackagePath = path.join(__dirname, 'oh-package.json5');
const entryPackagePath = path.join(__dirname, 'entry', 'oh-package.json5');

try {
  // 1. Update build-profile.json5
  let buildProfile = fs.readFileSync(buildProfilePath, 'utf8');
  const yzwebModuleBlock = `,\n    {\n      "name": "yzweb",\n      "srcPath": "../YouzanHarmonySDK/yzweb"\n    }`;

  if (mode === 'source') {
    if (!buildProfile.includes('"name": "yzweb"')) {
      buildProfile = buildProfile.replace(/}\n  ]\n}/, `}${yzwebModuleBlock}\n  ]\n}`);
    }
  } else {
    buildProfile = buildProfile.replace(yzwebModuleBlock, '');
    // Regex fallback
    buildProfile = buildProfile.replace(/,\s*\{\s*"name":\s*"yzweb",\s*"srcPath":\s*"\.\.\/YouzanHarmonySDK\/yzweb"\s*\}/g, '');
  }
  fs.writeFileSync(buildProfilePath, buildProfile);

  // 2. Update root oh-package.json5
  let rootPackage = fs.readFileSync(rootPackagePath, 'utf8');
  if (mode === 'source') {
    rootPackage = rootPackage.replace(/"@youzanyun\/app_web":\s*".*?"/, '"@youzanyun/app_web": "../YouzanHarmonySDK/yzweb"');
  } else {
    rootPackage = rootPackage.replace(/"@youzanyun\/app_web":\s*".*?"/, '"@youzanyun/app_web": "1.1.15"');
  }
  fs.writeFileSync(rootPackagePath, rootPackage);

  // 3. Update entry oh-package.json5
  let entryPackage = fs.readFileSync(entryPackagePath, 'utf8');
  if (mode === 'source') {
    if (!entryPackage.includes('"@youzanyun/app_web"')) {
      entryPackage = entryPackage.replace(/"dependencies":\s*\{/, '"dependencies": {\n    "@youzanyun/app_web": "../../YouzanHarmonySDK/yzweb"');
    }
  } else {
    entryPackage = entryPackage.replace(/\n\s*"@youzanyun\/app_web":\s*".*?"/, '');
  }
  fs.writeFileSync(entryPackagePath, entryPackage);

  console.log(`✅ 成功切换为 ${mode === 'source' ? '【源码依赖】' : '【远程依赖】'}!`);
  console.log(`👉 请在 DevEco Studio 中点击 "Sync Now" 或运行 "ohpm install" 以使配置生效。`);
} catch (err) {
  console.error('❌ 切换失败: ', err.message);
}
