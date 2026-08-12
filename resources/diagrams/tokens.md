# Course diagram tokens

Every diagram copies this `:root` block. Change a value here → carry it to all
diagram files (they're standalone HTML, no shared stylesheet by design — each
file must render alone in Claude Design and export alone).

```css
:root{
  /* base = Notion dark, so exports blend into the notes */
  --bg:#191919; --panel:#202020; --panel2:#232323; --zone:#1E1E1E; --line:#373737;
  --text:#D3D3D3; --muted:#9B9B9B; --faint:#6B6B6B;
  /* semantic accents (carry meaning — never rotate) */
  --dbt:#FF694B;   /* dbt-mechanism under discussion (badge, config, dbt-side cables) */
  --duck:#F2C94C;  /* warehouse / storage (dev.duckdb, path cables) */
  /* THE course accent — Luke's blue. ⚠️ placeholder hex until Luke supplies his */
  --blue:#58A6FF;  /* chips, generic highlights — the only decorative color */
  /* status pair — pass/fail semantics ONLY (mirrors dbt's terminal OK/ERROR); never decorative */
  --ok:#57AB5A; --err:#E5534B;
  --mono:'Source Code Pro',ui-monospace,'SF Mono',Menlo,Consolas,monospace;
  --sans:ui-sans-serif,-apple-system,'Segoe UI',Inter,Helvetica,Arial,sans-serif;
}
```

Every file also imports the title/code font (silent fallback offline):

```css
@import url('https://fonts.googleapis.com/css2?family=Source+Code+Pro:wght@400;600;700;800&display=swap');
```

## ⚠️ VIDEO-FIRST RULES (Luke, 2026-08-10 — supersede anything below that conflicts)

These are YouTube video assets FIRST, notes assets second. Text must read
easily in a 1080p video frame.

1. **Title: centered, Source Code Pro, WHITE.** `width:1920px;text-align:center`,
   font-family var(--mono), weight 700, ~54px, color #FFFFFF, top ~40px.
   **NO accent bar under the title** (Luke, 2026-08-10: visually distracting —
   the section blocks below already do the structuring).
2. **NO subtitle line. NO footer/corner text. NO bottom hint/rules strips**
   (Luke, 2026-08-10: a third block of hints is TMI on screen). Diagram =
   the visual itself. Hint/summary/gotcha text belongs in the LESSON NOTES
   right next to the exported image — make sure the Concept Inventory row
   carries it, then cut it from the diagram. Luke narrates connective tissue.
3. **Minimum text size 18px. Body/annotations 21–24px.** The old 15–17px
   annotation sizes are banned. Chips ≥19px.
4. **Concise while thorough:** annotations ≤ ~8 words, one clause, no
   parentheticals stacking. Spend freed space on BIGGER text, not more words.
5. **Fill the frame.** Scale panels/cards up to use the 1920×1080 stage —
   no large dead zones.
6. **Symbols over words (Luke, 2026-08-10).** Lean on emoji/symbols to convey
   meaning visually wherever a symbol is self-evident — 📄 file, 📁 folder,
   🗄 stored data, ⚙️ compute, ⚡ fast, ⏳ waiting, 🔗 connection, ✓/✗ status,
   → flow. Prefer icon + ≤5 words over a words-only annotation; keep words
   where a symbol would be ambiguous.

## Type scale (video-first)

title 54/700 white centered · panel titles 32–36 · card names 25–28 mono
bold · code blocks 22–24 mono · annotations/captions 21–22 · chips 19–20 ·
absolute floor 18.

## Rules (decided with Luke, 2026-08-06)

- **One decorative color.** No section color-coding — all generic chips are
  `--blue`. Luke: "I'd rather just use my favorite color blue when possible."
- **Semantic colors are exceptions, not decoration:** dbt orange only when
  pointing at the dbt mechanism; DuckDB yellow only for warehouse/storage;
  --ok/--err only for real pass/fail.
- **Base is stolen from Notion dark, not complemented** — diagrams also live
  in the course notes; the frame must be invisible there. Export PNG @2x on
  `--bg`.
- **Connectors** (Luke's canvas edit is the spec): 3.5px, `stroke-dasharray:
  2 10`, `stroke-linecap: round`, routed AROUND cards, never across content.
  Color = the semantic color of what the cable carries.
- **Canvas:** 1920×1080 fixed stage (16:9 — Luke films his screen).
- **Filenames and paths are always mono.** Emoji as icons (📁 🗂️ 🏠) — no
  icon library.

## Naming + content rules (Luke, 2026-08-06)

- **Filenames are prefixed by the lesson video**: `1.2_anatomy_dbt_project.html`,
  `1.7_view_vs_table.html` — the number IS the lesson (X.Y).
- **NO lesson/topic numbers inside diagrams** — they churn with every
  restructure and go stale in recorded/exported assets. Luke calls numbers
  out while filming; Notion notes carry them. Diagrams stay evergreen.

## Workflow

1. Author/revise in this folder (one standalone .html per diagram, first line
   `<!-- @dsCard group="dbt Course Diagrams" -->`).
2. Push via DesignSync to the "dbt Course Diagrams" project
   (id fe7703d2-1895-4c7c-8d86-9aee62dbb0c8). Luke reviews/edits on the
   claude.ai/design canvas.
3. Pull canvas edits back (get_file) BEFORE any local revision — Luke's canvas
   changes are the spec (same live-state rule as Notion).
4. Tracker: "Diagrams - dbt" page under the Notion course hub; rows carry
   "## Diagrams Needed" sections.
