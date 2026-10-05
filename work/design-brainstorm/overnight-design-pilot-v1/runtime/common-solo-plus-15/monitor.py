# coding: utf-8
import pathlib,json,subprocess,os,time,datetime,hashlib
BASE=pathlib.Path(__file__).resolve().parent
PACK=BASE.parent.parent/'common-pack-v0.3';S=json.loads((BASE/'sessions.json').read_text())
ENV=dict(os.environ);ENV.pop('HAPPIER_DAEMON_PENDING_FIRST_INPUT',None)
done=set();repairs={r:0 for r in S};last={r:int(time.time()*1000) for r in S}
def save(n,x):(BASE/n).write_text(json.dumps(x,ensure_ascii=False,indent=2))
def call(args):
 p=subprocess.run(['happier']+args,env=ENV,capture_output=True,text=True,timeout=40)
 try:return json.loads(p.stdout)
 except:return {'error':p.stderr,'returncode':p.returncode}
while len(done)<3:
 for r,v in S.items():
  if r in done:continue
  try:
   out=pathlib.Path(v['output']);old=json.loads((BASE/f'baseline-{r}.json').read_text())
   changed=[n for n,h in old.items() if not (out/n).exists() or hashlib.sha256((out/n).read_bytes()).hexdigest()!=h]
   if changed:
    save(f'needs-review-{r}.json',{'reason':'previous candidate changed','files':changed});done.add(r);continue
   pairs=[f'ROLE-{r}-{i:03}' for i in range(16,31) if (out/f'ROLE-{r}-{i:03}.html').is_file() and (out/f'ROLE-{r}-{i:03}.json').is_file()]
   stage='final' if len(pairs)==15 else 'progress'
   p=subprocess.run(['python3',str(PACK/'scripts/validate.py'),'--role',r,'--output',str(out),'--stage',stage],capture_output=True,text=True,timeout=40)
   report=json.loads(p.stdout);save(f'validation-{r}.json',report)
   legacy=[e for e in report.get('errors',[]) if r=='A' and e.startswith('ROLE-A-002: HTML/JSON identifier or title/status mismatch:')]
   errors=[e for e in report.get('errors',[]) if e not in legacy]
   status=call(['session','status',v['id'],'--live','--json']);save(f'status-{r}.json',status)
   save(f'progress-{r}.json',{'new_count':len(pairs),'target':15,'legacy_errors':legacy,'new_errors':errors,'at':datetime.datetime.now(datetime.timezone.utc).isoformat()})
   if len(pairs)==15 and not errors:
    save(f'completed-{r}.json',{'new_count':15,'total':30,'legacy_errors':legacy,'note':'New batch mechanically passed; visual and content review pending. No publication.'});done.add(r);continue
   h=call(['session','history',v['id'],'--limit','8','--format','raw','--json'])
   events=[m.get('createdAt',0) for m in h.get('data',{}).get('messages',[]) if m.get('raw',{}).get('content',{}).get('data',{}).get('type')=='task_complete'];new=max(events,default=0)
   if new>last[r]:
    last[r]=new
    if repairs[r]>=3:save(f'needs-review-{r}.json',{'reason':'three corrections used','errors':errors,'new_count':len(pairs)});done.add(r);continue
    repairs[r]+=1
    msg=f'追加回検証:新規ペア{len(pairs)}/15。016〜030の不足を作成し、manifest/index/progress/handoffを合計30件へ更新。前回001〜015は修正しない。ソロPvE面白さ優先、保存先は'+str(out)+'。追加回のエラー:'+json.dumps(errors[:12],ensure_ascii=False)+'。同じ保存先で完成まで進める。'
    save(f'correction-{r}-{repairs[r]}.json',call(['session','send',v['id'],msg,'--permission-mode','yolo','--model','opencode/space-bunny-free','--json']))
   if status.get('data',{}).get('session',{}).get('active') is False:
    save(f'needs-review-{r}.json',{'reason':'runner inactive; no automatic resume','new_count':len(pairs)});done.add(r)
  except Exception as e:save(f'error-{r}.json',{'error':str(e)})
 if len(done)<3:time.sleep(30)
save('finished.json',{'roles':sorted(done),'note':'See completed/needs-review. Public gallery not updated.'})
