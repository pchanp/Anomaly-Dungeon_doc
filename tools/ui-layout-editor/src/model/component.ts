/**
 * Component type registry.
 *
 * The registry is intentionally a *rendering* concern, not a validation concern. Unknown
 * types are preserved and rendered as placeholders (spec section 35), because the game
 * will grow game-specific types that this editor has never heard of.
 */

export interface ComponentTypeInfo {
  type: string;
  /** Canvas label only. Never used as identity. */
  label: string;
  known: boolean;
  defaultSize: { width: number; height: number };
  /** Texture state shown on the canvas. */
  textureState: string;
  /** Text that stands in for a texture when none is available. */
  fallbackLabel?: string;
}

const REGISTRY: Record<string, Omit<ComponentTypeInfo, "known">> = {
  panel: { type: "panel", label: "Panel", defaultSize: { width: 200, height: 120 }, textureState: "normal" },
  group: { type: "group", label: "Group", defaultSize: { width: 320, height: 200 }, textureState: "normal" },
  slot: {
    type: "slot",
    label: "Slot",
    defaultSize: { width: 96, height: 96 },
    textureState: "normal",
    fallbackLabel: "SLOT",
  },
  text: {
    type: "text",
    label: "Text",
    defaultSize: { width: 260, height: 40 },
    textureState: "normal",
    fallbackLabel: "TEXT",
  },
  image: {
    type: "image",
    label: "Image",
    defaultSize: { width: 128, height: 128 },
    textureState: "normal",
    fallbackLabel: "IMAGE",
  },
  button: {
    type: "button",
    label: "Button",
    defaultSize: { width: 180, height: 48 },
    textureState: "normal",
    fallbackLabel: "BUTTON",
  },
  gauge: {
    type: "gauge",
    label: "Gauge",
    defaultSize: { width: 360, height: 32 },
    textureState: "normal",
    fallbackLabel: "GAUGE",
  },
  minimap: {
    type: "minimap",
    label: "Minimap",
    defaultSize: { width: 240, height: 240 },
    textureState: "normal",
    fallbackLabel: "MAP",
  },
  radio: {
    type: "radio",
    label: "Radio",
    defaultSize: { width: 320, height: 56 },
    textureState: "normal",
    fallbackLabel: "RADIO",
  },
};

export const KNOWN_TYPES: string[] = Object.keys(REGISTRY).sort();

export function isKnownType(type: string): boolean {
  return Object.prototype.hasOwnProperty.call(REGISTRY, type);
}

export function getTypeInfo(type: string): ComponentTypeInfo {
  const entry = REGISTRY[type];
  if (entry) return { ...entry, known: true };
  return {
    type,
    label: `Unknown: ${type}`,
    known: false,
    defaultSize: { width: 160, height: 100 },
    textureState: "normal",
    fallbackLabel: "UNKNOWN",
  };
}

export function defaultSizeFor(type: string): { width: number; height: number } {
  return getTypeInfo(type).defaultSize;
}

/** Picks the texture path to show on the canvas, preferring the type's own state. */
export function resolveTexturePath(
  texture: string | Record<string, string> | null,
  preferredState: string,
): string | null {
  if (!texture) return null;
  if (typeof texture === "string") return texture.length > 0 ? texture : null;
  const preferred = texture[preferredState];
  if (typeof preferred === "string" && preferred.length > 0) return preferred;
  const fallbackKey = Object.keys(texture).find((key) => typeof texture[key] === "string" && texture[key] !== "");
  if (fallbackKey) return texture[fallbackKey] ?? null;
  return null;
}
