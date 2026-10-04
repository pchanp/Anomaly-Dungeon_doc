#!/usr/bin/env python3
"""Append an 'alternative palette / light direction' band to each map SVG.

Visual brainstorm only: proposes a second lighting direction per map so the
main rendering stays a single directional-key hypothesis.
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))

# map dir -> (title, note, sky_top, sky_bot, ground, haze, accent, light_px, light_label)
BANDS = {
    "august-31": (
        "ALT-AUGUST_31 / 代替案 A",
        "夕方から夜へ。低い太陽を湖の向こう側（右上手）に置き、水面が縦の帯으로光る",
        "#2E4A63", "#7A5F52", "#2B3A2E", "#8FA6B4", "#F0C88A", 1180,
        "主案: 昼（高い光・正面）→ 代替: 低い光（湖面反射）",
    ),
    "tsutaya": (
        "ALT-TSUTAYA / 代替案 A",
        "天井蛍光灯の生存率を下げ、店頭のCRT/看板だけを主光源にする。棚の背表紙は列ごとに点灯",
        "#141210", "#241C16", "#0E0B09", "#3A2A1C", "#6FD8E8", 1280,
        "主案: 天井蛍光灯（均一・冷たい）→ 代替: CRT/看板起点（点光源・冷たい）",
    ),
    "sekigahara": (
        "ALT-SEKIGAHARA / 代替案 A",
        "夜明け前の薄光。霞を薄くし、兵団のシルエットと旗の輪郭を地平線まで読ませる",
        "#6E7C86", "#B79A78", "#4A4438", "#C9BCA6", "#D8D2C4", 420,
        "主案: 夕焼け（暖色・強い霞）→ 代替: 薄明（低コントラスト・シルエット）",
    ),
    "korohkan": (
        "ALT-KOROHKAN / 代替案 A",
        "夜明け前の青。炎光を下げ、石垣と門灯の灯りだけで高所とルート差を読ませる",
        "#1B2333", "#3E4757", "#161A20", "#2C3646", "#FFC98A", 1320,
        "主案: 落日（暖色・長い影）→ 代替: 夜明け前（寒色・灯りが主体）",
    ),
    "open-liminal": (
        "ALT-OBSERVATION / 代替案 A",
        "正午前後の高照度。天頂光で影を落とし、遠景の『一点だけ異なる要素』だけを色差で残す",
        "#A9C4D8", "#CBD8E0", "#7E8C7A", "#D8E2E8", "#E05A48", 800,
        "主案: 曇天・低彩度（差分が不易視）→ 代替: 強光（差分を露出で拾う）",
    ),
}

SVG_TMPL = """
<rect x="0" y="900" width="1600" height="118" fill="#0d0f12"/>
<rect x="0" y="900" width="1600" height="2" fill="#3a4149"/>
<text x="24" y="928" fill="#9aa6b2" font-family="sans-serif" font-size="17">{title}</text>
<text x="24" y="950" fill="#6f7a86" font-family="sans-serif" font-size="13">{note}</text>
<rect x="24" y="962" width="470" height="34" fill="url(#altSky{gid})"/>
<rect x="24" y="962" width="117" height="34" fill="{ground}"/>
<rect x="504" y="962" width="470" height="34" fill="{haze}"/>
<rect x="504" y="962" width="34" height="34" fill="{accent}"/>
<g opacity="0.9">
<path d="M {lx} 996 L {lx2} 962 L {lx3} 996 Z" fill="{accent}" opacity="0.28"/>
</g>
<text x="24" y="1012" fill="#8d99a6" font-family="sans-serif" font-size="12">{lightlabel}</text>
<defs>
<linearGradient id="altSky{gid}" x1="0" y1="0" x2="0" y2="1">
<stop offset="0" stop-color="{skytop}"/>
<stop offset="1" stop-color="{skybot}"/>
</linearGradient>
</defs>
"""

HTML_TMPL = """
<style>
  .altband{{
    margin:0; padding:14px 24px 16px; background:#0d0f12;
    border-top:2px solid #3a4149; color:#9aa6b2;
    font-family:"Helvetica Neue",system-ui,sans-serif; box-sizing:border-box;
  }}
  .altband .t{{ font-size:17px; letter-spacing:.04em; }}
  .altband .n{{ font-size:13px; color:#6f7a86; margin-top:4px; }}
  .altband .chips{{ display:flex; gap:12px; margin-top:10px; align-items:center; }}
  .altband .sky{{ width:470px; height:34px; background:linear-gradient(180deg,{skytop},{skybot}); }}
  .altband .gnd{{ width:117px; height:34px; background:{ground}; }}
  .altband .haze{{ width:470px; height:34px; background:{haze}; }}
  .altband .acc{{ width:34px; height:34px; background:{accent}; }}
  .altband .l{{ font-size:12px; color:#8d99a6; margin-top:10px; }}
</style>
<div class="altband">
  <div class="t">{title}</div>
  <div class="n">{note}</div>
  <div class="chips">
    <div class="sky"></div><div class="gnd"></div>
    <div class="haze"></div><div class="acc"></div>
  </div>
  <div class="l">{lightlabel}</div>
</div>
"""


def esc(s):
    return (s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


def main():
    for d, (title, note, skytop, skybot, ground, haze, accent, lx, lightlabel) in BANDS.items():
        svg_path = os.path.join(HERE, d, "%s-view.svg" % d)
        html_path = os.path.join(HERE, d, "%s-view.html" % d)

        svg = open(svg_path, encoding="utf-8").read()
        # strip any previous band so this script is idempotent
        svg = re.sub(r'\n<rect x="0" y="900" width="1600" height="118".*?</defs>\n',
                     "\n", svg, flags=re.S)
        svg = svg.replace('height="900" viewBox="(0, 0, 1600, 900)"',
                          'height="1018" viewBox="(0, 0, 1600, 1018)"', 1)
        band = SVG_TMPL.format(
            gid=d, title=esc(title), note=esc(note), skytop=skytop, skybot=skybot,
            ground=ground, haze=haze, accent=accent,
            lx=lx, lx2=lx + 120, lx3=lx + 240, lightlabel=esc(lightlabel))
        svg = svg.replace("</svg>", band + "</svg>")
        open(svg_path, "w", encoding="utf-8").write(svg)

        html = open(html_path, encoding="utf-8").read()
        # drop any previous alt band (and anything a truncated run left behind)
        html = re.sub(r'\n?<style>\s*\.altband.*$', "\n", html, flags=re.S)
        html = re.sub(r'\n*<div class="altband">.*$', "\n", html, flags=re.S)
        if "</body>" not in html:
            html = html.rstrip() + "\n</body>\n"
        panel = HTML_TMPL.format(
            title=esc(title), note=esc(note), skytop=skytop, skybot=skybot,
            ground=ground, haze=haze, accent=accent, lightlabel=esc(lightlabel))
        html = html.replace("</body>", panel + "</body>")
        open(html_path, "w", encoding="utf-8").write(html)
        print("updated", d)


if __name__ == "__main__":
    main()