# Design System Strategy: The Quantitative Archive

## 1. Overview & Creative North Star
**Creative North Star: "The Sovereign Analyst"**
This design system rejects the cluttered, neon-soaked chaos of typical retail trading platforms. Instead, it adopts the "High-End Editorial" language of a private equity quarterly report combined with the brutal efficiency of a Bloomberg Terminal. 

We break the "standard template" look through **Intentional Asymmetry**. Dashboards should not be perfectly mirrored grids; rather, primary data (The Narrative) takes precedence in wide, expansive containers, while secondary metrics (The Metadata) are tucked into narrow, sophisticated side-bars. This creates a rhythmic hierarchy that guides the eye toward the most critical "P&L" realizations without visual fatigue.

## 2. Colors & Tonal Architecture
The palette is rooted in a "Deep Sea" dark mode, utilizing high-contrast accents to signal financial health.

*   **Primary Identity:** `primary` (#4edea3) is our "Emerald Profit." It is reserved for growth, successful executions, and positive equity curves.
*   **The Warning Signal:** `secondary` (#ff716a) is our "Crimson Loss." Use it sparingly but decisively to mark risk and drawdown.
*   **The Intelligence Layer:** `tertiary` (#699cff) serves as the "Muted Blue" for informational data, tooltips, and neutral market states.

### The "No-Line" Rule
**Strict Mandate:** 1px solid borders are prohibited for sectioning. 
Structure must be defined by background shifts. To separate a sidebar from a main feed, place a `surface_container_low` section against the `surface` background. This creates a sophisticated, "carved" look rather than a "boxed" look.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. 
*   **Base:** `background` (#060e20).
*   **Standard Cards:** `surface_container`.
*   **Nested Data Points:** `surface_container_high`.
By nesting darker containers within lighter ones (or vice versa), we create depth that feels architectural rather than accidental.

### The "Glass & Gradient" Rule
For floating elements like "Trade Entry" modals or "Quick Action" menus, use Glassmorphism. Apply `surface_container` with a 70% opacity and a `backdrop-blur` of 20px. 
*   **Signature Texture:** Use a subtle linear gradient from `primary` (#4edea3) to `primary_container` (#005236) at 15% opacity for the background of a "Winning Trade" card to give it a premium, holographic soul.

## 3. Typography: Precision over Personality
The system uses a dual-font strategy to balance editorial authority with mathematical precision.

*   **Display & Headlines (Space Grotesk):** This font brings a technical, slightly futuristic edge to large numbers and section titles (`display-lg` to `headline-sm`). Its wide apertures feel modern and "Terminal-esque."
*   **Body & Labels (Inter):** Chosen for its exceptional x-height and legibility in small sizes. Inter is used for all tabular data, trade logs, and "Label-sm" metadata. 
*   **Typographic Hierarchy:** Always lead with a `headline-md` for the total P&L, but use `label-sm` in `on_surface_variant` (#91aaeb) for the "Last Sync" timestamp to push it into the visual background.

## 4. Elevation & Depth
We eschew traditional drop shadows for **Tonal Layering**.

*   **The Layering Principle:** A "Positive P&L" card should simply be a `surface_container_highest` block sitting on a `surface` floor. The contrast in hex values provides the "lift."
*   **Ambient Shadows:** If a component *must* float (e.g., a dropdown), use a shadow with a 40px blur, 0% spread, and an opacity of 6% using the `on_tertiary_fixed_variant` color. This mimics a soft glow rather than a heavy shadow.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke (e.g., input fields), use `outline_variant` (#2b4680) at **20% opacity**. It should be felt, not seen.

## 5. Components

### Data Tables (The Core)
*   **Forbid Divider Lines:** Use `0.6rem` (spacing scale 3) of vertical padding between rows. 
*   **Alternating Tones:** Use a subtle shift between `surface` and `surface_container_low` for zebra-striping to guide the eye across the row without "caging" the data.

### KPI Cards
*   **Layout:** Large `display-sm` value top-left, `label-md` description bottom-left, and a micro-sparkline (using `primary` or `secondary`) taking up the right 30% of the card.
*   **Corner Radius:** Use `md` (0.375rem) for a sharp, professional "Terminal" feel.

### Screenshot Upload Areas
*   **Style:** Use a dashed "Ghost Border" using `outline`. 
*   **Interaction:** On drag-over, transition the background to `surface_bright` with a 10% `primary` tint.

### Performance Charts
*   **Line Charts:** Use a 2px stroke width. Fill the area under the curve with a gradient from `primary` (20% opacity) to `transparent` to create a "Glow" effect.
*   **Grid Lines:** Use `outline_variant` at 5% opacity. They should be nearly invisible, only appearing when the user focuses on the screen.

### Input Fields
*   **Base:** `surface_container_lowest`.
*   **Active State:** No change in border color; instead, the `on_surface_variant` label moves to a `primary` color and the background shifts to `surface_container_low`.

## 6. Do's and Don'ts

### Do:
*   **Embrace Negative Space:** Use spacing scale `12` (2.75rem) between major dashboard modules. High-end design requires room to breathe.
*   **Color as Data:** Only use `secondary` (#ee7d77) for losses. Never use it for "Close" buttons or "Delete" actions (use `on_surface_variant` for those).
*   **Monospace Numbers:** Ensure Inter's tabular num features are enabled so columns of numbers align perfectly.

### Don't:
*   **Don't use 100% white:** Use `on_background` (#dee5ff). Pure white (#FFFFFF) causes eye strain in a dark trading environment.
*   **Don't use rounded-xl:** Keep corners to `md` or `sm`. "Bubbly" corners degrade the professional, terminal-like authority of the system.
*   **Don't use "Grey":** Every neutral in this system is tinted with blue/charcoal. Avoid `#333333` or other dead greys; they look "cheap" next to our sophisticated palette.