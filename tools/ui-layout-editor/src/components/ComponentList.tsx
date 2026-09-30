/**
 * Component list: a searchable index of the layout. Selecting here selects on the canvas,
 * and vice versa (spec section 18).
 */

import { useMemo, useState } from "react";
import { getTypeInfo } from "../model/component";
import type { UiComponent } from "../model/layout";

export interface ComponentListProps {
  components: UiComponent[];
  selection: string | null;
  onSelect: (id: string) => void;
}

export function ComponentList({ components, selection, onSelect }: ComponentListProps): React.JSX.Element {
  const [search, setSearch] = useState("");

  const visible = useMemo(() => {
    const needle = search.trim().toLowerCase();
    if (needle === "") return components;
    return components.filter((component) =>
      `${component.id} ${component.type}`.toLowerCase().includes(needle),
    );
  }, [components, search]);

  return (
    <>
      <div className="pane__head">
        <span>Components ({visible.length}/{components.length})</span>
      </div>
      <div style={{ padding: 6, borderBottom: "1px solid var(--border)", flex: "0 0 auto" }}>
        <input
          className="field"
          type="search"
          aria-label="コンポーネント検索"
          placeholder="id / type で検索"
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
      </div>
      <div className="pane__body">
        {visible.length === 0 ? (
          <div className="empty-note">
            {components.length === 0 ? "コンポーネントがありません。" : "一致するコンポーネントがありません。"}
          </div>
        ) : (
          <ul className="component-list">
            {visible.map((component) => {
              const info = getTypeInfo(component.type);
              return (
                <li key={component.id}>
                  <button
                    type="button"
                    className={`component-list__item${
                      component.id === selection ? " component-list__item--selected" : ""
                    }`}
                    onClick={() => onSelect(component.id)}
                  >
                    <span className={`badge${info.known ? "" : " badge--unknown"}`}>{component.type}</span>
                    <span className="component-list__id" title={component.id}>
                      {component.id}
                    </span>
                    <span className="component-list__meta">
                      {component.x},{component.y} z{component.z}
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </>
  );
}
