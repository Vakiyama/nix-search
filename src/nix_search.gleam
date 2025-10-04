import ffi/execute
import gleam/io

pub fn main() {
  case execute.execute("nix search nixpkgs pgrep --json", 1024 * 1024 * 100) {
    Ok(message) -> io.println("Stdio: " <> message)
    Error(message) -> io.println_error("Error: " <> message)
  }
}
