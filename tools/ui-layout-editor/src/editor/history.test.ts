import { describe, expect, it } from "vitest";
import { createHistory, pushHistory, redo, undo } from "./history";
import { createComponent, createLayout, type UiLayout } from "../model/layout";

function layoutWithX(x: number): UiLayout {
  return createLayout({ components: [createComponent({ id: "a", x })] });
}

describe("history", () => {
  it("starts empty and refuses to undo or redo", () => {
    const history = createHistory();
    expect(undo(history, layoutWithX(0))).toBeNull();
    expect(redo(history, layoutWithX(0))).toBeNull();
  });

  it("undoes and redoes a single edit", () => {
    const start = layoutWithX(0);
    const after = layoutWithX(100);
    const history = pushHistory(createHistory(), start, "移動");
    expect(history.past).toHaveLength(1);

    const undone = undo(history, after);
    expect(undone?.layout.components[0]?.x).toBe(0);
    expect(undone?.history.future).toHaveLength(1);

    const redone = redo(undone!.history, undone!.layout);
    expect(redone?.layout.components[0]?.x).toBe(100);
    expect(redone?.history.past).toHaveLength(1);
  });

  it("drops the redo branch once a new edit lands", () => {
    const a = layoutWithX(0);
    const b = layoutWithX(10);
    const c = layoutWithX(20);
    const h1 = pushHistory(createHistory(), a, "1");
    const undone = undo(h1, b)!;
    const h2 = pushHistory(undone.history, c, "2");
    expect(h2.future).toHaveLength(0);
  });

  it("stores snapshots, not aliases", () => {
    const a = layoutWithX(0);
    const b = layoutWithX(10);
    const history = pushHistory(createHistory(), a, "移動");
    b.components[0]!.x = 999;
    const undone = undo(history, b);
    expect(undone?.layout.components[0]?.x).toBe(0);
  });
});
