package br.com.facol.api_chat_ia.controller;

import br.com.facol.api_chat_ia.client.ChatIaClient;
import br.com.facol.api_chat_ia.controller.dto.QuestionRequest;
import br.com.facol.api_chat_ia.controller.dto.Response;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AskQuestionController {

    private final ChatIaClient chatClient;

    public AskQuestionController(ChatIaClient chatClient) {
        this.chatClient = chatClient;
    }

    @PostMapping("/ask")
    public Response ask(@RequestBody QuestionRequest questionRequest) {
        return new Response(chatClient.chat(questionRequest.question()));
    }
}
