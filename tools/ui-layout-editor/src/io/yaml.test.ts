import { describe, expect, it } from "vitest";
import { parseLayoutYaml, serializeLayoutYaml } from "./yaml";
import { SAMPLE_YAML } from "../model/sample";
import { LAYOUT_VERSION } from "../model/layout";

const MINIMAL = `version: 1
screen:
  id: hud
  name: HUD
  width: 1920
  height: 1080
components:
  - id: a
    type: panel
    x: 10
    y: 20
    z: 1
    width: 100
    height: 50
    texture: null
    properties:
      visible: true
`;

describe("parseLayoutYaml", () => {
  it("reads a minimal definition", () => {
    const { layout, errors } = parseLayoutYaml(MINIMAL);
    expect(errors).toEqual([]);
    expect(layout.version).toBe(LAYOUT_VERSION);
    expect(layout.screen.width).toBe(1920);
    expect(layout.components).toHaveLength(1);
    const component = layout.components[0];
    expect(component?.id).toBe("a");
    expect(component?.x).toBe(10);
    expect(component?.properties).toEqual({ visible: true });
  });

  it("never throws on broken YAML", () => {
    const { layout, errors } = parseLayoutYaml("version: [1\n  bad: :");
    expect(errors.length).toBeGreaterThan(0);
    expect(layout.components).toEqual([]);
  });

  it("reports a non-object root instead of crashing", () => {
    const { layout, errors } = parseLayoutYaml("- just\n- a list");
    expect(errors.length).toBeGreaterThan(0);
    expect(layout.components).toEqual([]);
  });

  it("falls back when screen is missing", () => {
    const { layout, errors } = parseLayoutYaml("version: 1\ncomponents: []");
    expect(errors.some((message) => message.includes("screen"))).toBe(true);
    expect(layout.screen.width).toBe(1920);
  });

  it("rejects duplicate ids and keeps the first", () => {
    const text = MINIMAL + `  - id: a
    type: panel
    x: 0
    y: 0
    z: 0
    width: 10
    height: 10
`;
    const { layout, errors } = parseLayoutYaml(text);
    expect(errors.some((message) => message.includes("重複"))).toBe(true);
    expect(layout.components).toHaveLength(1);
  });

  it("rejects a component without a type", () => {
    const text = `version: 1
screen: { id: s, name: S, width: 100, height: 100 }
components:
  - id: a
    x: 0
    y: 0
    z: 0
    width: 10
    height: 10
`;
    const { layout, errors } = parseLayoutYaml(text);
    expect(errors.some((message) => message.includes("type"))).toBe(true);
    expect(layout.components).toHaveLength(0);
  });

  it("coerces numeric strings but reports them", () => {
    const text = MINIMAL.replace("x: 10", 'x: "24"');
    const { layout, warnings } = parseLayoutYaml(text);
    expect(layout.components[0]?.x).toBe(24);
    expect(warnings.some((message) => message.includes("数値"))).toBe(true);
  });

  it("keeps an unknown type so it survives a save", () => {
    const text = MINIMAL.replace("type: panel", "type: anomaly_effect");
    const { layout } = parseLayoutYaml(text);
    expect(layout.components[0]?.type).toBe("anomaly_effect");
    expect(serializeLayoutYaml(layout)).toContain("anomaly_effect");
  });

  it("keeps unknown component keys in extra", () => {
    const text = `version: 1
screen: { id: s, name: S, width: 100, height: 100 }
components:
  - id: a
    type: panel
    anchor: bottom-left
    x: 0
    y: 0
    z: 0
    width: 10
    height: 10
`;
    const { layout } = parseLayoutYaml(text);
    expect(layout.components[0]?.extra).toEqual({ anchor: "bottom-left" });
    expect(serializeLayoutYaml(layout)).toContain("anchor");
  });

  it("keeps unknown top-level keys", () => {
    const text = `version: 1
meta:
  author: someone
screen: { id: s, name: S, width: 100, height: 100 }
components: []
`;
    const { layout } = parseLayoutYaml(text);
    expect(layout.extra).toEqual({ meta: { author: "someone" } });
    expect(serializeLayoutYaml(layout)).toContain("author");
  });

  it("flattens a nested property into JSON with a warning instead of dropping it", () => {
    const text = MINIMAL.replace("      visible: true", "      visible: true\n      nested: { a: 1 }");
    const { layout, warnings } = parseLayoutYaml(text);
    expect(layout.components[0]?.properties.nested).toBe('{"a":1}');
    expect(warnings.some((message) => message.includes("nested"))).toBe(true);
  });
});

describe("round trip", () => {
  it("preserves the shipped sample through parse and serialize", () => {
    const first = parseLayoutYaml(SAMPLE_YAML);
    expect(first.errors).toEqual([]);
    const second = parseLayoutYaml(serializeLayoutYaml(first.layout));
    expect(second.errors).toEqual([]);
    expect(second.layout.components).toHaveLength(first.layout.components.length);
    expect(second.layout).toEqual(first.layout);
  });
});
