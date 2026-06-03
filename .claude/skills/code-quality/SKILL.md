---
name: code-quality
description: Run code quality checks (ruff lint, ruff format, pyright, pytest) on a directory and report findings by severity. Use when the user wants to audit code quality, check for type errors, lint issues, or run automated checks on a path. Accepts a directory path as argument. Triggers on requests like "check code quality", "run quality checks", "/code-quality apps/".
---

# Code Quality Review

Review code quality in the directory provided by the user.

## Instructions

1. **Choose review scope** — ask the user which mode, unless it is already clear from the request/argument:

   - **Review all** — every `.py` file in the given directory (or the repo, if none is given).
     ```bash
     # list the targets
     find <directory> -name '*.py' -not -path '*/migrations/*' -not -path '*/__pycache__/*'
     ```
   - **Review diff from main** — only the `.py` files changed against `main` (focus on the current branch's work).
     ```bash
     # list the targets (added/modified/renamed since the merge-base with main)
     git diff --name-only --diff-filter=ACMR main...HEAD -- '*.py' | grep -v '/migrations/'
     # also include changes not yet committed:
     git diff --name-only --diff-filter=ACMR -- '*.py' | grep -v '/migrations/'
     ```

   In both modes, exclude migrations, `__pycache__`, and generated files. The resulting set is the **`<targets>`** used in the next steps.

2. **Run automated checks**:
   ```bash
   uv run ruff check <targets>
   uv run ruff format --check <targets>
   uv run pyright <targets>
   uv run pytest <targets> -v
   ```
   - `<targets>` = the directory (*review all* mode) or the list of changed files (*review diff from main* mode).

3. **Manual review checklist**:
   - [ ] No `Any` types without justification
   - [ ] Proper error handling (no silent exceptions)
   - [ ] N+1 queries avoided (select_related/prefetch_related)
   - [ ] Forms have proper validation
   - [ ] Views return correct HTTP status codes
   - [ ] HTMX partials handle HX-Request header
   - [ ] Celery tasks are idempotent
   - [ ] Tests use factories, not raw object creation

4. **Report findings** organized by severity:
   - Critical (must fix)
   - Warning (should fix)
   - Suggestion (could improve)

---

> ⚠️ **Steps 5 to 7 below are OPTIONAL and opt-in.** Do not run them by default.
> After step 4, **ask the user** whether they want the extended legacy-code review
> (steps 5–6) and/or the specialized code review (step 7). Only proceed with the ones
> they explicitly approve; otherwise, stop at the step 4 report.

5. **Review legacy** (legacy-code assessment) — *optional, only if approved*

   Evaluate the reviewed files through recognized legacy-code methodologies — beyond lint.
   Use these lenses and **cite the reference** for each finding:

   | Lens | Reference |
   |---|---|
   | Legacy = code without tests; *seams*, *Sprout/Extract Method*, *Legacy Change Algorithm*, characterization tests | Feathers, *Working Effectively with Legacy Code* (2004) |
   | *Code smells* (Long Method, Duplicated Code, Primitive Obsession, Data Clump, Divergent Change, Shotgun Surgery, Switch Statements) | Fowler, *Refactoring* (2nd ed., 2018) |
   | SRP / OCP / DIP | Martin, *Clean Code* / *Agile Principles* |
   | Cognitive complexity (nesting) vs. cyclomatic | McCabe (1976); SonarSource *Cognitive Complexity* (2017) |
   | Coupling (Connascence: Position → Name) | Page-Jones |
   | Test quality | FIRST; AAA; Test Pyramid (Cohn) |

   - Assess file by file; classify findings by severity (Critical / Medium / Low) and **map each one to the reference** above.
   - Be honest: call out what is good (e.g. an extracted seam, a Sprout Method) **and** the real debt.

6. **Record the findings in the code** (not just in the report) — *optional, only if approved*

   For each criticism point, write a comment at the **exact location** in the code:

   ```python
   # TODO(<ISSUE-KEY> review): <criticism> — <methodology reference>
   ```

   This anchors the debt to the code and makes it trackable (it surfaces as `S1135` in SonarLint).
   Follow the repo's comment-language convention; re-run lint/format afterwards to make sure nothing broke.

7. **Ask about the specialized code review** — *optional, only if approved*

   At the end, **ask the user** whether they want to run the specialized (multi-agent, cloud) code review for a deeper analysis:
   - `/code-review ultra` — reviews the current local branch
   - `/code-review ultra <PR#>` — reviews a GitHub PR

   It is triggered **by the user** and is billed — you **cannot** launch it (not even via Bash). Just recommend it and explain how to trigger it.
