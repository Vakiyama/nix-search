import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type InputError {
  InputError
}

@external(javascript, "./input_ffi.mjs", "input")
fn input_ffi(prompt: String) -> Result(String, InputError)

pub type Key {
  Backspace
  Left
  Right
  Up
  Down
  Home
  End
  PageUp
  PageDown
  Tab
  Delete
  Insert
  Enter
  Space
  FKey(Int)
  Char(String)
  Alt(Key)
  Ctrl(Key)
  Shift(Key)
  Esc
  Unknown
}

pub fn get_user_input_key(prompt: String) -> Result(Key, InputError) {
  result.map(input_ffi(prompt), decode_key)
}

// ---------- Decoder ----------

fn decode_key(s: String) -> Key {
  let parts = string.split(s, "+")
  case list.reverse(parts) {
    [] -> Unknown
    [base_token, ..mods_rev] -> {
      let base = parse_base_token(base_token)
      let mods = list.reverse(mods_rev)
      apply_mods(base, mods)
    }
  }
}

fn apply_mods(base: Key, mods: List(String)) -> Key {
  list.fold(mods, base, fn(acc, mod) {
    case string.lowercase(mod) {
      "ctrl" -> Ctrl(acc)
      "alt" -> Alt(acc)
      "shift" -> Shift(acc)
      _ -> acc
    }
  })
}

fn parse_base_token(tok: String) -> Key {
  let t = string.lowercase(tok)

  // Direct names first
  case t {
    "left" -> Left
    "right" -> Right
    "up" -> Up
    "down" -> Down
    "home" -> Home
    "end" -> End
    "pageup" -> PageUp
    "pagedown" -> PageDown
    "tab" -> Tab
    "delete" -> Delete
    "insert" -> Insert
    "enter" -> Enter
    "space" -> Space
    "backspace" -> Backspace
    "escape" -> Esc
    _ -> parse_fkey_or_char(tok, t)
  }
}

fn parse_fkey_or_char(original: String, lower: String) -> Key {
  case string.starts_with(lower, "f") {
    True -> {
      let n_str = string.drop_start(lower, 1)
      case int.parse(n_str) {
        Ok(n) -> FKey(n)
        Error(_) -> parse_char_like(original, lower)
      }
    }
    False -> parse_char_like(original, lower)
  }
}

fn parse_char_like(original: String, lower: String) -> Key {
  case string.starts_with(lower, "char:") {
    True -> Char(string.drop_start(original, 5))
    False ->
      case string.length(original) {
        1 -> Char(original)
        _ -> Unknown
      }
  }
}

pub fn key_to_string(key: Key) {
  case key {
    Backspace -> "Backspace"
    Left -> "Left"
    Right -> "Right"
    Up -> "Up"
    Down -> "Down"
    Home -> "Home"
    End -> "End"
    PageUp -> "PageUp"
    PageDown -> "PageDown"
    Tab -> "Tab"
    Delete -> "Delete"
    Insert -> "Insert"
    Enter -> "Enter"
    Space -> "Space"
    FKey(int) -> "F" <> int.to_string(int)
    Char(string) -> string
    Alt(key) -> "Alt + " <> key_to_string(key)
    Ctrl(key) -> "Ctrl + " <> key_to_string(key)
    Shift(key) -> "Shift + " <> key_to_string(key)
    Esc -> "Escape"
    Unknown -> "Unknown Key"
  }
}
