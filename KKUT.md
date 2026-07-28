# Native build maintenance

- Treat `version.json` as the canonical native-stack version.
- Keep all eight wrapper gitlinks reproducible and reachable from the `psydack` forks configured in `.gitmodules`.
- Do not commit CMake files injected into submodule worktrees; edit the overrides under `cmake/`.
- Build Windows releases with the static MSVC runtime and the hardening in `cmake/windows-hardening.cmake`.
- Validate x64 and x86 locally with export checks, functional tests, PE dependency inspection, and antivirus scanning.
- Let GitHub Actions produce Windows ARM64, Linux x64, and macOS universal artifacts.
- Never publish or consume a mixed-platform release assembled from different native commits.
- Push wrapper repositories before committing their updated gitlinks here.
