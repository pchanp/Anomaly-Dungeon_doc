/**
 * Table mode: the same layout as rows.
 *
 * Cells for id / type / x / y / z / width / height / texture are editable in place
 * (spec section 19). Filtering covers id+type, type and a z range (section 20); sorting
 * covers id / type / x / y / z (section 21). Properties stay in the Inspector, as the
 * spec allows.
 */

import { useMemo, useState } from "react";
import { KNOWN_TYPES, isKnownType } from "../model/component";
import type { UiComponent } from "../model/layout";
import { describeTexture, filterComponents, sortComponents, type FilterState, type SortKey, type SortState } from "../editor/selection";
import { NumberField, TextField } from "./Fields";

export interface ComponentTableProps {
  components: UiComponent[];
  selection: string | null;
  onSelect: (id: string) => void;
  onPatch: (id: string, patch: Partial<UiComponent>, label: string) => void;
  onRename: (id: string, nextId: string) => void;
}

const DEFAULT_FILTER: FilterState = { search: "", type: "*", zMin: "", zMax: "" };
const SORTABLE: SortKey[] = ["id", "type", "x", "y", "z"];

export function ComponentTable({
  components,
  selection,
  onSelect,
  onPatch,
  onRename,
}: ComponentTableProps): React.JSX.Element {
  const [filter, setFilter] = useState<FilterState>(DEFAULT_FILTER);
  const [sort, setSort] = useState<SortState>({ key: "z", direction: 1 });

  const types = useMemo(() => {
    const set = new Set(components.map((component) => component.type));
    for (const known of KNOWN_TYPES) set.add(known);
    return [...set].sort();
  }, [components]);

  const rows = useMemo(
    () => sortComponents(filterComponents(components, filter), sort),
    [components, filter, sort],
  );

  const toggleSort = (key: SortKey): void => {
    setSort((previous) =>
      previous.key === key ? { key, direction: previous.direction === 1 ? -1 : 1 } : { key, direction: 1 },
    );
  };

  return (
    <>
      <div className="table-filter">
        <input
          className="field field--search"
          type="search"
          aria-label="検索"
          placeholder="Search id / type"
          value={filter.search}
          onChange={(event) => setFilter((previous) => ({ ...previous, search: event.target.value }))}
        />
        <div className="table-filter__group">
          <span className="table-filter__label">Type</span>
          <select
            className="field"
            aria-label="Typeフィルタ"
            value={filter.type}
            onChange={(event) => setFilter((previous) => ({ ...previous, type: event.target.value }))}
            style={{ width: 120 }}
          >
            <option value="*">All</option>
            {types.map((type) => (
              <option key={type} value={type}>
                {type}
              </option>
            ))}
          </select>
        </div>
        <div className="table-filter__group">
          <span className="table-filter__label">Z</span>
          <input
            className="field field--tiny field--num"
            type="number"
            aria-label="Z最小"
            placeholder="min"
            value={filter.zMin}
            onChange={(event) => setFilter((previous) => ({ ...previous, zMin: event.target.value }))}
          />
          <span className="table-filter__label">-</span>
          <input
            className="field field--tiny field--num"
            type="number"
            aria-label="Z最大"
            placeholder="max"
            value={filter.zMax}
            onChange={(event) => setFilter((previous) => ({ ...previous, zMax: event.target.value }))}
          />
        </div>
        <span className="table-filter__label">
          {rows.length} / {components.length}
        </span>
      </div>

      <div className="table-wrap">
        <table className="data-table">
          <thead>
            <tr>
              {SORTABLE.map((key) => (
                <th key={key} scope="col">
                  <button type="button" onClick={() => toggleSort(key)}>
                    {key.toUpperCase()}
                    {sort.key === key ? (sort.direction === 1 ? " ▲" : " ▼") : ""}
                  </button>
                </th>
              ))}
              <th scope="col">W</th>
              <th scope="col">H</th>
              <th scope="col">Texture</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((component) => (
              <tr
                key={component.id}
                data-selected={component.id === selection}
                onClick={() => onSelect(component.id)}
              >
                <td>
                  <TextField
                    value={component.id}
                    label="ID"
                    monospace
                    onCommit={(value) => onRename(component.id, value)}
                  />
                </td>
                <td>
                  <select
                    className="field"
                    aria-label="Type"
                    value={isKnownType(component.type) ? component.type : "__custom__"}
                    onClick={(event) => event.stopPropagation()}
                    onChange={(event) => {
                      if (event.target.value === "__custom__") return;
                      onPatch(component.id, { type: event.target.value }, "Type変更");
                    }}
                  >
                    {KNOWN_TYPES.map((type) => (
                      <option key={type} value={type}>
                        {type}
                      </option>
                    ))}
                    <option value="__custom__">{component.type}</option>
                  </select>
                </td>
                {(["x", "y", "z", "width", "height"] as const).map((key) => (
                  <td key={key}>
                    <NumberField
                      value={component[key]}
                      label={key}
                      min={key === "width" || key === "height" ? 4 : undefined}
                      onCommit={(value) => onPatch(component.id, { [key]: value }, `${key}変更`)}
                    />
                  </td>
                ))}
                <td style={{ maxWidth: 260, overflow: "hidden", textOverflow: "ellipsis" }}>
                  <span className="prop-row__key" title={describeTexture(component.texture)}>
                    {describeTexture(component.texture) || "—"}
                  </span>
                </td>
              </tr>
            ))}
            {rows.length === 0 ? (
              <tr>
                <td colSpan={9}>
                  <div className="empty-note">フィルタに一致する行がありません。</div>
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </>
  );
}
