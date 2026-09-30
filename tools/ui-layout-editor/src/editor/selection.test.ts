import { describe, expect, it } from "vitest";
import { describeTexture, filterComponents, nextSelection, sortComponents } from "./selection";
import { createComponent } from "../model/layout";

const components = [
  createComponent({ id: "slot_01", type: "slot", x: 440, y: 800, z: 20 }),
  createComponent({ id: "slot_02", type: "slot", x: 548, y: 800, z: 20 }),
  createComponent({ id: "exposure", type: "gauge", x: 1480, y: 60, z: 30 }),
  createComponent({ id: "panel_bg", type: "panel", x: 400, y: 760, z: 10 }),
];

describe("filterComponents", () => {
  it("matches id and type case-insensitively", () => {
    expect(filterComponents(components, { search: "slot", type: "*", zMin: "", zMax: "" }).map((c) => c.id)).toEqual([
      "slot_01",
      "slot_02",
    ]);
    expect(filterComponents(components, { search: "GAUGE", type: "*", zMin: "", zMax: "" }).map((c) => c.id)).toEqual([
      "exposure",
    ]);
  });

  it("filters by type", () => {
    expect(
      filterComponents(components, { search: "", type: "panel", zMin: "", zMax: "" }).map((c) => c.id),
    ).toEqual(["panel_bg"]);
  });

  it("filters by a z range", () => {
    expect(
      filterComponents(components, { search: "", type: "*", zMin: "20", zMax: "25" }).map((c) => c.id),
    ).toEqual(["slot_01", "slot_02"]);
  });

  it("treats an empty search as no filter", () => {
    expect(filterComponents(components, { search: "  ", type: "*", zMin: "", zMax: "" })).toHaveLength(4);
  });
});

describe("sortComponents", () => {
  it("sorts by z", () => {
    expect(sortComponents(components, { key: "z", direction: 1 }).map((c) => c.id)).toEqual([
      "panel_bg",
      "slot_01",
      "slot_02",
      "exposure",
    ]);
  });

  it("reverses with direction -1", () => {
    expect(sortComponents(components, { key: "x", direction: -1 }).map((c) => c.id)).toEqual([
      "exposure",
      "slot_02",
      "slot_01",
      "panel_bg",
    ]);
  });

  it("breaks ties by id for stable output", () => {
    expect(sortComponents(components, { key: "z", direction: 1 }).map((c) => c.id)).toContain("slot_01");
    expect(sortComponents(components, { key: "z", direction: 1 }).map((c) => c.id).indexOf("slot_01")).toBeLessThan(
      sortComponents(components, { key: "z", direction: 1 }).map((c) => c.id).indexOf("slot_02"),
    );
  });

  it("does not mutate the input", () => {
    const before = components.map((c) => c.id);
    sortComponents(components, { key: "id", direction: -1 });
    expect(components.map((c) => c.id)).toEqual(before);
  });
});

describe("nextSelection", () => {
  it("wraps around", () => {
    expect(nextSelection("panel_bg", components, 1)).toBe("slot_01");
    expect(nextSelection("exposure", components, 1)).toBe("panel_bg");
  });
});

describe("describeTexture", () => {
  it("describes a single path", () => {
    expect(describeTexture("assets/a.png")).toBe("assets/a.png");
  });

  it("describes a state map", () => {
    expect(describeTexture({ normal: "a.png", selected: "b.png" })).toBe("normal: a.png, selected: b.png");
  });

  it("handles nothing", () => {
    expect(describeTexture(null)).toBe("");
  });
});
