import * as path from "node:path";
import * as net from "node:net";
import * as fs from "node:fs/promises";
import {
  generateDungeonConfig,
  getGameDataErrorsWithAssets,
  loadGameData,
  writeGameData,
  type GameData,
} from "./dungeon-data.ts";

const cwd = process.cwd();
const preferredPort = Bun.env.PORT === undefined ? 0 : Number(Bun.env.PORT);
const editorDir = path.resolve(cwd, "editor");
const boosterMetadataPath = "data/editor/booster_metadata.json";
const boosterColorTokens = new Set(["green", "blue", "red", "yellow", "teal", "pink", "lime", "violet", "gray", "amber"]);

type EditorMetadata = {
  pack_colors: Record<string, string>;
};

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

async function readEditorMetadata(): Promise<EditorMetadata> {
  const file = Bun.file(path.resolve(cwd, boosterMetadataPath));
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
