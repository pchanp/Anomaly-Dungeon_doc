import json, pathlib, shutil, subprocess, datetime, time, os
BASE=pathlib.Path(__file__).resolve().parent
PACK=BASE.parent/'common-pack'
CLI='/Users/saitouyouwataru/.local/bin/happier'
DEADLINE=datetime.datetime.fromisoformat('2026-10-04T12:00:00+09:00').timestamp()
def save(name,data):
 (BASE/name).write_text(json.dumps(data,ensure_ascii=False,indent=2))
def call(args,timeout=90):
 p=subprocess.run([CLI]+args,capture_output=True,text=True,timeout=timeout)
 try: d=json.loads(p.stdout)
 except Exception: d={'stdout':p.stdout,'stderr':p.stderr,'exit':p.returncode}
 return d
sessions={}
save('settings.json',{'model':'opencode/space-bunny-free','account':'configured default','deadline':'2026-10-04T12:00:00+09:00','mode':'PILOT_ONLY','state':'starting','unused_probe_session':'cmut6ub0g1z5foi5ch4942r9z'})
for role in 'ABC':
 if time.time()>=DEADLINE: break
 root=BASE/'roots'/role
 pack=root/'work/design-brainstorm/overnight-design-pilot-v1/common-pack'
 shutil.copytree(PACK,pack,dirs_exist_ok=True)
 output=pack.parent/role
 output.mkdir(parents=True,exist_ok=True)
 (root/'AGENTS.md').write_text('この作業rootでは出力は work/design-brainstorm/overnight-design-pilot-v1/'+role+'/ のみ。資料は共通パックを読む。ゲーム実装、Git、他rootへのアクセスは禁止。\n')
 # Exclude external game/tool MCPs. Restrict edits to this role; default explicit deny.
 permission={'edit':{'*':'deny',str(output)+'/**':'allow','work/design-brainstorm/overnight-design-pilot-v1/'+role+'/**':'allow'},'external_directory':'deny','bash':'allow'}
 config={'permission':permission,'mcp':{}}
 prompt='ROLE='+role+'\nMODE=PILOT_ONLY\nMODEL=opencode/space-bunny-free\n終了期限=2026-10-04 12:00 JST。対象は001、004、013の3件だけ。以後は進めず終了。\n'+(pack/'prompts/common.md').read_text()+'\n'+(pack/('prompts/role-'+role.lower()+'.md')).read_text()+'\nここは独立した作業rootです。共通パックREADMEから必読文書を読み、生成を開始してください。bashも書き込みは担当出力だけ。外部MCP、Studio、他セッション、元リポジトリへアクセス禁止。終了後はhandoffを残して終了。'
 (BASE/('prompt-'+role+'.txt')).write_text(prompt)
 result=call(['session','create','--path',str(root),'--backend','opencode','--model','opencode/space-bunny-free','--auth','default','--permission-mode','acceptEdits','--title','OpenCode pilot '+role,'--tag','overnight-design-pilot-v1-'+role,'--transcript-storage','persisted','--env','OPENCODE_CONFIG_CONTENT='+json.dumps(config),'--prompt',prompt,'--json'])
 save('launch-'+role+'.json',result)
 sid=result.get('data',{}).get('session',{}).get('id')
 if sid: sessions[role]={'id':sid,'root':str(root),'output':str(output),'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat()}
 save('sessions.json',sessions)
# Watcher persists beyond this interactive turn. Stop only these exact sessions at deadline.
while time.time()<DEADLINE:
 for role,s in sessions.items():
  try: save('status-'+role+'.json',call(['session','status',s['id'],'--live','--json'],30))
  except Exception as e: save('status-'+role+'.json',{'error':str(e)})
 time.sleep(min(30,max(0,DEADLINE-time.time())))
for role,s in sessions.items():
 try:
  save('stop-'+role+'.json',call(['session','stop',s['id'],'--json'],45))
  save('final-status-'+role+'.json',call(['session','status',s['id'],'--live','--json'],30))
 except Exception as e: save('stop-'+role+'.json',{'stop_unconfirmed':str(e)})
save('supervisor-finished.json',{'finished_at':datetime.datetime.now(datetime.timezone.utc).isoformat()})
