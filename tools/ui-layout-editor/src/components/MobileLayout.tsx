/**
 * Mobile layout: a pane switcher for narrow screens.
 *
 * The spec forbids removing features on phones, so instead of hiding anything the three
 * columns and the table become tabs (spec section 27). On wide screens the same markup is
 * shown but the tab bar is hidden by CSS and every pane is visible.
 */

export type PaneKey = "components" | "canvas" | "inspector" | "table";

export interface MobileLayoutProps {
  pane: PaneKey;
  onPane: (pane: PaneKey) => void;
  counts: { components: number };
}

const TABS: { key: PaneKey; label: string }[] = [
  { key: "components", label: "Components" },
  { key: "canvas", label: "Canvas" },
  { key: "inspector", label: "Inspector" },
  { key: "table", label: "Table" },
];

export function MobileLayout({ pane, onPane, counts }: MobileLayoutProps): React.JSX.Element {
  return (
    <nav className="pane-tabs" aria-label="ペイン切り替え">
      {TABS.map((tab) => (
        <button
          key={tab.key}
          type="button"
          className={`pane-tabs__btn${pane === tab.key ? " pane-tabs__btn--active" : ""}`}
          aria-current={pane === tab.key}
          onClick={() => onPane(tab.key)}
        >
          {tab.label}
          {tab.key === "components" && counts.components > 0 ? ` (${counts.components})` : ""}
        </button>
      ))}
    </nav>
  );
}
