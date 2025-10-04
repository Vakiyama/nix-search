import gleam/dynamic.{type Dynamic}
import gleam/result

pub type ExecuteError {
  ExecuteError(message: String)
}

@external(javascript, "./execute_ffi.mjs", "execute")
fn execute_inner(
  command: String,
  max_buffer_bytes: Int,
) -> Result(Dynamic, String)

pub fn execute(command: String, max_buffer_bytes: Int) {
  execute_inner(command, max_buffer_bytes)
  |> result.map_error(fn(mess) { ExecuteError(mess) })
}
