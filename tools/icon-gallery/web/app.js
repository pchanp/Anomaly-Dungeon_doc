"use strict";
const $ = (id) => document.getElementById(id);
const labels = {unreviewed:"未確認",candidate:"採用候補",revise:"修正したい",rejected:"見送り"};
const jobLabels = {queued:"待機中",running:"生成中",done:"完了",failed:"失敗",uncertain:"結果を要確認"};
let data = {items:[],jobs:[]}, lane = "all", shown = [], selected = null, fingerprint = "", polling = false, dirty = false, saving = false;

async function api(path, body) {
  const response = await fetch(path, {cache:"no-store", ...(body === undefined ? {} : {
    method:"POST", headers:{"Content-Type":"application/json","X-Icon-Gallery":"1"}, body:JSON.stringify(body)
  })});
  const result = await response.json();
  if (!response.ok) {
    if (response.status === 401) showLogin();
    throw new Error(result.error || "接続できませんでした");
  }
  return result;
}
function showLogin() { $("login").hidden=false; $("workspace").hidden=true; $("connection").textContent="キーで開いてください"; document.querySelector(".live").classList.remove("online"); }
async function login(token) {
  try { await api("/api/login", {token}); $("login").hidden=true; $("workspace").hidden=false; $("token").value=""; $("login-error").textContent=""; await refresh(); }
  catch (error) { $("login-error").textContent=error.message; }
}
function imageURL(item, thumb=false) { return "/image?id="+encodeURIComponent(item.id)+(thumb?"&thumb=1":"")+"&v="+item.modified; }
function title(item) { return String(item.metadata.title || item.metadata.target_id || item.filename); }
function displayError(error) { $("error").hidden=false; $("error").textContent=error.message; }
async function refresh() {
  if (polling) return;
  polling=true;
  try {
    const next = await api("/api/gallery");
    $("login").hidden=true; $("workspace").hidden=false; $("error").hidden=true;
    $("connection").textContent="自動更新 · "+new Date().toLocaleTimeString("ja-JP",{hour:"2-digit",minute:"2-digit"});
    document.querySelector(".live").classList.add("online");
    const nextFingerprint=JSON.stringify({items:next.items,jobs:next.jobs});
    data=next;
    if (nextFingerprint !== fingerprint) { fingerprint=nextFingerprint; render(); renderJobs(); if(selected) updateDetail(false); }
  } catch(error) {
    document.querySelector(".live").classList.remove("online");
    if (!$("workspace").hidden) { $("connection").textContent="再接続を待っています"; displayError(error); }
  } finally { polling=false; }
}
function render() {
  $("count-all").textContent=data.items.length;
  for(const letter of ["A","B","C"]) $("count-"+letter).textContent=data.items.filter(x=>x.lane===letter).length;
  const query=$("search").value.toLocaleLowerCase().trim(), filter=$("review-filter").value;
  shown=data.items.filter(item=>(lane==="all"||item.lane===lane)&&(filter==="all"||item.review.state===filter)&&
    (!query||[title(item),item.filename,item.metadata.prompt,item.metadata.target_id,item.review.note].join(" ").toLocaleLowerCase().includes(query)));
  if($("sort").value==="oldest") shown.sort((a,b)=>a.modified-b.modified);
  if($("sort").value==="name") shown.sort((a,b)=>title(a).localeCompare(title(b),"ja"));
  $("grid").replaceChildren();
  for(const item of shown) {
    const card=$("card-template").content.cloneNode(true);
    const img=card.querySelector("img"); img.src=imageURL(item,true); img.alt=title(item);
    card.querySelector(".card-lane").textContent="WORKER "+item.lane;
    card.querySelector(".card-title").textContent=title(item);
    card.querySelector(".card-subtitle").textContent=item.metadata.seed !== undefined?"SEED "+item.metadata.seed:item.filename;
    const badge=card.querySelector(".badge"); badge.textContent=labels[item.review.state]||"未確認"; badge.classList.add(item.review.state);
    const star=card.querySelector(".star"); star.textContent=item.review.state==="candidate"?"★":"☆";
    star.classList.toggle("selected",item.review.state==="candidate"); star.setAttribute("aria-label",item.review.state==="candidate"?"採用候補を解除":"採用候補にする");
    star.addEventListener("click",async()=>{star.disabled=true;try{await saveReview(item,item.review.state==="candidate"?"unreviewed":"candidate",item.review.note);}catch(error){displayError(error);}finally{star.disabled=false;}});
    card.querySelector(".image-button").addEventListener("click",()=>openDetail(item.id));
    card.querySelector(".card-title").addEventListener("click",()=>openDetail(item.id));
    $("grid").append(card);
  }
  $("result-count").textContent=shown.length+"枚 / "+data.items.length+"枚";
  $("empty").hidden=shown.length>0;
  $("empty-title").textContent=data.items.length?"条件に合う画像がありません":"最初のアイコンを待っています";
  $("empty-text").textContent=data.items.length?"担当・状態・検索条件を変えてみてください。":"A・B・Cの画像フォルダに保存すると、ここに自動で届きます。";
}
function renderJobs() {
  const pending=data.jobs.filter(x=>["queued","running"].includes(x.state)).length;
  $("queue-count").textContent=pending+"件待機・生成中";
  $("jobs").replaceChildren();
  if(!data.jobs.length){const p=document.createElement("p");p.textContent="まだ生成リクエストはありません。";$("jobs").append(p);}
  for(const job of data.jobs){const row=document.createElement("div");row.className="job";const id=document.createElement("code");id.textContent=job.id;const state=document.createElement("span");state.textContent=jobLabels[job.state]||job.state;row.append(id,state);if(job.error){const note=document.createElement("p");note.textContent=job.error;row.append(note);}$("jobs").append(row);}
}
function openDetail(id) { selected=id;dirty=false;$("save-status").textContent="";updateDetail(true);if(!$("detail").open)$("detail").showModal(); }
function updateDetail(reset) {
  const item=data.items.find(x=>x.id===selected);
  if(!item){$("detail").close();return;}
  const url=imageURL(item);
  for(const id of ["detail-image","small-32","small-48","small-64"]) if($(id).getAttribute("src")!==url)$(id).src=url;
  $("detail-image").alt=title(item);$("detail-title").textContent=title(item);$("detail-file").textContent=item.id;$("detail-lane").textContent="WORKER "+item.lane+" / OUTPUT";
  $("detail-meta").replaceChildren();
  const fields=[["モデル",item.metadata.model],["Seed",item.metadata.seed],["サイズ",item.metadata.width&&item.metadata.height?item.metadata.width+" × "+item.metadata.height:undefined],["Steps / CFG",item.metadata.steps!==undefined?item.metadata.steps+" / "+item.metadata.cfg_scale:undefined],["Sampler",item.metadata.sampler_name],["システムID",item.metadata.target_id]];
  for(const [name,value] of fields)if(value!==undefined){const dt=document.createElement("dt"),dd=document.createElement("dd");dt.textContent=name;dd.textContent=String(value);$("detail-meta").append(dt,dd);}
  document.querySelectorAll("[data-review]").forEach(button=>{const active=button.dataset.review===item.review.state;button.classList.toggle("active",active);button.setAttribute("aria-pressed",String(active));});
  if(reset||!dirty)$("note").value=item.review.note;
  $("prompt").textContent=item.metadata.prompt||"生成情報は記録されていません。";$("negative").textContent=item.metadata.negative_prompt||"指定なし";
  $("copy-prompt").disabled=!item.metadata.prompt;
  if(reset)$("copy-prompt").textContent="コピー";
  $("generation-notes").textContent=item.metadata.notes?"生成時の注記: "+String(item.metadata.notes):"";
  $("source-docs").textContent=Array.isArray(item.metadata.source_docs)?"参照: "+item.metadata.source_docs.join(" / "):"";
  $("download").href=url;$("download").download=item.filename;
  const index=shown.findIndex(x=>x.id===selected);$("position").textContent=index>=0?(index+1)+" / "+shown.length:"絞り込み範囲外";$("previous").disabled=index<=0;$("next").disabled=index<0||index>=shown.length-1;
}
async function saveReview(item,state,note) {
  const review=await api("/api/review",{id:item.id,state,note});
  item.review=review;fingerprint="";render();if(selected===item.id)updateDetail(false);
}
async function saveDetail(state) {
  if(saving)return;const item=data.items.find(x=>x.id===selected);if(!item)return;
  saving=true;$("save-status").textContent="保存中…";$("save-note").disabled=true;
  try{await saveReview(item,state||item.review.state,$("note").value);dirty=false;$("save-status").textContent="保存しました";}
  catch(error){$("save-status").textContent=error.message;}
  finally{saving=false;$("save-note").disabled=false;}
}
document.querySelectorAll("[data-lane]").forEach(button=>button.addEventListener("click",()=>{lane=button.dataset.lane;document.querySelectorAll("[data-lane]").forEach(x=>{x.classList.toggle("active",x===button);x.setAttribute("aria-pressed",String(x===button));});render();}));
for(const id of ["search","review-filter","sort"])$(id).addEventListener(id==="search"?"input":"change",render);
$("refresh").addEventListener("click",refresh);
$("login-form").addEventListener("submit",event=>{event.preventDefault();login($("token").value.trim());});
$("close").addEventListener("click",()=>$("detail").close());
$("detail").addEventListener("close",()=>{selected=null;dirty=false;});
$("note").addEventListener("input",()=>{dirty=true;$("save-status").textContent="未保存";});
$("save-note").addEventListener("click",()=>saveDetail());
document.querySelectorAll("[data-review]").forEach(button=>button.addEventListener("click",()=>saveDetail(button.dataset.review)));
for(const [id,direction] of [["previous",-1],["next",1]])$(id).addEventListener("click",()=>{const index=shown.findIndex(x=>x.id===selected);if(shown[index+direction])openDetail(shown[index+direction].id);});
$("copy-prompt").addEventListener("click",async()=>{try{await navigator.clipboard.writeText($("prompt").textContent);$("copy-prompt").textContent="コピーしました";}catch{ $("copy-prompt").textContent="本文を選択してコピーしてください";}});
$("logout").addEventListener("click",async()=>{try{await api("/api/logout",{});showLogin();}catch(error){displayError(error);}});
document.addEventListener("visibilitychange",()=>{if(!document.hidden)refresh();});
setInterval(()=>{if(!document.hidden&&!$("workspace").hidden)refresh();},5000);
const initialQuery=new URLSearchParams(location.search).get("q");
if(initialQuery)$("search").value=initialQuery;
const hash=new URLSearchParams(location.hash.slice(1)), token=hash.get("token");
if(token){history.replaceState(null,"",location.pathname+location.search);login(token);}else{refresh();}
