import * as fs from "node:fs/promises";
import * as path from "node:path";
import * as process from "node:process";
import { pathToFileURL } from "node:url";
import { generateDungeonConfig as generateDungeonData } from "./dungeon-data.ts";

async function loadPatchedBend(cwd: string) {
  const bendSrcDir = path.resolve(cwd, "../Bend2/bend-ts/src");
  const patchedRoot = path.resolve(process.env.TMPDIR ?? "/tmp", `dungeonbend-bend-ts-src-${process.pid}`);
  const typeAnalysisPath = path.join(patchedRoot, "Compile/ToJS/TypeAnalysis.ts");
  const compilerPath = path.join(patchedRoot, "Compile/ToJS/Compiler.ts");
  const originalForceType = `export function force_type(book: Core.Book, typ: Core.Term | null): Core.Term | null {
  if (typ === null) {
    return null;
  }
  return Core.wnf_force(book, typ);
}`;
  const patchedForceType = `export function force_type(book: Core.Book, typ: Core.Term | null): Core.Term | null {
  if (typ === null) {
    return null;
  }
  try {
    return Core.wnf_force(book, typ);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
}`;
  const originalNativeType = `export function native_type(book: Core.Book | null, typ: Core.Term | null): "char" | "string" | "vector" | null {
  if (book === null) {
    return null;
  }
  var typ = force_type(book, typ);
  if (typ === null || typ.$ !== "ADT") {
    return null;
  }
  if (adt_is_char(book, typ)) {
    return "char";
  }
  if (adt_is_string(book, typ)) {
    return "string";
  }
  if (adt_is_vector(book, typ)) {
    return "vector";
  }
  return null;
}`;
  const originalCtrFlds = `export function ctr_flds(
  book: Core.Book | null,
  typ: Core.Term | null,
  nam: string,
): Core.TeleFld[] | null {
  if (book === null) {
    return null;
  }
  var adt = force_type(book, typ);
  if (adt === null || adt.$ !== "ADT") {
    return null;
  }
  var [ctr] = Core.take_constructor(adt, nam);
  if (ctr === null) {
    return null;
  }
  return Core.tele_flds(ctr.fds);
}`;
  const patchedCtrFlds = `export function ctr_flds(
  book: Core.Book | null,
  typ: Core.Term | null,
  nam: string,
): Core.TeleFld[] | null {
  if (book === null) {
    return null;
  }
  let adt: Core.Term | null = null;
  try {
    adt = force_type(book, typ);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
  if (adt === null || adt.$ !== "ADT") {
    return null;
  }
  var [ctr] = Core.take_constructor(adt, nam);
  if (ctr === null) {
    return null;
  }
  try {
    return Core.tele_flds(ctr.fds);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
}`;
  const patchedEmitStringCtr = `function emit_string_ctr(st: Types.EmitState, dst: string, trm: Core.Ctr, ctx: Types.EmitCtx): void {
  function unwrap(tm: Core.Term): Core.Term {
    while (tm.$ === "Ann" || tm.$ === "Red") {
      tm = tm.$ === "Ann" ? tm.val : tm.rgt;
    }
    return tm;
  }
  var cur: Core.Term = trm;
  var out = "";
  while (true) {
    cur = unwrap(cur);
    if (cur.$ !== "Ctr") {
      break;
    }
    if (cur.nam === "nil") {
      Emit.emit_set(st, dst, JSON.stringify(out));
      return;
    }
    if (cur.nam !== "cons" || cur.fds.length !== 2) {
      break;
    }
    var hed_tm = unwrap(cur.fds[0]);
    if (hed_tm.$ !== "Ctr" || hed_tm.nam !== "char" || hed_tm.fds.length !== 1) {
      break;
    }
    var chr_tm = unwrap(hed_tm.fds[0]);
    if (chr_tm.$ !== "W32") {
      break;
    }
    out += String.fromCharCode((chr_tm.val >>> 0) & 0xFFFF);
    cur = cur.fds[1];
  }
  if (trm.nam === "nil") {
    Emit.emit_set(st, dst, '""');
    return;
  }
  var hed = emit_sub(st, trm.fds[0], ctx);
  var rst = emit_sub(st, trm.fds[1], ctx);
  Emit.emit_set(st, dst, "(" + hed + " + " + rst + ")");
}`;
  const emitStringCtrPattern = /function emit_string_ctr\(st: Types\.EmitState, dst: string, trm: Core\.Ctr, ctx: Types\.EmitCtx\): void \{[\s\S]*?\n\}/;
  const patchedNativeType = `export function native_type(book: Core.Book | null, typ: Core.Term | null): "char" | "string" | "vector" | null {
  if (book === null) {
    return null;
  }
  try {
    var typ = force_type(book, typ);
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
  if (typ === null || typ.$ !== "ADT") {
    return null;
  }
  try {
    if (adt_is_char(book, typ)) {
      return "char";
    }
    if (adt_is_string(book, typ)) {
      return "string";
    }
    if (adt_is_vector(book, typ)) {
      return "vector";
    }
  } catch (err) {
    if (err instanceof RangeError) {
      return null;
    }
    throw err;
  }
  return null;
}`;

  await fs.rm(patchedRoot, { recursive: true, force: true });
  await fs.cp(bendSrcDir, patchedRoot, { recursive: true });

  const typeAnalysisSource = await fs.readFile(typeAnalysisPath, "utf8");
  const compilerSource = await fs.readFile(compilerPath, "utf8");
  if (!typeAnalysisSource.includes(originalForceType)) {
    throw new Error("Could not locate Bend TypeAnalysis.force_type for patching");
  }
  if (!typeAnalysisSource.includes(originalNativeType)) {
    throw new Error("Could not locate Bend TypeAnalysis.native_type for patching");
  }
  if (!typeAnalysisSource.includes(originalCtrFlds)) {
    throw new Error("Could not locate Bend TypeAnalysis.ctr_flds for patching");
  }
  if (!emitStringCtrPattern.test(compilerSource)) {
    throw new Error("Could not locate Bend Compiler.emit_string_ctr for patching");
  }
  await fs.writeFile(
    typeAnalysisPath,
    typeAnalysisSource
      .replace(originalForceType, patchedForceType)
      .replace(originalNativeType, patchedNativeType)
      .replace(originalCtrFlds, patchedCtrFlds)
  );
  await fs.writeFile(compilerPath, compilerSource.replace(emitStringCtrPattern, patchedEmitStringCtr));

  return import(`${pathToFileURL(path.join(patchedRoot, "Bend.ts")).href}?ts=${Date.now()}`);
}

function patchAppRuntime(html: string): string {
  const childPatchBuggy = [
    "    var nxt = __app_patch(kid, prev.kids[i], next.kids[i], dispatch, kidSvg);",
    "    if (nxt !== kid) {",
      "      dom.replaceChild(nxt, kid);",
    "    }",
  ].join("\n");

  const childPatchFixed = [
    "    var nxt = __app_patch(kid, prev.kids[i], next.kids[i], dispatch, kidSvg);",
    "    if (nxt !== kid && kid.parentNode === dom) {",
    "      dom.replaceChild(nxt, kid);",
    "    }",
  ].join("\n");

  const replaceBuggy = [
    "function __app_replace(dom, view, dispatch, svg) {",
    "  var nxt = __app_mount(view, dispatch, svg);",
    "  __app_dispose(dom);",
    "  dom.replaceWith(nxt);",
    "  return nxt;",
    "}",
  ].join("\n");

  const replaceFixed = [
    "function __app_replace(dom, view, dispatch, svg) {",
    "  var nxt = __app_mount(view, dispatch, svg);",
    "  __app_dispose(dom);",
    "  return nxt;",
    "}",
  ].join("\n");

  const stepBuggy = [
    "    dom  = __app_patch(dom, view, next, step, false);",
    "    view = next;",
  ].join("\n");

  const stepFixed = [
    "    dom  = __app_patch(dom, view, next, step, false);",
    "    if (dom.parentNode !== root) {",
    "      root.replaceChildren(dom);",
    "    }",
    "    view = next;",
  ].join("\n");

  let out = html;
  // Bend's JS backend sometimes emits discard bindings such as `var #_$5 = x$4;`
  // which are invalid identifiers in JS and crash the app before first render.
  out = out.replace(/#_\$(\d+)/g, (_match, suffix) => `_discard_$${suffix}`);
  if (out.includes(childPatchBuggy)) {
    out = out.replace(childPatchBuggy, childPatchFixed);
  }
  if (out.includes(replaceBuggy)) {
    out = out.replace(replaceBuggy, replaceFixed);
  }
  if (out.includes(stepBuggy)) {
    out = out.replace(stepBuggy, stepFixed);
  }
  // Inject a global keydown listener so arrow keys work without clicking the
  // board first.  The listener finds the .page element and, if it is not
  // already the event target, re-dispatches the key event on it.
  const globalKeyPatch = [
    "document.addEventListener(\"keydown\", function(e) {",
    "  var page = document.querySelector(\".page\");",
    "  if (page && e.target !== page) {",
    "    page.dispatchEvent(new KeyboardEvent(\"keydown\", {",
    "      key: e.key, code: e.code, keyCode: e.keyCode,",
    "      bubbles: false, cancelable: true",
    "    }));",
    "    e.preventDefault();",
    "  }",
    "});",
  ].join("\n");

  out = out.replace("</script>", globalKeyPatch + "\n</script>");

  return out;
}

function usage(): never {
  console.error("usage: bun scripts/build.ts <input.bend> <output.html>");
  process.exit(1);
}

const input = process.argv[2];
const output = process.argv[3];

if (input === undefined || output === undefined) {
  usage();
}

const cwd = process.cwd();
const file = path.resolve(cwd, input);
const out = path.resolve(cwd, output);
const preludeDir = path.resolve(cwd, process.env.BEND_PRELUDE_DIR ?? "../Bend2/prelude");

await generateDungeonData(cwd);
const Bend = await loadPatchedBend(cwd);

const loaded = Bend.Loader.load_book(file, { prelude_dir: preludeDir, strict: true });
const ok = Bend.Core.check_book(loaded.book, {
  show_ok: false,
  write: process.stderr.write.bind(process.stderr),
});

if (!ok) {
  process.exit(1);
}

const html = patchAppRuntime(Bend.ToJS.page(loaded.book, {
  main_name: loaded.main,
  title: path.basename(file, ".bend"),
}));

await Bun.write(out, html);
