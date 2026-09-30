/**
 * Inspector: everything about the selected component.
 *
 * Properties are rendered dynamically from whatever the YAML actually contains, rather
 * than from a fixed per-type form (spec section 16). Three editing entry points — canvas
 * drag, this panel, and the table — all go through the same callbacks in App, so they can
 * never disagree (spec section 33).
 */

import { useState } from "react";
import { KNOWN_TYPES, getTypeInfo, isKnownType } from "../model/component";
import type { PropValue, TextureMap, TextureValue, UiComponent } from "../model/layout";
import { CheckField, NumberField, TextField } from "./Fields";
import { fileNameToAssetPath, pickImageFile } from "../io/file";

type PropertyKind = "string" | "number" | "boolean";

export interface InspectorProps {
  component: UiComponent | undefined;
  onPatch: (id: string, patch: Partial<UiComponent>, label: string) => void;
  onRename: (id: string, nextId: string) => void;
  onDelete: (id: string) => void;
  onDuplicate: (id: string) => void;
}

export function Inspector({
  component,
  onPatch,
  onRename,
  onDelete,
  onDuplicate,
}: InspectorProps): React.JSX.Element {
  const [customTypeOpen, setCustomTypeOpen] = useState(false);

  if (!component) {
    return <div className="empty-note">コンポーネントを選択してください。</div>;
  }

  const info = getTypeInfo(component.type);

  return (
    <div className="inspector">
      <section className="inspector__section">
        <h2 className="inspector__heading">Identity</h2>
        <div className="field-row">
          <span className="field-row__label">ID</span>
          <div className="field-row__control">
            <TextField
              value={component.id}
              label="ID"
              monospace
              onCommit={(value) => onRename(component.id, value)}
            />
          </div>
        </div>
        <div className="field-row">
          <span className="field-row__label">Type</span>
          <div className="field-row__control">
            {customTypeOpen ? (
              <div className="field-row__control--split" style={{ display: "grid", gap: 4 }}>
                <TextField
                  value={component.type}
                  label="Custom type"
                  monospace
                  onCommit={(value) => {
                    const cleaned = value.trim();
                    if (cleaned.length > 0) onPatch(component.id, { type: cleaned }, "Type変更");
                    setCustomTypeOpen(false);
                  }}
                />
                <button type="button" className="btn" onClick={() => setCustomTypeOpen(false)}>
                  戻る
                </button>
              </div>
            ) : (
              <select
                className="field"
                aria-label="Type"
                value={isKnownType(component.type) ? component.type : "__custom__"}
                onChange={(event) => {
                  if (event.target.value === "__custom__") {
                    setCustomTypeOpen(true);
                    return;
                  }
                  onPatch(component.id, { type: event.target.value }, "Type変更");
                }}
              >
                {KNOWN_TYPES.map((type) => (
                  <option key={type} value={type}>
                    {type}
                  </option>
                ))}
                <option value="__custom__">{isKnownType(component.type) ? "custom…" : component.type}</option>
              </select>
            )}
          </div>
        </div>
        {!info.known ? (
          <p className="empty-note" style={{ padding: "4px 0" }}>
            Unknown Component: {component.type} — プレースホルダー表示。type は保存時に維持されます。
          </p>
        ) : null}
      </section>

      <section className="inspector__section">
        <h2 className="inspector__heading">Transform</h2>
        <div className="field-row">
          <span className="field-row__label">Position</span>
          <div className="field-row__control field-row__control--split">
            <NumberField
              value={component.x}
              label="X"
              onCommit={(value) => onPatch(component.id, { x: value }, "X変更")}
            />
            <NumberField
              value={component.y}
              label="Y"
              onCommit={(value) => onPatch(component.id, { y: value }, "Y変更")}
            />
          </div>
        </div>
        <div className="field-row">
          <span className="field-row__label">Z</span>
          <div className="field-row__control">
            <NumberField
              value={component.z}
              label="Z"
              onCommit={(value) => onPatch(component.id, { z: value }, "Z変更")}
            />
          </div>
        </div>
        <div className="field-row">
          <span className="field-row__label">Size</span>
          <div className="field-row__control field-row__control--split">
            <NumberField
              value={component.width}
              label="Width"
              min={4}
              onCommit={(value) => onPatch(component.id, { width: value }, "Width変更")}
            />
            <NumberField
              value={component.height}
              label="Height"
              min={4}
              onCommit={(value) => onPatch(component.id, { height: value }, "Height変更")}
            />
          </div>
        </div>
      </section>

      <TextureSection component={component} onPatch={onPatch} />

      <PropertiesSection component={component} onPatch={onPatch} />

      <section className="inspector__section">
        <h2 className="inspector__heading">Actions</h2>
        <div className="inspector__actions">
          <button type="button" className="btn" onClick={() => onDuplicate(component.id)}>
            Duplicate
          </button>
          <button
            type="button"
            className="btn btn--danger"
            onClick={() => {
              if (window.confirm(`"${component.id}" を削除しますか？`)) onDelete(component.id);
            }}
          >
            Delete
          </button>
        </div>
      </section>
    </div>
  );
}

function TextureSection({
  component,
  onPatch,
}: {
  component: UiComponent;
  onPatch: InspectorProps["onPatch"];
}): React.JSX.Element {
  const texture = component.texture;
  const asMap: TextureMap = typeof texture === "string" || texture === null ? {} : texture;

  const setSingle = (value: string): void => {
    onPatch(component.id, { texture: value.trim() === "" ? null : value }, "Texture変更");
  };

  const setState = (state: string, value: string): void => {
    const next: TextureMap = { ...asMap };
    if (value.trim() === "") delete next[state];
    else next[state] = value;
    onPatch(component.id, { texture: next }, "Texture変更");
  };

  const upload = async (state: string): Promise<void> => {
    const picked = await pickImageFile();
    if (!picked) return;
    // A browser cannot persist a local path, so uploads become self-contained data URLs.
    setState(state, picked.dataUrl);
  };

  return (
    <section className="inspector__section">
      <h2 className="inspector__heading">Texture</h2>
      {typeof texture === "string" || texture === null ? (
        <>
          <div className="texture-row">
            <span className="texture-row__state">single</span>
            <TextField
              value={typeof texture === "string" ? texture : ""}
              label="Texture path"
              placeholder="assets/example.png"
              monospace
              onCommit={setSingle}
            />
            <button
              type="button"
              className="btn btn--icon"
              title="画像をアップロード"
              onClick={() => void upload("normal")}
            >
              ↑
            </button>
          </div>
          <div className="inspector__actions">
            <button
              type="button"
              className="btn"
              onClick={() => onPatch(component.id, { texture: { normal: "" } }, "Texture状態化")}
            >
              複数状態へ
            </button>
          </div>
        </>
      ) : (
        <>
          {Object.entries(asMap).map(([state, path]) => (
            <div className="texture-row" key={state}>
              <span className="texture-row__state">{state}</span>
              <TextField
                value={path}
                label={`Texture ${state}`}
                placeholder="assets/example.png"
                monospace
                onCommit={(value) => setState(state, value)}
              />
              <button
                type="button"
                className="btn btn--icon"
                title="画像をアップロード"
                onClick={() => void upload(state)}
              >
                ↑
              </button>
            </div>
          ))}
          <div className="inspector__actions">
            <button
              type="button"
              className="btn"
              onClick={() => onPatch(component.id, { texture: { ...asMap, normal: "" } }, "Texture状態追加")}
            >
              状態を追加
            </button>
            <button
              type="button"
              className="btn"
              onClick={() => onPatch(component.id, { texture: null }, "Texture解除")}
            >
              単一画像へ
            </button>
          </div>
        </>
      )}
      {texture !== null ? (
        <p className="empty-note" style={{ padding: "4px 0" }}>
          アップロードした画像は data URL として保存されます（ブラウザはローカルパスを保持できないため）。
          参考名: {fileNameToAssetPath("example.png")}
        </p>
      ) : null}
    </section>
  );
}

function kindOf(value: PropValue): PropertyKind {
  if (typeof value === "boolean") return "boolean";
  if (typeof value === "number") return "number";
  return "string";
}

function PropertiesSection({
  component,
  onPatch,
}: {
  component: UiComponent;
  onPatch: InspectorProps["onPatch"];
}): React.JSX.Element {
  const entries = Object.entries(component.properties);

  const setProperty = (key: string, value: PropValue, label: string): void => {
    onPatch(component.id, { properties: { ...component.properties, [key]: value } }, label);
  };

  const removeProperty = (key: string): void => {
    const next = { ...component.properties };
    delete next[key];
    onPatch(component.id, { properties: next }, "Property削除");
  };

  return (
    <section className="inspector__section">
      <h2 className="inspector__heading">Properties</h2>
      {entries.length === 0 ? <div className="empty-note">properties はありません。</div> : null}
      {entries.map(([key, value]) => (
        <div className="prop-row" key={key}>
          <span className="prop-row__key" title={key}>
            {key}
          </span>
          <select
            className="field"
            aria-label={`${key} の型`}
            value={kindOf(value)}
            onChange={(event) => {
              const kind = event.target.value as PropertyKind;
              const next: PropValue =
                kind === "boolean" ? value === true : kind === "number" ? Number(value) || 0 : String(value);
              setProperty(key, next, "Property型変更");
            }}
          >
            <option value="string">string</option>
            <option value="number">number</option>
            <option value="boolean">boolean</option>
          </select>
          {typeof value === "boolean" ? (
            <div style={{ paddingLeft: 4 }}>
              <CheckField
                value={value}
                label=""
                onCommit={(next) => setProperty(key, next, "Property変更")}
              />
            </div>
          ) : (
            <TextField
              value={String(value)}
              label={key}
              monospace={kindOf(value) === "number"}
              onCommit={(next) =>
                setProperty(
                  key,
                  kindOf(value) === "number" ? (Number.isFinite(Number(next)) ? Number(next) : 0) : next,
                  "Property変更",
                )
              }
            />
          )}
          <button
            type="button"
            className="btn btn--icon btn--danger"
            title={`${key} を削除`}
            onClick={() => removeProperty(key)}
          >
            ×
          </button>
        </div>
      ))}
      <div className="inspector__actions">
        <button
          type="button"
          className="btn"
          onClick={() => onPatch(component.id, { properties: { ...component.properties, new_property: "" } }, "Property追加")}
        >
          + Property
        </button>
      </div>
    </section>
  );
}

export type { TextureValue };
