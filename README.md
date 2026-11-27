# github-copilot-agents

Reusable GitHub Copilot CLI agents for enterprise Java development. The primary target is Java 25, but agents inspect the actual project toolchain and do not upgrade it automatically.

## Installation

The eight profiles work as a set. For one project, copy them from `.github/agents/` into the target project's `.github/agents/`. For user-wide installation on Linux or macOS, run the following from this repository.

```sh
./install.sh --dry-run
./install.sh
```

The installer uses `~/.copilot/agents/`, or `$COPILOT_HOME/agents/` when configured. It skips identical files and preserves existing definitions by default. Use `./install.sh --dry-run --overwrite` to preview replacing existing regular `.agent.md` files, then run `./install.sh --overwrite` if you want those replacements. If a flat `<agent-id>.md` already defines the same agent, move it aside yourself before installing the corresponding profile.

Restart Copilot and use `/agent` to verify discovery. Personal agents take precedence over repository agents with the same ID. To uninstall, check the installation output and remove only the agent files you installed. Keep other definitions and restore any profiles you backed up before replacing them.

## Usage

From your target project, run `copilot --agent=tech-lead` or open `copilot`, run `/agent` and select `tech-lead`. In a plain Copilot session, custom agents may be selected for individual tasks, so choose the tech lead explicitly to start the full workflow. Give it requirements and acceptance criteria using a prompt like this.

> Classify this task by risk and execute the tech-lead workflow for these requirements and acceptance criteria: [insert details]. Show the plan and request approval when required; report actual delegation and checks.

- **FAST** covers small changes with low risk, such as correcting a validation message and its test.
- **STANDARD** is the default and includes independent code and QA reviews. Adding an endpoint to an existing service can fit this mode.
- **CRITICAL** requires explicit approval before implementation and adds security review. A change to tenant authorization belongs here.

The lead revisits the risk if new evidence changes the scope or assumptions.

| Agent | Responsibility |
| --- | --- |
| tech-lead | Plan, delegate, triage, coordinate up to three local review/fix rounds, final checks |
| software-architect | Assess significant design choices and architectural trade-offs |
| java-developer | Implement, test and self-review |
| code-reviewer | Independent correctness and regression review |
| qa-engineer | Independent acceptance coverage and test review |
| security-reviewer | Security review for sensitive work |
| devops-reviewer | Review infrastructure, deployment, and pipeline configuration changes |
| ci-reviewer | Analyze supplied GitLab pipeline and MR evidence |

The lead consults the software architect for significant design choices and supplies the actual diff, baseline and acceptance criteria to reviewers. Independent reviewers submit their first assessments before seeing each other's conclusions. For a consequential disagreement, the lead asks the relevant specialists to respond to specific claims and evidence, then records the decision. The team favors designs that meet the requirements and stay easy to read, test, and change. Extra structure should solve a concrete problem. The lead brings unresolved consequential choices to the human.

For changes with operational impact, the lead adds the DevOps reviewer. It uses the diff and supplied evidence to check how the change will build, deploy, and run. It has access to read and search tools.

For GitLab CI review, the lead retrieves evidence using authorized read-only tools and passes it to the CI reviewer. With `glab` authenticated for the right host and project, examples include `glab mr view 42 --comments`, `glab ci get --merge-request=42 --with-job-details` and `glab ci trace 12345`. Check your version's help and confirm the project, pipeline and commit SHA before relying on the results. If evidence is missing or stale, the lead reports CI as pending or incomplete.

## Delegation, permissions and limits

Custom agents and subagent contexts are native CLI features. Ask explicitly for named subagents and inspect the session's activity and the `/tasks` view, where available, for actual invocations and results; a role mentioned in prose is not evidence. If parallel review is unavailable, run reviews sequentially. If delegation is unavailable, run separate fresh sessions with the appropriate `/agent` selections, give each reviewer the diff and criteria, and bring its findings back to the lead. Do not describe self-review as independent.

Where available, `/fleet` can be used to request parallel work, for example `/fleet Execute the approved plan with independent read-only reviews.` Use Plan Mode for planning and Autopilot only within your organization's permission policy; availability and behavior depend on CLI version. Do not allow concurrent writers to overlapping files. Instructions, risk classification, review rounds and approvals are best-effort model behavior, not deterministic guarantees. Hooks can enforce specific checks or permissions, but require careful policy review and are not enabled here. An external orchestrator would be needed to guarantee the full bounded workflow. Do not blanket-approve tools. Agents must not commit, push, merge, publish comments or change remote resources without explicit approval.

The tech lead, architect and CI reviewer require GPT-6.2 Sol; the other agents require GPT-6.1 Terra. All request high reasoning effort. These pinned versions require updates when newer models become available. Model availability depends on your plan and organization settings. Select a concrete session model rather than Auto when relying on per-agent model assignments; inspect actual task details to verify the models used. Required model policy prevents a silent fallback when a required model is unavailable; reasoning effort can still be overridden by session or per-agent settings. Independent contexts do not guarantee different models or independent conclusions. Do not send confidential code to unapproved services. Verify tests and findings yourself before final review and MR.

If agents are missing, restart CLI, check filenames, directory, home and `/agent`, and check for a personal agent shadowing a project agent. Update or consult your installed CLI's help if fields or commands are unsupported. The installer copies only the agent definitions.

References: [custom agents](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli), [CLI reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference), [hooks](https://docs.github.com/en/copilot/concepts/customizations/hooks).
