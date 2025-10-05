import fs from "node:fs";
import { execSync } from "node:child_process";
import { Buffer } from "node:buffer";
import { EventEmitter } from "node:events";
import { Ok, Error as GError } from "../../gleam_stdlib/gleam.mjs";

import { keypress } from "./keypress.mjs"

function setRaw(on) {
  try {
    execSync(`stty ${on ? "raw -echo" : "-raw echo"} < /dev/tty`, {
      stdio: ["ignore", "ignore", "ignore"],
    });
  } catch {
    // If no TTY, we silently ignore; we'll fall back to line-mode on stdin.
  }
}

function stringifyKey(ch, key) {
  // Prefer structured key info if present
  let base = null;

  // Normalize 'return' to 'enter'
  const normalizeName = (n) => {
    if (n === "return") return "enter";
    if (n === "escape") return "escape";
    if (n === "space") return "space";
    if (n === "delete") return "delete";
    if (n === "insert") return "insert";
    if (n === "home") return "home";
    if (n === "end") return "end";
    if (n === "pageup") return "pageup";
    if (n === "pagedown") return "pagedown";
    if (n === "tab") return "tab";
    if (n === "backspace") return "backspace";
    if (n === "up" || n === "down" || n === "left" || n === "right") return n;
    // function keys come as f1..f12, keep as-is
    return n;
  };

  if (key && key.name) {
    const n = normalizeName(key.name);
    if (n && typeof n === "string") base = n;
  }

  // If no structured name, fall back to character
  if (!base) {
    if (typeof ch === "string" && ch.length > 0) {
      if (ch === " ") base = "space";
      else base = `char:${ch}`;
    }
  }

  // If still nothing, give up
  if (!base) return null;

  const mods = [];
  if (key) {
    if (key.ctrl) mods.push("ctrl");
    // Treat "meta" as "alt" for TTYs
    if (key.meta) mods.push("alt");
    if (key.shift) mods.push("shift");
  }

  if (mods.length > 0) return `${mods.join("+")}+${base}`;
  return base;
}

export function input(prompt) {
  let fd = null;
  try {
    process.stdout.write(prompt);

    // Try to read direct from controlling terminal
    try {
      fd = fs.openSync("/dev/tty", "r");
    } catch {
      // Fallback to line mode on stdin (needs Enter)
      const buf = Buffer.alloc(4096);
      const n = fs.readSync(0, buf, 0, buf.length, null);
      const s = buf.toString("utf8", 0, n).replace(/[\r\n]+$/, "");
      return s ? new Ok(s) : new GError(undefined);
    }

    setRaw(true);

    const buf = Buffer.alloc(32);
    let n = 0;
    // Blocking read with retry for transient conditions
    // (rare with a blocking fd, but cheap to handle)
    /* eslint no-constant-condition: 0 */
    while (true) {
      try {
        n = fs.readSync(fd, buf, 0, buf.length, null);
        break;
      } catch (e) {
        if (e && (e.code === "EAGAIN" || e.code === "EINTR")) continue;
        throw e;
      }
    }

    setRaw(false);
    fs.closeSync(fd);
    fd = null;

    if (n <= 0) return new GError(undefined);

    // Ctrl-C = cancel
    if (buf[0] === 0x03) return new GError(undefined);

    const s = buf.toString("utf8", 0, n);

    // Decode via your keypress parser
    const stream = new EventEmitter();

    keypress(stream)

    let name = null;
    stream.on("keypress", (ch, key) => {
      console.log({ ch, key })
      if (name !== null) return; // first event only
      name = stringifyKey(ch, key);
    });

    stream.emit("data", Buffer.from(s, "utf8"));

    // Fallback if undecodable: first printable char
    if (!name) {
      if (s === " ") name = "space";
      else if (s && s.length > 0) name = `char:${s[0]}`;
    }

    return name ? new Ok(name) : new GError(undefined);
  } catch {
    try { setRaw(false); } catch {}
    try { if (fd !== null) fs.closeSync(fd); } catch {}
    return new GError(undefined);
  }
}

