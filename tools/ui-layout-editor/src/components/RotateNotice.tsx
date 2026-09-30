/**
 * Portrait guard. CSS-driven so it also appears before React mounts, which matters on
 * iPhone Safari where the rotation happens faster than the JS bundle can boot.
 */
export function RotateNotice(): React.JSX.Element {
  return (
    <div className="rotate-notice" role="alert">
      <div>
        <span className="rotate-notice__glyph" aria-hidden="true">
          ⟳
        </span>
        Please rotate your device.
        <br />
        端末を横向きにしてください。
      </div>
    </div>
  );
}
