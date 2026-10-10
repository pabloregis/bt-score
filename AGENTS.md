## Comandos

O Swift no WSL vem do `swiftly` e só entra no PATH de shells de login. Em shells não interativos, carregue antes:

```bash
. ~/.local/share/swiftly/env.sh
```

- Testes do motor (roda no WSL): `swift test --package-path ScoreEngine`
- Um teste só: `swift test --package-path ScoreEngine --filter <nome>`
- Projeto Xcode (só no macOS): `xcodegen generate` a partir do `project.yml`; o `.xcodeproj` não é versionado.

O app SwiftUI não compila no Linux. Ele é verificado pelo job macOS do CI (`.github/workflows/ci.yml`), que gera o projeto e compila o target watchOS a cada push.

## Agent skills

### Issue tracker

Issues e specs ficam no Linear. See `docs/agents/issue-tracker.md`.

### Triage labels

Vocabulário padrão: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: um `GLOSSARY.md` e `docs/adr/` na raiz. See `docs/agents/domain.md`.
