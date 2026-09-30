/**
 * View state coupling between the toolbar view switch and the mobile pane switcher.
 *
 * The table pane is only mounted while the view mode is "table". Narrow screens reveal panes
 * through the `data-pane` attribute and hide the others with CSS, so the pane and the mode
 * have to move together. Changing only the pane left the "Table" tab pointing at a section
 * that was never rendered, which produced an empty pane on phones.
 *
 * Pure logic so it can be unit tested without a DOM.
 */

export type PaneKey = "components" | "canvas" | "inspector" | "table";
export type ViewMode = "canvas" | "table";

export interface ViewState {
  pane: PaneKey;
  mode: ViewMode;
}

/** Picking a pane on a narrow screen also enters/leaves table view. */
export function viewFromPane(pane: PaneKey): ViewState {
  return { pane, mode: pane === "table" ? "table" : "canvas" };
}

/** Switching the view from the toolbar also moves the narrow-screen pane. */
export function viewFromMode(mode: ViewMode): ViewState {
  return { pane: mode === "table" ? "table" : "canvas", mode };
}
