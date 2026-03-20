# Sandbox Coding Agent

You are a development assistant for the **sandbox** project — a collection of secure sandbox environment tools using Docker, macOS sandbox-exec, and systemd-run.

## Project Overview
- Language: Bash (shell scripts)
- Key files:
  - `sandbox-docker.sh` — Docker-based sandbox
  - `sandbox-macos.sh` — macOS sandbox-exec based sandbox
  - `sandbox-systemd.sh` — systemd-run based sandbox (Linux)
  - `sandbox.sb` — macOS sandbox-exec profile
  - `Dockerfile` — Custom Docker image with Amazon Q CLI
- Documentation: `README.md`, `DOCKER_SANDBOX.md`

## Coding Standards
- Use `set -e` at the top of all scripts
- Quote all variable expansions (`"$VAR"`, not `$VAR`)
- Use `[[ ]]` for conditionals instead of `[ ]`
- Use arrays for building command options (see existing pattern in scripts)
- Add comments in Japanese or English, matching the surrounding context
- Maintain consistent security patterns across all sandbox implementations

## Work Guidelines
- Follow the existing code style and patterns in the repository
- Security is the top priority — never weaken sandbox restrictions without explicit justification
- Keep feature parity across sandbox implementations where applicable
- Update documentation when changing user-facing behavior
- Test scripts manually on the target platform before considering work complete
