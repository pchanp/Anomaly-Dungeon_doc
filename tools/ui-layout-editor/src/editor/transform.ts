/**
 * Move / resize maths for the canvas.
 *
 * Everything here is in *layout* units (the virtual 1920x1080 space), never in screen
 * pixels. The canvas converts pointer deltas by dividing by zoom before calling in, so
 * changing the browser zoom never changes what gets stored (spec section 6).
 */

import { MIN_COMPONENT_SIZE, type UiComponent } from "../model/layout";
import { snapValue } from "./snap";

export const HANDLE_IDS = ["nw", "n", "ne", "e", "se", "s", "sw", "w"] as const;
export type HandleId = (typeof HANDLE_IDS)[number];

export interface Rect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface MoveResult {
  x: number;
  y: number;
}

export interface ResizeOptions {
  gridSize: number;
  snap: boolean;
}

/** A drag on the component body. Deltas are already in layout units. */
export function moveComponent(
  component: UiComponent,
  deltaX: number,
  deltaY: number,
  options: { gridSize: number; snap: boolean },
): MoveResult {
  return {
    x: snapValue(component.x + deltaX, options.gridSize, options.snap),
    y: snapValue(component.y + deltaY, options.gridSize, options.snap),
  };
}

/**
 * Resize from one of the eight handles. Deltas are in layout units and are relative to the
 * pointer, so the component follows the finger.
 */
export function resizeComponent(
  component: UiComponent,
  handle: HandleId,
  deltaX: number,
  deltaY: number,
  options: ResizeOptions,
): Rect {
  const right = component.x + component.width;
  const bottom = component.y + component.height;

  let left = component.x;
  let top = component.y;
  let nextRight = right;
  let nextBottom = bottom;

  const movesLeft = handle === "nw" || handle === "w" || handle === "sw";
  const movesRight = handle === "ne" || handle === "e" || handle === "se";
  const movesTop = handle === "nw" || handle === "n" || handle === "ne";
  const movesBottom = handle === "sw" || handle === "s" || handle === "se";

  if (movesRight) nextRight = right + deltaX;
  if (movesLeft) left = component.x + deltaX;
  if (movesBottom) nextBottom = bottom + deltaY;
  if (movesTop) top = component.y + deltaY;

  if (nextRight - left < MIN_COMPONENT_SIZE) {
    if (movesLeft) left = nextRight - MIN_COMPONENT_SIZE;
    else nextRight = left + MIN_COMPONENT_SIZE;
  }
  if (nextBottom - top < MIN_COMPONENT_SIZE) {
    if (movesTop) top = nextBottom - MIN_COMPONENT_SIZE;
    else nextBottom = top + MIN_COMPONENT_SIZE;
  }

  if (options.snap) {
    if (movesRight) nextRight = snapValue(nextRight, options.gridSize, true);
    if (movesLeft) left = snapValue(left, options.gridSize, true);
    if (movesBottom) nextBottom = snapValue(nextBottom, options.gridSize, true);
    if (movesTop) top = snapValue(top, options.gridSize, true);
  }

  return {
    x: Math.round(left),
    y: Math.round(top),
    width: Math.max(MIN_COMPONENT_SIZE, Math.round(nextRight - left)),
    height: Math.max(MIN_COMPONENT_SIZE, Math.round(nextBottom - top)),
  };
}

/**
 * Painter's order: larger z in front. Equal z keeps document order as a stable
 * second-order key, which the spec leaves undefined but which keeps the canvas
 * predictable while editing.
 */
export function sortForPaint(components: UiComponent[]): UiComponent[] {
  return components
    .map((component, index) => ({ component, index }))
    .sort((a, b) => a.component.z - b.component.z || a.index - b.index)
    .map((entry) => entry.component);
}
