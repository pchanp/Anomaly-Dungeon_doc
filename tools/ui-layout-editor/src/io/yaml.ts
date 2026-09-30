/**
 * YAML read / write for the Layout Definition.
 *
 * Two rules drive this module:
 *  1. A malformed file must never crash the editor. Problems are collected as messages
 *     and loading continues on a best-effort basis (spec section 34).
 *  2. Data must survive a round trip. Unknown component types *and* unknown keys are kept
 *     so that saving never destroys something this prototype does not understand
 *     (spec sections 35 and 40).
 */

import { parse as parseYaml, stringify as stringifyYaml } from "yaml";
import {
  COMPONENT_KEYS,
  LAYOUT_VERSION,
  cloneComponent,
  cloneLayout,
  createComponent,
  createLayout,
  type PropMap,
  type PropValue,
  type TextureMap,
  type TextureValue,
  type UiComponent,
  type UiLayout,
  type UiScreen,
} from "../model/layout";

export interface ParseResult {
  layout: UiLayout;
  errors: string[];
  warnings: string[];
}

const COMPONENT_KEY_SET = new Set<string>(COMPONENT_KEYS);

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readNumber(value: unknown, path: string, errors: string[], warnings: string[]): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      warnings.push(`${path}: "${value}" を数値 ${parsed} として読み込みました。`);
      return parsed;
    }
  }
  errors.push(`${path}: 数値が必要です（受信値: ${describe(value)}）。0 として扱います。`);
  return 0;
}

function readString(value: unknown, path: string, errors: string[], fallback: string): string {
  if (typeof value === "string") return value;
  if (typeof value === "number" || typeof value === "boolean") {
    errors.push(`${path}: 文字列が必要です。${describe(value)} として扱います。`);
    return String(value);
  }
  errors.push(`${path}: 文字列がありません。既定値 "${fallback}" を使用します。`);
  return fallback;
}

function describe(value: unknown): string {
  if (value === null) return "null";
  if (value === undefined) return "なし";
  if (Array.isArray(value)) return `配列(${value.length})`;
  if (typeof value === "object") return "オブジェクト";
  return JSON.stringify(value);
}

function readTexture(value: unknown, path: string, errors: string[]): TextureValue {
  if (value === null || value === undefined) return null;
  if (typeof value === "string") return value;
  if (isPlainObject(value)) {
    const map: TextureMap = {};
    for (const [state, entry] of Object.entries(value)) {
      if (typeof entry === "string") map[state] = entry;
      else errors.push(`${path}.${state}: 文字列（画像パス）が必要です。省略しました。`);
    }
    return map;
  }
  errors.push(`${path}: 文字列かオブジェクトが必要です。null として扱います。`);
  return null;
}

function readProperties(value: unknown, path: string, errors: string[], warnings: string[]): PropMap {
  if (value === null || value === undefined) return {};
  if (!isPlainObject(value)) {
    errors.push(`${path}: オブジェクトが必要です。空として扱います。`);
    return {};
  }
  const out: PropMap = {};
  for (const [key, entry] of Object.entries(value)) {
    if (typeof entry === "string" || typeof entry === "number" || typeof entry === "boolean") {
      out[key] = entry as PropValue;
    } else {
      // Nested structures are explicitly out of prototype scope; keep them visible as JSON
      // instead of dropping them, and say so.
      warnings.push(`${path}.${key}: プリミティブでないため JSON 文字列として保持しました。`);
      out[key] = JSON.stringify(entry);
    }
  }
  return out;
}

function readScreen(value: unknown, errors: string[]): UiScreen {
  if (!isPlainObject(value)) {
    errors.push("screen: オブジェクトがありません。既定値 (1920x1080) を使用します。");
    return { id: "screen", name: "Screen", width: 1920, height: 1080, extra: {} };
  }
  const extra: Record<string, unknown> = {};
  for (const [key, entry] of Object.entries(value)) {
    if (key !== "id" && key !== "name" && key !== "width" && key !== "height") extra[key] = entry;
  }
  const widthErrors: string[] = [];
  const heightErrors: string[] = [];
  const width = readNumber(value.width, "screen.width", widthErrors, []);
  const height = readNumber(value.height, "screen.height", heightErrors, []);
  for (const message of [...widthErrors, ...heightErrors]) errors.push(message);
  return {
    id: readString(value.id, "screen.id", errors, "screen"),
    name: readString(value.name, "screen.name", errors, "Screen"),
    width: width > 0 ? width : 1920,
    height: height > 0 ? height : 1080,
    extra,
  };
}

function readComponent(
  value: unknown,
  index: number,
  errors: string[],
  warnings: string[],
  usedIds: Set<string>,
): UiComponent | null {
  const path = `components[${index}]`;
  if (!isPlainObject(value)) {
    errors.push(`${path}: オブジェクトではありません。読み飛ばしました。`);
    return null;
  }

  const rawId = value.id;
  if (typeof rawId !== "string" || rawId.trim() === "") {
    errors.push(`${path}: id がありません。読み飛ばしました。`);
    return null;
  }
  if (usedIds.has(rawId)) {
    errors.push(`${path}: id "${rawId}" が重複しています。読み飛ばしました。`);
    return null;
  }
  usedIds.add(rawId);

  if (typeof value.type !== "string" || value.type.trim() === "") {
    errors.push(`${path} (${rawId}): type がありません。読み飛ばしました。`);
    usedIds.delete(rawId);
    return null;
  }

  const extra: Record<string, unknown> = {};
  for (const [key, entry] of Object.entries(value)) {
    if (!COMPONENT_KEY_SET.has(key)) extra[key] = entry;
  }

  const widthErrors: string[] = [];
  const heightErrors: string[] = [];
  const width = readNumber(value.width, `${path}.width`, widthErrors, warnings);
  const height = readNumber(value.height, `${path}.height`, heightErrors, warnings);
  for (const message of [...widthErrors, ...heightErrors]) errors.push(message);

  return createComponent({
    id: rawId,
    type: value.type,
    x: readNumber(value.x, `${path}.x`, errors, warnings),
    y: readNumber(value.y, `${path}.y`, errors, warnings),
    z: readNumber(value.z, `${path}.z`, errors, warnings),
    width,
    height,
    texture: readTexture(value.texture, `${path}.texture`, errors),
    properties: readProperties(value.properties, `${path}.properties`, errors, warnings),
    extra,
  });
}

export function parseLayoutYaml(text: string): ParseResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  let raw: unknown;
  try {
    raw = parseYaml(text);
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return {
      layout: createLayout(),
      errors: [`YAML の構文を解析できませんでした: ${message}`],
      warnings,
    };
  }

  if (!isPlainObject(raw)) {
    return {
      layout: createLayout(),
      errors: ["YAML のルートがオブジェクトではありません。空のレイアウトで開きました。"],
      warnings,
    };
  }

  if (raw.version === undefined) {
    warnings.push(`version がありません。${LAYOUT_VERSION} として扱います。`);
  }
  if (raw.screen === undefined) {
    errors.push("screen がありません。既定値 (1920x1080) を使用します。");
  }

  const versionRaw = raw.version;
  const version =
    typeof versionRaw === "number" && Number.isFinite(versionRaw) ? versionRaw : LAYOUT_VERSION;
  if (typeof versionRaw === "number" && versionRaw > LAYOUT_VERSION) {
    warnings.push(
      `version ${versionRaw} はこの Prototype が理解する ${LAYOUT_VERSION} より新です。未知のキーは保持して読み込みます。`,
    );
  }

  const screen = readScreen(raw.screen, errors);

  const components: UiComponent[] = [];
  const usedIds = new Set<string>();
  const rawComponents = raw.components;
  if (rawComponents === undefined) {
    warnings.push("components がありません。空として扱います。");
  } else if (!Array.isArray(rawComponents)) {
    errors.push("components が配列ではありません。空として扱います。");
  } else {
    rawComponents.forEach((entry, index) => {
      const component = readComponent(entry, index, errors, warnings, usedIds);
      if (component) components.push(component);
    });
  }

  const extra: Record<string, unknown> = {};
  for (const [key, entry] of Object.entries(raw)) {
    if (key !== "version" && key !== "screen" && key !== "components") extra[key] = entry;
  }

  return { layout: { version, screen, components, extra }, errors, warnings };
}

export function serializeLayoutYaml(layout: UiLayout): string {
  const document: Record<string, unknown> = {
    version: layout.version,
    screen: { id: layout.screen.id, name: layout.screen.name, ...layout.screen.extra, width: layout.screen.width, height: layout.screen.height },
    components: layout.components.map((component) => ({
      id: component.id,
      type: component.type,
      x: component.x,
      y: component.y,
      z: component.z,
      width: component.width,
      height: component.height,
      texture: component.texture,
      properties: { ...component.properties },
      ...component.extra,
    })),
    ...layout.extra,
  };
  return stringifyYaml(document, { lineWidth: 0 });
}

/** Deep copy used by history snapshots. Re-exported so callers need only one import. */
export { cloneComponent, cloneLayout };
