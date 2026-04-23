# Loops — Autonomous Project Evolution for Claude Code

A Claude Code plugin that evolves any project toward its final form. Each cycle: **test → triage → act → verify → commit**. Automatically picks the right action — fix, clean, or upgrade — based on what the project needs most right now.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/charleschenai/loops/main/install.sh | bash
```

Restart Claude Code after installing.

## Usage

```
/evolve [count] [target]
```

| Argument | Description |
|----------|-------------|
| `count` | Number of iterations. Omit for infinite (runs until nothing left). |
| `target` | Directory to evolve. Defaults to current working directory. |

### Examples

```
/evolve 10 ~/Desktop/codemap       # 10 evolution cycles on codemap
/evolve ~/Desktop/my-project        # evolve until final form
/evolve 5                           # 5 cycles on current directory
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
3. **Triage** — categorize findings by priority
4. **Research** — web search for best practices (upgrade mode)
5. **Pick ONE** — single highest-impact item
6. **Safety Check** — stops and asks if change is risky
7. **Implement** — focused, minimal change
8. **Validate** — codemap blast-radius and complexity check
9. **Verify** — re-run tests, confirm no regressions
10. **Log** — append to `EVOLUTION.log`
11. **Commit** — `fix:`, `clean:`, or `upgrade:` prefix

### Safety

- **Containment** — only modifies files inside the target directory
- **One change per cycle** — small, verifiable, reversible
- **Stops on risk** — asks the human before risky changes
- **Max 2 retries** — skips changes that fail twice

## Uninstall

```bash
bash ~/.claude/plugins/marketplaces/loops/install.sh --uninstall
```

## Changelog

All changes applied by `/evolve` on this project are tracked in [EVOLUTION.log](EVOLUTION.log).

### Releases

- **v2.0.0** — Unified `/evolve` skill (replaced separate `/upgradeloop`, `/fixloop`, `/cleanloop`). Added codemap integration, web research, and EVOLUTION.log tracking.
- **v1.0.0** — Initial release with `/upgradeloop` and `/fixloop` skills.
