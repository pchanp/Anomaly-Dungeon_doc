/**
 * Local file helpers. No backend, no server: everything runs in the browser.
 *
 * Texture limitation (spec section 17): a browser cannot persist an absolute local file
 * path. Uploaded images are therefore kept as data URLs inside the layout, which keeps a
 * saved YAML self-contained at the cost of file size.
 */

export function downloadText(filename: string, text: string, mime = "text/yaml"): void {
  const blob = new Blob([text], { type: `${mime};charset=utf-8` });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  // Revoke on the next tick so Safari has time to start the download.
  window.setTimeout(() => URL.revokeObjectURL(url), 1000);
}

export function readFileAsText(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result ?? ""));
    reader.onerror = () => reject(reader.error ?? new Error("ファイル読み込みに失敗しました。"));
    reader.readAsText(file);
  });
}

export function readFileAsDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result ?? ""));
    reader.onerror = () => reject(reader.error ?? new Error("画像読み込みに失敗しました。"));
    reader.readAsDataURL(file);
  });
}

export interface LoadedFile {
  name: string;
  text: string;
}

export function pickYamlFile(): Promise<LoadedFile | null> {
  return new Promise((resolve) => {
    const input = document.createElement("input");
    input.type = "file";
    input.accept = ".yaml,.yml,text/yaml,application/x-yaml";
    input.onchange = () => {
      const file = input.files?.[0];
      if (!file) {
        resolve(null);
        return;
      }
      readFileAsText(file)
        .then((text) => resolve({ name: file.name, text }))
        .catch(() => resolve(null));
    };
    input.click();
  });
}

export function pickImageFile(): Promise<{ name: string; dataUrl: string } | null> {
  return new Promise((resolve) => {
    const input = document.createElement("input");
    input.type = "file";
    input.accept = "image/*";
    input.onchange = () => {
      const file = input.files?.[0];
      if (!file) {
        resolve(null);
        return;
      }
      readFileAsDataUrl(file)
        .then((dataUrl) => resolve({ name: file.name, dataUrl }))
        .catch(() => resolve(null));
    };
    input.click();
  });
}

/** Strips directories and the extension so a file name can stand in for an asset path. */
export function fileNameToAssetPath(name: string): string {
  return name.replace(/^.*[\\/]/, "").replace(/\.[^.]+$/, "");
}
