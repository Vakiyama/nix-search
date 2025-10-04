import fs from "node:fs";
import { execSync } from "node:child_process";
import { Buffer } from "node:buffer";
import { Ok, Error as GError } from "../../gleam_stdlib/gleam.mjs";

export function input(prompt) {
  let fd = null;
  const setRaw = (on) => {
    try {
      execSync(`stty ${on ? "raw -echo" : "-raw echo"} < /dev/tty`, {
        stdio: ["ignore", "ignore", "ignore"],
      });
    } catch {
      // If stty fails (no TTY), we’ll fall back below.
    }
  };

  try {
    process.stdout.write(prompt);

    // Open controlling TTY directly (blocking)
    try {
      fd = fs.openSync("/dev/tty", "r");
    } catch {
      // No /dev/tty (e.g. piped). Fall back to line mode via stdin.
      const buf = Buffer.alloc(4096);
      const n = fs.readSync(0, buf, 0, buf.length, null);
      const s = buf.toString("utf8", 0, n).replace(/[\r\n]+$/, "");
      return new Ok(s);
    }

    // Put terminal in raw mode (no newline needed)
    setRaw(true);

    const buf = Buffer.alloc(8);
    let n = 0;

    // Blocking read; tolerate transient EINTR/EAGAIN (rare with blocking fd)
    while (true) {
      try {
        n = fs.readSync(fd, buf, 0, buf.length, null);
        break;
      } catch (e) {
        if (e && (e.code === "EAGAIN" || e.code === "EINTR")) continue;
        throw e;
      }
    }

    // Restore terminal and close fd
    setRaw(false);
    fs.closeSync(fd);
    fd = null;

    if (n <= 0) return new GError(undefined);

    // Handle Ctrl+C (0x03) as cancel
    if (buf[0] === 0x03) return new GError(undefined);

    const s = buf.toString("utf8", 0, n).replace(/[\r\n]+$/, "");
    return new Ok(s);
  } catch (e) {
    try { setRaw(false); } catch {}
    try { if (fd !== null) fs.closeSync(fd); } catch {}
    return new GError(undefined);
  }
}

