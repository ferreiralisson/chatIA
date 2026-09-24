# ChatIA — Flutter Cupertino

Para executar API, Ollama e app juntos, veja o [guia na raiz do projeto](../README.md).

Interface de chat inspirada no ChatGPT, construída com `CupertinoApp`,
`CupertinoPageScaffold`, `CupertinoTextField` e `CupertinoButton`.
Não utiliza widgets Material nem fontes de ícones Material.

## Executar

Inicie a API Spring e o Ollama antes de enviar mensagens. Na pasta deste app:

```sh
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

O endereço padrão é `http://localhost:8080`. Para o emulador Android:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Em um celular físico, use o IP do computador na mesma rede. A API precisa estar
acessível nesse endereço. Para distribuir o app, prefira uma API HTTPS.
O Android permite HTTP local nas builds de demonstração debug/profile.
No navegador, uma API em outra origem também precisa permitir CORS.

## Aparência

Toque na engrenagem no topo do chat para abrir **Configurações → Aparência**.
Escolha **Sistema**, **Claro** ou **Escuro**. O padrão é Sistema, que acompanha
as mudanças de aparência do dispositivo. A preferência é salva localmente e
restaurada ao reabrir o aplicativo; trocar o tema preserva conversas e rascunhos.

## Interface

- Layout responsivo: histórico lateral no desktop e painel de conversas no celular.
- Sugestões que preenchem o campo, mensagens por autor e cópia de respostas.
- Estado de carregamento, bloqueio de envio duplicado e repetição após erro.
- Novas conversas e rascunhos separados, mantidos em memória durante a sessão.

A API continua recebendo `POST /ask` com `{"question":"..."}` e devolvendo
`{"response":"..."}`. O histórico da interface não é enviado ao modelo:
cada pergunta ainda é independente. Não há persistência após fechar o app
nem streaming; a resposta aparece completa quando a API termina.

## Organização

- `lib/main.dart`: aplicação e tema Cupertino.
- `lib/screens/chat_screen.dart`: conversas, composição e layout responsivo.
- `lib/widgets/chat_widgets.dart`: mensagens, sugestões e controles.
- `lib/models/conversation.dart`: conversas e autores das mensagens.
- `lib/services/chat_service.dart`: HTTP, configuração da URL e tratamento de erros.

## Validação

```sh
flutter analyze
flutter test
flutter build web
```

Os testes usam uma API simulada para verificar envio, caracteres acentuados,
falhas, repetição, conversas e descarte da tela durante uma requisição.
