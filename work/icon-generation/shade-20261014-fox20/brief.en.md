# SHADE — Fox Illusion visual study (20 candidates)

Status: Draft. This file is an art brief for candidate images, not a game-specification change.

## User direction

Create 20 SHADE candidate icons. The visual image should match Fox's side-B (Fox Illusion) in Super Smash Bros. All delegate instructions, labels, prompts, negative prompts, and variant notes must be in English. The primary agent reports progress and summaries to the user in Japanese.

The user explicitly asks for a VISUAL brief rather than an explanation of SHADE's gameplay. Work from the visible pose, afterimages, color, and motion. Do not translate damage, stun, ranks, stealth rules, enemies, or diagrams into pictures.

## Visual reference

Local reference: references/fox-illusion-reference.jpg
Source image: https://d1lss44hh2trtw.cloudfront.net/assets/article/2018/10/16/super-smash-bros-ultimate-fox-3_feature.jpg
Source page: https://www.shacknews.com/article/107941/super-smash-bros-ultimate-character-profiles-fox
Official move-name reference: https://www.smashbros.com/wii/en_us/characters/fox.html

Observed visual: a low, forward-pitched body bursts horizontally toward the right. The head and shoulders lead; the torso folds forward, the legs sweep back, and the arms follow the compact rushing pose. Immediately behind the leading body is a luminous cyan-blue ghost of that SAME pose, pulled horizontally toward the left and crossed by narrow parallel streaks. The real leading body is sharply readable; the blue afterimage is translucent and dissolves into a long horizontal energy smear. This is a fast side-on dash captured in one instant, not a running-pose sequence or a diagram.

For SHADE, use an anonymous shadowlike humanoid as the foreground figure. Transfer the reference's rushing pose and blue afterimage effect; character identity and costume are not being established by this visual study. Keep the silhouette faceless and free of gear. This is the same visual motion, with the figure serving as a simple icon subject.

## Image composition

- One cohesive action illustration. One dominant rushing figure leads on the right, with a connected translucent echo and horizontal light trail behind it on the left.
- Strictly horizontal left-to-right motion, seen from the side. Low forward lean, compact airborne lunge. No upright standing figure.
- The blue echo belongs to the same moving figure. It must not become a crowd, a row of upright people, or separate diagram cells.
- Blue/cyan-white glow with dark navy/charcoal negative space. Focus the contrast on the leading contour, readable echo, and straight streak.
- Stylized painted game-icon illustration with an energetic luminous motion effect. Avoid flat restroom pictograms, vector infographic language, maps, technical diagrams, orbital circles, frames, pedestals, or scenic stages.
- No typography, labels, logos, border, weapons, helmets, clothing details, gore, or unrelated emblems.
- The icon fills a square canvas, but keep canvas dimensions, pixel-readability specifications, variant numbers, and production instructions OUT of the image prompt.
- The final SDXL prompt must describe what is VISIBLE. Proper move names alone are not a useful image description. Do not include game mechanics in the prompt.

## Controlled variation

Keep the core image above in every candidate. Vary only the amount of forward lean, position and scale of the leading figure, shape/transparency of the connected echo, trail length and thickness, edge glow, and the balance of blue/cyan/white. The result must still look like the same Fox Illusion visual idea.

A: 7 variants focused on silhouette/pose and a coherent attached afterimage.
B: 7 variants focused on the horizontal cyan-blue trail and ghost transparency.
C: 6 variants focused on compact icon composition, contrast, and luminous painted finish.

Each variant needs an English label, a concise English SDXL prompt (roughly 60-110 words), an English negative_prompt, and English notes naming the concrete visual difference. Notes should not explain gameplay.

Read repository/workspace safety instructions, then this visual brief. Do not use the old 5-image brief or skill-mechanics table as the image-writing brief. Do not edit game documents or infer a new System ID. Do not call Draw Things or enqueue work yourself. The primary agent validates and saves the prompts, then sends exactly 20 requests through the shared serial worker.
