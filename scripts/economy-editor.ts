import * as path from "node:path";
import * as net from "node:net";
import * as fs from "node:fs/promises";
import {
  generateDungeonConfig,
  getGameDataErrors,
  getGameDataErrorsWithAssets,
  loadGameData,
  writeGameData,
  type GameData,
} from "./dungeon-data.ts";

const cwd = process.cwd();
const preferredPort = Bun.env.PORT === undefined ? 0 : Number(Bun.env.PORT);
const editorDir = path.resolve(cwd, "editor");
const boosterMetadataPath = "data/editor/booster_metadata.json";
const savedVersionsDir = "data/old_versions";
const boosterColorTokens = new Set(["green", "blue", "red", "yellow", "teal", "pink", "lime", "violet", "gray", "amber"]);

type EditorMetadata = {
  pack_colors: Record<string, string>;
};

type VersionFile = {
  source: string;
  versionPath: string;
  required: boolean;
};

type SavedVersion = {
  slug: string;
  label: string;
  created_at: string;
  files: string[];
};

const versionFiles: VersionFile[] = [
  { source: "data/game/heroes.json", versionPath: "game/heroes.json", required: true },
  { source: "data/game/monsters.json", versionPath: "game/monsters.json", required: true },
  { source: "data/game/weapons.json", versionPath: "game/weapons.json", required: true },
  { source: "data/game/potions.json", versionPath: "game/potions.json", required: true },
  { source: "data/game/hero_upgrades.json", versionPath: "game/hero_upgrades.json", required: true },
  { source: "data/game/boosters.json", versionPath: "game/boosters.json", required: true },
  { source: "data/game/decks.json", versionPath: "game/decks.json", required: true },
  { source: "data/game/rules.json", versionPath: "game/rules.json", required: true },
  { source: "data/content/en.json", versionPath: "content/en.json", required: true },
  { source: "data/presentation/heroes.json", versionPath: "presentation/heroes.json", required: true },
  { source: boosterMetadataPath, versionPath: "editor/booster_metadata.json", required: false },
];

const mimeTypes: Record<string, string> = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
};

const assetExtensions = new Set([".png", ".jpg", ".jpeg", ".svg", ".gif", ".webp"]);

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function normalizeEditorMetadata(value: unknown): EditorMetadata {
  if (!isRecord(value)) {
    return { pack_colors: {} };
  }
  const rawColors = isRecord(value.pack_colors) ? value.pack_colors : {};
  const packColors: Record<string, string> = {};
  Object.entries(rawColors).forEach(([packId, color]) => {
    if (typeof color === "string") {
      packColors[packId] = color;
    }
  });
  return { pack_colors: packColors };
}

async function readEditorMetadata(root = cwd): Promise<EditorMetadata> {
  const file = Bun.file(path.resolve(root, boosterMetadataPath));
  if (!(await file.exists())) {
    return { pack_colors: {} };
  }
  return normalizeEditorMetadata(await file.json());
}

async function writeEditorMetadata(metadata: EditorMetadata): Promise<void> {
  await fs.mkdir(path.resolve(cwd, "data/editor"), { recursive: true });
  await Bun.write(path.resolve(cwd, boosterMetadataPath), `${JSON.stringify(metadata, null, 2)}\n`);
}

function getEditorMetadataErrors(data: GameData, metadata: EditorMetadata): string[] {
  const errors: string[] = [];
  const packs = Array.isArray(data.boosters?.packs) ? data.boosters.packs : [];
  const packIds = new Set(packs.map((pack) => pack.id));
  Object.entries(metadata.pack_colors).forEach(([packId, color]) => {
    if (!packIds.has(packId)) {
      errors.push(`editor booster metadata references unknown pack_id "${packId}"`);
    }
    if (!boosterColorTokens.has(color)) {
      errors.push(`editor booster metadata for "${packId}" must use a valid pack color`);
    }
  });
  return errors;
}

function unpackGameDataPayload(payload: unknown): { data: GameData; editorMetadata: EditorMetadata } {
  if (isRecord(payload) && isRecord(payload.data)) {
    return {
      data: payload.data as GameData,
      editorMetadata: normalizeEditorMetadata(payload.editorMetadata),
    };
  }
  return {
    data: payload as GameData,
    editorMetadata: { pack_colors: {} },
  };
}

function slugifyVersionLabel(label: string): string {
  return label
    .trim()
    .toLowerCase()
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function isSafeVersionSlug(slug: string): boolean {
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug);
}

function versionRoot(): string {
  return path.resolve(cwd, savedVersionsDir);
}

function versionDir(slug: string): string {
  return path.join(versionRoot(), slug);
}

function versionDataPath(file: VersionFile, root = cwd): string {
  return path.resolve(root, file.source);
}

function versionStoredPath(file: VersionFile, slug: string): string {
  return path.join(versionDir(slug), file.versionPath);
}

async function fileExists(filePath: string): Promise<boolean> {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

function normalizeVersionManifest(value: unknown, slug: string): SavedVersion | null {
  if (!isRecord(value)) {
    return null;
  }
  const label = typeof value.label === "string" && value.label.trim() !== "" ? value.label : slug;
  const createdAt = typeof value.created_at === "string" && value.created_at.trim() !== "" ? value.created_at : "";
  const files = Array.isArray(value.files) ? value.files.filter((file) => typeof file === "string") : [];
  return {
    slug,
    label,
    created_at: createdAt,
    files,
  };
}

async function readVersionManifest(slug: string): Promise<SavedVersion | null> {
  if (!isSafeVersionSlug(slug)) {
    return null;
  }
  const manifest = Bun.file(path.join(versionDir(slug), "manifest.json"));
  if (!(await manifest.exists())) {
    return null;
  }
  return normalizeVersionManifest(await manifest.json(), slug);
}

async function listSavedVersions(): Promise<SavedVersion[]> {
  let entries: import("node:fs").Dirent[];
  try {
    entries = await fs.readdir(versionRoot(), { withFileTypes: true });
  } catch (err) {
    if (err instanceof Error && "code" in err && err.code === "ENOENT") {
      return [];
    }
    throw err;
  }
  const versions = await Promise.all(
    entries
      .filter((entry) => entry.isDirectory() && isSafeVersionSlug(entry.name))
      .map((entry) => readVersionManifest(entry.name))
  );
  return versions
    .filter((version): version is SavedVersion => version !== null)
    .sort((a, b) => a.created_at.localeCompare(b.created_at) || a.label.localeCompare(b.label));
}

async function validateCurrentData(): Promise<string[]> {
  const data = await loadGameData(cwd);
  const editorMetadata = await readEditorMetadata();
  return [
    ...(await getGameDataErrorsWithAssets(cwd, data)),
    ...getEditorMetadataErrors(data, editorMetadata),
  ];
}

async function createSavedVersion(label: string): Promise<SavedVersion> {
  const cleanLabel = label.trim();
  const slug = slugifyVersionLabel(cleanLabel);
  if (cleanLabel === "" || slug === "") {
    throw new Error("Version name is required");
  }
  if (await fileExists(versionDir(slug))) {
    throw new Error(`Version "${slug}" already exists`);
  }

  const errors = await validateCurrentData();
  if (errors.length > 0) {
    throw new Error(errors.join("\n"));
  }

  const dir = versionDir(slug);
  const copiedFiles: string[] = [];
  try {
    await fs.mkdir(dir, { recursive: true });
    for (const file of versionFiles) {
      const source = versionDataPath(file);
      if (!(await fileExists(source))) {
        if (file.required) {
          throw new Error(`Missing required JSON file: ${file.source}`);
        }
        continue;
      }
      const target = versionStoredPath(file, slug);
      await fs.mkdir(path.dirname(target), { recursive: true });
      await fs.copyFile(source, target);
      copiedFiles.push(file.versionPath);
    }
    const version: SavedVersion = {
      slug,
      label: cleanLabel,
      created_at: new Date().toISOString(),
      files: copiedFiles,
    };
    await Bun.write(path.join(dir, "manifest.json"), `${JSON.stringify(version, null, 2)}\n`);
    return version;
  } catch (err) {
    await fs.rm(dir, { recursive: true, force: true });
    throw err;
  }
}

function tempRestoreRoot(slug: string): string {
  return path.join("/tmp", `dungeonbend-version-${slug}-${Date.now()}`);
}

async function stageVersionForValidation(slug: string, root: string): Promise<void> {
  for (const file of versionFiles) {
    const source = versionStoredPath(file, slug);
    const target = versionDataPath(file, root);
    if (!(await fileExists(source))) {
      if (file.required) {
        throw new Error(`Version "${slug}" is missing ${file.versionPath}`);
      }
      continue;
    }
    await fs.mkdir(path.dirname(target), { recursive: true });
    await fs.copyFile(source, target);
  }
}

async function restoreSavedVersion(slug: string): Promise<void> {
  if (!isSafeVersionSlug(slug)) {
    throw new Error("Invalid version id");
  }
  const manifest = await readVersionManifest(slug);
  if (manifest === null) {
    throw new Error(`Version "${slug}" does not exist`);
  }

  const tempRoot = tempRestoreRoot(slug);
  try {
    await stageVersionForValidation(slug, tempRoot);
    const stagedData = await loadGameData(tempRoot);
    const stagedMetadata = await readEditorMetadata(tempRoot);
    const errors = [
      ...getGameDataErrors(stagedData),
      ...getEditorMetadataErrors(stagedData, stagedMetadata),
    ];
    if (errors.length > 0) {
      throw new Error(errors.join("\n"));
    }

    for (const file of versionFiles) {
      const source = versionStoredPath(file, slug);
      const target = versionDataPath(file);
      if (!(await fileExists(source))) {
        if (file.required) {
          throw new Error(`Version "${slug}" is missing ${file.versionPath}`);
        }
        await fs.rm(target, { force: true });
        continue;
      }
      await fs.mkdir(path.dirname(target), { recursive: true });
      await fs.copyFile(source, target);
    }
    await generateDungeonConfig(cwd);
  } finally {
    await fs.rm(tempRoot, { recursive: true, force: true });
  }
}

function jsonResponse(body: unknown, status = 200): Response {
  return Response.json(body, {
    status,
    headers: {
      "Cache-Control": "no-store",
    },
  });
}

function textResponse(body: string, status = 200): Response {
  return new Response(body, {
    status,
    headers: {
      "Content-Type": "text/plain; charset=utf-8",
      "Cache-Control": "no-store",
    },
  });
}

async function serveFile(filePath: string): Promise<Response> {
  const file = Bun.file(filePath);
  if (!(await file.exists())) {
    return textResponse("Not found", 404);
  }
  const ext = path.extname(filePath);
  return new Response(file, {
    headers: {
      "Content-Type": mimeTypes[ext] ?? "application/octet-stream",
      "Cache-Control": "no-store",
    },
  });
}

function editorFile(urlPath: string): string {
  if (urlPath === "/" || urlPath === "/index.html") {
    return path.join(editorDir, "index.html");
  }
  const safePath = path.normalize(urlPath).replace(/^(\.\.(\/|\\|$))+/, "");
  return path.join(editorDir, safePath);
}

async function buildDocs(): Promise<{ ok: boolean; output: string }> {
  const proc = Bun.spawn(["sh", "scripts/build-pages.sh"], {
    cwd,
    stdout: "pipe",
    stderr: "pipe",
  });
  const [stdout, stderr, exitCode] = await Promise.all([
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
    proc.exited,
  ]);
  return {
    ok: exitCode === 0,
    output: [stdout.trim(), stderr.trim()].filter(Boolean).join("\n"),
  };
}

async function listAssets(): Promise<string[]> {
  const assetDir = path.resolve(cwd, "assets");
  const entries = await fs.readdir(assetDir, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isFile() && assetExtensions.has(path.extname(entry.name).toLowerCase()))
    .map((entry) => `assets/${entry.name}`)
    .sort();
}

async function handleRequest(req: Request): Promise<Response> {
  const url = new URL(req.url);

  try {
    if (url.pathname === "/api/game-data" && req.method === "GET") {
      const data = await loadGameData(cwd);
      const editorMetadata = await readEditorMetadata();
      return jsonResponse({
        data,
        editorMetadata,
        errors: [
          ...(await getGameDataErrorsWithAssets(cwd, data)),
          ...getEditorMetadataErrors(data, editorMetadata),
        ],
      });
    }

    if (url.pathname === "/api/assets" && req.method === "GET") {
      return jsonResponse({ assets: await listAssets() });
    }

    if (url.pathname === "/api/versions" && req.method === "GET") {
      return jsonResponse({ versions: await listSavedVersions() });
    }

    if (url.pathname === "/api/versions" && req.method === "POST") {
      const payload = await req.json();
      const label = isRecord(payload) && typeof payload.label === "string" ? payload.label : "";
      try {
        const version = await createSavedVersion(label);
        return jsonResponse({ ok: true, version });
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        return jsonResponse({ ok: false, errors: [message] }, message.includes("already exists") ? 409 : 400);
      }
    }

    if (url.pathname === "/api/versions/restore" && req.method === "POST") {
      const payload = await req.json();
      const slug = isRecord(payload) && typeof payload.slug === "string" ? payload.slug : "";
      try {
        await restoreSavedVersion(slug);
        return jsonResponse({ ok: true });
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        return jsonResponse({ ok: false, errors: [message] }, 400);
      }
    }

    if (url.pathname === "/api/game-data" && req.method === "PUT") {
      const { data, editorMetadata } = unpackGameDataPayload(await req.json());
      const errors = [
        ...(await getGameDataErrorsWithAssets(cwd, data)),
        ...getEditorMetadataErrors(data, editorMetadata),
      ];
      if (errors.length > 0) {
        return jsonResponse({ ok: false, errors }, 400);
      }
      await writeGameData(cwd, data);
      await writeEditorMetadata(editorMetadata);
      await generateDungeonConfig(cwd);
      return jsonResponse({ ok: true, errors: [] });
    }

    if (url.pathname === "/api/build-docs" && req.method === "POST") {
      const result = await buildDocs();
      return jsonResponse(result, result.ok ? 200 : 500);
    }

    if (url.pathname.startsWith("/assets/") && req.method === "GET") {
      return serveFile(path.resolve(cwd, url.pathname.slice(1)));
    }

    if (req.method === "GET") {
      return serveFile(editorFile(url.pathname));
    }

    return textResponse("Method not allowed", 405);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return jsonResponse({ ok: false, errors: [message] }, 500);
  }
}

function canListen(port: number): Promise<boolean> {
  return new Promise((resolve) => {
    const probe = net.createServer();
    probe.once("error", () => resolve(false));
    probe.once("listening", () => {
      probe.close(() => resolve(true));
    });
    probe.listen(port, "127.0.0.1");
  });
}

function freeSystemPort(): Promise<number> {
  return new Promise((resolve, reject) => {
    const probe = net.createServer();
    probe.once("error", reject);
    probe.once("listening", () => {
      const address = probe.address();
      if (typeof address === "object" && address !== null) {
        probe.close(() => resolve(address.port));
      } else {
        probe.close(() => reject(new Error("Could not allocate a local port")));
      }
    });
    probe.listen(0, "127.0.0.1");
  });
}

async function choosePort(): Promise<number> {
  if (preferredPort === 0) {
    return freeSystemPort();
  }
  for (let offset = 0; offset < 200; offset += 1) {
    const candidatePort = preferredPort + offset;
    if (await canListen(candidatePort)) {
      return candidatePort;
    }
  }
  return freeSystemPort();
}

async function startServer(): Promise<ReturnType<typeof Bun.serve>> {
  const port = await choosePort();
  return Bun.serve({
    hostname: "127.0.0.1",
    port,
    fetch: handleRequest,
  });
}

const server = await startServer();

console.log(`Economy editor running at http://127.0.0.1:${server.port}`);
