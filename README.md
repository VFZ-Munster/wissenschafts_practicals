# Practical Course: Quantitative Methods in Health Sciences

This repository contains the interactive course website for the SPSS practicals at the **Faculty of Medicine, University of Münster (Medizinische Fakultät, Universität Münster)**.

The website is built with [Quarto](https://quarto.org/) and styled with a custom design system inspired by [Dopamine Studio](https://www.dopaminestudio.io), featuring dual-mode theming (**Dark Studio** `#050505` with high-voltage neon lime `#ccff00`, and **Light Theme** `#f8f9fb` with slate `#0f172a` and emerald `#16a34a`), real-time classroom polls powered by Supabase, step-by-step SPSS instruction flows, countdown timers, and interactive mathematical components.

---

## Table of Contents

1. [Interactive Classroom Polls](#1-interactive-classroom-polls)
   - [Single-Choice Poll](#single-choice-poll)
   - [Multiple-Choice Poll](#multiple-choice-poll)
   - [Fill-in Table (Live Contingency Matrix)](#fill-in-table-live-contingency-matrix)
   - [Presenter Mode & Teacher Toolbar](#presenter-mode--teacher-toolbar)
2. [Instruction & Workflow Components](#2-instruction--workflow-components)
   - [SPSS Instruction Flow](#spss-instruction-flow)
   - [Task Results Accordion](#task-results-accordion)
   - [Topic & Methods Tag Cloud](#topic--methods-tag-cloud-methods-card)
3. [Mathematical & Formula Components](#3-mathematical--formula-components)
   - [Formula Grid & Cards](#formula-grid--cards)
   - [Step-by-Step Odds Ratio Breakdown](#step-by-step-odds-ratio-breakdown)
   - [Notation Legend Card](#notation-legend-card)
4. [Timer & QR Code Extensions](#4-timer--qr-code-extensions)
   - [Interactive Countdown Timer](#interactive-countdown-timer)
   - [Course QR Code Card](#course-qr-code-card)
5. [Page & Layout Components](#5-page--layout-components)
   - [Homepage Hero Section](#homepage-hero-section)
   - [Practicals Showcase Grid](#practicals-showcase-grid)
   - [Feature Cards](#feature-cards)
   - [Result Figure Containers](#result-figure-containers)
6. [Theming & Global Design System](#6-theming--global-design-system)
   - [Theme Switcher](#theme-switcher)
   - [Color Palette](#color-palette)
   - [Typography](#typography)
   - [Callouts & Alerts](#callouts--alerts)
   - [Interactive DataTables (itables)](#interactive-datatables-itables)
7. [Project Structure & Rendering](#7-project-structure--rendering)

---

## 1. Interactive Classroom Polls

Classroom polls turn any Quarto document into a real-time classroom response system. They are anonymous for students (tracked via a random UUID stored in `localStorage`) and synchronized with a Supabase PostgreSQL backend.

### Single-Choice Poll

Renders radio options for single-answer conceptual questions.

````markdown
::: {.poll #p2-t1-bmi correct="3"}
What is the level of measurement of **BMI**?

- Nominal
- Ordinal
- Scale (metric)

::: poll-explanation
**Scale** – BMI is a continuous measurement in kg/m²; values can be meaningfully added, subtracted and averaged.
:::
:::
````

- **Attributes**:
  - `#p2-t1-bmi`: Unique poll identifier across the database.
  - `correct="3"`: 1-based index of the correct answer (turns green with a `✓` upon reveal).
- **Sub-blocks**:
  - `::: poll-explanation ... :::`: Collapsed explanation block that automatically reveals under the question with a `💡 Why?` trigger once the teacher reveals answers.

---

### Multiple-Choice Poll

Allows students to select several answers ("select all that apply"). Votes are stored as an integer bitmask.

````markdown
::: {.poll #p2-t2-attach correct="2,3" multiple="true"}
Best graph for **mean attachment loss**?

- Bar chart
- Histogram
- Boxplot

::: poll-explanation
**Histogram and boxplot** – both work, because mean attachment loss is continuous: a histogram shows the distribution shape, while a boxplot summarizes median, spread, and outliers.
:::
:::
````

- **Attributes**:
  - `multiple="true"`: Enables checkboxes and a dedicated "Submit" / "Update answer" button.
  - `correct="2,3"`: Comma-separated list of 1-based correct choice indices.

---

### Fill-in Table (Live Contingency Matrix)

Transforms a standard Markdown table into an interactive mathematical calculation grid with live inputs, auto-calculated row and column totals, and real-time validation.

````markdown
::: {.poll-table #p2-t3}
Fill in the missing counts from your SPSS output. The totals are calculated automatically – check them against your output.

| diab         | perio2 = periodontitis | perio2 = no      | **Total** |
|--------------|------------------------|------------------|-----------|
| **diabetes** | [199]{.blank}          | 578              |           |
| **no**       | 988                    | [6290]{.blank}   |           |
| **Total**    |                        |                  |           |
:::
````

- **Key Features**:
  - Cells marked with `[199]{.blank}` become numeric text inputs with expected answers.
  - Empty cells in the last row and column automatically compute dynamic live sums as the student types.
  - Provides a **Submit** button; upon submission or teacher reveal, inputs display green checkmarks (`.poll-ok`) or red outlines (`.poll-bad`).

---

### Presenter Mode, Live Classroom & Self-Study Practice Mode

A persistent gear icon (`⚙`) is embedded on every page in the top right of the navigation bar, providing complete lifecycle management for both in-class lectures and post-class revision:

#### 1. Live Classroom Mode (During Lecture)
- **Synchronized Voting**: Students participate live in real-time. Votes are recorded in Supabase (`votes` table).
- **Hidden Telemetry**: Results and "Why?" explanation blocks remain concealed from students until the presenter chooses to reveal them.
- **Presenter Controls**:
  - **Live Vote Count**: Shows real-time submission counts across all active devices.
  - **Reveal / Hide Results**: Toggles whether students see the percentage telemetry bars and correct explanations.
  - **Votes as CSV**: One-click download of all raw vote records (timestamps, poll IDs, rounds, and selected answers) for teaching evaluation or research analysis.

#### 2. Practice / Self-Study Mode (On-Demand Post-Class Revision)
- **One-Click Activation**: At the conclusion of the lecture, the teacher clicks **`[ 🎓 Open Practice Mode for Students ]`** in the floating Presenter toolbar.
- **Self-Paced Student Quizzes**: When students open the practical website after class:
  - Questions are presented fresh and unanswered so students can test their own understanding.
  - Selecting an option triggers **instant client-side feedback**:
    - The student's choice is highlighted (green `✓` if correct, crimson `✗` if incorrect).
    - The correct answer is flagged with a green badge.
    - The **`💡 Why?` explanation panel** automatically unfolds with full reasoning.
    - If live votes were recorded during lecture, class telemetry benchmark bars are displayed (`Class results (28 votes in lecture)`), allowing students to compare their reasoning with their classmates.
    - A **`[ ↺ Try again ]`** button lets students clear their attempt and re-test themselves as many times as desired.
- **Zero Database Pollution**: All practice attempts are evaluated 100% locally in the browser (`localStorage`). **`cast_vote` is never called**, ensuring the live lecture dataset in Supabase remains completely clean, unaltered, and unpolluted by post-class clicks.
- **New Semester / Class Reset**: The teacher can click **`[ 🔴 Switch to Live Classroom ]`** or **`[ ↺ Reset all polls on this page ]`** to start a new round for the next semester while archiving past data.

---

## 2. Instruction & Workflow Components

### SPSS Instruction Flow

Displays software navigation breadcrumbs as styled pill badges connected by neon arrows.

```html
<div class="instruction-flow">
  <span class="step">ANALYSIEREN</span>
  <span class="arrow">→</span>
  <span class="step">DESKRIPTIVE STATISTIKEN</span>
  <span class="arrow">→</span>
  <span class="step">KREUZTABELLEN</span>
</div>
```

- In Dark Mode, steps render as translucent frosted pills with a subtle border and neon arrows.
- In Light Mode, steps render as crisp light gray badges (`#f1f5f9`) with high-contrast text and dark slate arrows.

---

### Task Results Accordion

Displays collapsible task solutions, tables, and SPSS output interpretations without spoiling the exercise upfront.

```html
<details class="result-panel">
<summary>Task results</summary>

Here is the detailed solution, SPSS output screenshot, or data summary.

</details>
```

- Uses a glass-styled card container with a custom neon disclosure indicator that rotates on open.

---

### Topic & Methods Tag Cloud (`.methods-card`)

Displays lesson methods, statistical techniques, and learning goals as categorized, interactive pill tag badges.

````html
<div class="methods-card">
  <div class="methods-card-head">
    <span class="methods-kicker"><span class="kicker-dot"></span> Methods applied today</span>
  </div>

  <div class="method-group">
    <div class="method-label">
      <strong>Graphical representations of quantitative variables</strong>
    </div>
    <div class="tag-cloud">
      <span class="method-tag">bar charts</span>
      <span class="method-tag">histograms</span>
      <span class="method-tag">boxplots</span>
      <span class="method-tag">Q–Q plots</span>
    </div>
  </div>

  <div class="method-group">
    <div class="method-label">
      <strong>Qualitative variables</strong>
    </div>
    <div class="tag-cloud">
      <span class="method-tag">cross-tabulations</span>
      <span class="method-tag">relative frequencies</span>
      <span class="method-tag">risk difference</span>
      <span class="method-tag">relative risk</span>
      <span class="method-tag">odds ratio</span>
    </div>
  </div>
</div>
````

- **Key Features**:
  - Automatically arranges category headers on the left and a wrapping flex tag cloud on the right on desktop, collapsing to stacked mobile cards on narrow viewports.
  - Interactive pill tags with glowing dot indicators (`&::before`) and subtle lift animations on hover.
  - Fully reactive to Dark Studio mode (neon hover glow `#ccff00`) and Light mode (emerald hover `#16a34a`).
  - Standalone tags can also be written in markdown anywhere using `[my tag]{.tag}` or `<span class="tag">my tag</span>`.

---

## 3. Mathematical & Formula Components

### Formula Grid & Cards

Presents statistical formulas in clean, side-by-side modular glass cards.

````markdown
::: {.formula-grid}
::: {.formula-card}
**Risk difference (RD)**

Subtract the percentage values:
$$
RD = p_{\text{diabetic w/ perio}} - p_{\text{non-diabetic w/ perio}}
$$
:::

::: {.formula-card}
**Relative risk (RR)**

Divide the percentage values:
$$
RR = \frac{p_{\text{diabetic w/ perio}}}{p_{\text{non-diabetic w/ perio}}}
$$
:::
:::
````

- For full-width formula presentations, use `::: {.formula-card .formula-card-wide}`.

---

### Step-by-Step Odds Ratio Breakdown

Visualizes multi-stage statistical derivations (e.g., odds for Group 1, odds for Group 2, and the combined cross-product odds ratio).

````markdown
::: {.odds-grid}
::: {.odds-step}
**Diabetic group**
$$
\text{Odds}_{\text{diabetic}} = \frac{a}{b}
$$
:::

::: {.odds-step}
**Non-diabetic group**
$$
\text{Odds}_{\text{non-diabetic}} = \frac{c}{d}
$$
:::
:::

::: {.odds-final}
**Final odds ratio**
$$
OR = \frac{a/b}{c/d} = \frac{a \times d}{b \times c}
$$
:::
````

---

### Notation Legend Card

Structured summary box defining mathematical variables and indices in contingency tables.

````markdown
::: {.notation-card}
**Notation**

| Symbol | Meaning |
|:------:|:--------|
| $a$ | Diabetics **with** periodontitis |
| $b$ | Diabetics **without** periodontitis |
| $c$ | Non-diabetics **with** periodontitis |
| $d$ | Non-diabetics **without** periodontitis |
:::
````

---

## 4. Timer & QR Code Extensions

### Interactive Countdown Timer

A client-side countdown timer extension (`_extensions/produnis/timer`) used for in-class exercises and timed practical assignments.

````markdown
::: {.timer #task1 seconds=300 starton=interaction}
:::
````

- **Parameters**:
  - `#task1`: Unique HTML ID for the timer instance.
  - `seconds=300`: Duration in seconds (e.g., 300 = 5 minutes).
  - `starton=interaction`: Automatically starts the countdown when the student scrolls to or interacts with the section. Use `starton=click` for manual start.

---

### Course QR Code Card

Generates an SVG/canvas QR code ticket linking students directly to the online practicals from mobile devices.

````markdown
::: {.qr-card}
::: {.qr-label}
Scan course link
:::
{{< qrcode https://vfz-munster.github.io/wissenschafts_practicals/ width=144 height=144 colorDark="#000000" colorLight="#ffffff" >}}

::: {.qr-url}
vfz-munster.github.io
:::
:::
````

---

## 5. Page & Layout Components

### Homepage Hero Section

The Dopamine Studio hero banner used on `index.qmd`.

````markdown
::: {.home-hero}
::: {.hero-copy}
::: {.home-kicker}
Quantitative Methods in Health Sciences
:::

```{=html}
<h1 class="hero-title">Practical Course.<br><span>Real data. Applied research.</span></h1>
```

Explore, analyze, and interpret real NHANES data while building a reproducible workflow for applied health research.

::: {.hero-actions}
[Start with Practical 1](praktikum1/praktikum1.qmd){.hero-button .primary}
[View Blackboard](blackboard.qmd){.hero-button}
:::
:::

::: {.hero-panel}
![](mfm-logo.svg){.hero-logo fig-alt="University of Münster logo"}
<!-- Embedded QR Card here -->
:::
:::
````

- **`.hero-button.primary`**: High-voltage neon accent button.
- **`.hero-button`**: Translucent frosted pill button with hover lift.

---

### Practicals Showcase Grid

Interactive editorial cards linking to each of the 6 practical modules on the homepage.

```html
<section class="practicals">
  <div class="practicals-head">
    <span class="practicals-kicker">Course content</span>
    <h2 class="practicals-title">Six practicals.<br><span>One dataset.</span></h2>
  </div>
  <div class="practicals-grid">
    <a class="practical-card" href="praktikum1/praktikum1.html">
      <div class="practical-top">
        <span class="practical-num">01 / 06</span>
        <span class="practical-arrow" aria-hidden="true">↗</span>
      </div>
      <h3>SPSS Setup.</h3>
      <p>Download, install and activate SPSS, and get connected to the university licence.</p>
      <div class="practical-tags"><span>Setup</span><span>SPSS</span></div>
    </a>
    <!-- Additional practical cards (02 to 06) -->
  </div>
</section>
```

---

### Feature Cards

Two-column overview cards highlighting datasets and research objectives.

````markdown
::: {.grid .home-grid}
::: {.g-col-12 .g-col-md-6 .feature-card}
### Data Analysis
We will use data from the [NHANES](https://wwwn.cdc.gov/nchs/nhanes/) (1999–2003) to describe the health status of the U.S. population.
:::

::: {.g-col-12 .g-col-md-6 .feature-card}
### The Dataset
The data is stored in `nhanes30.sav`, containing observed health variables, codings, and metadata.
:::
:::
````

---

### Result Figure Containers

Encloses plots and diagrams inside framed, high-contrast containers with auto-centered captions.

````markdown
::: {.result-figure}
![Bar plot displaying the distribution of the sex variable by category](bar_sex.png)
:::

<!-- For full-width figures: -->
::: {.result-figure .wide}
![Histogram showing the distribution of number of teeth by sex](histo_nteeth_sex.png)
:::
````

---

## 6. Theming & Global Design System

### Theme Switcher

The website includes a dual-theme engine:
- **Button**: Injected into the top navigation bar (`.theme-toggle-btn`) displaying `☀ Light` in Dark Mode and `☾ Dark` in Light Mode.
- **Zero-FOUC Head Script** (`utilities/theme-head.html`): Reads `localStorage.getItem('theme-mode')` synchronously before the DOM paints, preventing theme flickering.
- **Toggle Script** (`utilities/theme-toggle.html`): Handles clicks, toggles the `.theme-light` class on `<html>`, and saves user preference.

### Color Palette

| Token | Dark Studio Mode | Light Mode | Description |
|:------|:-----------------|:-----------|:------------|
| Canvas Background | `#050505` | `#f8f9fb` | Main page background with subtle 48px mesh grid |
| Card / Panel Background | `rgba(18, 18, 20, 0.75)` | `#ffffff` | Elevated cards and containers |
| Primary Accent | `#ccff00` (Electric Neon) | `#16a34a` (Emerald Green) | Active links, primary buttons, correct badges |
| Primary Headings | `#ffffff` | `#0f172a` (Deep Slate) | Page titles, `h1`–`h6`, card headings |
| Body Text | `rgba(255, 255, 255, 0.78)` | `#334155` (Slate Gray) | Paragraphs, documentation prose |
| Monospace Accent | `rgba(255, 255, 255, 0.6)` | `#64748b` (Muted Slate) | Kickers, metadata labels, code tags |
| Borders | `rgba(255, 255, 255, 0.1)` | `#e2e8f0` | Subtle hairline borders on panels and cards |

### Typography

- **Headings & Hero Titles**: [Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk) (`sans-serif`, geometric editorial aesthetic).
- **Body & Prose**: [Inter](https://fonts.google.com/specimen/Inter) (`sans-serif`, optimized for reading clarity).
- **Code, Kickers & Technical Badges**: [IBM Plex Mono](https://fonts.google.com/specimen/IBM+Plex+Mono) (`monospace`, precise numeric data).

### Callouts & Alerts

Quarto callouts (`callout-note`, `callout-tip`, `callout-important`, `callout-warning`, `callout-caution`) are styled as dark frosted cards with a solid neon accent stripe along the left margin and monospace headers.

````markdown
::: callout-tip
## Pro Tip
Keep your outcome variables consistently placed in columns when constructing contingency tables.
:::
````

### Interactive DataTables (itables)

Python code blocks utilizing `itables` render paged, searchable, and sortable tables. DataTables are styled with dark transparent rows, custom pagination buttons, and neon active page indicators in Dark Mode, while switching to clean bordered tables in Light Mode.

---

## 7. Project Structure & Rendering

### Directory Layout

```
.
├── _quarto.yml               # Quarto configuration (navbar, output-dir, includes)
├── style.scss                # Complete SCSS design system (Dark Studio + Light Theme)
├── index.qmd                 # Homepage with hero, QR ticket, and practical modules
├── render.sh                 # Build and preview helper script
├── mfm-logo.svg              # Münster Faculty of Medicine logo
├── nhanes30.sav              # Course SPSS dataset
├── blackboard.qmd            # Digital blackboard reference
├── confidence_interval.qmd   # Interactive CI explainer
├── pvalue.qmd                # Interactive p-value explainer
├── praktikum1/ – praktikum6/ # Practicals 1 to 6 (.qmd, figures, assets)
├── _extensions/
│   ├── produnis/timer        # Quarto timer filter
│   └── jmbuhr/qrcode         # Quarto QR code generator
├── utilities/
│   ├── poll.html             # Supabase classroom polls & presenter bar
│   ├── theme-head.html       # Zero-FOUC theme detector
│   └── theme-toggle.html     # Navbar theme switch button
└── docs/                     # Rendered static output (published via GitHub Pages)
```

### Rendering Instructions

To render the site locally without re-running long-running Python calculations:

```bash
# Render specific practical or page quickly
quarto render index.qmd --no-execute
quarto render praktikum2/praktikum2.qmd --no-execute

# Full site build and live preview
./render.sh
```

All rendered HTML, assets, and libraries are compiled directly into the [`docs/`](file:///Users/ignaleiva/Library/CloudStorage/GoogleDrive-ignacio.leiva.e@gmail.com/My%20Drive/Uni-Munster/practical/wissenschafts_practicals/docs) directory for automatic deployment on GitHub Pages.
