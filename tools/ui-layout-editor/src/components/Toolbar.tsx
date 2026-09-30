/**
 * Toolbar: file I/O, add / duplicate / delete, undo / redo, grid, snap, zoom, view mode.
 * Kept as one flat strip of groups so it stays readable at any width.
 */

import { GRID_SIZES, type GridSize } from "../editor/snap";

export const ZOOM_PRESETS = [0.25, 0.5, 0.75, 1, 1.5, 2] as const;

export type ViewMode = "canvas" | "table";
export type Theme = "dark" | "light";

export interface ToolbarProps {
  fileName: string;
  canUndo: boolean;
  canRedo: boolean;
  hasSelection: boolean;
  gridOn: boolean;
  gridSize: GridSize;
  snapOn: boolean;
  zoom: number;
  mode: ViewMode;
  theme: Theme;
  onOpen: () => void;
  onSave: () => void;
  onAdd: () => void;
  onDuplicate: () => void;
  onDelete: () => void;
  onUndo: () => void;
  onRedo: () => void;
  onToggleGrid: () => void;
  onGridSize: (size: GridSize) => void;
  onToggleSnap: () => void;
  onZoom: (zoom: number) => void;
  onFit: () => void;
  onMode: (mode: ViewMode) => void;
  onTheme: (theme: Theme) => void;
}

export function Toolbar(props: ToolbarProps): React.JSX.Element {
  const {
    fileName,
    canUndo,
    canRedo,
    hasSelection,
    gridOn,
    gridSize,
    snapOn,
    zoom,
    mode,
    theme,
    onOpen,
    onSave,
    onAdd,
    onDuplicate,
    onDelete,
    onUndo,
    onRedo,
    onToggleGrid,
    onGridSize,
    onToggleSnap,
    onZoom,
    onFit,
    onMode,
    onTheme,
  } = props;

  return (
    <div className="toolbar">
      <div className="toolbar__group">
        <button type="button" className="btn" onClick={onOpen}>
          Open
        </button>
        <button type="button" className="btn" onClick={onSave}>
          Save
        </button>
      </div>

      <div className="toolbar__group">
        <button type="button" className="btn" onClick={onAdd}>
          + Add
        </button>
        <button type="button" className="btn" onClick={onDuplicate} disabled={!hasSelection}>
          Duplicate
        </button>
        <button type="button" className="btn btn--danger" onClick={onDelete} disabled={!hasSelection}>
          Delete
        </button>
      </div>

      <div className="toolbar__group">
        <button type="button" className="btn" onClick={onUndo} disabled={!canUndo} title="Ctrl/Cmd + Z">
          Undo
        </button>
        <button
          type="button"
          className="btn"
          onClick={onRedo}
          disabled={!canRedo}
          title="Ctrl/Cmd + Shift + Z"
        >
          Redo
        </button>
      </div>

      <div className="toolbar__group">
        <span className="toolbar__label">Grid</span>
        <button
          type="button"
          className={`btn${gridOn ? " btn--active" : ""}`}
          onClick={onToggleGrid}
          aria-pressed={gridOn}
        >
          {gridOn ? "ON" : "OFF"}
        </button>
        <select
          className="field"
          aria-label="Grid Size"
          value={String(gridSize)}
          onChange={(event) => onGridSize(Number(event.target.value) as GridSize)}
          style={{ width: 62 }}
          disabled={!gridOn}
        >
          {GRID_SIZES.map((size) => (
            <option key={size} value={size}>
              {size}
            </option>
          ))}
        </select>
        <span className="toolbar__label">Snap</span>
        <button
          type="button"
          className={`btn${snapOn ? " btn--active" : ""}`}
          onClick={onToggleSnap}
          aria-pressed={snapOn}
        >
          {snapOn ? "ON" : "OFF"}
        </button>
      </div>

      <div className="toolbar__group">
        <span className="toolbar__label">Zoom</span>
        <select
          className="field"
          aria-label="Zoom"
          value={String(zoom)}
          onChange={(event) => onZoom(Number(event.target.value))}
          style={{ width: 76 }}
        >
          {ZOOM_PRESETS.map((preset) => (
            <option key={preset} value={preset}>
              {Math.round(preset * 100)}%
            </option>
          ))}
          {!ZOOM_PRESETS.includes(zoom as (typeof ZOOM_PRESETS)[number]) ? (
            <option value={zoom}>{Math.round(zoom * 100)}%</option>
          ) : null}
        </select>
        <button type="button" className="btn" onClick={onFit}>
          Fit
        </button>
      </div>

      <div className="toolbar__spacer" />

      <div className="toolbar__group">
        <button
          type="button"
          className={`btn${mode === "canvas" ? " btn--active" : ""}`}
          onClick={() => onMode("canvas")}
        >
          Canvas
        </button>
        <button
          type="button"
          className={`btn${mode === "table" ? " btn--active" : ""}`}
          onClick={() => onMode("table")}
        >
          Table
        </button>
      </div>

      <div className="toolbar__group">
        <button
          type="button"
          className="btn"
          onClick={() => onTheme(theme === "dark" ? "light" : "dark")}
          title="エディタの表示テーマを切り替え"
        >
          {theme === "dark" ? "Dark" : "Light"}
        </button>
      </div>

      <div className="toolbar__group">
        <span className="toolbar__label" title="読み込み中のファイル">
          {fileName}
        </span>
      </div>
    </div>
  );
}
