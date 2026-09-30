// `vitest/config` re-exports defineConfig with the `test` block typed; `vite` alone does not.
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

// Relative asset URLs keep `npm run build` output portable (any sub-path, or file://).
export default defineConfig({
  base: "./",
  plugins: [react()],
  build: {
    outDir: "dist",
    sourcemap: true,
  },
  test: {
    environment: "node",
    include: ["src/**/*.test.ts", "src/**/*.test.tsx"],
  },
});
