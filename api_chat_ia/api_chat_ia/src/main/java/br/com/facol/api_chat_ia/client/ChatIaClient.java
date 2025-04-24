package br.com.facol.api_chat_ia.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.ChatClient;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.stereotype.Component;

@Component
public class ChatIaClient {

    private static final Logger log = LoggerFactory.getLogger(ChatIaClient.class);

    private final ChatClient chatClient;

    public ChatIaClient(ChatClient chatClient) {
        this.chatClient = chatClient;
    }

    public String chat(String question){
        log.info("ChatIA - question: {}", question);

        var aiResponse = this.chatClient.call(new Prompt(question));
        var response = aiResponse.getResult().getOutput().getContent();

        log.info("ChatIA - response: {}", response);
        return response;
    }
}
