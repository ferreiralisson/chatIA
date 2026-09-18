# API Chat IA

API Java 21 com Spring Boot 4.1.1 e Spring AI 2.0.1, integrada ao Ollama.

## Executar

Requisitos: JDK 21, Maven 3.6.3 ou superior e Ollama em execução.
Execute os comandos abaixo nesta pasta (`api_chat_ia`).

```sh
ollama pull qwen3.5:4b
mvn spring-boot:run
```

Se o Ollama ainda não estiver em execução, inicie-o com `ollama serve` em outro terminal.
A API não baixa modelos automaticamente. Prepare o modelo antes de fazer perguntas.

| Variável | Valor padrão | Uso |
| --- | --- | --- |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | Endereço do servidor Ollama |
| `OLLAMA_MODEL` | `qwen3.5:4b` | Modelo instalado no Ollama |

## Fazer uma pergunta

```sh
curl http://localhost:8080/ask \
  -H 'Content-Type: application/json' \
  -d '{"question":"O que é Spring AI?"}'
```

A resposta mantém o formato utilizado pelo aplicativo Flutter:

```json
{"response":"Texto gerado pelo modelo"}
```

Cada chamada é independente; não há histórico de conversa compartilhado entre requisições.

## Verificar

```sh
mvn clean verify
```

Os testes iniciam a API e um servidor HTTP que simula o Ollama. Verificam a
autoconfiguração, o envio da pergunta ao provedor e o contrato JSON de `/ask`,
sem baixar modelos ou depender de uma instalação local do Ollama.

Os scripts `mvnw` existentes estão incompletos: o projeto não contém
`.mvn/wrapper/maven-wrapper.properties`. Use o Maven instalado para os comandos acima.

## Atualização do Spring AI

- Spring AI 0.8.0 → 2.0.1 e Spring Boot 3.2.3 → 4.1.1, mantendo Java 21.
- Starter Ollama atualizado para `spring-ai-starter-model-ollama`.
- Cliente criado pelo `ChatClient.Builder` autoconfigurado, com
  `prompt().user(question).call().content()`.
- Removido o `ComponentScan` de pacotes internos do Spring AI; a integração usa autoconfiguração.
- Dependências estáveis resolvidas pelo Maven Central, sem repositórios de snapshots ou milestones.
- Perguntas e respostas completas deixam de ser registradas nos logs da aplicação.

Referências: [ChatClient](https://docs.spring.io/spring-ai/reference/api/chatclient.html),
[Ollama](https://docs.spring.io/spring-ai/reference/api/chat/ollama-chat.html) e
[compatibilidade do Spring AI](https://docs.spring.io/spring-ai/reference/getting-started.html).
