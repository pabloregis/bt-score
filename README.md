# BT Score

Marcador de beach tennis para Apple Watch. Você marca os pontos tocando na metade da tela da sua dupla ou na da outra dupla, e o app cuida do resto:

- **Pontuação:** game no-ad, tie-break no 6-6, set único ou melhor de 3 com match tie-break.
- **Saque:** rodízio entre os quatro jogadores.
- **Correção:** desfazer pela Digital Crown.
- **Retomada:** a partida em andamento sobrevive se o app fechar ou o relógio reiniciar.
- **Sem olhar a tela:** vibração diferente por evento.
- **Registro:** histórico das partidas e treino de tênis gravado no app Saúde.

## Estrutura

- `ScoreEngine/`: o motor de pontuação, um pacote Swift sem dependência de interface. Roda e é testado em qualquer sistema com Swift, inclusive Linux.
- `App/`: o app watchOS em SwiftUI. Só compila no macOS, com Xcode.
- `project.yml`: a definição do projeto Xcode para o [XcodeGen](https://github.com/yonaskolb/XcodeGen). O `BTScore.xcodeproj` é gerado a partir dele e não é versionado.
- `docs/design/`: o design de referência (`bt-score.pen`) e o catálogo de alternativas de interface.

## Instalar no Apple Watch

O app é só para o relógio (watch-only): não há app de iPhone. Mesmo assim, o relógio precisa estar pareado com um iPhone, porque o Xcode instala no relógio por meio dele.

### O que você precisa

- Um Mac com macOS compatível com o Xcode 26 ou mais recente.
- Xcode 26 ou mais recente, instalado pela App Store. O app exige watchOS 26.
- Um Apple Watch com watchOS 26, pareado com um iPhone.
- Uma conta Apple (Apple ID). A conta gratuita serve, com as limitações descritas em [Conta gratuita](#conta-gratuita).
- [Homebrew](https://brew.sh), para instalar o XcodeGen.

### 1. Preparar o Mac

1. Instale o Xcode pela App Store e abra-o uma vez para aceitar a licença e instalar os componentes adicionais.
2. Na primeira abertura, ou depois em **Xcode > Settings > Components**, instale a plataforma **watchOS**.
3. Instale o XcodeGen:

   ```bash
   brew install xcodegen
   ```

4. Em **Xcode > Settings > Accounts**, clique em **+** e entre com o seu Apple ID. O Xcode cria um time pessoal (**Personal Team**) para assinar o app.

### 2. Gerar o projeto Xcode

1. Clone o repositório e entre na pasta:

   ```bash
   git clone https://github.com/pabloregis/bt-score.git
   ```

   ```bash
   cd bt-score
   ```

2. Gere o projeto a partir do `project.yml`:

   ```bash
   xcodegen generate
   ```

   O comando cria o `BTScore.xcodeproj` e a pasta `Generated/`, com o `Info.plist` e o arquivo de entitlements do HealthKit. Nenhum dos dois é versionado. Rode `xcodegen generate` de novo sempre que puxar mudanças no `project.yml` ou quando arquivos forem adicionados ou removidos em `App/`.

3. Abra o projeto:

   ```bash
   open BTScore.xcodeproj
   ```

### 3. Configurar a assinatura

1. No Xcode, selecione o projeto **BTScore** na barra lateral e depois o target **BTScore**.
2. Na aba **Signing & Capabilities**, marque **Automatically manage signing** e escolha o seu time em **Team**.
3. Se você não é o dono do repositório, troque o **Bundle Identifier** `com.pabloregis.btscore` por um identificador seu, por exemplo `com.seunome.btscore`. Cada identificador só pode pertencer a um time.

O `xcodegen generate` recria o projeto e desfaz essas escolhas. Repita este passo depois de cada geração. Para não precisar repetir, você pode fixar o time e o identificador no `project.yml`, em `targets > BTScore > settings > base`, com as chaves `DEVELOPMENT_TEAM` e `PRODUCT_BUNDLE_IDENTIFIER`. Não faça commit dessa mudança.

### 4. Preparar o iPhone e o relógio

1. Deixe o iPhone e o relógio na mesma rede Wi-Fi do Mac, com o Bluetooth ligado.
2. Conecte o iPhone ao Mac por cabo e toque em **Confiar** quando o iPhone perguntar.
3. Ative o modo de desenvolvedor no iPhone: **Ajustes > Privacidade e Segurança > Modo de Desenvolvedor**. O iPhone reinicia e pede confirmação.
4. Abra **Window > Devices and Simulators** no Xcode e espere o relógio aparecer junto do iPhone. A primeira conexão pode levar alguns minutos, enquanto o Xcode prepara o relógio para desenvolvimento.
5. Ative o modo de desenvolvedor no relógio: **Ajustes > Privacidade e Segurança > Modo de Desenvolvedor**. A opção só aparece depois que o Xcode reconhece o relógio. O relógio reinicia e pede confirmação.

### 5. Instalar e abrir

1. Na barra superior do Xcode, escolha o esquema **BTScore** e, como destino, o seu Apple Watch.
2. Clique em **Run** (▶) ou use `⌘R`. A primeira instalação no relógio é lenta.
3. Se o relógio disser que o desenvolvedor não é confiável, autorize em **Ajustes > Geral > VPN e Gerenciamento de Dispositivos**, no iPhone ou no relógio, e rode de novo.
4. Na primeira abertura, o app pede permissão para gravar treinos no app Saúde. Se você negar, o placar funciona do mesmo jeito, só sem o treino.

### Conta gratuita

Com um Apple ID sem o Apple Developer Program pago:

- O perfil de instalação expira em 7 dias. Depois disso o app não abre mais, e você precisa rodar pelo Xcode de novo.
- Há limite de apps instalados pelo mesmo time ao mesmo tempo.
- Se o Xcode recusar a assinatura por causa da capability do HealthKit, a saída é usar uma conta paga. A alternativa é tirar temporariamente o bloco `entitlements` do `project.yml` e gerar o projeto de novo. Nesse caso o app instala, mas a sessão de treino não funciona: a tela apaga ao baixar o pulso e o placar não volta sozinho.

### Sem relógio: simulador

Para ver o app sem um relógio, escolha um simulador de Apple Watch como destino no passo 5. O simulador não tem Digital Crown física (use a roda do mouse ou do trackpad), não vibra e não grava treinos no Saúde.

## Desenvolvimento

O motor roda em qualquer sistema com Swift 6:

```bash
swift test --package-path ScoreEngine
```

Para rodar um teste só:

```bash
swift test --package-path ScoreEngine --filter <nome>
```

O CI (`.github/workflows/ci.yml`) roda os testes do motor no Linux e, num runner macOS, gera o projeto e compila o target watchOS sem assinatura a cada push. Ele não instala nem roda o app. O que só dá para conferir no relógio fica na lista de verificação da issue PAB-15, no Linear.
