pub type InputError {
  InputError
}

@external(javascript, "./input_ffi.mjs", "input")
pub fn input(prompt: String) -> Result(String, InputError)
