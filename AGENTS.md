## Comandos

O Swift no WSL vem do `swiftly` e só entra no PATH de shells de login. Em shells não interativos, carregue antes:

```bash
. ~/.local/share/swiftly/env.sh
```

- Testes do motor (roda no WSL): `swift test --package-path ScoreEngine`
- Um teste só: `swift test --package-path ScoreEngine --filter <nome>`
- Projeto Xcode (só no macOS): `xcodegen generate` a partir do `project.yml`. O `.xcodeproj` e a pasta `Generated/` (`Info.plist` e entitlements do HealthKit) não são versionados.

O app SwiftUI não compila no Linux. Ele é verificado pelo job macOS do CI (`.github/workflows/ci.yml`), que gera o projeto e compila o target watchOS sem assinatura a cada push. Depois de abrir um PR, confira o job macOS antes de dar o app como compilado.

O CI não roda o app. Ao entregar um ticket com mudança de interface ou de comportamento no relógio, acrescente o que só dá para conferir no aparelho como critério na PAB-15 (verificação no relógio com Mac emprestado).

## Instalação no relógio

O passo a passo para gerar o projeto, assinar e instalar no Apple Watch está no `README.md`, em "Instalar no Apple Watch". Mantenha-o atualizado quando mudar algo que afete a instalação:

- `project.yml`: target, bundle identifier, versão mínima do watchOS, capabilities, chaves `INFOPLIST_KEY_*`, entitlements.
- Permissões novas (ex.: outra capability do HealthKit) ou requisitos de conta Apple.
- A versão do Xcode exigida no CI.

## Convenções

- Configuração do target fica no `project.yml`. Não crie `Info.plist` nem entitlements à mão: use chaves `INFOPLIST_KEY_*` e as seções `info` e `entitlements` do XcodeGen, que geram os arquivos em `Generated/`.
- Regras de pontuação e de saque ficam no `ScoreEngine`, com testes. O app só traduz o estado em tela, vibração e HealthKit.
- O estado da partida é sempre derivado do log de eventos (`Match.events`). `Match.record` recusa eventos que o estado atual não aceita; desfazer é remover o último evento.
- Mudanças no formato gravado (`Match`, `MatchFormat`, `History`) precisam continuar lendo gravações antigas ou recusá-las com erro, nunca derrubar o app. Cubra com teste de decodificação.

## Agent skills

### Issue tracker

Issues e specs ficam no Linear. See `docs/agents/issue-tracker.md`.

### Triage labels

Vocabulário padrão: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: um `GLOSSARY.md` e `docs/adr/` na raiz. See `docs/agents/domain.md`.
