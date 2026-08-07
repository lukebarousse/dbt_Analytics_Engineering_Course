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
  --blue:#58A6FF;  /* chips, title bar, generic highlights — the only decorative color */
  /* status pair — pass/fail semantics ONLY (mirrors dbt's terminal OK/ERROR); never decorative */
  --ok:#57AB5A; --err:#E5534B;
  --mono:ui-monospace,'SF Mono',Menlo,Consolas,monospace;
  --sans:ui-sans-serif,-apple-system,'Segoe UI',Inter,Helvetica,Arial,sans-serif;
}
```

## Rules (decided with Luke, 2026-08-06)

- **One decorative color.** No section color-coding — all lesson chips are
  `--blue`. Luke: "I'd rather just use my favorite color blue when possible."
- **Semantic colors are exceptions, not decoration:** dbt orange only when
  pointing at the dbt mechanism; DuckDB yellow only for warehouse/storage.
- **Base is stolen from Notion dark, not complemented** — diagrams live in the
  course notes; the frame must be invisible there. Export PNG @2x on `--bg`.
- **Connectors** (Luke's canvas edit is the spec): 3.5px, `stroke-dasharray:
  2 10`, `stroke-linecap: round`, routed AROUND cards, never across content.
  Color = the semantic color of what the cable carries.
- **Canvas:** 1920×1080 fixed stage. Type scale: title 46/800, card names
  23 mono bold, body 16.5, captions 15–16, chips 17 mono bold.
- **Filenames and paths are always mono.** Emoji as icons (📁 🗂️ 🏠) — no
  icon library.

## Naming + content rules (Luke, 2026-08-06)

- **Filenames are prefixed by the lesson video**: `1.2_anatomy_dbt_project.html`,
  `1.2_job_postings_folders.html` — the number IS the lesson (X.Y), so a
  diagram's home is readable at a glance in the repo and the Design pane.
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
