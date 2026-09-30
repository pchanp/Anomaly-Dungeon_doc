/**
 * Canvas view: renders the Layout Definition at the screen's virtual resolution.
 *
 * Interaction rules (spec sections 10, 13, 14, 28):
 *  - one pointer on a component body -> drag
 *  - one pointer on a handle -> resize
 *  - one pointer on empty canvas -> pan
 *  - two pointers -> pinch zoom + pan around the pinch centre
 *  - wheel -> zoom around the cursor
 *  - middle button or Space+drag -> pan on desktop
 *
 * Pointer deltas are divided by `zoom` before they reach the model, so stored coordinates
 * stay in layout units regardless of browser zoom (spec section 6).
 */

import { useCallback, useRef, useSyncExternalStore } from "react";
import { getTypeInfo, resolveTexturePath } from "../model/component";
import type { PropMap, TextureValue, UiComponent, UiScreen } from "../model/layout";
import { HANDLE_IDS, sortForPaint, type HandleId } from "../editor/transform";

/** Selected nodes are lifted above every z so the selection is never buried. */
const SELECTED_Z_BASE = 2_000_000_000;

type Point = { x: number; y: number };

type Gesture =
  | { kind: "none" }
  | { kind: "drag"; pointerId: number; componentId: string; grabOffsetX: number; grabOffsetY: number; moved: boolean }
  | { kind: "resize"; pointerId: number; componentId: string; handle: HandleId; startClientX: number; startClientY: number; moved: boolean }
  | { kind: "pan"; pointerId: number; startClientX: number; startClientY: number; originX: number; originY: number }
  | {
      kind: "pinch";
      startDistance: number;
      startZoom: number;
      startCenterX: number;
      startCenterY: number;
      startLayoutX: number;
      startLayoutY: number;
    };

export interface CanvasProps {
  screen: UiScreen;
  components: UiComponent[];
  selection: string | null;
  zoom: number;
  pan: Point;
  gridOn: boolean;
  gridSize: number;
  onSelect: (id: string | null) => void;
  /** Absolute layout-space position preview during a drag. */
  onMovePreview: (id: string, x: number, y: number) => void;
  onMoveCommit: (label: string) => void;
  /** Delta in layout units plus the handle being dragged. */
  onResizePreview: (id: string, handle: HandleId, deltaX: number, deltaY: number) => void;
  onResizeCommit: (label: string) => void;
  onPan: (pan: Point) => void;
  onZoomAtViewportPoint: (nextZoom: number, viewportX: number, viewportY: number) => void;
}

const MIN_ZOOM = 0.1;
const MAX_ZOOM = 4;

function clampZoom(value: number): number {
  return Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, value));
}

/** Tracks `(pointer: coarse)` so touch devices get larger handles and hit areas. */
function useCoarsePointer(): boolean {
  const subscribe = useCallback((onChange: () => void) => {
    if (typeof window === "undefined" || !window.matchMedia) return () => {};
    const query = window.matchMedia("(pointer: coarse)");
    query.addEventListener("change", onChange);
    return () => query.removeEventListener("change", onChange);
  }, []);
  const getSnapshot = useCallback(() => {
    if (typeof window === "undefined" || !window.matchMedia) return false;
    return window.matchMedia("(pointer: coarse)").matches;
  }, []);
  return useSyncExternalStore(subscribe, getSnapshot, () => false);
}

export function Canvas(props: CanvasProps): React.JSX.Element {
  const {
    screen,
    components,
    selection,
    zoom,
    pan,
    gridOn,
    gridSize,
    onSelect,
    onMovePreview,
    onMoveCommit,
    onResizePreview,
    onResizeCommit,
    onPan,
    onZoomAtViewportPoint,
  } = props;

  const viewportRef = useRef<HTMLDivElement | null>(null);
  const gestureRef = useRef<Gesture>({ kind: "none" });
  const pointersRef = useRef(new Map<number, Point>());
  const spaceRef = useRef(false);
  const coarse = useCoarsePointer();

  /** Client point -> layout (1920x1080) point. */
  const toLayoutPoint = useCallback(
    (clientX: number, clientY: number): Point => {
      const rect = viewportRef.current?.getBoundingClientRect();
      if (!rect) return { x: 0, y: 0 };
      return { x: (clientX - rect.left - pan.x) / zoom, y: (clientY - rect.top - pan.y) / zoom };
    },
    [pan, zoom],
  );

  const startPinch = useCallback(() => {
    const points = [...pointersRef.current.values()];
    const a = points[0];
    const b = points[1];
    const rect = viewportRef.current?.getBoundingClientRect();
    if (!a || !b || !rect) return;
    const centerX = (a.x + b.x) / 2 - rect.left;
    const centerY = (a.y + b.y) / 2 - rect.top;
    gestureRef.current = {
      kind: "pinch",
      startDistance: Math.max(1, Math.hypot(a.x - b.x, a.y - b.y)),
      startZoom: zoom,
      startCenterX: centerX,
      startCenterY: centerY,
      startLayoutX: (centerX - pan.x) / zoom,
      startLayoutY: (centerY - pan.y) / zoom,
    };
  }, [pan, zoom]);

  const handlePointerDown = useCallback(
    (event: React.PointerEvent<HTMLDivElement>) => {
      const viewport = viewportRef.current;
      if (!viewport) return;
      pointersRef.current.set(event.pointerId, { x: event.clientX, y: event.clientY });

      if (pointersRef.current.size === 2) {
        startPinch();
        return;
      }
      if (pointersRef.current.size > 2) return;

      const target = event.target as HTMLElement;
      const handle = target.dataset["handle"] as HandleId | undefined;
      const node = target.closest("[data-component-id]") as HTMLElement | null;
      const componentId = node?.dataset["componentId"] ?? null;
      const panGesture = event.button === 1 || spaceRef.current || componentId === null;

      if (handle && componentId) {
        viewport.setPointerCapture(event.pointerId);
        onSelect(componentId);
        gestureRef.current = {
          kind: "resize",
          pointerId: event.pointerId,
          componentId,
          handle,
          startClientX: event.clientX,
          startClientY: event.clientY,
          moved: false,
        };
        return;
      }

      if (panGesture) {
        viewport.setPointerCapture(event.pointerId);
        if (componentId === null) onSelect(null);
        gestureRef.current = {
          kind: "pan",
          pointerId: event.pointerId,
          startClientX: event.clientX,
          startClientY: event.clientY,
          originX: pan.x,
          originY: pan.y,
        };
        return;
      }

      viewport.setPointerCapture(event.pointerId);
      onSelect(componentId);
      const point = toLayoutPoint(event.clientX, event.clientY);
      const component = components.find((item) => item.id === componentId);
      gestureRef.current = {
        kind: "drag",
        pointerId: event.pointerId,
        componentId: componentId ?? "",
        grabOffsetX: point.x - (component?.x ?? 0),
        grabOffsetY: point.y - (component?.y ?? 0),
        moved: false,
      };
    },
    [components, onSelect, pan, startPinch, toLayoutPoint],
  );

  const handlePointerMove = useCallback(
    (event: React.PointerEvent<HTMLDivElement>) => {
      if (!pointersRef.current.has(event.pointerId)) return;
      pointersRef.current.set(event.pointerId, { x: event.clientX, y: event.clientY });
      const gesture = gestureRef.current;

      if (gesture.kind === "pinch") {
        const points = [...pointersRef.current.values()];
        const a = points[0];
        const b = points[1];
        const rect = viewportRef.current?.getBoundingClientRect();
        if (!a || !b || !rect) return;
        const distance = Math.max(1, Math.hypot(a.x - b.x, a.y - b.y));
        const nextZoom = clampZoom((gesture.startZoom * distance) / gesture.startDistance);
        const centerX = (a.x + b.x) / 2 - rect.left;
        const centerY = (a.y + b.y) / 2 - rect.top;
        // Keep the layout point that was under the pinch centre pinned to it.
        onZoomAtViewportPoint(nextZoom, centerX, centerY);
        onPan({
          x: centerX - gesture.startLayoutX * nextZoom,
          y: centerY - gesture.startLayoutY * nextZoom,
        });
        return;
      }

      if (gesture.kind === "none" || gesture.pointerId !== event.pointerId) return;

      if (gesture.kind === "pan") {
        onPan({
          x: gesture.originX + (event.clientX - gesture.startClientX),
          y: gesture.originY + (event.clientY - gesture.startClientY),
        });
        return;
      }

      if (gesture.kind === "drag") {
        const point = toLayoutPoint(event.clientX, event.clientY);
        onMovePreview(gesture.componentId, point.x - gesture.grabOffsetX, point.y - gesture.grabOffsetY);
        if (!gesture.moved) gestureRef.current = { ...gesture, moved: true };
        return;
      }

      onResizePreview(
        gesture.componentId,
        gesture.handle,
        (event.clientX - gesture.startClientX) / zoom,
        (event.clientY - gesture.startClientY) / zoom,
      );
      if (!gesture.moved) gestureRef.current = { ...gesture, moved: true };
    },
    [onMovePreview, onPan, onResizePreview, onZoomAtViewportPoint, toLayoutPoint, zoom],
  );

  const handlePointerUp = useCallback(
    (event: React.PointerEvent<HTMLDivElement>) => {
      pointersRef.current.delete(event.pointerId);
      const viewport = viewportRef.current;
      if (viewport?.hasPointerCapture(event.pointerId)) viewport.releasePointerCapture(event.pointerId);

      const gesture = gestureRef.current;
      if (gesture.kind === "drag" && gesture.moved) onMoveCommit("移動");
      if (gesture.kind === "resize" && gesture.moved) onResizeCommit("サイズ変更");
      if (pointersRef.current.size < 2 && gesture.kind !== "none") gestureRef.current = { kind: "none" };
    },
    [onMoveCommit, onResizeCommit],
  );

  const handleWheel = useCallback(
    (event: React.WheelEvent<HTMLDivElement>) => {
      const rect = viewportRef.current?.getBoundingClientRect();
      if (!rect) return;
      const factor = event.deltaY < 0 ? 1.1 : 1 / 1.1;
      onZoomAtViewportPoint(clampZoom(zoom * factor), event.clientX - rect.left, event.clientY - rect.top);
    },
    [onZoomAtViewportPoint, zoom],
  );

  const ordered = sortForPaint(components);
  const gridStyle = gridOn
    ? {
        backgroundImage:
          "linear-gradient(to right, rgba(140,150,170,0.18) 1px, transparent 1px)," +
          "linear-gradient(to bottom, rgba(140,150,170,0.18) 1px, transparent 1px)",
        backgroundSize: `${gridSize}px ${gridSize}px`,
      }
    : undefined;

  return (
    <div
      ref={viewportRef}
      className="canvas-viewport"
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerCancel={handlePointerUp}
      onWheel={handleWheel}
      onKeyDown={(event) => {
        if (event.code === "Space") {
          spaceRef.current = true;
          event.preventDefault();
        }
      }}
      onKeyUp={(event) => {
        if (event.code === "Space") spaceRef.current = false;
      }}
      onBlur={() => {
        spaceRef.current = false;
      }}
      tabIndex={0}
      role="application"
      aria-label="UIレイアウトキャンバス"
    >
      <div className="canvas-stage" style={{ transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})` }}>
        <div className="canvas-screen" style={{ width: screen.width, height: screen.height, ...gridStyle }}>
          <div className="canvas-screen__label">
            {screen.name} · {screen.width}×{screen.height}
          </div>
          {ordered.map((component) => (
            <CanvasNode
              key={component.id}
              component={component}
              selected={component.id === selection}
              coarse={coarse}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

interface CanvasNodeProps {
  component: UiComponent;
  selected: boolean;
  coarse: boolean;
}

function CanvasNode({ component, selected, coarse }: CanvasNodeProps): React.JSX.Element {
  const info = getTypeInfo(component.type);
  const path = resolveTexturePath(component.texture as TextureValue, info.textureState);
  // On touch, tiny components get an enlarged invisible hit area (spec section 28).
  const needsBiggerTarget = coarse && (component.width < 44 || component.height < 44);
  const opacity = typeof component.properties.opacity === "number" ? component.properties.opacity : 1;
  const hidden = component.properties.visible === false;

  const className = [
    "canvas-node",
    info.known ? `canvas-node--${info.type}` : "canvas-node--unknown",
    selected ? "canvas-node--selected" : "",
    needsBiggerTarget ? "canvas-node--small" : "",
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <div
      className={className}
      data-component-id={component.id}
      style={{
        left: component.x,
        top: component.y,
        width: component.width,
        height: component.height,
        zIndex: selected ? SELECTED_Z_BASE + component.z : component.z,
        opacity,
        visibility: hidden ? "hidden" : "visible",
      }}
    >
      {path ? <img className="canvas-node__image" src={path} alt="" draggable={false} /> : null}
      {path ? null : <FallbackBody type={component.type} properties={component.properties} info={info} />}
      {component.type === "gauge" ? <GaugeBody properties={component.properties} /> : null}
      <div className="canvas-node__frame" />
      {selected ? <SelectionAffordances component={component} /> : null}
    </div>
  );
}

function FallbackBody({
  type,
  properties,
  info,
}: {
  type: string;
  properties: PropMap;
  info: ReturnType<typeof getTypeInfo>;
}): React.JSX.Element {
  if (type === "text" && typeof properties.text === "string") {
    return (
      <div className="canvas-node__fallback" style={{ color: "var(--text)", whiteSpace: "pre-wrap" }}>
        {properties.text}
      </div>
    );
  }
  if (type === "button" && typeof properties.text === "string") {
    return (
      <div className="canvas-node__fallback" style={{ color: "var(--text)" }}>
        {properties.text}
      </div>
    );
  }
  if (type === "radio") {
    return (
      <div className="canvas-node__fallback" style={{ color: "var(--text-dim)" }}>
        <span>{String(properties.channel ?? "CH")}</span>
        {typeof properties.band === "string" ? <span>{properties.band}</span> : null}
      </div>
    );
  }
  return (
    <div className="canvas-node__fallback">
      <span className="canvas-node__kind">{info.label}</span>
      {info.fallbackLabel ? <span>{info.fallbackLabel}</span> : null}
    </div>
  );
}

function GaugeBody({ properties }: { properties: PropMap }): React.JSX.Element {
  const min = typeof properties.min === "number" ? properties.min : 0;
  const max = typeof properties.max === "number" ? properties.max : 100;
  const value = typeof properties.value === "number" ? properties.value : min;
  const ratio = max > min ? Math.min(1, Math.max(0, (value - min) / (max - min))) : 0;
  const label = typeof properties.label === "string" ? properties.label : "";
  return (
    <div className="canvas-node__gauge">
      {label ? (
        <div className="canvas-node__gauge-caption">
          <span>{label}</span>
          <span>{value}</span>
        </div>
      ) : null}
      <div className="canvas-node__gauge-track">
        <div className="canvas-node__gauge-fill" style={{ width: `${ratio * 100}%` }} />
      </div>
    </div>
  );
}

function SelectionAffordances({ component }: { component: UiComponent }): React.JSX.Element {
  return (
    <>
      <span className="canvas-node__tag">{component.id}</span>
      <span className="canvas-node__z">z {component.z}</span>
      {HANDLE_IDS.map((handle) => (
        <span
          key={handle}
          className="canvas-handle"
          data-handle={handle}
          style={handleStyle(handle)}
        />
      ))}
    </>
  );
}

function handleStyle(handle: HandleId): React.CSSProperties {
  switch (handle) {
    case "nw":
      return { top: 0, left: 0 };
    case "n":
      return { top: 0, left: "50%" };
    case "ne":
      return { top: 0, left: "100%" };
    case "e":
      return { top: "50%", left: "100%" };
    case "se":
      return { top: "100%", left: "100%" };
    case "s":
      return { top: "100%", left: "50%" };
    case "sw":
      return { top: "100%", left: 0 };
    case "w":
      return { top: "50%", left: 0 };
    default:
      return { top: 0, left: 0 };
  }
}
