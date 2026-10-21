// One-off QR login using login.mjs from c1overzz/dsh-bili-scroll (MIT): reads the cookies from the
// poll response's Set-Cookie headers and writes bili_credential.json in the format mcp_server.py reads.
import { loginStart, loginPoll, saveCredential, renderQrPng } from './login.mjs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { rmSync } from 'node:fs'

const here = dirname(fileURLToPath(import.meta.url))
const py = process.platform === 'win32' ? join(here, '.venv', 'Scripts', 'python.exe') : join(here, '.venv', 'bin', 'python')
const { key, url } = await loginStart()
const png = await renderQrPng(py, here, url)
console.log('QR:', png || '(no png)')
console.log('URL:', url)
for (let i = 0; i < 90; i++) {
  const r = await loginPoll(key)
  if (r.state === 'ok') {
    saveCredential(here, r.credential)
    try { rmSync(join(here, 'qrcode_login.png'), { force: true }) } catch {}
    console.log('LOGIN OK')
    process.exit(0)
  }
  if (r.state === 'expired') break
  if (r.state === 'scanned') console.log('scanned, waiting for confirm')
  if (r.state === 'unknown') { console.log('LOGIN PROBLEM:', r.message); process.exit(2) }
  await new Promise((res) => setTimeout(res, 2000))
}
try { rmSync(join(here, 'qrcode_login.png'), { force: true }) } catch {}
console.log('LOGIN TIMEOUT')
process.exit(1)
