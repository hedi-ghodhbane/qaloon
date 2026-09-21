#!/usr/bin/env node
/**
 * Bundles the mushaf reference data for the app, from an Ertak checkout (where the word
 * map is turned into page files): `ERTAK=/path/to/ertak`, by default ../ertak.
 *
 *   Qaloon/Qaloon/Resources/qaloun-index.json  copy of src/lib/quran/qaloun-index.json
 *   Qaloon/Qaloon/Resources/layout.json        ayah line boxes for all 604 pages, compact:
 *       { "pages": [ [ [ayahId, surah, ayah, [[line,x1,y1,x2,y2], …], marker, words, texts], … ], … ] }   (index = page - 1)
 *       `marker` is the box [x1,y1,x2,y2] of the end-of-ayah sign ۝ on this page, or null
 *       when the ayah ends on another page (the app can leave it uncovered in hide mode).
 *       `words` are the ayah's word boxes on this page, [[w, line, x1, y1, x2, y2, kind], …]:
 *       kind 0 = a word, 1 = the rub' al-hizb star ۞ (never covered), 2 = the ayah's
 *       opening word (the prompt that word-hiding can leave visible).
 *       `texts` are the same words' spellings, one per row of `words`: what the app
 *       matches a recitation against when it follows the reader by ear.
 *
 * Run `npm run mushaf:build` in the Ertak checkout first so public/mushaf/qaloun exists.
 *
 * Run: node scripts/build-data.mjs
 */
import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const here = join(dirname(fileURLToPath(import.meta.url)), '..')
const root = process.env.ERTAK ?? join(here, '..', 'ertak')
const out = join(here, 'Qaloon', 'Qaloon', 'Resources')
mkdirSync(out, { recursive: true })

const index = JSON.parse(
  readFileSync(join(root, 'src', 'lib', 'quran', 'qaloun-index.json'), 'utf8'),
)
copyFileSync(
  join(root, 'src', 'lib', 'quran', 'qaloun-index.json'),
  join(out, 'qaloun-index.json'),
)

const RUB_EL_HIZB = '۞'
const HARAKAT = /[ً-ٰٟۖ-ۭ]/g

/**
 * kind and spelling of every word position of an ayah. kind: 1 for the star, 2
 * for the opening word, 0 otherwise. Word rows skip the basmala that opens a
 * surah's first ayah in the text, so row `w` is token `w - 1` counted after it.
 */
function wordInfo(a) {
  const tokens = a.t.split(/\s+/).filter(Boolean)
  const basmala =
    a.a === 1 &&
    a.s !== 9 &&
    tokens.length > 4 &&
    tokens[0].replace(HARAKAT, '') === 'بسم'
  const skip = basmala ? 4 : 0
  const kinds = new Map()
  const texts = new Map()
  let cued = false
  for (let i = skip; i < tokens.length; i++) {
    const w = i - skip + 1
    texts.set(w, tokens[i])
    if (tokens[i] === RUB_EL_HIZB) kinds.set(w, 1)
    else if (!cued) {
      kinds.set(w, 2)
      cued = true
    }
  }
  return { kinds, texts }
}

const pages = []
let wordRows = 0
for (let p = 1; p <= index.pages.length; p++) {
  const data = JSON.parse(
    readFileSync(join(root, 'public', 'mushaf', 'qaloun', `${p}.json`), 'utf8'),
  )
  // words: [ayahId, line, wordPosition, isMarker, x1, y1, x2, y2]
  const markers = new Map()
  const words = new Map()
  for (const w of data.words) {
    if (w[3] === 1) markers.set(w[0], w.slice(4, 8))
    else {
      const list = words.get(w[0]) ?? []
      list.push(w)
      words.set(w[0], list)
    }
  }
  pages.push(
    data.ayahs.map((a) => {
      const { kinds, texts } = wordInfo(a)
      const rows = (words.get(a.id) ?? [])
        .slice()
        .sort((u, v) => u[2] - v[2])
        .map((w) => [w[2], w[1], w[4], w[5], w[6], w[7], kinds.get(w[2]) ?? 0])
      wordRows += rows.length
      const spellings = rows.map((r) => texts.get(r[0]) ?? '')
      return [a.id, a.s, a.a, a.seg, markers.get(a.id) ?? null, rows, spellings]
    }),
  )
}
const json = JSON.stringify({ pages })
writeFileSync(join(out, 'layout.json'), json)
console.log(
  `layout.json: ${pages.length} pages, ${pages.reduce((n, p) => n + p.length, 0)} ayah rows, ${wordRows} word rows, ${(json.length / 1024).toFixed(0)} KB`,
)
