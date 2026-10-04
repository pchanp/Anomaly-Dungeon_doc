import os,json,pathlib,subprocess,datetime,sys
BASE=pathlib.Path(__file__).resolve().parent
ROOT=BASE/'root'
ENV=dict(os.environ)
ENV.pop('HAPPIER_DAEMON_PENDING_FIRST_INPUT',None)
CLI='/Users/saitouyouwataru/.local/bin/happier'
def call(args):
 p=subprocess.run([CLI]+args,env=ENV,capture_output=True,text=True,timeout=60)
 try: data=json.loads(p.stdout)
 except Exception: data={'stdout':p.stdout,'stderr':p.stderr,'exit':p.returncode}
 return data
if sys.argv[1]=='start':
 if datetime.datetime.now(datetime.timezone.utc)>=datetime.datetime.fromisoformat('2026-10-04T03:00:00+00:00'): raise SystemExit('deadline reached')
 ROOT.mkdir(exist_ok=True)
 (ROOT/'output').mkdir(exist_ok=True)
 (ROOT/'fixture.txt').write_text('READ_CHECK=violet-742\n')
 (ROOT/'fixture.txt').chmod(0o444)
 (ROOT/'AGENTS.md').write_text('このrootはCLI接続テスト専用。設計候補は作らない。Bash、task、外部MCP、外部directoryを使わない。Read/Edit/Writeのネイティブ操作だけを使用。fixture.txtを読む。書き込みはoutput/のみ。\n')
 prompt='候補生成なしの接続テストです。Bash、task、MCP、外部directoryを使わず、ネイティブReadでfixture.txtを読み、ネイティブWriteまたはEditでoutput/probe.txtを作成し、読み取ったREAD_CHECKをそのまま書いてください。最後に同じ文字列を回答し、この指示だけで終了。output以外は変更禁止。'
 data=call(['session','create','--path',str(ROOT),'--backend','opencode','--model','opencode/space-bunny-free','--auth','default','--permission-mode','safe-yolo','--transcript-storage','persisted','--title','OpenCode minimal lifecycle test','--tag','overnight-pilot-minimal-test','--prompt',prompt,'--json'])
 (BASE/'launch.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)); print(json.dumps(data))
else:
 sid=json.loads((BASE/'launch.json').read_text())['data']['session']['id']
 data=call(['session']+sys.argv[1:2]+[sid]+sys.argv[2:]+['--json'])
 print(json.dumps(data,ensure_ascii=False))
