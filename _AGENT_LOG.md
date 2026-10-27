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
- Students:
  - **Live Classroom Mode**: anonymous voter id (`poll-voter`), own live votes in `poll-votes`. Polling every 4 s. Students change votes until reveal.
  - **Practice / Self-Study Mode (Approach 1)**: triggered when presenter opens practice mode for the page. Questions are interactive self-tests; clicking answers yields immediate feedback (green/crimson option highlights, check/cross badge, chip status, automatic expansion of the "Why?" block, class lecture benchmarks if votes exist, and a "Try again" retry button).
  - **Zero Database Writes in Practice Mode**: all student practice attempts are stored locally in `localStorage` (`poll-practice-votes`). `cast_vote` is NEVER called, keeping the teacher's classroom dataset completely clean and unpolluted.
- Presenter: a persistent ⚙ gear in the navbar (`.quarto-navbar-tools`) is always visible on every page. Logged-in teachers see:
  - Current mode indicator (`🔴 Live Classroom` vs `🎓 Practice / Self-Study`).
  - One-click toggle: `[ 🎓 Open Practice Mode for Students ]` / `[ 🔴 Switch to Live Classroom ]`.
  - Checkbox: `Preview as student` to test the practice quiz directly in browser without logging out.
  - Action buttons: `[ Votes as CSV ]`, `[ Reset all polls on this page ]`, `[ Log out ]`.
- UI strings are English only.

**Polls currently in the content**
- `praktikum2/part1.qmd`: `p2-t1-sex` (1), `p2-t1-bmi` (3), `p2-t1-bmicat` (2),
  `p2-t1-teeth` (2), and multi-select `p2-t2-sex` (1), `p2-t2-attach` (2,3), `p2-t2-teeth` (2,3).
  The old "Task results" panels of Tasks 1–2 were removed; their content now lives in the
  `poll-explanation` blocks. The user asked for no tables or tip callouts in the "Why?"
  boxes – short explanation text only (plus the figures in Task 2).
- `praktikum2/part2.qmd`: Task 3 = `p2-t3` fill-in table (blanks: 199 and 6290).
  Task 4 = calc card `p2-t4` (RD, RR, OR) + `p2-t4-or` (3). Task 6 = calc card `p2-t6` (r)
  + `p2-t6-r` (2). Task 5 and the additional task still use a plain result panel.
- `praktikum3/praktikum3.qmd`: Ex 1 = calc card `p3-e1` (height CI bounds, mortstat mean)
  + `p3-e1-ci` (2). Ex 2 = multi-select `p3-e2-normal` (1 = height only). Ex 3 =
  `p3-e3-log` (2) and `p3-e3-n` (3, why N drops: ln(0)).
- Interpretation questions must not give away the numbers of the calc card above them.

**Calculation cards:** `::: {.poll-calc #id}` around a list of
`[Label]{.calc answer="1.88" tol="0.02" unit="%" mistakes="0.53: feedback | …"}`.
Votes: `<id>` (0 = all correct) and `<id>-k` per field (0 = right, 1..n = nth listed
mistake, n+1 = other). `unit="%"` also accepts proportions (0.12 → 12).

**Results before reveal:** nobody sees percentages/bars before Reveal – not even the logged-in
presenter (the screen is usually projected). The presenter sees only the submission count.

**Presenter-only panels:** `<details class="result-panel presenter-only" data-reveal-with="<poll-id>">`
is visible to logged-in teachers always, to students only once that poll is revealed (or in
practice mode). Convention: link it to the *last* question of the task, not the calc card.

### 2. Dopamine Studio design system conversion (`style.scss` & `index.qmd`)
- Overhauled the entire site styling to match `dopaminestudio.io`:
  - Deep black canvas (`#050505`) with a 48px grid overlay and ambient lighting.
  - High-voltage neon lime accents (`#ccff00`).
  - Space Grotesk for all titles, banners, headings, and cards with two-tone subtitle splits.
  - IBM Plex Mono for technical tags, numbers, kickers, code chips, buttons, and tables.
  - Removed the left sidebar / table of contents (`sidebar:` in `_quarto.yml`); consolidated practical navigation into a dark frosted glass dropdown menu under the top navbar.
  - Homepage hero redesigned with a two-tone title, neon kicker badge, pill buttons, and scannable QR ticket.
  - Complete dark mode overhaul for DataTables (`itables`) variable descriptions, interactive classroom polls, and fill-in tables.
  - Added a global theme toggle button in the navbar (`utilities/theme-toggle.html` & `utilities/theme-head.html`), saving `theme-mode` in `localStorage`.
  - Supports both the dark Dopamine Studio aesthetic (`#050505` with neon lime accents) and a crisp light mode (`#f8f9fb` off-white background with dark slate typography `#0f172a` and emerald accents).
  - Practical pages 1–6 updated with dark studio cards, neon accent dots, and dark callouts.
  - Added `.methods-card` & `.method-tag` / `.tag` component: converts bulleted method/topic lists into categorized interactive pill tag clouds (desktop 2-column grid, mobile stacked cards, neon/emerald dot indicators and hover glow).
  - Enhanced poll boxes and option styling: upgraded `div.poll` with frosted glass backdrop, electric hairline top gradient, pulsing live badge, tactile option tiles with interactive letter badges and right-hand selection indicators, animated telemetry bars with neon leading edges, and pill-styled vote count tags.

### 3. Open items / warnings
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
- Storing the actual typed values for fill-in tables (needs a schema change).
- Polls for Practical 2 Task 5 (trend direction) and Practicals 4–6.
- Practical 3 text says "kurtosis should be 3", but SPSS shows excess kurtosis (normal = 0); the user has not decided whether to change it.

## Presenter Bar & Poll Footers Redesign (Session Update)
- **Uninterrupted Flow**: Completely removed the in-page `.poll-praktikum-bar` that was previously inserted right before the first question of Task 1. Practical reading flow is now 100% natural and unhindered.
- **Floating Presenter Remote Dock (`#poll-presenter-dock`)**: Pinned at bottom-right (`position: fixed; bottom: 22px; right: 24px; z-index: 1080;`) using Dopamine Studio frosted glass. Shows current mode (`🔴 Live Classroom` vs `🎓 Practice Mode`), 1-click mode switcher button, CSV export, page reset, and a minimize button `—` that collapses into a tiny 40px corner indicator circle (`🔴`/`🎓`).
- **Navbar Status Badge (`.poll-navbar-badge`)**: Sits right in `.quarto-navbar-tools` at the top right of the fixed header. Pulsing red/cyan indicator dot, 1-click toggle between Live and Practice, and `⚙` dropdown for presenter settings.
- **Clean Poll Footers**: Removed all per-card "Set to Live" / "Set to Practice" buttons from poll card footers. Footers only display `[ Reveal results ]` / `[ Hide results ]` and `[ ↺ Reset ]`.
- **Student Preview Banner (`.poll-preview-banner`)**: Floats at bottom-right when previewing as student with a 1-click "Exit Preview" button.
- **Strict Per-Practical Scope Isolation**: Each practical maps to its own independent session row in Supabase (`session-p1`, `session-p2`, `session-p3`, `session-p4`, `session-p5`, `session-p6`). Setting Practical 2 to Practice mode after class only updates `session-p2` and `p2-*` polls; Practicals 1, 3, 4, 5, 6 remain completely unaffected. Surfaced explicit scope badges (`[P2]`, `Practical 2: Live Classroom`, `[ Set P2 to Practice ]`, and `P2 · Live`) in both the floating dock and top navbar so the presenter always knows exactly which practical is being controlled.
- **Removed Hat & Ball Emojis**: Removed all `🎓` and `🔴` emojis from mode badges, dock buttons, navbar, and modals. Mode status is indicated solely by clean typography and the animated **beating dot** (pulsing red for Live, pulsing cyan for Practice).
- **Consolidated Switch Locations (2-Tier Standard UX)**: Eliminated the 3rd duplicate toggle button from the navbar. The navbar pill (`P2 · Live`) is now purely an informational status indicator that opens the `⚙` drawer on click. The mode switch button now lives in exactly 2 standard places: (1) The **Floating Remote Dock** for quick 1-click action during class, and (2) Inside the **Presenter Menu Drawer (`⚙`)** for administrative settings.
- **Unified Exercise Card Boxes Across All Practicals**:
  - Replaced all instances of "Task" with "Exercise" across all practicals (`## Exercise 1`, `## Exercise 2`, `<summary>Exercise results</summary>`).
  - Standardized exercise headings in Practical 3 and Practical 4 from `###` to `##`, bringing all exercises into the signature Dopamine Studio card boxes (`section.level2`) with glowing accent dots, frosted glass backdrops, and rounded corners.
  - Enhanced `style.scss` so sub-exercises (`section.level2 section.level3`, e.g. Exercise 1.1 in P5 & P6) render as crisp nested sub-cards.
  - Upgraded solution accordions across all practicals to `.result-panel` with consistent interactive styling in both dark and light modes.

## SPSS Stepper & Workflow Guide Design (Session Update)
- **New Stepper UI Component (`.spss-workflow`)**:
  - Transformed all disjointed, raw step text (`Step 1: Analyze...`, `Step 2: Assign...`) into unified, modern timeline cards following the Dopamine Studio design system.
  - Card features frosted glass backdrop, gradient accent top border (`#00ffcc` -> `#ccff00`), and a dedicated `.spss-workflow-header` with an `SPSS` badge and `Workflow Guide` label.
  - Sequential steps formatted via `<ol class="spss-steps">` with an automated vertical timeline connector line.
  - Each step item features an interactive glowing pill badge (`Step 1`, `Step 2`, ...) in monospace font (`IBM Plex Mono`) that scales and glows on hover.
  - Content area displays menu breadcrumb chips (`.step` + `.arrow`), variable codes (`<code>variable</code>`), dialog buttons (`.spss-button`), and formatted substep bullet lists (`.spss-substeps`).
- **Comprehensive Rollout Across All Practicals**:
  - Upgraded all step walkthroughs across Practical 2, Practical 3, Practical 4, Practical 5, and Practical 6.
  - Translated remaining German menu items in Practical 2 and Practical 4 into standard English SPSS menu paths (`Analyze` → `Compare Means` → `One-Sample T Test`, `Analyze` → `Nonparametric Tests` → `Legacy Dialogs` → `2 Independent Samples`, etc.).
  - Wrapped HTML blocks with ````{=html} ... ```` so Quarto/Pandoc parses them with 0 warnings.
  - Provided complete Dark and Light theme styling in `style.scss`.
