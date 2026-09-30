/**
 * Layout Definition data model.
 *
 * This module is the only place that knows the shape of a layout. React components
 * must not hard-code coordinates; they read and write these types instead, so that
 * `Layout Definition` stays the single source of truth (see spec section 32).
 *
 * Naming note for this repository: `id` and `type` are stable system IDs that code and
 * generators depend on. Any human-facing label is derived from them and is never stored
 * as the identity of a component.
 */

/** Scalar values allowed in `properties`. Nested structures are out of prototype scope. */
export type PropValue = string | number | boolean;

export type PropMap = Record<string, PropValue>;

/** Multi-state texture, e.g. `{ normal: ..., selected: ... }`. */
export type TextureMap = Record<string, string>;

/** A single path, a state map, or nothing. */
export type TextureValue = string | TextureMap | null;

export interface UiComponent {
  id: string;
  type: string;
  x: number;
  y: number;
  z: number;
  width: number;
  height: number;
  texture: TextureValue;
  properties: PropMap;
  /** Unknown keys found in the source YAML are kept here so a round trip never loses data. */
  extra: Record<string, unknown>;
}

export interface UiScreen {
  id: string;
  name: string;
  /** Virtual resolution. Internal coordinates never depend on the browser zoom. */
  width: number;
  height: number;
  extra: Record<string, unknown>;
}

export interface UiLayout {
  version: number;
  screen: UiScreen;
  components: UiComponent[];
  /** Unknown top-level keys, preserved for round-trip safety. */
  extra: Record<string, unknown>;
}

export const LAYOUT_VERSION = 1;

/** Component keys the editor understands. Anything outside this list is kept but unknown. */
export const COMPONENT_KEYS = [
  "id",
  "type",
  "x",
  "y",
  "z",
  "width",
  "height",
  "texture",
  "properties",
] as const;

export const MIN_COMPONENT_SIZE = 4;

export function createComponent(overrides: Partial<UiComponent> = {}): UiComponent {
  const base: UiComponent = {
    id: "new_component",
    type: "panel",
    x: 0,
    y: 0,
    z: 0,
    width: 100,
    height: 100,
    texture: null,
    properties: {},
    extra: {},
  };
  return { ...base, ...overrides, properties: { ...(overrides.properties ?? {}) }, extra: { ...(overrides.extra ?? {}) } };
}

export function createScreen(overrides: Partial<UiScreen> = {}): UiScreen {
  const base: UiScreen = { id: "screen", name: "Screen", width: 1920, height: 1080, extra: {} };
  return { ...base, ...overrides, extra: { ...(overrides.extra ?? {}) } };
}

export function createLayout(overrides: Partial<UiLayout> = {}): UiLayout {
  return {
    version: LAYOUT_VERSION,
    components: [],
    extra: {},
    ...overrides,
    screen: createScreen(overrides.screen),
  };
}

export function cloneLayout(layout: UiLayout): UiLayout {
  return {
    version: layout.version,
    screen: { ...layout.screen, extra: { ...layout.screen.extra } },
    components: layout.components.map(cloneComponent),
    extra: { ...layout.extra },
  };
}

export function cloneComponent(component: UiComponent): UiComponent {
  return {
    ...component,
    properties: { ...component.properties },
    extra: { ...component.extra },
  };
}

export function findComponent(layout: UiLayout, id: string | null): UiComponent | undefined {
  if (!id) return undefined;
  return layout.components.find((component) => component.id === id);
}

export function componentIndex(layout: UiLayout, id: string | null): number {
  if (!id) return -1;
  return layout.components.findIndex((component) => component.id === id);
}

export function collectIds(layout: UiLayout): string[] {
  return layout.components.map((component) => component.id);
}

/**
 * Returns `base` when free, otherwise `base_2`, `base_3`, ... until unique.
 * Duplicate is expected to produce `<id>_copy` first (spec section 23).
 */
export function uniqueId(base: string, taken: Iterable<string>): string {
  const used = new Set(taken);
  if (!used.has(base)) return base;
  let index = 2;
  while (used.has(`${base}_${index}`)) index += 1;
  return `${base}_${index}`;
}

/** Sanitises a user-typed ID into something usable as a YAML key and as a DOM-safe name. */
export function sanitizeId(raw: string, fallback = "component"): string {
  const cleaned = raw
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/_{2,}/g, "_");
  return cleaned.length > 0 ? cleaned : fallback;
}
