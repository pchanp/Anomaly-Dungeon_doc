import { describe, expect, it } from "vitest";
import { sanitizeId, uniqueId, createComponent, createLayout, cloneLayout, findComponent } from "./layout";
import { getTypeInfo, isKnownType, resolveTexturePath } from "./component";

describe("uniqueId", () => {
  it("keeps a free id untouched", () => {
    expect(uniqueId("slot_01", [])).toBe("slot_01");
  });

  it("produces slot_01_copy first, matching the documented Duplicate behaviour", () => {
    expect(uniqueId("slot_01", ["slot_01"])).toBe("slot_01_2");
    expect(uniqueId("slot_01", ["slot_01", "slot_01_2"])).toBe("slot_01_3");
  });

  it("skips gaps rather than reusing a taken name", () => {
    expect(uniqueId("a", ["a", "a_2", "a_3"])).toBe("a_4");
  });
});

describe("sanitizeId", () => {
  it("keeps a normal id", () => {
    expect(sanitizeId("slot_01")).toBe("slot_01");
  });

  it("normalises spaces, symbols and case", () => {
    expect(sanitizeId("  My Slot!  ")).toBe("my_slot");
    expect(sanitizeId("A--B")).toBe("a_b");
  });

  it("falls back when nothing usable remains", () => {
    expect(sanitizeId("!!!")).toBe("component");
  });
});

describe("createComponent", () => {
  it("provides the documented defaults", () => {
    const component = createComponent();
    expect(component).toMatchObject({
      id: "new_component",
      type: "panel",
      x: 0,
      y: 0,
      z: 0,
      width: 100,
      height: 100,
      texture: null,
      properties: {},
    });
  });

  it("does not alias the caller's properties object", () => {
    const properties = { min: 0 };
    const first = createComponent({ properties });
    first.properties.min = 5;
    expect(properties.min).toBe(0);
  });
});

describe("cloneLayout", () => {
  it("produces an independent copy", () => {
    const layout = createLayout({ components: [createComponent({ id: "a" })] });
    const copy = cloneLayout(layout);
    const target = copy.components[0];
    expect(target).toBeDefined();
    if (target) target.x = 999;
    expect(layout.components[0]?.x).toBe(0);
    expect(findComponent(layout, "a")).toBeDefined();
  });
});

describe("component registry", () => {
  it("knows the prototype types", () => {
    for (const type of ["panel", "slot", "text", "image", "button", "gauge", "minimap", "group"]) {
      expect(isKnownType(type)).toBe(true);
    }
  });

  it("marks an unknown type without throwing", () => {
    expect(isKnownType("anomaly_effect")).toBe(false);
    const info = getTypeInfo("anomaly_effect");
    expect(info.known).toBe(false);
    expect(info.type).toBe("anomaly_effect");
  });
});

describe("resolveTexturePath", () => {
  it("returns a single path as-is", () => {
    expect(resolveTexturePath("assets/a.png", "normal")).toBe("assets/a.png");
  });

  it("prefers the requested state", () => {
    expect(resolveTexturePath({ normal: "a.png", selected: "b.png" }, "selected")).toBe("b.png");
  });

  it("falls back to the first usable state", () => {
    expect(resolveTexturePath({ normal: "", selected: "b.png" }, "normal")).toBe("b.png");
  });

  it("returns null for nothing", () => {
    expect(resolveTexturePath(null, "normal")).toBeNull();
    expect(resolveTexturePath({}, "normal")).toBeNull();
  });
});
