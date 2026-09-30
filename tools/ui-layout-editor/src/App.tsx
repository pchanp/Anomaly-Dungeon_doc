/**
 * Application shell and the single owner of layout state.
 *
 * All three editing entry points (canvas drag, inspector, table) call the same
 * `patchComponent`, so they cannot drift apart (spec section 33). Continuous gestures use
 * a preview path that mutates without touching history, then commit once on release, so
 * one drag equals one undo step.
 */

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { Canvas } from "./components/Canvas";
import { ComponentList } from "./components/ComponentList";
import { ComponentTable } from "./components/ComponentTable";
import { Inspector } from "./components/Inspector";
import { MobileLayout, type PaneKey } from "./components/MobileLayout";
import { RotateNotice } from "./components/RotateNotice";
import { Toolbar, type Theme, type ViewMode } from "./components/Toolbar";
import { createHistory, pushHistory, redo as redoHistory, undo as undoHistory, type HistoryState } from "./editor/history";
import { snapValue, type GridSize } from "./editor/snap";
import { resizeComponent, type HandleId } from "./editor/transform";
import { viewFromMode, viewFromPane } from "./editor/view";
import { KNOWN_TYPES, defaultSizeFor } from "./model/component";
import {
  cloneLayout,
  createComponent,
  findComponent,
  sanitizeId,
  uniqueId,
  type UiComponent,
  type UiLayout,
} from "./model/layout";
import { SAMPLE_FILE_NAME, SAMPLE_YAML } from "./model/sample";
import { downloadText, pickYamlFile } from "./io/file";
import { parseLayoutYaml, serializeLayoutYaml } from "./io/yaml";

interface Messages {
  errors: string[];
  warnings: string[];
}

/** Zoom and pan move together, so they are one piece of state. */
interface Viewport {
  zoom: number;
  pan: { x: number; y: number };
}

export function App(): React.JSX.Element {
  const initial = useMemo(() => {
    const parsed = parseLayoutYaml(SAMPLE_YAML);
    return { layout: parsed.layout, messages: { errors: parsed.errors, warnings: parsed.warnings } };
  }, []);

  const [layout, setLayout] = useState<UiLayout>(initial.layout);
  const [messages, setMessages] = useState<Messages>(initial.messages);
  const [fileName, setFileName] = useState(SAMPLE_FILE_NAME);

  const [history, setHistory] = useState(createHistory());
  const [selection, setSelection] = useState<string | null>(null);
  const [gridOn, setGridOn] = useState(true);
  const [gridSize, setGridSize] = useState<GridSize>(8);
  const [snapOn, setSnapOn] = useState(true);
  const [viewport, setViewport] = useState<Viewport>({ zoom: 0.5, pan: { x: 0, y: 0 } });

  const [mode, setMode] = useState<ViewMode>("canvas");
  const [pane, setPane] = useState<PaneKey>("canvas");
  const [theme, setTheme] = useState<Theme>("dark");

  const { zoom, pan } = viewport;

  /*
   * Layout mutations go through `applyLayout` rather than a `setLayout` updater that calls
   * `setHistory` inside it. Nesting one state setter inside another's updater is not safe:
   * React may invoke an updater more than once, which would push duplicate history entries.
   * The ref keeps the previous layout readable synchronously and stays in step with state.
   */
  const layoutRef = useRef<UiLayout>(initial.layout);
  /** Mirrors `history` so undo/redo can read it without waiting for a render. */
  const historyRef = useRef<HistoryState>(createHistory());
  /** Snapshot taken when a gesture starts, so the commit can push the pre-gesture state. */
  const gestureStartRef = useRef<UiLayout | null>(null);

  const applyLayout = useCallback((next: UiLayout, label: string | null) => {
    const previous = layoutRef.current;
    layoutRef.current = next;
    setLayout(next);
    if (label !== null) {
      setHistory((h) => {
        const updated = pushHistory(h, previous, label);
        historyRef.current = updated;
        return updated;
      });
    }
  }, []);

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
  }, [theme]);

  /** Commits a labelled change: pushes the previous layout onto the undo stack. */
  const patchComponent = useCallback(
    (id: string, patch: Partial<UiComponent>, label: string) => {
      const next = cloneLayout(layoutRef.current);
      const index = next.components.findIndex((component) => component.id === id);
      if (index < 0) return;
      const current = next.components[index];
      if (!current) return;
      next.components[index] = { ...current, ...patch };
      applyLayout(next, label);
    },
    [applyLayout],
  );

  /** Undo-free mutation used while a pointer gesture is still running. */
  const previewComponent = useCallback((id: string, patch: Partial<UiComponent>) => {
    const next = cloneLayout(layoutRef.current);
    const index = next.components.findIndex((component) => component.id === id);
    if (index < 0) return;
    const current = next.components[index];
    if (!current) return;
    next.components[index] = { ...current, ...patch };
    applyLayout(next, null);
  }, [applyLayout]);

  const renameComponent = useCallback(
    (id: string, nextId: string) => {
      const cleaned = sanitizeId(nextId);
      const current = layoutRef.current;
      const next = cloneLayout(current);
      const index = next.components.findIndex((component) => component.id === id);
      if (index < 0) return;
      if (next.components.some((component, i) => i !== index && component.id === cleaned)) {
        window.alert(`"${cleaned}" は既に使われています。`);
        return;
      }
      const target = next.components[index];
      if (!target) return;
      next.components[index] = { ...target, id: cleaned };
      applyLayout(next, "ID変更");
      setSelection((selected) => (selected === id ? cleaned : selected));
    },
    [applyLayout],
  );

  const addComponent = useCallback(() => {
    const type = KNOWN_TYPES.includes("panel") ? "panel" : (KNOWN_TYPES[0] ?? "panel");
    const size = defaultSizeFor(type);
    const next = cloneLayout(layoutRef.current);
    const id = uniqueId(
      "new_component",
      next.components.map((component) => component.id),
    );
    next.components.push(
      createComponent({
        id,
        type,
        // Drop new components near the middle of the screen so they are visible.
        x: snapValue(Math.round((next.screen.width - size.width) / 2), gridSize, snapOn),
        y: snapValue(Math.round((next.screen.height - size.height) / 2), gridSize, snapOn),
        z: 50,
        width: size.width,
        height: size.height,
      }),
    );
    applyLayout(next, "Add Component");
    setSelection(id);
    setMode("canvas");
    setPane("canvas");
  }, [applyLayout, gridSize, snapOn]);

  const deleteComponent = useCallback(
    (id: string) => {
      const next = cloneLayout(layoutRef.current);
      next.components = next.components.filter((component) => component.id !== id);
      applyLayout(next, "Delete Component");
      setSelection((selected) => (selected === id ? null : selected));
    },
    [applyLayout],
  );

  const duplicateComponent = useCallback(
    (id: string) => {
      const current = layoutRef.current;
      const source = findComponent(current, id);
      if (!source) return;
      const next = cloneLayout(current);
      const copyId = uniqueId(
        `${source.id}_copy`,
        next.components.map((component) => component.id),
      );
      const copy = createComponent({
        ...source,
        id: copyId,
        // Offset so the copy is visibly distinct from its source.
        x: snapValue(source.x + gridSize * 2, gridSize, snapOn),
        y: snapValue(source.y + gridSize * 2, gridSize, snapOn),
        properties: { ...source.properties },
        extra: { ...source.extra },
      });
      const index = next.components.findIndex((component) => component.id === id);
      next.components.splice(index + 1, 0, copy);
      applyLayout(next, "Duplicate");
      setSelection(copyId);
    },
    [applyLayout, gridSize, snapOn],
  );

  const doUndo = useCallback(() => {
    const result = undoHistory(historyRef.current, layoutRef.current);
    if (!result) return;
    historyRef.current = result.history;
    setHistory(result.history);
    applyLayout(result.layout, null);
  }, [applyLayout]);

  const doRedo = useCallback(() => {
    const result = redoHistory(historyRef.current, layoutRef.current);
    if (!result) return;
    historyRef.current = result.history;
    setHistory(result.history);
    applyLayout(result.layout, null);
  }, [applyLayout]);

  const handleOpen = useCallback(async () => {
    const file = await pickYamlFile();
    if (!file) return;
    const parsed = parseLayoutYaml(file.text);
    layoutRef.current = parsed.layout;
    historyRef.current = createHistory();
    setLayout(parsed.layout);
    setHistory(createHistory());
    setSelection(null);
    setMessages({ errors: parsed.errors, warnings: parsed.warnings });
    setFileName(file.name);
    setViewport({ zoom: 0.5, pan: { x: 0, y: 0 } });
  }, []);

  const handleSave = useCallback(() => {
    downloadText(
      fileName.endsWith(".yaml") || fileName.endsWith(".yml") ? fileName : `${fileName}.yaml`,
      serializeLayoutYaml(layoutRef.current),
    );
  }, [fileName]);

  const handleFit = useCallback(() => {
    // Approximate the viewport: the canvas pane is what is left after the side panes.
    if (typeof window === "undefined") return;
    const narrow = window.innerWidth <= 900;
    const width = narrow ? window.innerWidth : window.innerWidth - 210 - 260 - 2;
    const height = window.innerHeight - 190;
    const next = Math.min(width / layoutRef.current.screen.width, height / layoutRef.current.screen.height, 1);
    setViewport({
      zoom: next,
      pan: { x: (width - layoutRef.current.screen.width * next) / 2, y: (height - layoutRef.current.screen.height * next) / 2 },
    });
  }, []);

  /**
   * The table pane is only mounted while the view mode is "table", so the mobile pane
   * switcher and the toolbar's view switch have to move both. Setting only the pane left
   * the "Table" tab pointing at a section that was never rendered, i.e. an empty pane.
   */
  const handlePane = useCallback((pane: PaneKey) => {
    const resolved = viewFromPane(pane);
    setPane(resolved.pane);
    setMode(resolved.mode);
  }, []);

  const handleMode = useCallback((mode: ViewMode) => {
    const resolved = viewFromMode(mode);
    setPane(resolved.pane);
    setMode(resolved.mode);
  }, []);

  /** Zooms while keeping the layout point under (viewportX, viewportY) pinned in place. */
  const handleZoomAtViewportPoint = useCallback((nextZoom: number, viewportX: number, viewportY: number) => {
    setViewport((current) => {
      const clamped = Math.min(4, Math.max(0.1, nextZoom));
      return {
        zoom: clamped,
        pan: {
          x: viewportX - ((viewportX - current.pan.x) / current.zoom) * clamped,
          y: viewportY - ((viewportY - current.pan.y) / current.zoom) * clamped,
        },
      };
    });
  }, []);

  /** Records the pre-gesture snapshot on the undo stack, once per gesture. */
  const commitGesture = useCallback((label: string) => {
    const before = gestureStartRef.current;
    gestureStartRef.current = null;
    if (!before) return;
    setHistory((h) => {
      const updated = pushHistory(h, before, label);
      historyRef.current = updated;
      return updated;
    });
  }, []);

  const onMovePreview = useCallback(
    (id: string, x: number, y: number) => {
      if (!gestureStartRef.current) gestureStartRef.current = cloneLayout(layoutRef.current);
      previewComponent(id, {
        x: snapValue(Math.round(x), gridSize, snapOn),
        y: snapValue(Math.round(y), gridSize, snapOn),
      });
    },
    [gridSize, previewComponent, snapOn],
  );

  const onResizePreview = useCallback(
    (id: string, handle: HandleId, deltaX: number, deltaY: number) => {
      if (!gestureStartRef.current) gestureStartRef.current = cloneLayout(layoutRef.current);
      const current = findComponent(layoutRef.current, id);
      if (!current) return;
      const rect = resizeComponent(current, handle, deltaX, deltaY, { gridSize, snap: snapOn });
      const next = cloneLayout(layoutRef.current);
      next.components = next.components.map((component) =>
        component.id === id ? { ...component, ...rect } : component,
      );
      applyLayout(next, null);
    },
    [applyLayout, gridSize, snapOn],
  );

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent): void => {
      const meta = event.metaKey || event.ctrlKey;
      if (!meta) return;
      const key = event.key.toLowerCase();
      if (key === "z") {
        event.preventDefault();
        if (event.shiftKey) doRedo();
        else doUndo();
        return;
      }
      if (key === "y") {
        event.preventDefault();
        doRedo();
        return;
      }
      if (key === "s") {
        event.preventDefault();
        handleSave();
      }
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [doRedo, doUndo, handleSave]);

  const selected = findComponent(layout, selection);
  const bodyClass = `app__body${mode === "table" ? " app__body--table" : ""}`;

  return (
    <div className="app">
      <RotateNotice />
      <Toolbar
        fileName={fileName}
        canUndo={history.past.length > 0}
        canRedo={history.future.length > 0}
        hasSelection={selected !== undefined}
        gridOn={gridOn}
        gridSize={gridSize}
        snapOn={snapOn}
        zoom={zoom}
        mode={mode}
        theme={theme}
        onOpen={() => void handleOpen()}
        onSave={handleSave}
        onAdd={addComponent}
        onDuplicate={() => {
          if (selection) duplicateComponent(selection);
        }}
        onDelete={() => {
          if (selection && window.confirm(`"${selection}" を削除しますか？`)) deleteComponent(selection);
        }}
        onUndo={doUndo}
        onRedo={doRedo}
        onToggleGrid={() => setGridOn((value) => !value)}
        onGridSize={setGridSize}
        onToggleSnap={() => setSnapOn((value) => !value)}
        onZoom={(value) => setViewport((current) => ({ ...current, zoom: value }))}
        onFit={handleFit}
        onMode={handleMode}
        onTheme={setTheme}
      />

      <MobileLayout pane={pane} onPane={handlePane} counts={{ components: layout.components.length }} />

      {messages.errors.length > 0 || messages.warnings.length > 0 ? (
        <div className="notice-bar">
          {messages.errors.length > 0 ? (
            <div className="notice-bar__group notice-bar--error">
              <div className="notice-bar__title">読み込みエラー（{messages.errors.length}）</div>
              <ul className="notice-bar__list">
                {messages.errors.map((message) => (
                  <li key={message}>{message}</li>
                ))}
              </ul>
            </div>
          ) : null}
          {messages.warnings.length > 0 ? (
            <div className="notice-bar__group notice-bar--warn">
              <div className="notice-bar__title">警告（{messages.warnings.length}）</div>
              <ul className="notice-bar__list">
                {messages.warnings.map((message) => (
                  <li key={message}>{message}</li>
                ))}
              </ul>
            </div>
          ) : null}
        </div>
      ) : null}

      <div className={bodyClass} data-pane={pane}>
        <section className="pane pane--side">
          <ComponentList components={layout.components} selection={selection} onSelect={setSelection} />
        </section>

        <section className="pane pane--canvas">
          <div className="pane__head">
            <span>Canvas</span>
            <span>{Math.round(zoom * 100)}%</span>
          </div>
          <div className="pane__body pane__body--flush">
            <Canvas
              screen={layout.screen}
              components={layout.components}
              selection={selection}
              zoom={zoom}
              pan={pan}
              gridOn={gridOn}
              gridSize={gridSize}
              onSelect={setSelection}
              onMovePreview={onMovePreview}
              onMoveCommit={commitGesture}
              onResizePreview={onResizePreview}
              onResizeCommit={commitGesture}
              onPan={(value) => setViewport((current) => ({ ...current, pan: value }))}
              onZoomAtViewportPoint={handleZoomAtViewportPoint}
            />
          </div>
        </section>

        <section className="pane pane--inspector">
          <div className="pane__head">
            <span>Inspector</span>
          </div>
          <div className="pane__body">
            <Inspector
              component={selected}
              onPatch={patchComponent}
              onRename={renameComponent}
              onDelete={deleteComponent}
              onDuplicate={duplicateComponent}
            />
          </div>
        </section>

        {mode === "table" ? (
          <section className="pane pane--table">
            <div className="pane__head">
              <span>Table</span>
            </div>
            <ComponentTable
              components={layout.components}
              selection={selection}
              onSelect={setSelection}
              onPatch={patchComponent}
              onRename={renameComponent}
            />
          </section>
        ) : null}
      </div>

      <div className="status-strip">
        <span>
          <span className="status-strip__key">screen</span> {layout.screen.width}×{layout.screen.height}
        </span>
        <span>
          <span className="status-strip__key">components</span> {layout.components.length}
        </span>
        <span>
          <span className="status-strip__key">selected</span> {selection ?? "—"}
        </span>
        <span>
          <span className="status-strip__key">snap</span> {snapOn ? `${gridSize}px` : "off"}
        </span>
        <span>
          <span className="status-strip__key">history</span> {history.past.length}/{history.future.length}
        </span>
        <span>
          <span className="status-strip__key">version</span> {layout.version}
        </span>
      </div>
    </div>
  );
}
