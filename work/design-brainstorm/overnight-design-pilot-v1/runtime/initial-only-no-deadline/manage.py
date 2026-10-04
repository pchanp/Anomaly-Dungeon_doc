import os,json,pathlib,subprocess,datetime,time,shutil,threading,concurrent.futures
BASE=pathlib.Path(__file__).resolve().parent
PACK=BASE.parent.parent/'common-pack'
CLI='/Users/saitouyouwataru/.local/bin/happier'
DEADLINE=float('inf')
ENV=dict(os.environ);ENV.pop('HAPPIER_DAEMON_PENDING_FIRST_INPUT',None)
sessions={};done=set();lock=threading.Lock()
def save(name,data):
 (BASE/name).write_text(json.dumps(data,ensure_ascii=False,indent=2))
def call(args,timeout=45):
 p=subprocess.run([CLI]+args,env=ENV,capture_output=True,text=True,timeout=timeout)
 try: return json.loads(p.stdout)
 except Exception: return {'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
def stop_one(role,s):
 try:
  save('stop-'+role+'.json',call(['session','stop',s['id'],'--json']))
  save('final-status-'+role+'.json',call(['session','status',s['id'],'--live','--json']))
 except Exception as e: save('stop-'+role+'.json',{'stop_unconfirmed':str(e)})
save('settings.json',{'model':'opencode/space-bunny-free','account':'configured default','deadline':None,'mode':'PILOT_ONLY','resume':False,'bash_by_agent':False,'validation_by':'manager','state':'starting'})
for role in 'ABC':
 if time.time()>=DEADLINE: break
 root=BASE/'roots'/role;pack=root/'work/design-brainstorm/overnight-design-pilot-v1/common-pack'
 shutil.copytree(PACK,pack,dirs_exist_ok=False)
 output=pack.parent/role;output.mkdir()
 (root/'AGENTS.md').write_text('ROLE='+role+'。Bash/task/MCP/外部directoryは禁止。ネイティブRead/Write/Editのみ。出力はwork/design-brainstorm/overnight-design-pilot-v1/'+role+'/のみ。Python検証・ブラウザ確認は管理側が担当。設計3件以外作らない。\n')
 override='管理側の今回専用上書き指示: Bash、task、MCP、外部directory、外部調査、Git、Studioを一切使わない。ネイティブRead/Write/Edit/Glob/Grepのみ。共通パックのPython検証と実表示確認は管理側が行うので自分では実行しない。日時取得もBash不要、観測不能な時刻はnull。3件(001,004,013)のHTML+JSON、index、manifest、progress、handoffを作成して回答し、runnerは管理側が停止するまで待機。本番12件へ進まない。'
 prompt='ROLE='+role+'\nMODE=PILOT_ONLY\nMODEL=opencode/space-bunny-free\n時間制限なし。各3件完了で確認待ち。\n管理側観測開始時刻='+datetime.datetime.now(datetime.timezone.utc).isoformat()+'\n'+override+'\n'+(pack/'prompts/common.md').read_text()+'\n'+(pack/('prompts/role-'+role.lower()+'.md')).read_text()+'\n'+override+'\n共通パックREADMEと指定資料を読み開始してください。巨大なsources.jsonやschemaは必要ならReadのoffset/limitで分けて読む。'
 (BASE/('prompt-'+role+'.txt')).write_text(prompt)
 try:
  result=call(['session','create','--path',str(root),'--backend','opencode','--model','opencode/space-bunny-free','--auth','default','--permission-mode','safe-yolo','--transcript-storage','persisted','--title','OpenCode pilot '+role+' initial-only','--tag','pilot-initial-only-no-deadline-'+role,'--prompt',prompt,'--json'],60)
  save('launch-'+role+'.json',result);sid=result.get('data',{}).get('session',{}).get('id')
  if sid:
   with lock: sessions[role]={'id':sid,'root':str(root),'output':str(output),'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat()};save('sessions.json',sessions)
   if time.time()>=DEADLINE: stop_one(role,sessions[role])
 except Exception as e: save('launch-'+role+'.json',{'error':str(e),'do_not_retry_automatically':True})
while time.time()<DEADLINE:
 for role,s in list(sessions.items()):
  if time.time()>=DEADLINE: break
  try:
   state=call(['session','status',s['id'],'--live','--json'],15);save('status-'+role+'.json',state)
   out=pathlib.Path(s['output']);files=sorted(f.name for f in out.iterdir() if f.is_file());save('files-'+role+'.json',files)
   expected=['ROLE-'+role+'-'+n for n in ['001','004','013']]
   if all((out/(i+'.html')).exists() and (out/(i+'.json')).exists() for i in expected):
    p=subprocess.run(['python3',str(PACK/'scripts/validate.py'),'--role',role,'--output',str(out),'--stage','pilot'],capture_output=True,text=True,timeout=15)
    try: report=json.loads(p.stdout)
    except Exception: report={'stdout':p.stdout,'stderr':p.stderr,'exit':p.returncode}
    save('validation-'+role+'.json',report)
  except Exception as e: save('monitor-error-'+role+'.json',{'error':str(e)})

 if sessions and len(sessions)==3 and all(all((pathlib.Path(v['output'])/f).exists() for f in ['handoff.md','manifest.json','index.html']+[('ROLE-'+r+'-'+n+ext) for n in ['001','004','013'] for ext in ['.html','.json']]) for r,v in sessions.items()):
  save('awaiting-review.json',{'state':'awaiting_pilot_review','at':datetime.datetime.now(datetime.timezone.utc).isoformat()})
  break
 time.sleep(20)
save('finished.json',{'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'roles':list(sessions)})
