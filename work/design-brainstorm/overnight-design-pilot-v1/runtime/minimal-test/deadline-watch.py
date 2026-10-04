import time,datetime,subprocess,os,json,pathlib
p=pathlib.Path(__file__).parent
deadline=datetime.datetime.fromisoformat('2026-10-04T12:00:00+09:00').timestamp()
while time.time()<deadline: time.sleep(min(30,max(0,deadline-time.time())))
env=dict(os.environ);env.pop('HAPPIER_DAEMON_PENDING_FIRST_INPUT',None)
sid=json.loads((p/'launch.json').read_text())['data']['session']['id']
r=subprocess.run(['/Users/saitouyouwataru/.local/bin/happier','session','stop',sid,'--json'],env=env,capture_output=True,text=True,timeout=60)
(p/'deadline-stop.json').write_text(r.stdout)
