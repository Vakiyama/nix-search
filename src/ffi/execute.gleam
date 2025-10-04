@external(javascript, "./execute_ffi.mjs", "execute")
pub fn execute(command: String, max_buffer_bytes: Int) -> Result(String, String)
