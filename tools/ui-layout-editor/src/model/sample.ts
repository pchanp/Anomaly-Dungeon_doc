/**
 * The sample layout shipped with the editor.
 *
 * `samples/inventory.yaml` stays the single source of truth and is embedded as a raw
 * string import, so there is no build step to keep two copies in sync.
 */

import sampleYaml from "../../samples/inventory.yaml?raw";

export const SAMPLE_YAML: string = sampleYaml;
export const SAMPLE_FILE_NAME = "inventory.yaml";
