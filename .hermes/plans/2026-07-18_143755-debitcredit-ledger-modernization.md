# Implementation Plan — debitcredit-ledger Modernization (1.0.0)

- **Plan path:** `/home/dpaluy/Projects/debitcredit-ledger.modernization-design/.hermes/plans/2026-07-18_143755-debitcredit-ledger-modernization.md`
- **Approved design:** `docs/superpowers/specs/2026-07-18-debitcredit-ledger-modernization-design.md` (branch `modernization-design`, HEAD `fe43d2a`)
- **Canonical repo:** https://github.com/dpaluy/debitcredit-ledger (detached: `isFork` null/false, `parent` null, default branch `master`)
- **Mode:** Code Factory pilot. This plan is BOTH the modernization work order AND the controlled model-trial harness.
- **auto_merge:** false — human merge required for every PR, including the trial winner.
- **No RubyGems publish.** Publishing is a separate approval gate.

This plan assumes the implementer has no prior context. Every task lists exact paths, commands, and verification. Read this whole document before touching the repo.

---

## 0. Read-first contract (do before any code)

Implementer must read, in order:

1. This plan (whole document).
2. `docs/superpowers/specs/2026-07-18-debitcredit-ledger-modernization-design.md` — the approved design; the source of truth for scope.
3. `AGENTS.md` (after Slice A creates it) and `skills/debitcredit-ledger/SKILL.md`.
4. Existing source under `app/models/debitcredit/`, `db/migrate/`, `lib/debitcredit/`, `spec/` (old RSpec + fixtures — the behavioral reference for the Minitest conversion).

Non-negotiable invariants (repeat verbatim in `AGENTS.md`):

- Distribution/gem name: `debitcredit-ledger`. Ruby namespace: `Debitcredit`. Require path: `require "debitcredit"`. Do NOT rename the namespace or require path.
- `Debitcredit::VERSION = "1.0.0"` (reset).
- `spec.required_ruby_version = ">= 4.0"`, `spec.add_dependency "rails", ">= 8.0"`. NEVER add `< 5.0` Ruby or `< 9.0` Rails upper bounds anywhere (gemspec, Gemfile, CI matrix comments, README). Later compatible versions remain installable; CI matrix defines *verified* combos only.
- Preserve current ledger behavior. This is modernization, NOT hardening. Any behavior change is a bug. P0 hardening is deferred to GitHub Issues #2–#8.
- Fork attribution: Vitaly Kushner © (per `MIT-LICENSE`), MIT license preserved. README/changelog/gemspec metadata state this is a maintained fork/continuation of `vitaly/debitcredit`.
- No RubyGems release in this plan.

Environment verified available: Ruby 4.0.3, Bundler 4.0.14, Rails 8.1.3, sqlite3 gem 2.9.5, sqlite3 CLI 3.53.3, psql (PostgreSQL) 18.4, `pg` gem NOT installed (dev dep must be added), `gh` 2.96.0, `pi` 0.80.10, Cursor `agent` 2026.07.16. (Implementer must re-verify in its own session — versions drift.)

---

## 1. PM contract (acceptance summary)

End goal: ship a `debitcredit-ledger` 1.0.0 gem that builds, installs, requires as `"debitcredit"`, boots a Rails 8 API-only dummy app, and passes fixture-backed Minitest on SQLite and PostgreSQL — with no behavior change from the current engine — plus full CI, agent guidance, and a verified GitHub Issue backlog for all deferred hardening.

Non-goals / deferred (GitHub Issues #2–#8, already created and verified):

- MySQL adapter (#2)
- posted-entry immutability (#3)
- inverse-entry/concurrent-reversal hardening (#4)
- entry/item validation hardening incl. empty-entry and malformed-amount (#5)
- schema constraints / bigint identifiers (#6)
- concurrent account creation / balance-verification semantics (#7)
- idempotent posting + reconciliation (#8)

Acceptance criteria (from design §Acceptance Criteria; every item must have real command/output evidence):

1. Repo verified standalone after detachment (`gh repo view dpaluy/debitcredit-ledger --json isFork,parent` → `isFork: false`, `parent: null`).
2. `gem build debitcredit-ledger.gemspec` → `debitcredit-ledger-1.0.0.gem`, no warnings.
3. Gemspec Ruby/Rails bounds are lower-only; grep proves no `< 5.0` / `< 9.0` ceilings.
4. `require "debitcredit"` succeeds from the *installed* artifact (not just local load path).
5. Rails 8 API-only dummy app boots (`test/dummy`, `config.load_defaults 8.0`).
6. `DB=sqlite bundle exec rake test` passes. `DB=postgresql bundle exec rake test` passes.
7. No tracked RSpec/Travis references except historical prose. Grep evidence recorded.
8. Gem build + install smoke clean (install into a throwaway GEM_HOME, `require` works, `Debitcredit::VERSION == "1.0.0"`).
9. `AGENTS.md` + `skills/debitcredit-ledger/SKILL.md` present and internally consistent.
10. README + `CHANGELOG.md` identify maintained-fork status + attribution.
11. GitHub Issues enabled AND all 7 deferred-work issues (#2–#8) exist with verified URLs.
12. No publish.

Verification commands (canonical; record real output for each):

```
git rev-parse HEAD                              # record base SHA
gh repo view dpaluy/debitcredit-ledger --json isFork,parent,defaultBranchRef --jq '{isFork,parent:(.parent.nameWithOwner // null),defaultBranch:.defaultBranchRef.name}'
DB=sqlite      bundle exec rake test
DB=postgresql  bundle exec rake test
bundle exec rake style                          # or rubocop per Slice F
gem build debitcredit-ledger.gemspec
gem install --install-dir /tmp/dc-gemhouse --no-document ./pkg/debitcredit-ledger-1.0.0.gem
GEM_HOME=/tmp/dc-gemhouse ruby -e 'require "debitcredit"; abort "ver" unless Debitcredit::VERSION=="1.0.0"; puts Debitcredit::Entry'
bundle exec rake dummy:boot                     # Rails 8 dummy boot check (add task)
grep -RIn --exclude-dir=.git -e 'rspec' -e 'travis' -e 'byebug' . | grep -v -E 'CHANGELOG|README|historical'
gh issue list --repo dpaluy/debitcredit-ledger --state all --limit 20
```

Constraints / likely files:

- Rename: `debitcredit.gemspec` → `debitcredit-ledger.gemspec`; `CHANGELOG` → `CHANGELOG.md`.
- Delete: `.rspec`, `.travis.yml`, `spec/` tree, `spec/test_app/`.
- New: `test/` tree (Minitest), `test/dummy/` (Rails 8 app), `.github/workflows/`, `AGENTS.md`, `skills/debitcredit-ledger/SKILL.md`.
- Keep unchanged (historical migrations): `db/migrate/*.rb` content. Do NOT edit historical migrations. Engine migration install path unchanged.
- Keep: `app/models/debitcredit/**`, `lib/debitcredit/**`, `config/locales/en.yml`, `MIT-LICENSE`, `Rakefile` (rewritten), `Gemfile` (modernized).
- `docile`: keep unless proven behavior-neutral by the converted suite (design §Packaging). Default: keep.

Follow-ups split out: issues #2–#8; plus (out of scope here) RubyGems trusted-publishing setup, if/when publishing is approved.

---

## 2. Slice graph

The modernization is sliced so each slice has a commit boundary and verifiable evidence. Trial candidates implement ALL slices in one branch/worktree (the trial freezes the *full* implementation, see §3).

| Slice | One-line scope | Commit | Independently reviewable |
|-------|----------------|-------|--------------------------|
| A | Repo hygiene: gemspec rename+modernize, version reset, Gemfile cleanup, AGENTS.md + SKILL.md skeleton | yes | yes (builds metadata) |
| B | Remove Travis/byebug and RSpec runner integration; retain `spec/` as read-only behavioral source | yes | yes (legacy runner gone, source retained) |
| C | Build Rails 8 API-only `test/dummy` (DB=sqlite/postgresql) | yes | yes (boots) |
| D | Convert all 4 suites to fixture-backed Minitest under `test/`; prove parity, then delete `spec/`; Rakefile test task | yes | yes (sqlite green) |
| E | PostgreSQL wiring + green `DB=postgresql rake test` | yes | yes (pg green) |
| F | Rubocop/style + gem build/install/require smoke + package-contents check | yes | yes (smoke green) |
| G | GitHub Actions CI (matrix: Ruby 4.x × {sqlite,postgresql} + build/lint/require jobs) | yes | yes (CI green on push) |
| H | Docs: README rewrite, CHANGELOG.md rename+1.0.0 entry, attribution | yes | yes (prose review) |
| I | GitHub: enable Issues (already on) + verify 7 deferred issues #2–#8 exist | yes | yes (gh evidence) |
| J | Pilot process: model trial harness + retrospective (does NOT touch the gem repo) | n/a (out-of-repo) | yes (results.jsonl + retro) |

Ordering dependencies: A → B → C → D (red→green) → E → F → G → H, with I verifiable any time after A. J is out-of-repo and runs in parallel/after.

Each slice below uses TDD red-green where a test exists (D, E, F). Slices A, B, C, G, H, I are infrastructure/doc changes — verify by execution/command, not unit test.

---

## 3. Controlled model trial (Code Factory pilot) — Slice J

This is the first Code Factory pilot. The modernization (Slices A–I) is the frozen implementation task used to compare three developer routes. The trial itself adds NO code to the gem repo (no benchmark harness, no result files committed). All trial artifacts live OUTSIDE the repo.

### 3.1 What is frozen (constant across all candidates)

Before launch, commit this plan on `modernization-design`, require a clean worktree, resolve that commit once with `git rev-parse modernization-design^{commit}`, and write it to the out-of-repo trial manifest as `FROZEN_BASE_SHA`. Record the resolved 40-character value in each candidate's evidence row. Changing it to rescue a candidate invalidates the trial.

- **Base SHA:** the single `FROZEN_BASE_SHA` resolved after this plan is committed. It must contain approved design HEAD `fe43d2a` plus this plan. Confirm `git -C <worktree> rev-parse HEAD == "$FROZEN_BASE_SHA"` before each run.
- **Worker profile / role:** builder (`BUILD MODE`). Peer reviewer is the opposite worker, fresh session, blind.
- **Prompt bytes:** identical self-contained builder prompt (see §3.3). Run each candidate with its worktree as the current directory so the prompt needs no candidate-specific path or branch substitution.
- **Project instructions:** this plan file path + the approved design path, read-only.
- **Acceptance criteria:** §1 acceptance criteria (1)–(10) and (12). (11 is infra, verified by coordinator.)
- **Verification commands:** §1 verification command block. Same for all candidates.
- **Permissions / toolsets:** full read/write within the candidate's own worktree only; no push to `master`; no RubyGems publish; no force-push; `gh` read-only on the canonical repo until winner handoff.
- **Timeout / retry policy:** single attempt per candidate; bounded process wrapper (§3.5) terminates the run no later than the earlier of (a) a terminal `agent_settled`/completion event or (b) a hard wall of 45 minutes elapsed. No retries to rescue a candidate; a crash/timeout = failed hard gate.
- **Blind reviewer:** same opposite-worker profile/session config for all three; reviewer never sees candidate identity, route, cost, or duration.

### 3.2 Candidates (provider/model/effort vary; route/runtime is an explicit confound)

Disclose in EVERY result row and in the retrospective: this is a developer-route experiment, NOT a pure model-only comparison. The Grok candidate runs through Cursor Agent directly; Luna and GLM run through Pi. Runtime/tooling is a confound that cannot be separated from model quality by this trial.

| # | Candidate label (blind only) | Route | Provider | Model | Effort | Runtime | Smoke status |
|---|------------------------------|-------|----------|-------|--------|---------|--------------|
| C1 | (blind) | Pi | openai-codex | gpt-5.6-luna | xhigh | Pi 0.80.10 | ROUTE_OK (agent_settled emitted; failed to exit ≤150s — needs wrapper) |
| C2 | (blind) | Pi | zai-coding | glm-5.2 | max | Pi 0.80.10 | ROUTE_OK (same exit issue) |
| C3 | (blind) | Cursor Agent CLI | (direct) | cursor-grok-4.5-high | high | `agent` 2026.07.16 | ROUTE_OK; exited normally; init stream-json verified model `Cursor Grok 4.5 High` |

Command forms (verified against live `pi --help` and Cursor's official headless CLI docs; re-verify at run time):

- C1 (Pi): `pi --approve --mode json --no-session --model "openai-codex/gpt-5.6-luna:xhigh" --print "$(<\"$PROMPT_FILE\")"`
- C2 (Pi): `pi --approve --mode json --no-session --model "zai-coding/glm-5.2:max" --print "$(<\"$PROMPT_FILE\")"`
- C3 (Cursor): `agent -p --trust --force --output-format stream-json --model cursor-grok-4.5-high --workspace "$WORKTREE_PATH" "$(<\"$PROMPT_FILE\")"`

The coordinator launches every command with `cwd=$WORKTREE_PATH`. `PROMPT_FILE` is one coordinator-owned immutable file outside all worktrees; record its SHA-256 in the trial manifest before launch.

### 3.3 Builder prompt (identical bytes to all candidates)

The prompt is self-contained and uses only relative paths in the candidate's OWN current worktree. Save these exact bytes once outside the repo; do not render candidate-specific values into it:

```
You are a Code Factory builder in BUILD MODE implementing the debitcredit-ledger
modernization. Work ONLY in the current worktree. Do not inspect sibling worktrees.

Read in order, then implement:
  1. .hermes/plans/2026-07-18_143755-debitcredit-ledger-modernization.md
  2. docs/superpowers/specs/2026-07-18-debitcredit-ledger-modernization-design.md
  3. AGENTS.md (after you create it in Slice A)

Implement Slices A through I in order. Commit at each slice boundary with a clear
message. Do NOT push. Do NOT publish. Do NOT modify historical db/migrate files.

Invariants (non-negotiable):
- gem name debitcredit-ledger; require "debitcredit"; namespace Debitcredit.
- Debitcredit::VERSION = "1.0.0".
- required_ruby_version ">= 4.0"; rails ">= 8.0". NEVER add < 5.0 or < 9.0 ceilings.
- Preserve ledger behavior exactly. Modernization only. No hardening.
- Keep MIT-LICENSE attribution (Vitaly Kushner). State maintained-fork status in README/changelog/gemspec.

When done, run and record exact output of:
  git log --oneline "$(git merge-base HEAD modernization-design)"..HEAD
  DB=sqlite bundle exec rake test
  DB=postgresql bundle exec rake test
  bundle exec rake style        # or rubocop, per Slice F
  gem build debitcredit-ledger.gemspec
  smoke_dir="$(mktemp -d)"
  gem install --install-dir "$smoke_dir" --no-document ./pkg/debitcredit-ledger-1.0.0.gem
  GEM_HOME="$smoke_dir" ruby -e 'require "debitcredit"; abort "ver" unless Debitcredit::VERSION=="1.0.0"; puts Debitcredit::Entry'
  gh repo view dpaluy/debitcredit-ledger --json isFork,parent --jq '{isFork,parent:(.parent.nameWithOwner // null)}'
  gh issue list --repo dpaluy/debitcredit-ledger --state all --limit 20

Then print a final JSON line on stdout: {"done":true,"head_sha":"<40-char>","slices":[...]}.
Do not review or judge your own work. Stop after emitting the done line.
```

### 3.4 Worktree setup (three isolated, same base SHA)

For each candidate, from a coordinator shell OUTSIDE all three worktrees:

```
REPO=/home/dpaluy/Projects/debitcredit-ledger.modernization-design
PARENT=/home/dpaluy/Projects/debitcredit-ledger            # master worktree (do not build here)
test -z "$(git -C "$REPO" status --porcelain)"             # plan must already be committed
FROZEN_BASE_SHA="$(git -C "$REPO" rev-parse 'modernization-design^{commit}')"

# candidate worktrees (names are BLIND labels; do not encode provider/model)
for c in c1 c2 c3; do
  wt=/home/dpaluy/Projects/dc-trial.$c
  git -C "$REPO" worktree add -b trial/$c "$wt" "$FROZEN_BASE_SHA"
  test "$(git -C "$wt" rev-parse HEAD)" = "$FROZEN_BASE_SHA"
done
```

Each candidate runs ONLY in its own `$wt`. A candidate must not read another candidate's branch/worktree/transcript/evidence.

### 3.5 Bounded process wrapper/monitor (outside the repo)

Pi 0.80.10 emits `agent_settled` but failed to exit within 150s for BOTH Pi routes. Cursor Agent exited normally. Design a wrapper that:

- Launches the candidate command with stdout+stderr teed to `<run_dir>/raw.log`.
- Captures JSONL stream events (for Cursor `stream-json`; for Pi `--mode json` or parsed text) into `<run_dir>/events.jsonl`.
- Terminates the process ONLY after: a terminal completion event is observed (`agent_settled` for Pi; final done message / `type:"result"` for Cursor stream-json) AND stdout has flushed the candidate's final `{"done":true,...}` line, OR the 45-minute hard wall is hit.
- On termination, writes `<run_dir>/meta.json` with: start_ts, end_ts, duration_seconds, exit_reason (`settled` | `wall_timeout` | `crash` | `manual`), final head SHA (from `git -C <wt> rev-parse HEAD`), and observed provider/model/effort strings parsed from events.
- Preserves `<run_dir>/raw.log`, `<run_dir>/events.jsonl`, and the candidate's recorded verification output as JSONL evidence.

Implementation note (coordinator-owned; NOT committed to the gem repo): a small Python or bash supervisor using `subprocess`/`timeout` + a line reader. Keep it in `~/.hermes/code-factory/model-trial/` (outside the repo). The wrapper's only job is lifecycle + evidence; it does not influence the candidate's code.

### 3.6 Hard gates (reject before ranking)

A candidate is rejected (cannot win) if ANY of:

- `git rev-parse HEAD` in its worktree equals `FROZEN_BASE_SHA` (no implementation commits) OR worktree is dirty at end.
- `DB=sqlite bundle exec rake test` exits non-zero.
- `DB=postgresql bundle exec rake test` exits non-zero.
- `bundle exec rake style`/rubocop exits non-zero with unresolved offenses.
- `gem build debitcredit-ledger.gemspec` emits warnings OR fails.
- `gem install` + `require "debitcredit"` smoke fails OR `Debitcredit::VERSION != "1.0.0"`.
- Grep finds `< 5.0` Ruby or `< 9.0` Rails ceiling, or RSpec/Travis/byebug tracked references (excluding historical prose).
- Blind review reports any UNRESOLVED critical or high finding.
- Actual provider/model/effort route is missing/unverifiable from evidence (per model-only-tournament rule).
- Scope is unauthorized (e.g., edited historical migrations, added hardening, published).

### 3.7 Blind review (same reviewer config for all three)

- Opposite worker, fresh session that did NOT build any candidate.
- Present candidates in a fixed blind order (C1, C2, C3) with identity/route/cost/duration stripped. Provide only: branch diff vs `FROZEN_BASE_SHA`, recorded verification output, `events.jsonl` (sanitized of model names), final head SHA.
- Reviewer applies §1 acceptance criteria + a rubric (correctness/completeness, defect/regression risk, simplicity/scope discipline, human correction required). Records findings counts: critical/high/medium.
- Reviewer verdict per candidate: ACCEPT | CHANGES_REQUIRED | BLOCKED, with the exact head SHA. Any later push invalidates the verdict.

### 3.8 Selection and handoff

- Only candidates passing ALL hard gates AND blind review with zero unresolved critical/high findings are rankable.
- Rank passing candidates by: (1) correctness/completeness, (2) defects/regression risk, (3) simplicity/scope discipline, (4) human correction required. Cost/latency are tie-breakers only.
- At most one candidate row may carry `winner: true`. If none passes, all rows are false and NO PR handoff occurs (escalate to human).
- Only the winner's branch advances into the normal PR flow: coordinator pushes the winner's branch to `origin` and opens ONE PR. The winner's PR then goes through ordinary independent review (fresh opposite-worker session) and human merge (`auto_merge: false`).
- Remove losing worktrees/branches AFTER the comparison record is appended and the winner PR is opened. Keep winner worktree until merge.
- Never merge as part of the trial.

### 3.9 Append-only evidence

Append EXACTLY ONE JSON object per candidate attempt to:

```
/home/dpaluy/.hermes/code-factory/model-trial/results.jsonl
```

(Canonical real-HOME path; NOT the shaper profile's remapped HOME.) Never rewrite/truncate/reorder/delete prior rows. Minimal fields:

```json
{"date":"<ISO-8601>","task":"debitcredit-ledger-modernization-1.0.0","task_class":"full-pr-implementation","base_sha":"<FROZEN_BASE_SHA>","profile":"developer-contract","provider_requested":"...","model_requested":"...","effort_requested":"...","provider_actual":"...","model_actual":"...","effort_actual":"...","route":"pi|cursor-direct","attempt":1,"retry_count":0,"head_sha":"<40-char>","checks":[{"command":"DB=sqlite bundle exec rake test","passed":true}],"acceptance_passed":true,"review_findings":{"critical":0,"high":0,"medium":0},"human_rescue":false,"cost":null,"duration_seconds":<int>,"winner":false,"runtime_confound":"Luna/GLM via Pi; Grok via Cursor Agent direct","notes":"..."}
```

Disclose the route/runtime confound in `runtime_confound` and `notes` for every row.

### 3.10 Retrospective (post-merge, Slice J close)

After the winner PR is MERGED (not just opened), produce a short retrospective capturing:

- Which route won and why (quality ranking, not cost).
- Runtime/tooling confound disclosure (Pi non-exit bug, Cursor direct runtime) and what CANNOT be claimed about model-only quality.
- Process lessons: worktree isolation effectiveness, wrapper reliability, blind-review feasibility, evidence completeness, where the frozen contract held vs slipped.
- Recommendations for the next Code Factory pilot (what to freeze harder, what wrapper fix is needed, whether to add a Kimi-K3 candidate).
Store the retrospective under `~/.hermes/code-factory/model-trial/` (out of repo). Do not commit it to the gem.

---

## 4. Slice A — Repo hygiene + gemspec + agent guidance

Goal: rename + modernize gemspec, reset version, clean Gemfile, commit AGENTS.md + skill skeleton. Build must still load.

Steps:

1. Candidate worktrees are already on `trial/<c>` from §3.4. For a non-trial fallback, branch `modernization` from the frozen implementation base recorded in the trial manifest.
2. `git mv debitcredit.gemspec debitcredit-ledger.gemspec`.
3. Rewrite `debitcredit-ledger.gemspec`:
   - `s.name = "debitcredit-ledger"`.
   - `s.version = Debitcredit::VERSION` (now 1.0.0).
   - `s.required_ruby_version = ">= 4.0"`.
   - `s.add_dependency "rails", ">= 8.0"`.
   - Keep `s.add_dependency "docile"` (per design; revisit only if Minitest suite proves removable).
   - Dev deps: `s.add_development_dependency "sqlite3"`, `s.add_development_dependency "pg"`, `s.add_development_dependency "minitest"`, `s.add_development_dependency "rubocop", "~> 1.88"` (or rubocop-minitest pack). Remove `rspec-rails`.
   - HTTPS homepage: `s.homepage = "https://github.com/dpaluy/debitcredit-ledger"`.
   - Metadata: `source_code_uri`, `bug_tracker_uri`, `changelog_uri`, `documentation_uri` all HTTPS to the canonical repo / `CHANGELOG.md`.
   - `s.metadata["rubygems_mfa_required"] = "true"`.
   - Distinct `s.summary` and `s.description`; description notes maintained fork/continuation of `vitaly/debitcredit`.
   - Deterministic `s.files`: keep `Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]`; explicitly exclude `test/`, `.github/`, `Gemfile.lock`, `*.gem`, `pkg/`, log/db/tmp.
   - Keep authors/email from original; preserve `s.license = "MIT"`.
4. Edit `lib/debitcredit/version.rb`: `Debitcredit::VERSION = "1.0.0"`.
5. Rewrite `Gemfile`: drop `byebug` group; `gemspec` only; optional comment that CI resolves Rails 8.x.
6. Delete `Gemfile.lock` and regenerate with `bundle lock` (Rails 8.x resolution). Commit the new lock.
7. Create root `AGENTS.md` (authoritative agent contract). Include every non-negotiable invariant from §0, the §1 verification command block, the fixture-backed-Minitest policy, the historical-migration-preservation rule, supported DBs (sqlite/postgresql), the no-upper-bounds policy, modernization-only scope, and a directive: "Read `skills/debitcredit-ledger/SKILL.md` before acting."
8. Create `skills/debitcredit-ledger/SKILL.md` with valid YAML frontmatter and the workflow sections from design §Repository Agent Guidance (setup; DB selection; dummy db prepare; focused/full Minitest; loader/migration checks; build/inspect gem; release prep without auto-publish).

TDD/verify (Slice A):

```
gem build debitcredit-ledger.gemspec           # builds debitcredit-ledger-1.0.0.gem, no warnings
grep -n 'required_ruby_version\|add_dependency "rails"' debitcredit-ledger.gemspec
ruby -e 'require "./lib/debitcredit/version"; puts Debitcredit::VERSION'   # => 1.0.0
! grep -RIn '< 5.0\|< 9.0' --include='*.gemspec' --include='Gemfile*' .
test -f AGENTS.md && test -f skills/debitcredit-ledger/SKILL.md
```

Commit: `git commit -m "Slice A: rename gemspec to debitcredit-ledger, reset version to 1.0.0, modernize metadata, add AGENTS.md and repo skill"`

---

## 5. Slice B — Remove obsolete runner integration; retain behavioral source

Goal: remove obsolete CI/debugger/RSpec runner integration without deleting the old specs or their fixtures. `spec/` remains a read-only behavioral reference until Slice D proves the fixture-backed Minitest port green.

Steps:

1. Delete `.rspec` and `.travis.yml`. Do NOT delete or edit `spec/` yet.
2. Remove RSpec references from `lib/debitcredit/engine.rb` (`g.test_framework :rspec` → `g.test_framework :minitest`).
3. Remove the RSpec rake loader from `Rakefile` (rewritten fully in Slice D).
4. Update `Rakefile`/`bin/rails` paths that referenced `spec/test_app` to point at `test/dummy` (done concretely in Slice C).
5. `.gitignore`: add `test/dummy/db/*.sqlite3*`, `test/dummy/log/*.log`, `test/dummy/tmp/`, `/pkg/`, `*.gem`. Defer removal of obsolete `spec/...` entries until Slice D deletes the legacy tree.

Verify (Slice B):

```
test ! -e .rspec && test ! -e .travis.yml && test -d spec/
! grep -RIn 'rspec\|travis\|byebug' app/ lib/ Rakefile Gemfile debitcredit-ledger.gemspec
```

(Note: `spec/` is intentionally allowed to contain RSpec until Slice D. Historical references in `README.md`/`CHANGELOG` are handled in Slice H; the grep above must be clean for active code/build files.)

Commit: `git commit -m "Slice B: remove Travis, byebug, and RSpec runner integration"`

---

## 6. Slice C — Rails 8 API-only dummy app at `test/dummy`

Goal: a minimal Rails 8 API-only app that boots, loads the engine via the local gem, holds only the host `User` model + schema, and selects DB via `DB=`. This replaces the deleted `spec/test_app`.

Steps:

1. Generate (or hand-write) a minimal Rails 8 app at `test/dummy`:
   - `test/dummy/config/application.rb`: `require "active_record/railtie"` (+ only railties the engine needs; skip action_view/action_mailer/active_job/action_cable/sprockets). `config.load_defaults 8.0`. `config.api_only = true`. `Bundler.require(*Rails.groups); require "debitcredit"`.
   - `test/dummy/config/boot.rb`: set `BUNDLE_GEMFILE` to the repo root `Gemfile`; push root `lib/` onto `$LOAD_PATH`.
   - `test/dummy/config/environment.rb`, `test/dummy/config.ru` (standard).
   - `test/dummy/config/environments/{development,test,production}.rb` (minimal; test env with `cache_classes`, `eager_load=false`, `public_file_server`).
   - `test/dummy/config/initializers/` only what's needed (none beyond defaults).
2. DB selection via `DB`:
   - `test/dummy/config/database.yml`: ERB that reads `ENV["DB"]` (default `sqlite`).
     - `sqlite`: adapter `sqlite3`, database `db/test.sqlite3`.
     - `postgresql`: adapter `postgresql`, using `ENV["DATABASE_URL"]` or PG env vars (`POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`) with CI-safe defaults (host `localhost`, user `postgres`, db `debitcredit_test`).
   - `test/dummy/db/migrate/20140121193940_create_users.rb` (mirror original: `create_table :users` with `name` + timestamps).
   - `test/dummy/db/schema.rb` regenerated from migrations (users + engine tables after migration install).
3. `test/dummy/app/models/user.rb`: copy original (`include Debitcredit::Extension`, `has_accounts { asset :cash ... }`, `has_entries { ... }`).
4. Engine migration install path: ensure `rake debitcredit:install:migrations` (engine task) copies engine migrations into `test/dummy/db/migrate`, then `db:migrate` builds `debitcredit_accounts`, `debitcredit_entries`, `debitcredit_items` (historical migration content unchanged).
5. Add a loader/boot check rake task (`lib/tasks/dummy_boot.rake` or in `Rakefile`): `rake dummy:boot` requires the dummy environment and prints `Rails::VERSION::STRING` + `Debitcredit::VERSION`; exit 0.
6. Rakefile rewritten to point `APP_RAKEFILE` at `test/dummy/Rakefile` (replaces the old `spec/test_app/Rakefile` pointer).

Verify (Slice C) — RED first (no test yet, expect boot to fail until deps resolve), then GREEN:

```
DB=sqlite bundle exec rake dummy:boot          # prints Rails 8.x + Debitcredit 1.0.0
DB=sqlite bundle exec rake debitcredit:install:migrations
DB=sqlite bundle exec rake db:migrate
DB=postgresql bundle exec rake db:setup        # after pg deps installed
```

Commit: `git commit -m "Slice C: add Rails 8 API-only dummy app at test/dummy with DB=sqlite/postgresql selection"`

---

## 7. Slice D — Convert 4 RSpec suites to fixture-backed Minitest

Goal: faithful Minitest port of `spec/models/debitcredit/{account,entry,extension,item}_spec.rb` + the `spec/support/*` helpers + fixtures, under `test/`. RED (failing ports) → GREEN. Preserves the behaviors enumerated in design §Minitest Conversion.

Source behaviors to cover (must all have Minitest assertions):

- account kinds + `Account.by_kind`
- account creation via associations; `Account[]` find/create/overdraft-toggle; `BadKind`/`NotFound`
- overdraft validation (disabled: prevent negative on decrease; allow increase/keep; enabled: allow negative)
- `total_balance` / `balanced?` (incl. `A+Ex = L+E+I` case)
- entry DSL: `kind`, `description`/`desc`, `reference`/`ref`; balanced/unbalanced validation
- account balance updates on `save!`; overdraft failure raises `ActiveRecord::RecordInvalid` and rolls back
- symbol-based account references via `reference.accounts`
- entry inverse: defaults (description, kind `rollback`, reference, parent_entry, ignore_overdraft), `inverse_entry` linkage, `parent_not_inversed`, inverted items
- item `inverse` (account/entry/amount retained; kind inverted; no mutation of source)
- extension `has_accounts`/`has_entries` proxy methods (`accounts.cash`, `accounts_method`, `entries[kind]`, `entries_method`)

Steps:

1. Mirror fixtures:
   - `test/fixtures/users.yml`, `test/fixtures/debitcredit/accounts.yml`, `test/fixtures/debitcredit/entries.yml`, `test/fixtures/debitcredit/items.yml` (copy `spec/fixtures/*` content verbatim, preserving the `reference: john (User)` polymorphic fixture refs and the balanced seed scenario: equipment 10000 / rent 0 / bank 100000 / salary 0 / amex 10000 / capital 100000).
2. `test/test_helper.rb`:
   - Set `ENV["RAILS_ENV"] ||= "test"`; require `test/dummy/config/environment`.
   - Push `test/dummy/db/migrate` onto `ActiveRecord::Migrator.migrations_paths`.
   - `ActiveRecord::Migration.maintain_test_schema!`.
   - `require "rails/test_help"` (fixtures, transactional fixtures).
   - `ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)`; `fixtures :all`.
3. Port helpers to Minitest modules (`test/support/`):
   - `RecordHelpers`: `described_class`, `_record`, `record` (use `define_method` helpers or explicit attr in each testcase; Minitest has no `let`). Provide a small `let`-shim if desired, but prefer explicit setup in `setup` blocks to keep it traditional Minitest.
   - `ValidFixtures`: port the `valid_fixtures` shared behavior as a module method/assertion helper usable from any test (e.g., `assert_valid_fixtures(Debitcredit::Account, count:)`).
4. Port the four suites to `test/models/debitcredit/{account,entry,extension,item}_test.rb` using `ActiveSupport::TestCase` / `assert` / `assert_raises` / `assert_equal`. Preserve every assertion from the RSpec originals; do not weaken or skip. Use normal Rails fixture accessors such as `users(:john)`, `debitcredit_accounts(:bank)`, and `debitcredit_entries(:laptop_purchase)`; if setup assigns convenience instance variables, do so explicitly rather than assuming Rails creates them.
5. Rakefile `test` task: `require "rake/testtask"`; `Rake::TestTask.new(:test) { |t| t.libs << "test"; t.pattern = "test/**/*_test.rb" }`. Default `task default: :test`.
6. Engine generator config in `lib/debitcredit/engine.rb`: `g.test_framework :minitest` (already set in Slice B), `g.fixture_replacement :fixture_hub` not needed (use Rails default fixtures).
7. Only after the complete SQLite Minitest port passes, delete the legacy `spec/` tree (including `spec/test_app/`) and remove its obsolete `.gitignore` entries. Re-run the full SQLite suite after deletion to prove the new harness is self-contained.

TDD red→green:

```
# RED: write the tests first (they fail because engine.rb/DB wiring may still need tweaks),
#      OR confirm they fail against a deliberately-broken assertion, then restore.
DB=sqlite bundle exec rake test                # → all green
```

Verify (Slice D):

```
DB=sqlite bundle exec rake test
# expect: N runs, 0 failures, 0 errors (N = total ported assertions across 4 suites)
test ! -e spec/
```

Commit: `git commit -m "Slice D: convert RSpec suites to fixture-backed Minitest (sqlite green)"`

---

## 8. Slice E — PostgreSQL green

Goal: `DB=postgresql bundle exec rake test` passes with zero changes to assertions.

Steps:

1. Ensure `pg` dev dependency is installed: `bundle install`.
2. Provision a local test DB (CI-safe defaults from Slice C): `psql` create role/db matching `database.yml` defaults, or set `DATABASE_URL=postgres://...`.
3. `DB=postgresql bundle exec rake debitcredit:install:migrations && DB=postgresql bundle exec rake db:migrate`.
4. `DB=postgresql bundle exec rake test`.

Pitfalls to handle (do NOT change assertions; fix wiring only):

- Decimal precision/scale identical (migrations already `precision: 20, scale: 2`).
- Boolean/null behavior differences: ensure fixtures bind correctly (Rails handles this).
- Any SQLite-ism in the dummy app (none expected; engine is vanilla AR).
- Ensure transactional fixtures work under pg.

Verify (Slice E):

```
DB=postgresql bundle exec rake test            # same N, 0 failures
```

Commit: `git commit -m "Slice E: verify fixture-backed Minitest green on PostgreSQL"`

---

## 9. Slice F — Style, gem build/install/require smoke, package contents

Goal: lint clean; gem builds warning-free; installed artifact requires correctly; package contents deterministic and design-compliant.

Steps:

1. Add `.rubocop.yml` (minimal: target Ruby 4.0, `require: rubocop-minitest`, disable cops that fight Rails engine conventions; keep style honest but not noisy). Add `rubocop` + `rubocop-minitest` dev deps (if not in Slice A).
2. `bundle exec rubocop` clean (autocreate offense-free code). Add `task :style => :rubocop` or `rake style`.
3. `gem build debitcredit-ledger.gemspec` → no warnings.
4. Package contents check:
   - `tar -tf pkg/debitcredit-ledger-1.0.0.gem` → must contain `metadata.gz`, `data.tar.gz`, `CHECKSUM`.
   - Extract `data.tar.gz`; assert it includes `lib/debitcredit.rb`, `lib/debitcredit/version.rb`, `lib/debitcredit/engine.rb`, `app/models/debitcredit/*.rb`, `db/migrate/*.rb`, `config/locales/en.yml`, `MIT-LICENSE`, `Rakefile`, `README.md`, `CHANGELOG.md`.
   - Assert it EXCLUDES `test/`, `.github/`, `Gemfile.lock`, `*.gem`, `pkg/`, `spec/`.
5. Install smoke (throwaway GEM_HOME):
   ```
   rm -rf /tmp/dc-gemhouse-<branch>
   gem install --install-dir /tmp/dc-gemhouse-<branch> --no-document ./pkg/debitcredit-ledger-1.0.0.gem
   GEM_HOME=/tmp/dc-gemhouse-<branch> ruby -e 'require "debitcredit"; abort "ver" unless Debitcredit::VERSION=="1.0.0"; puts Debitcredit::Entry; puts Debitcredit::Account'
   ```

Verify (Slice F):

```
bundle exec rake style                         # 0 offenses
gem build debitcredit-ledger.gemspec           # no warnings
# install smoke above prints Entry + Account constants, exits 0
```

Commit: `git commit -m "Slice F: rubocop, gem build/install/require smoke, deterministic package contents"`

---

## 10. Slice G — GitHub Actions CI

Goal: least-privilege workflows on PR + push. Matrix: Ruby 4.x × Rails 8 resolution, with SQLite and PostgreSQL. Plus build/lint/require jobs.

Steps:

1. `.github/workflows/ci.yml` (on `pull_request`, `push` to `master` and `modernization-design`):
   - Job `test` (matrix: `db: [sqlite, postgresql]`):
     - `runs-on: ubuntu-latest`, `services` postgres (only for the pg variant), checkout, `ruby/setup-ruby` with `ruby-version: 4.0` (or `.ruby-version`), `bundle install`, `bin/rails db:prepare` equivalent under `DB=$DB`, `DB=$DB bundle exec rake test`.
   - Job `style`: `bundle exec rake style` / `rubocop`.
   - Job `build`: `gem build debitcredit-ledger.gemspec` (warn on warnings via `-W`? gem build emits warnings to stderr; grep for "warning").
   - Job `install_smoke`: install gem into temp GEM_HOME, `require "debitcredit"`, version check.
   - Job `contents`: extract gem, assert inclusions/exclusions per Slice F.
   - Do NOT add a MySQL job (deferred — Issue #2).
2. Least-privilege: `permissions: contents: read` at workflow + job level. No secrets needed.
3. Matrix note in workflow comments: Ruby/Rails bounds are lower-only; CI verifies 4.x/8.x only.

Verify (Slice G): push the branch and confirm all jobs are green via `gh run watch` / `gh run view`. (For the trial, the coordinator pushes only the WINNER branch; candidates do not push.)

Commit: `git commit -m "Slice G: add least-privilege GitHub Actions CI (Ruby 4.x, sqlite+postgresql, build/lint/install)"`

---

## 11. Slice H — Docs: README + CHANGELOG rename + attribution

Goal: README rewritten; `CHANGELOG` → `CHANGELOG.md` with a 1.0.0 entry that accurately describes prior history without claiming unpublished versions were released to RubyGems; maintained-fork status clear.

Steps:

1. `git mv CHANGELOG CHANGELOG.md`.
2. `CHANGELOG.md`:
   - New `## 1.0.0 (2026-07-18)` section: "First release of the maintained `debitcredit-ledger` continuation. Modernization of the original `vitaly/debitcredit` (MIT) to Ruby 4.0+/Rails 8.0+ lower bounds, fixture-backed Minitest, SQLite + PostgreSQL CI. No ledger behavior changes."
   - Preserve prior history verbatim below, under a clear "Prior history (original vitaly/debitcredit)" heading. Do NOT claim 1.1.6 (etc.) was published to RubyGems.
3. README rewrite (design §Documentation):
   - Install as `debitcredit-ledger`; unchanged `require "debitcredit"` + namespace.
   - Rails 8.0+/Ruby 4.0+ lower-bound policy; verified CI combos vs installable.
   - SQLite + PostgreSQL support; `DB=` selection.
   - Migration install (`rake debitcredit:install:migrations db:migrate`).
   - Maintained-fork statement + Vitaly Kushner attribution + MIT.
   - Drop the Travis/CodeClimate badges.
4. Keep the accounting-domain explainer prose (Account Types, Debits/Credits, Accounting Equation) — it's still accurate.

Verify (Slice H):

```
test -f CHANGELOG.md && ! test -e CHANGELOG
grep -in 'maintained fork\|continuation\|vitaly\|MIT' README.md CHANGELOG.md debitcredit-ledger.gemspec
! grep -RIn 'travis\|codeclimate' README.md
```

Commit: `git commit -m "Slice H: rewrite README and CHANGELOG.md for 1.0.0 with maintained-fork attribution"`

---

## 12. Slice I — GitHub Issues enablement + verify 7 deferred issues

State at plan time (verified): GitHub Issues is ENABLED on `dpaluy/debitcredit-ledger`, and all 7 deferred-work issues already exist as #2–#8:

- #2 Add MySQL support and CI coverage
- #3 Prevent posted entries and items from mutating or being destroyed
- #4 Harden inverse-entry validation and concurrent reversal handling
- #5 Strengthen entry and item validation
- #6 Modernize ledger schema constraints and identifier widths
- #7 Harden concurrent account creation and balance verification
- #8 Add idempotent posting and ledger reconciliation

Each must contain motivation, current evidence, proposed acceptance criteria, and the modernization release boundary (design §GitHub Issues). Verify content at run time; if any issue body is thin, edit it to satisfy the design (this is the one GitHub-side edit allowed in this plan).

Steps / verify:

```
# enablement (idempotent; already on):
gh repo edit dpaluy/debitcredit-ledger --enable-issues=true

# presence + bodies:
gh issue list --repo dpaluy/debitcredit-ledger --state all --limit 20
for n in 2 3 4 5 6 7 8; do gh issue view $n --repo dpaluy/debitcredit-ledger | head -40; done
```

Record the 7 issue URLs in the PR description and in the trial evidence.

Commit: none (GitHub-side). But add a line to README/CHANGELOG referencing the issue backlog, committed within Slice H's commit or a tiny follow-up commit `Slice I: reference deferred-work issue backlog`.

---

## 13. Final pre-PR verification (builder runs; coordinator re-runs on winner)

Record real output for every command. All must pass.

```
git rev-parse HEAD
git status --short                           # clean
gh repo view dpaluy/debitcredit-ledger --json isFork,parent,defaultBranchRef --jq '{isFork,parent:(.parent.nameWithOwner // null),defaultBranch:.defaultBranchRef.name}'
DB=sqlite      bundle exec rake test
DB=postgresql  bundle exec rake test
bundle exec rake style
gem build debitcredit-ledger.gemspec
gem install --install-dir /tmp/dc-gemhouse-final --no-document ./pkg/debitcredit-ledger-1.0.0.gem
GEM_HOME=/tmp/dc-gemhouse-final ruby -e 'require "debitcredit"; abort unless Debitcredit::VERSION=="1.0.0"; puts Debitcredit::Entry'
bundle exec rake dummy:boot
! grep -RIn --exclude-dir=.git -e 'rspec' -e 'travis' -e 'byebug' app/ lib/ test/ Rakefile Gemfile debitcredit-ledger.gemspec
! grep -RIn '< 5.0\|< 9.0' --include='*.gemspec' --include='Gemfile*' .
gh issue list --repo dpaluy/debitcredit-ledger --state all --limit 20
```

---

## 14. Trial → PR handoff (coordinator only)

After §3 trial completes and a winner is selected:

1. Coordinator pushes ONLY the winner's branch: `git -C <winner_wt> push origin trial/<winner>:refs/heads/modernization` (or a feature branch name).
2. Coordinator opens ONE PR via `gh pr create` against `master`, body includes:
   - Summary of all slices.
   - The 7 deferred-issue URLs (#2–#8).
   - Winner's recorded verification output (§13).
   - Statement: maintained fork of `vitaly/debitcredit`; no behavior changes; no publish.
   - "Replaces: " references to the trial (internal; not part of PR prose if reviewer must stay blind).
3. The winner PR goes through ordinary independent review: fresh opposite-worker session, exact head SHA recorded, verdict ACCEPT/CHANGES_REQUIRED/BLOCKED. `auto_merge: false` → human merges.
4. After merge: remove losing worktrees/branches; write §3.10 retrospective; append results.jsonl is already complete.

---

## 15. Risks / open questions (flag, do not block)

- `pg` gem was not in the local gem list at plan time; builder must `bundle install` it. If the native build fails, fall back to a CI-only pg run and mark local pg as best-effort — but CI pg MUST pass (acceptance criterion).
- Rails 8.1 is the resolved version locally (8.0 lower bound). CI should pin/verify a concrete 8.x; document verified-vs-installable in README.
- The dummy app's `manifest.js` asset config is not needed for API-only; omit it.
- If `docile` removal is attempted, it MUST be proven behavior-neutral by the full Minitest suite on BOTH DBs first; otherwise keep it. Default: keep.
- Historical migrations use `Migration[4.2]`; do NOT bump to `[8.0]` (preservation rule). New dummy app migration should use `[8.0]`.
- If GitHub Actions postgres service needs a specific DB/user, match `database.yml` pg defaults exactly.

---

## 16. Out of scope (do not do)

- Any ledger behavior change, hardening, new constraints, immutability, idempotency, reconciliation (Issues #2–#8).
- RubyGems publish.
- MySQL CI (Issue #2).
- Editing historical `db/migrate/*.rb`.
- Adding `< 5.0` / `< 9.0` ceilings.
- Benchmark harness or result files inside the repo.
- Closing issues or writing final lessons before the winner PR is merged.
