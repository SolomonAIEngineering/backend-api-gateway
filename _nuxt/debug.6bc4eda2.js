import{Q as a}from"./entry.6adbee61.js";function d(t){let o=[],i=!1;const s=(u,l)=>{const{loc:e}=l,n=[`🔑 ${u}`];e!=null&&e.file&&(n.push(""),n.push(`🔗 ${e.file}`)),e!=null&&e.type&&(n.push(""),n.push(`❓ Missing token inside a ${e.type==="v"?"variant":"computed style or CSS prop"}.`)),o.push(n.join(`
`)),i||(a(()=>{console.log("🖌️ Pinceau `runtime` encountered some errors!"),o.forEach(r=>{console.log(r)}),console.log("‼️ This warning will be hidden from production and can be disabled using `dev: false` option.")}),i=!0)};t.onNotFound=s}export{d as usePinceauRuntimeDebug};