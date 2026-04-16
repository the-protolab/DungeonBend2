import * as path from "node:path";
import { generateDungeonConfig, getGameDataErrors, loadGameData, writeGameData, type GameData } from "./dungeon-data.ts";

const cwd = process.cwd();
const preferredPort = Number(Bun.env.PORT ?? "4181");
const editorDir = path.resolve(cwd, "editor");

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

async function buildEditor(): Promise<{ ok: boolean; output: string }> {
  const proc = Bun.spawn(["bun", "scripts/build.ts", "src/Editor/main.bend", "editor/index.html"], {
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

async function handleRequest(req: Request): Promise<Response> {
  const url = new URL(req.url);

  try {
    if (url.pathname === "/api/game-data" && req.method === "GET") {
      const data = await loadGameData(cwd);
      return jsonResponse({ data, errors: getGameDataErrors(data) });
    }

    if (url.pathname === "/api/game-data" && req.method === "PUT") {
      const data = (await req.json()) as GameData;
      const errors = getGameDataErrors(data);
      if (errors.length > 0) {
        return jsonResponse({ ok: false, errors }, 400);
      }
      await writeGameData(cwd, data);
      await generateDungeonConfig(cwd);
      const editorBuild = await buildEditor();
      if (!editorBuild.ok) {
        return jsonResponse({ ok: false, errors: [editorBuild.output || "Editor build failed after save"] }, 500);
      }
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

function startServer(): ReturnType<typeof Bun.serve> {
  let lastError: unknown = null;
  for (let offset = 0; offset < 200; offset += 1) {
    const candidatePort = preferredPort + offset;
    try {
      return Bun.serve({
        hostname: "127.0.0.1",
        port: candidatePort,
        fetch: handleRequest,
      });
    } catch (err) {
      lastError = err;
    }
  }
  try {
    return Bun.serve({
      hostname: "127.0.0.1",
      port: 0,
      fetch: handleRequest,
    });
  } catch (err) {
    throw lastError ?? err;
  }
}

const initialEditorBuild = await buildEditor();
if (!initialEditorBuild.ok) {
  throw new Error(initialEditorBuild.output || "Editor build failed");
}

const server = startServer();

console.log(`Economy editor running at http://127.0.0.1:${server.port}`);
