import { describe, expect, it } from "vitest";
import { viewFromMode, viewFromPane, type PaneKey, type ViewMode } from "./view";

const PANES: PaneKey[] = ["components", "canvas", "inspector", "table"];

describe("viewFromPane", () => {
  it("mounts table view for the table pane", () => {
    expect(viewFromPane("table")).toEqual({ pane: "table", mode: "table" });
  });

  it("leaves table view for every other pane", () => {
    for (const pane of PANES.filter((p) => p !== "table")) {
      expect(viewFromPane(pane)).toEqual({ pane, mode: "canvas" });
    }
  });

  it("always echoes the requested pane", () => {
    for (const pane of PANES) {
      expect(viewFromPane(pane).pane).toBe(pane);
    }
  });
});

describe("viewFromMode", () => {
  it("shows the table pane in table view", () => {
    expect(viewFromMode("table")).toEqual({ pane: "table", mode: "table" });
  });

  it("returns to the canvas pane in canvas view", () => {
    expect(viewFromMode("canvas")).toEqual({ pane: "canvas", mode: "canvas" });
  });
});

describe("pane and mode stay consistent", () => {
  it("never reports table mode while pointing at a non-table pane", () => {
    for (const pane of PANES) {
      const state = viewFromPane(pane);
      const tableMounted = state.mode === "table";
      expect(tableMounted).toBe(state.pane === "table");
    }
  });

  it("round-trips through the toolbar switch", () => {
    for (const mode of ["canvas", "table"] as ViewMode[]) {
      const fromMode = viewFromMode(mode);
      expect(viewFromPane(fromMode.pane)).toEqual(fromMode);
    }
  });
});
