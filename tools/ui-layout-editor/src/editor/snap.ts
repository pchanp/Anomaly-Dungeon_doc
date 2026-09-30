/** Snap to the grid. Pure so the rule can be unit tested (spec section 11). */

export function snapValue(value: number, gridSize: number, enabled: boolean): number {
  if (!enabled || gridSize <= 0) return value;
  return Math.round(value / gridSize) * gridSize;
}

export interface SnapRect {
  x: number;
  y: number;
}

export function snapPosition(x: number, y: number, gridSize: number, enabled: boolean): SnapRect {
  return { x: snapValue(x, gridSize, enabled), y: snapValue(y, gridSize, enabled) };
}

export const GRID_SIZES = [8, 16, 32] as const;
export type GridSize = (typeof GRID_SIZES)[number];
