#!/usr/bin/env python3
"""events.jsonlを読み、実測の経過時間を標準出力へまとめる。"""
import argparse
from datetime import datetime
import json
from pathlib import Path


def summarize(path):
    warnings, intervals, open_phases = [], [], {}
    previous = None
    starts, ends = [], []
    events = [json.loads(line) for line in path.read_text(encoding='utf-8').splitlines() if line.strip()]
    for n, event in enumerate(events, 1):
        raw = event.get('at')
        if raw is None:
            warnings.append(f'line {n}: timestamp unavailable');continue
        time = datetime.fromisoformat(raw.replace('Z', '+00:00'))
        if time.tzinfo is None:
            warnings.append(f'line {n}: timezone unavailable');continue
        if previous and time < previous:
            warnings.append(f'line {n}: timestamp went backwards')
        previous = time
        name = event.get('event','')
        if name == 'session_start':starts.append(time)
        if name == 'session_end':ends.append(time)
        if name.endswith('_start'):
            phase=name[:-6]
            if phase in open_phases:warnings.append(f'line {n}: duplicate start: {phase}')
            open_phases[phase]=(time,event)
        elif name.endswith('_end'):
            phase=name[:-4]
            if phase not in open_phases:
                warnings.append(f'line {n}: end without start: {phase}');continue
            start,begin=open_phases.pop(phase)
            seconds=(time-start).total_seconds()
            if seconds<0:
                warnings.append(f'line {n}: negative interval: {phase}');continue
            intervals.append({'phase':phase,'started_at':start.isoformat(),'ended_at':time.isoformat(),'elapsed_seconds':seconds,'candidate_ids':event.get('candidate_ids') or begin.get('candidate_ids',[]),'note':event.get('note','')})
    for phase in open_phases:warnings.append('unfinished phase: '+phase)
    totals={}
    for interval in intervals:totals[interval['phase']]=totals.get(interval['phase'],0)+interval['elapsed_seconds']
    complete=bool(starts) and len(starts)==len(ends) and 'session' not in open_phases and not any('timestamp' in w or 'timezone' in w or 'session' in w for w in warnings)
    overall=(max(ends)-min(starts)).total_seconds() if complete else None
    session_total=totals.get('session')
    return {'events_file':str(path),'overall_elapsed_seconds':overall,'session_elapsed_seconds':session_total,'between_sessions_seconds':overall-session_total if overall is not None and session_total is not None else None,'phase_totals_seconds':totals,'intervals':intervals,'retries':sum(e.get('event')=='retry' for e in events),'first_session_start':min(starts).isoformat() if starts else None,'last_session_end':max(ends).isoformat() if complete else None,'warnings':warnings,'note':'batch時間は図作成・内部待機を含み得る。phaseは重なるため合算して作業時間にしない。'}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('events',nargs='+',type=Path)
    args=parser.parse_args()
    try:
        roles=[summarize(p) for p in args.events]
        all_complete=all(x['first_session_start'] and x['last_session_end'] for x in roles)
        elapsed=(max(datetime.fromisoformat(x['last_session_end']) for x in roles)-min(datetime.fromisoformat(x['first_session_start']) for x in roles)).total_seconds() if all_complete else None
        print(json.dumps({'roles':roles,'parallel_overall_elapsed_seconds':elapsed,'generation_capacity_estimate':'初回の実測と内容品質を確認後に算出。未計測値を推定しない。'},ensure_ascii=False,indent=2))
        return 0
    except (OSError,ValueError,TypeError,KeyError) as exc:
        print(json.dumps({'error':str(exc)},ensure_ascii=False));return 2


if __name__=='__main__':raise SystemExit(main())
