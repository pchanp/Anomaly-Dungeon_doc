/** Selection and filtering rules. Single selection is enough for the prototype. */

import type { UiComponent } from "../model/layout";

export type SelectionId = string | null;

export function select(selection: SelectionId, id: string): SelectionId {
  return selection === id ? selection : id;
}

export function clearSelection(): SelectionId {
  return null;
}

export function nextSelection(
  selection: SelectionId,
  components: UiComponent[],
  direction: 1 | -1,
): SelectionId {
  if (components.length === 0) return null;
  if (!selection) return direction === 1 ? (components[0]?.id ?? null) : (components[components.length - 1]?.id ?? null);
  const index = components.findIndex((component) => component.id === selection);
  if (index < 0) return components[0]?.id ?? null;
  const next = (index + direction + components.length) % components.length;
  return components[next]?.id ?? null;
}

export interface FilterState {
  search: string;
  type: string;
  zMin: string;
  zMax: string;
}

/** Search covers id and type (spec section 20). The type dropdown and z range narrow further. */
export function filterComponents(components: UiComponent[], filter: FilterState): UiComponent[] {
  const needle = filter.search.trim().toLowerCase();
  const zMin = filter.zMin.trim() === "" ? null : Number(filter.zMin);
  const zMax = filter.zMax.trim() === "" ? null : Number(filter.zMax);

  return components.filter((component) => {
    if (needle.length > 0) {
      const haystack = `${component.id} ${component.type}`.toLowerCase();
      if (!haystack.includes(needle)) return false;
    }
    if (filter.type !== "*" && component.type !== filter.type) return false;
    if (zMin !== null && Number.isFinite(zMin) && component.z < zMin) return false;
    if (zMax !== null && Number.isFinite(zMax) && component.z > zMax) return false;
    return true;
  });
}

export type SortKey = "id" | "type" | "x" | "y" | "z";

export interface SortState {
  key: SortKey;
  direction: 1 | -1;
}

export function sortComponents(components: UiComponent[], sort: SortState): UiComponent[] {
  const factor = sort.direction;
  return [...components].sort((a, b) => {
    if (sort.key === "id") return a.id.localeCompare(b.id) * factor;
    if (sort.key === "type") return a.type.localeCompare(b.type) * factor || a.id.localeCompare(b.id);
    return (a[sort.key] - b[sort.key]) * factor || a.id.localeCompare(b.id);
  });
}

/** A short single-line summary of a texture value, for tables and lists. */
export function describeTexture(texture: UiComponent["texture"]): string {
  if (!texture) return "";
  if (typeof texture === "string") return texture;
  const entries = Object.entries(texture);
  if (entries.length === 0) return "";
  return entries
    .map(([state, path]) => `${state}: ${path}`)
    .join(", ");
}
