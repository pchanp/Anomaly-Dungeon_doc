import { describe, expect, it } from "vitest";
import { snapValue, snapPosition } from "./snap";
import { moveComponent, resizeComponent, sortForPaint } from "./transform";
import { createComponent } from "../model/layout";

const grid = { gridSize: 8, snap: true };
const free = { gridSize: 8, snap: false };

describe("snapValue", () => {
  it("rounds to the nearest multiple", () => {
    expect(snapValue(417, 8, true)).toBe(416);
    expect(snapValue(410, 8, true)).toBe(408);
  });

  it("is a no-op when disabled", () => {
    expect(snapValue(417, 8, false)).toBe(417);
  });

  it("handles a zero grid defensively", () => {
    expect(snapValue(417, 0, true)).toBe(417);
  });

  it("snaps both axes at once", () => {
    expect(snapPosition(417, 33, 8, true)).toEqual({ x: 416, y: 32 });
  });
});

describe("moveComponent", () => {
  const component = createComponent({ id: "a", x: 100, y: 200 });

  it("adds the delta and snaps", () => {
    expect(moveComponent(component, 17, -5, grid)).toEqual({ x: 120, y: 192 });
  });

  it("moves freely when snap is off", () => {
    expect(moveComponent(component, 17, -5, free)).toEqual({ x: 117, y: 195 });
  });

  it("allows negative coordinates", () => {
    expect(moveComponent(component, -500, -500, free)).toEqual({ x: -400, y: -300 });
  });
});

describe("resizeComponent", () => {
  const component = createComponent({ id: "a", x: 100, y: 100, width: 200, height: 100 });

  it("resizes from the south-east handle", () => {
    const rect = resizeComponent(component, "se", 50, 20, free);
    expect(rect).toEqual({ x: 100, y: 100, width: 250, height: 120 });
  });

  it("resizes from the north-west handle, moving the origin", () => {
    const rect = resizeComponent(component, "nw", 20, 10, free);
    expect(rect).toEqual({ x: 120, y: 110, width: 180, height: 90 });
  });

  it("resizes from edge handles", () => {
    expect(resizeComponent(component, "e", 10, 999, free)).toEqual({
      x: 100,
      y: 100,
      width: 210,
      height: 100,
    });
  });

  it("never collapses below the minimum size", () => {
    const rect = resizeComponent(component, "se", -500, -500, free);
    expect(rect.width).toBe(4);
    expect(rect.height).toBe(4);
  });

  it("snaps the moving edge, not the resulting size", () => {
    const rect = resizeComponent(component, "se", 47, 0, grid);
    // The origin (100) is deliberately off-grid, so the invariant is the *edge*, not width.
    expect(rect.x + rect.width).toBe(344);
  });
});

describe("sortForPaint", () => {
  it("puts larger z in front", () => {
    const low = createComponent({ id: "low", z: 0 });
    const high = createComponent({ id: "high", z: 100 });
    expect(sortForPaint([low, high]).map((c) => c.id)).toEqual(["low", "high"]);
    expect(sortForPaint([high, low]).map((c) => c.id)).toEqual(["low", "high"]);
  });

  it("keeps document order for equal z", () => {
    const first = createComponent({ id: "first", z: 10 });
    const second = createComponent({ id: "second", z: 10 });
    expect(sortForPaint([first, second]).map((c) => c.id)).toEqual(["first", "second"]);
  });
});
