import{u as m}from"./index.-rTkXkxY.js";import{d as h,r as v,I as y,b as s,c as o,J as i,f as p,e as t,F as f,ah as C,p as k,i as b,t as g,l as I}from"./entry.JhSn3spu.js";const n=e=>(k("data-v-63eb7158"),e=e(),b(),e),S={key:0,class:"copied"},w=n(()=>t("div",{class:"scrim"},null,-1)),x=n(()=>t("div",{class:"content"}," Copied! ",-1)),B=[w,x],T=n(()=>t("div",{class:"header"},[t("div",{class:"controls"},[t("div"),t("div"),t("div")]),t("div",{class:"title"}," Bash ")],-1)),F={class:"window"},N=n(()=>t("span",{class:"sign"},"$",-1)),V={class:"content"},j={key:1,class:"prompt"},q=h({__name:"Terminal",props:{content:{type:[Array,String],required:!0}},setup(e){const a=e,{copy:l}=m(),c=v("init"),r=y(()=>typeof a.content=="string"?[a.content]:a.content),_=u=>{l(r.value.join(`
`)).then(()=>{c.value="copied",setTimeout(()=>{c.value="init"},1e3)}).catch(()=>{console.warn("Couldn't copy to clipboard!")})};return(u,A)=>(s(),o("div",{class:"terminal",onClick:_},[i(c)==="copied"?(s(),o("div",S,B)):p("",!0),T,t("div",F,[(s(!0),o(f,null,C(i(r),d=>(s(),o("span",{key:d,class:"line"},[N,t("span",V,g(d),1)]))),128))]),i(c)!=="copied"?(s(),o("div",j," Click to copy ")):p("",!0)]))}}),J=I(q,[["__scopeId","data-v-63eb7158"]]);export{J as default};
