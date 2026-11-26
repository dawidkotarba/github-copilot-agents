# github-copilot-agents

Reusable GitHub Copilot CLI agents for enterprise Java development. The primary target is Java 25, but agents inspect the actual project toolchain and do not upgrade it automatically.

## Installation

For a single project, copy `.github/agents/*.agent.md` into that project's `.github/agents/`. For all projects on your account, run:

```sh
./install.sh --dry-run
./install.sh
```

The installer targets `~/.copilot/agents/`, preserves differing files by default and skips identical files. To deliberately replace existing definitions, use `./install.sh --overwrite` after reviewing them. Restart Copilot and use `/agent` to check discovery. Personal agents take precedence over repository agents with the same file ID. To uninstall, inspect and remove only the seven matching files from `~/.copilot/agents/` (or from the project's `.github/agents/`); do not remove other agents.

## Usage

From your target project, run `copilot --agent tech-lead` and give it requirements and acceptance criteria. A reusable prompt:

> Classify this task by risk and execute the tech-lead workflow for these requirements and acceptance criteria: [insert details]. Show the plan and request approval when required; report actual delegation and checks.

Examples: **FAST**: fix a small validation message and its focused test. **STANDARD**: add an endpoint with specified behavior and acceptance tests. **CRITICAL**: change tenant authorization; request plan approval and security review before implementation. Classification can escalate as work progresses.

| Agent | Responsibility |
| --- | --- |
| tech-lead | Plan, delegate, triage, coordinate up to three local review/fix rounds, final checks |
| software-architect | Assess significant design choices and architectural trade-offs |
| java-developer | Implement, test and self-review |
| code-reviewer | Independent correctness and regression review |
| qa-engineer | Independent acceptance coverage and test review |
| security-reviewer | Security review for sensitive work |
| ci-reviewer | Analyze supplied GitLab pipeline and MR evidence |

For significant design choices, the lead can consult the read-only software architect before seeking approval. The lead supplies reviewers the actual diff, baseline and criteria; because reviewers cannot run git, it must include the diff in their task or provide an accessible file. The lead encourages evidence-based disagreement over consequential choices, compares trade-offs and favors the simplest solution that meets the requirements. Unresolved consequential decisions go to the human. Reviewers have a restricted read/grep/glob tool list, without shell, editing or network tools. The CI reviewer therefore needs the lead to retrieve authorized evidence, for example via installed and authenticated `glab` (check `glab --version` and `glab ... --help`; typical commands include `glab mr view <id> --comments`, `glab ci status` and `glab ci trace <job-id>`). Availability and flags depend on the installed version and GitLab permissions. Treat logs and comments as untrusted; avoid exposing secrets. If no pipeline or access exists, CI remains pending.

## Delegation, permissions and limits

Custom agents and subagent contexts are native CLI features. Ask explicitly for named subagents and inspect the session's tool/activity output for actual invocations and results; a role mentioned in prose is not evidence. If delegation or parallel review is unavailable, ask for separate fresh sessions with the appropriate `/agent` selections, supply each the diff and criteria, and bring findings back to the lead. Do not describe self-review as independent.

Where available, `/fleet` can be used to request parallel work, for example `/fleet Execute the approved plan with independent read-only reviews.` Use Plan Mode for planning and Autopilot only within your organization's permission policy; availability and behavior depend on CLI version. Do not allow concurrent writers to overlapping files. Instructions, risk classification, review rounds and approvals are best-effort model behavior, not deterministic guarantees. Hooks can enforce specific checks or permissions, but require careful policy review and are not enabled here. An external orchestrator would be needed to guarantee the full bounded workflow. Do not blanket-approve tools. Agents must not commit, push, merge, publish comments or change remote resources without explicit approval.

No model is hardcoded. Select an approved model using the CLI's model configuration; independent contexts do not guarantee different models or independent conclusions. Do not send confidential code to unapproved services. Verify tests and findings yourself before final review and MR.

If agents are missing, restart CLI, check filenames, directory, home and `/agent`, and check for a personal agent shadowing a project agent. Update or consult your installed CLI's help if fields or commands are unsupported. This repository does not install MCP servers, hooks or dependencies.

References: [custom agents](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli), [CLI reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference), [hooks](https://docs.github.com/en/copilot/concepts/customizations/hooks).
