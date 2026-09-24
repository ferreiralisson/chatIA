# ChatIA

Exemplo de chat com interface Flutter Cupertino, API Spring Boot e geração de
respostas pelo Ollama. O modelo padrão é `qwen3.5:4b`.

| Pasta | Projeto |
| --- | --- |
| `api_chat_ia` | API Java 21, Spring Boot 4.1.1 e Spring AI 2.0.1 |
| `app_chat_ia` | Aplicativo Flutter para conversar com a API |

## Pré-requisitos

- JDK 21 e Maven 3.6.3 ou superior disponíveis no terminal.
- Flutter instalado e configurado. A versão usada na validação foi Flutter 3.41.4.
- Ollama instalado.
- Chrome para executar o app web. Para Android ou iOS, configure o respectivo
  SDK e um emulador/simulador; iOS exige macOS e Xcode.

Confira as ferramentas:

```sh
java -version
mvn -version
flutter doctor
ollama --version
```

## 1. Obter e abrir o projeto

Se ainda não tiver uma cópia local:

```sh
git clone https://github.com/ferreiralisson/chatIA.git
cd chatIA
```

Se o projeto já estiver baixado, abra a pasta que contém `api_chat_ia` e
`app_chat_ia`. No VS Code, abra essa pasta ou diretamente `app_chat_ia` para
executar o Flutter deste repositório.

**Nos passos seguintes, abra cada novo terminal na raiz do repositório.**
Mantenha o Ollama, a API e o app em execução ao mesmo tempo.

## 2. Iniciar o Ollama e preparar o modelo

Se o aplicativo Ollama já estiver em execução, não é necessário iniciar outro
servidor. Caso contrário, execute em um terminal dedicado:

```sh
ollama serve
```

Em outro terminal, baixe o modelo na primeira execução e confira a instalação:

```sh
ollama pull qwen3.5:4b
ollama list
```

O Ollama atende em `http://localhost:11434`. A API não baixa modelos
automaticamente. O download do Qwen ocupa aproximadamente 3,4 GB em disco.

## 3. Executar a API

Em um novo terminal, a partir da raiz do repositório:

```sh
cd api_chat_ia
mvn spring-boot:run
```

A API estará disponível em `http://localhost:8080`. Aguarde a mensagem
`Started ApiChatIaApplication` antes de enviar perguntas.

Use o Maven instalado (`mvn`): os scripts `mvnw` deste repositório não possuem
os arquivos de configuração necessários do Maven Wrapper.

Para testar a API em outro terminal:

```sh
curl http://localhost:8080/ask \
  -H 'Content-Type: application/json' \
  -d '{"question":"Diga olá para a turma em uma frase curta."}'
```

A resposta terá este formato, com texto gerado pelo modelo:

```json
{"response":"Olá, turma!"}
```

A primeira resposta pode demorar enquanto o Ollama carrega o modelo na memória.

## 4. Executar o aplicativo Flutter

### Navegador — demonstração local

Em um novo terminal, a partir da raiz do repositório:

```sh
cd app_chat_ia
flutter pub get
flutter run -d chrome --web-hostname localhost --web-port 5173 \
  --dart-define=API_BASE_URL=http://localhost:8080
```

Abra `http://localhost:5173`. A API já permite requisições das origens
`http://localhost:5173` e `http://127.0.0.1:5173`.
Use a porta **5173** para aproveitar essa configuração de CORS.

### Emulador Android

Inicie o emulador. Na pasta `app_chat_ia`, descubra seu identificador:

```sh
flutter devices
```

Substitua `ID_DO_EMULADOR` pelo identificador mostrado:

```sh
flutter run -d ID_DO_EMULADOR \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

No emulador Android padrão, `10.0.2.2` aponta para o computador que executa
a API. `localhost` apontaria para o próprio emulador.

### Simulador iOS no Mac

Inicie o simulador e consulte seu identificador com `flutter devices`.
Na pasta `app_chat_ia`, substitua `ID_DO_SIMULADOR`:

```sh
flutter run -d ID_DO_SIMULADOR \
  --dart-define=API_BASE_URL=http://localhost:8080
```

### Celular físico

Conecte o celular e o computador à mesma rede. Use o IP de rede do computador
no lugar de `localhost`. Na pasta `app_chat_ia`, substitua `ID_DO_CELULAR` e
`IP_DO_COMPUTADOR` pelos valores do seu ambiente:

```sh
flutter run -d ID_DO_CELULAR \
  --dart-define=API_BASE_URL=http://IP_DO_COMPUTADOR:8080
```

A porta 8080 precisa estar acessível pela rede. As builds Android debug/profile
permitem HTTP para a demonstração local. Em iOS físico, o acesso HTTP pode
exigir configuração de segurança de transporte para o ambiente de desenvolvimento;
use HTTPS quando disponível. Builds de distribuição devem usar uma API HTTPS.

## Configuração

| Opção | Onde definir | Padrão |
| --- | --- | --- |
| `OLLAMA_MODEL` | Variável de ambiente da API | `qwen3.5:4b` |
| `OLLAMA_BASE_URL` | Variável de ambiente da API | `http://localhost:11434` |
| `APP_CORS_ALLOWED_ORIGINS` | Variável de ambiente da API | `http://localhost:5173,http://127.0.0.1:5173` |
| `API_BASE_URL` | `--dart-define` ao executar/compilar o Flutter | `http://localhost:8080` |

Para usar outra origem web, informe o endereço completo, incluindo a porta,
ao iniciar a API. Exemplo em macOS/Linux, dentro de `api_chat_ia`:

```sh
APP_CORS_ALLOWED_ORIGINS=http://localhost:5200 mvn spring-boot:run
```

Nesse caso, execute o Flutter com `--web-port 5200`. Ao alterar uma variável
da API, reinicie a API; ao alterar `API_BASE_URL`, encerre e execute novamente
o Flutter com o novo `--dart-define`.

## Usar o chat

Digite uma pergunta e toque no botão de envio. A resposta aparece completa
quando a API termina a geração. A engrenagem no topo abre
**Configurações → Aparência**, com os modos Sistema, Claro e Escuro.

As conversas da interface ficam em memória durante a sessão. Atualmente a API
recebe somente a pergunta atual: o modelo não recebe o histórico, e não há
streaming de respostas.

## Validar o projeto

Na raiz do repositório, execute os testes da API:

```sh
mvn -f api_chat_ia/pom.xml clean verify
```

Para analisar, testar e compilar a versão web do Flutter:

```sh
cd app_chat_ia
flutter analyze
flutter test
flutter build web
```

Os testes automatizados simulam os serviços externos e não precisam de um
modelo Ollama carregado.

## Encerrar

Pressione `q` no terminal do `flutter run` para encerrar o app e `Ctrl+C` no
terminal da API. Se iniciou o Ollama com `ollama serve`, use `Ctrl+C` nesse
terminal para encerrar o servidor também.

## Problemas comuns

- **Não conecta à API:** confira se a API está rodando e se `API_BASE_URL`
  corresponde ao dispositivo usado, conforme os exemplos acima.
- **Erro de CORS no navegador:** confira a origem e a porta do app. Por padrão,
  use `http://localhost:5173`.
- **Modelo não encontrado:** execute `ollama pull qwen3.5:4b` e confira `ollama list`.
- **Porta 8080 ou 5173 ocupada:** encerre a execução anterior antes de iniciar outra.
- **Tela antiga ou opção de aparência ausente:** confirme que está executando
  `app_chat_ia/lib/main.dart` deste repositório. Pare o app e execute novamente
  após atualizar dependências; somente hot reload não registra novos plugins.

Mais detalhes: [API](api_chat_ia/README.md) e [Flutter](app_chat_ia/README.md).
