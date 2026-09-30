/**
 * Undo / Redo.
 *
 * Snapshots rather than inverse operations: a layout is a few hundred small objects, and a
 * snapshot stack cannot drift out of sync with the edit that produced it. Continuous
 * gestures (a drag, a resize) commit once on release, so one gesture is one undo step.
 */

import { cloneLayout, type UiLayout } from "../model/layout";

export const HISTORY_LIMIT = 100;

export interface HistoryEntry {
  label: string;
  layout: UiLayout;
}

export interface HistoryState {
  past: HistoryEntry[];
  future: HistoryEntry[];
}

export function createHistory(): HistoryState {
  return { past: [], future: [] };
}

/** Records `previous` so the next undo can return to it. */
export function pushHistory(
  history: HistoryState,
  previous: UiLayout,
  label: string,
): HistoryState {
  const past = [...history.past, { label, layout: cloneLayout(previous) }];
  if (past.length > HISTORY_LIMIT) past.shift();
  // Any new edit invalidates the redo branch.
  return { past, future: [] };
}

export interface HistoryResult {
  layout: UiLayout;
  history: HistoryState;
  label: string | null;
}

/** Returns the previous snapshot, or null when there is nothing to undo. */
export function undo(history: HistoryState, current: UiLayout): HistoryResult | null {
  const entry = history.past[history.past.length - 1];
  if (!entry) return null;
  return {
    layout: cloneLayout(entry.layout),
    history: {
      past: history.past.slice(0, -1),
      future: [{ label: entry.label, layout: cloneLayout(current) }, ...history.future],
    },
    label: entry.label,
  };
}

export function redo(history: HistoryState, current: UiLayout): HistoryResult | null {
  const entry = history.future[0];
  if (!entry) return null;
  return {
    layout: cloneLayout(entry.layout),
    history: {
      past: [...history.past, { label: entry.label, layout: cloneLayout(current) }],
      future: history.future.slice(1),
    },
    label: entry.label,
  };
}
