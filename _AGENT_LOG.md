# Agent log – live polls & site redesign

Handoff notes for the next agent. Last updated: 2026-10-27.
The `_` prefix keeps Quarto from rendering this file into the site.

## Project in one paragraph

Quarto website for the SPSS practicals (Uni Münster, Medizinische Fakultät).
English only (the German version and its render profile were removed on 2026-10-27).
Config: `_quarto.yml` → `docs/`.
`docs/` is the deployed output (GitHub Pages, repo `VFZ-Munster/wissenschafts_practicals`).
Pages like `praktikum2/praktikum2.qmd` include `part1.qmd` / `part2.qmd`; those parts are
included as plain text. Render with `./render.sh` (render + preview) or `quarto render <file>`.

## What was built (Oct 2026)

### 1. Live classroom polls (Practical 2)
- **Code:** `utilities/poll.html` – a single inline script + supabase-js 2.45.4 from jsDelivr,
  included on every page via `include-after-body` in `_quarto.yml`. It does nothing on
  pages without polls.
- **Backend:** Supabase project `ztjjlogcdhynfkifaqtp` (EU). URL + public anon key are hard-coded
  at the top of `utilities/poll.html` (the anon key is meant to be public). Never put the
  `service_role` key in the repo.
- **Schema:** `supabase/schema.sql` (already run by the user). Tables `teachers`, `polls`
  (`id, round, revealed`), `votes` (`poll_id, round, voter uuid, choice int 0–19`).
  RLS on; students only call the RPCs `cast_vote` and `poll_results`. `set_revealed` /
  `reset_poll` require `is_teacher()` (e-mail in `teachers`). Before reveal, students only get
  the total vote count, not the per-option counts.
- **Setup docs for the user:** `supabase/README.md`.

**Markdown syntax**
```markdown
::: {.poll #p2-t1-bmi correct="3"}          <!-- 1-based; "2,3" = several correct -->
Question text

- Option A
- Option B
- Option C

::: poll-explanation
Shown as "💡 Why?" only after the teacher reveals.
:::
:::
```
- `multiple="true"` → select-all-that-apply. The vote is stored as a **bitmask** in `choice`
  (DB check allows 0–19, so at most 4 options). NB: Pandoc emits it as a plain `multiple`
  attribute, not `data-multiple`; the script reads both.
- **Fill-in tables:** `::: {.poll-table #p2-t3}` around a Markdown table. Cells written as
  `[199]{.blank}` become inputs (the number is the answer). The last row and last column are
  computed totals. A submission casts votes on `<id>` (0 = all correct, 1 = not) and
  `<id>-k` per blank (0 = right, 1 = wrong). Only right/wrong is stored, not the typed value.

**Behaviour**
- Students: anonymous; the voter id is a random UUID in localStorage (`poll-voter`), and own
  votes are in `poll-votes`. Polling every 4 s. Students can change their vote until reveal.
- Presenter: open any poll page with `?presenter` once → remembered in localStorage
  (`poll-presenter`); `?presenter=off` clears it. A ⚙ gear in the navbar
  (`.quarto-navbar-tools`) opens the login panel. Logged-in teachers see live results +
  correct marks, Reveal/Hide, Reset (new round, old votes kept), and a CSV export.
- UI strings are English only.

**Polls currently in the content**
- `praktikum2/part1.qmd`: `p2-t1-sex` (1), `p2-t1-bmi` (3), `p2-t1-bmicat` (2),
  `p2-t1-teeth` (2), and multi-select `p2-t2-sex` (1), `p2-t2-attach` (2,3), `p2-t2-teeth` (2,3).
  The old "Task results" panels of Tasks 1–2 were removed; their content now lives in the
  `poll-explanation` blocks. The user asked for no tables or tip callouts in the "Why?"
  boxes – short explanation text only (plus the figures in Task 2).
- `praktikum2/part2.qmd`: Task 3 = `p2-t3` fill-in table (blanks: 199 and 6290).
  Tasks 4–6 still use the classic `<details class="result-panel">`.

### 2. Site-wide visual refresh (`style.scss`)
- Poll styles: section `// Classroom polls`, plus `// Fill-in tables`.
- `// Fresh look (all pages)` at the end of the file: gradient title banner for the first
  `h1` on practical pages, accent bars on part headings, every `section.level2` as a white
  rounded card, softer result panels, callouts and step chips. The home page is excluded via
  `main.content:not(:has(.home-hero))`.
- The user wants the fresh look on the whole site, not just Practical 2.

## Open items / warnings
- **Nothing is committed or pushed.** Branch `Igna`. The changes are in `_quarto.yml`,
  `style.scss`, `praktikum2/part1.qmd`, `praktikum2/part2.qmd`, `utilities/poll.html`,
  `supabase/`, and the rendered `docs/`. The `.DS_Store` changes are noise.
- **`supabase/README.md` ends with two password-like lines the user pasted.** They were told
  to delete them; don't commit them. Don't copy them anywhere.
- Test data in the DB: poll `zz-test` (from API tests; delete with
  `delete from polls where id = 'zz-test';`). `p2-t2-teeth` has one old single-choice test
  vote → the user should press Reset on it before class.
- The poll answers are visible in the page source (accepted trade-off).
- The presenter login/reveal flow could not be tested by the agent (needs the user's password);
  everything else was tested via curl against the RPCs and headless Chrome with a mocked
  `window.supabase`.

## How to test without touching real data
- **API as a student:**
  `curl -X POST "$URL/rest/v1/rpc/poll_results" -H "apikey: $KEY" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d '{"p_polls":["p2-t1-sex"]}'`
- **UI:** copy `docs/praktikum2/praktikum2.html` to a temporary `_test.html`, replace the
  supabase `<script src>` with a stub
  `window.supabase = {createClient: () => ({rpc: async () => ({data: [...]}), auth: {getSession: async () => ({data: {session: null}})}})}`,
  screenshot with headless Chrome (`--window-size=1300,9000`, no `#anchor` – anchors give blank
  shots), and delete the temp file afterwards. Headless Chrome won't go narrower than ~485 px.
- **Local server:** `python3 -m http.server 4321` from `docs/`. Remind the user about
  `?presenter` and Cmd+Shift+R (they hit both several times).

## Ideas the user may ask for next
- A "Reset all polls on this page" button in the presenter panel (offered, not built).
- Storing the actual typed values for fill-in tables (needs a schema change).
- Polls for Task 4 (OR interpretation) and Task 5 (trend direction).
