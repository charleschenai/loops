# Loops — Autonomous Project Evolution for Claude Code

A Claude Code plugin that evolves any project toward its final form. Each cycle: **test → triage → act → verify → commit**. Automatically picks the right action — fix, clean, or upgrade — based on what the project needs most right now.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/charleschenai/loops/main/install.sh | bash
```

Restart Claude Code after installing.

## Usage

```
/evolve [count] [target] [flags]
```

| Argument | Description |
|----------|-------------|
| `count` | Number of iterations. Omit for infinite (runs until nothing left). |
| `target` | Directory to evolve. Defaults to current working directory. |
| `--dry-run` | Scan and triage only — shows what it would do without making changes. |
| `--goals` | Pick evolution targets from a menu, then grind toward them autonomously. |
| `--resume` | Continue a previous run — reads EVOLUTION.log and .evolve-goals. |
| `--focus <subdir>` | Restrict scanning and changes to a subdirectory. |
| `--only <mode>` | Only act on one category: `fix`, `clean`, or `upgrade`. |

### Examples

```
/evolve 10 ~/Desktop/codemap         # 10 evolution cycles on codemap
/evolve ~/Desktop/my-project          # evolve until final form
/evolve 5                             # 5 cycles on current directory
/evolve --dry-run ~/Desktop/my-app    # preview without touching anything
/evolve --goals ~/Desktop/my-app      # pick goals, then grind
/evolve --resume ~/Desktop/my-app     # pick up where last session left off
/evolve --focus src/api ~/Desktop/app # only evolve the API subdirectory
```

## How It Works

Every cycle, the skill triages the project and acts on the **highest priority category**:

| Priority | Mode | What it does |
|----------|------|-------------|
| 1 | **Fix** | Crashes, compile errors, wrong output, failing tests |
| 2 | **Clean** | Dead files, unused functions, dead dependencies, commented-out code |
| 3 | **Upgrade** | Missing capabilities, better patterns, new features |

Fix first — a project with bugs shouldn't get new features. Clean second — a project with dead code shouldn't grow more code. Upgrade last — only add when the foundation is solid.

### Each Iteration

1. **Test** — run the project's test suite or exercise it end-to-end
2. **Deep Scan** — structural analysis with [codemap](https://github.com/charleschenai/codemap) (if available)
3. **Triage** — categorize findings by priority (security issues first)
4. **Research** — web search, wiki (AI/ML), context7 (frameworks), claude-mem (prior sessions)
5. **Pick ONE** — single highest-impact item
6. **Safety Check** — stops and asks if change is risky
7. **Implement** — focused, minimal change
8. **Validate** — codemap blast-radius and complexity check
9. **Verify** — re-run tests, confirm no regressions
10. **Log + Commit** — append to `EVOLUTION.log` and commit in one Bash call
11. **Report** — print progress, push every 20 iterations

### Safety

- **Containment** — only modifies files inside the target directory
- **One change per cycle** — small, verifiable, reversible
- **Stops on risk** — asks the human before risky changes
- **Max 2 retries** — skips changes that fail twice, reverts cleanly with `git checkout`
- **Batch push** — pushes every 20 iterations, not every commit
- **GitHub release** — creates a release on completion (if `gh` available and 3+ changes)
- **No test suite?** — adapts to build-only, CLI, library, or config/docs projects
- **Scope guard** — upgrades must align with the project's existing purpose
- **Parallel scanning** — dispatches subagents for large codebases (>500 files)
- **Security scanning** — catches hardcoded secrets, injection patterns, unsanitized inputs
- **Pre-flight checks** — refuses dirty working trees, warns on open PRs
- **Worktree isolation** — medium-risk changes tested in a git worktree before merging
- **Progress tracking** — visual task tracking via TaskCreate/TaskUpdate
- **Completion notification** — iMessage self-chat when long runs finish
- **Linter integration** — clippy, eslint, ruff, go vet
- **Dependency scanning** — npm/pip/cargo/go outdated checks

## Uninstall

```bash
bash ~/.claude/plugins/marketplaces/loops/install.sh --uninstall
```

### Check Installation

```bash
bash ~/.claude/plugins/marketplaces/loops/install.sh --check
```

## Changelog

All changes applied by `/evolve` on this project are tracked in [EVOLUTION.log](EVOLUTION.log).

### Releases

- **v2.4.0** — Self-evolved (round 4): `--only`, `--check`, dep scanning, linter integration, flag combos, worktree isolation, iMessage notification, rich commits.
- **v2.3.0** — Self-evolved (round 3): `--resume`, `--focus`, pre-flight checks, security scanning, task tracking, DOT graph cleanup.
- **v2.2.0** — Self-evolved (round 2): `--dry-run`, `--goals`, context7 docs, claude-mem, parallel scanning, scope guard.
- **v2.1.0** — Self-evolved: fixed step ordering bug, added batch push/GitHub releases, wiki search for AI/ML, test-suite fallback, updated flow diagram, README.
- **v2.0.0** — Unified `/evolve` skill (replaced separate `/upgradeloop`, `/fixloop`, `/cleanloop`). Added codemap integration, web research, and EVOLUTION.log tracking.
- **v1.0.0** — Initial release with `/upgradeloop` and `/fixloop` skills.
