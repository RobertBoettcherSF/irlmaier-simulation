const pp=require('/workspace/uim-tools/node_modules/puppeteer-core');
(async()=>{const exe=require('child_process').execSync('command -v chromium || command -v google-chrome').toString().trim();
const b=await pp.launch({executablePath:exe,args:['--no-sandbox']});
async function run(name,vp,mobile){const p=await b.newPage();const errs=[];p.on('pageerror',e=>errs.push(e.message));p.on('console',m=>{if(m.type()==='error'&&!/CORS|version.txt|Failed to load/.test(m.text()))errs.push(m.text())});
await p.setViewport(vp);
await p.goto('file:///workspace/irlmaier/repo/index.html?karte');await new Promise(r=>setTimeout(r,1500));
// tap North Sea at 56N 3E
const xy=await p.evaluate(()=>toScr(56,3));await p.mouse.click(xy[0],xy[1]);await new Promise(r=>setTimeout(r,800));
const land=await p.evaluate(()=>toScr(52,10));await p.mouse.click(land[0],land[1]);await new Promise(r=>setTimeout(r,200));
const info=await p.evaluate(()=>({mark,txt:document.getElementById('pinfo').innerText,toast:document.getElementById('toast').innerText}));
await p.screenshot({path:'/workspace/irlmaier/'+name+'.png'});console.log(name,JSON.stringify(info),'errors:',errs);await p.close()}
await run('v030_desktop',{width:1280,height:800},false);
await run('v030_phone',{width:390,height:844,deviceScaleFactor:2,isMobile:true,hasTouch:true},true);
await b.close()})();
