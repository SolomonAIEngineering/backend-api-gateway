import b from"./TabsHeader.a46f477c.js";import g from"./ComponentPlaygroundProps.7ece86c8.js";import{_ as v}from"./ComponentPlaygroundSlots.vue.8f90f75b.js";import{_ as x}from"./ComponentPlaygroundTokens.vue.85c5c03e.js";import{a as k}from"./index.f1e4f71e.js";import{d as D,r as V,b as n,c as C,g as P,J as o,X as m,au as T,f as s,k as B}from"./entry.6adbee61.js";import"./ProseH4.9392f428.js";import"./ProseCodeInline.7c90423f.js";import"./Badge.7e73e4ea.js";import"./slot.70e5a52e.js";import"./node.676c5e99.js";import"./ProseP.7eeef6d2.js";const I={class:"component-playground-data"},j=D({__name:"ComponentPlaygroundData",props:{modelValue:{type:Object,required:!1,default:()=>({})},componentData:{type:Object,required:!1,default:()=>({})}},emits:["update:modelValue"],setup(t,{emit:p}){const a=k(t,"modelValue",p),e=V(0),r=[{label:"Props"},{label:"Slots"},{label:"Design Tokens"}],d=c=>e.value=c;return(c,l)=>{const u=b,_=g,i=v,f=x;return n(),C("div",I,[P(u,{"active-tab-index":o(e),tabs:r,"onUpdate:activeTabIndex":d},null,8,["active-tab-index"]),o(e)===0?(n(),m(_,{key:0,modelValue:o(a),"onUpdate:modelValue":l[0]||(l[0]=y=>T(a)?a.value=y:null),"component-data":t.componentData},null,8,["modelValue","component-data"])):s("",!0),o(e)===1?(n(),m(i,{key:1,"component-data":t.componentData},null,8,["component-data"])):s("",!0),o(e)===2?(n(),m(f,{key:2,"component-data":t.componentData},null,8,["component-data"])):s("",!0)])}}});const z=B(j,[["__scopeId","data-v-ff75821c"]]);export{z as default};