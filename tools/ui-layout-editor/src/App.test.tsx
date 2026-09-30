/**
 * Render smoke test.
 *
 * The prototype is meant to be used by dragging a mouse, which unit tests cannot do. This
 * renders the whole component tree with the shipped sample data so that a render-time
 * crash (undefined access, bad hook usage) fails here rather than in the browser.
 *
 * Server rendering also enforces the "no setState during render" and "no missing
 * getServerSnapshot" rules that `useSyncExternalStore` requires.
 */

import { describe, expect, it } from "vitest";
import { renderToStaticMarkup } from "react-dom/server";
import { createElement } from "react";
import { App } from "./App";

describe("App render", () => {
  it("renders the sample layout without throwing", () => {
    const markup = renderToStaticMarkup(createElement(App));
    expect(markup.length).toBeGreaterThan(0);
  });

  it("shows every sample component id", () => {
    const markup = renderToStaticMarkup(createElement(App));
    for (const id of [
      "anomaly_status",
      "exposure",
      "minimap",
      "radio",
      "inventory_panel",
      "slot_01",
      "slot_02",
      "slot_03",
      "slot_04",
    ]) {
      expect(markup).toContain(id);
    }
  });

  it("reports the screen resolution in the canvas label", () => {
    const markup = renderToStaticMarkup(createElement(App));
    expect(markup).toContain("1920");
    expect(markup).toContain("1080");
  });

  it("includes the rotate guard for portrait phones", () => {
    const markup = renderToStaticMarkup(createElement(App));
    expect(markup).toContain("Please rotate your device.");
  });
});
