import { execSync } from 'child_process';
import { Ok, Error } from '../../gleam_stdlib/gleam.mjs'

export function execute(command, maxBufferBytes, done) {
  try  {
    const result = execSync(command, { maxBuffer: maxBufferBytes, encoding: "utf8", stdio: ["pipe", "pipe", "ignore"] })
    const parsed = JSON.parse(result)
    return new Ok(parsed)
  } catch(err) {
    return new Error(err.message)
  }
}
