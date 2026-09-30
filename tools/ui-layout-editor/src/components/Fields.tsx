/**
 * Small controlled inputs used by the Inspector and the Table.
 *
 * `NumberField` keeps a local text buffer so a value can be cleared and retyped without
 * the layout jumping to 0 mid-keystroke, while still committing every parseable value
 * immediately (spec sections 15 and 33).
 */

import { useEffect, useState } from "react";

interface NumberFieldProps {
  value: number;
  onCommit: (value: number) => void;
  label?: string;
  min?: number;
  step?: number;
  disabled?: boolean;
}

export function NumberField({
  value,
  onCommit,
  label,
  min,
  step = 1,
  disabled,
}: NumberFieldProps): React.JSX.Element {
  const [buffer, setBuffer] = useState(String(value));
  const [invalid, setInvalid] = useState(false);

  useEffect(() => {
    setBuffer(String(value));
    setInvalid(false);
  }, [value]);

  const commit = (raw: string): void => {
    const trimmed = raw.trim();
    if (trimmed === "") {
      setInvalid(true);
      return;
    }
    const parsed = Number(trimmed);
    if (!Number.isFinite(parsed)) {
      setInvalid(true);
      return;
    }
    setInvalid(false);
    onCommit(min === undefined ? parsed : Math.max(min, parsed));
  };

  return (
    <input
      className={`field field--num${invalid ? " field--invalid" : ""}`}
      type="number"
      inputMode="decimal"
      step={step}
      min={min}
      aria-label={label}
      value={buffer}
      disabled={disabled}
      onChange={(event) => {
        const raw = event.target.value;
        setBuffer(raw);
        const parsed = Number(raw);
        if (raw.trim() !== "" && Number.isFinite(parsed)) {
          setInvalid(false);
          onCommit(min === undefined ? parsed : Math.max(min, parsed));
        } else {
          setInvalid(true);
        }
      }}
      onBlur={(event) => commit(event.target.value)}
    />
  );
}

interface TextFieldProps {
  value: string;
  onCommit: (value: string) => void;
  label?: string;
  placeholder?: string;
  monospace?: boolean;
  disabled?: boolean;
}

export function TextField({
  value,
  onCommit,
  label,
  placeholder,
  monospace,
  disabled,
}: TextFieldProps): React.JSX.Element {
  const [buffer, setBuffer] = useState(value);

  useEffect(() => {
    setBuffer(value);
  }, [value]);

  return (
    <input
      className="field"
      style={monospace ? { fontFamily: "var(--font-mono)", fontSize: "11px" } : undefined}
      type="text"
      aria-label={label}
      placeholder={placeholder}
      value={buffer}
      disabled={disabled}
      onChange={(event) => {
        setBuffer(event.target.value);
        onCommit(event.target.value);
      }}
    />
  );
}

interface CheckFieldProps {
  value: boolean;
  onCommit: (value: boolean) => void;
  label: string;
}

export function CheckField({ value, onCommit, label }: CheckFieldProps): React.JSX.Element {
  return (
    <label className="table-filter__group" style={{ cursor: "pointer" }}>
      <input type="checkbox" checked={value} onChange={(event) => onCommit(event.target.checked)} />
      <span className="table-filter__label">{label}</span>
    </label>
  );
}
