package br.com.facol.api_chat_ia.client;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Component;

@Component
public class ChatIaClient {

    private final ChatClient chatClient;

    public ChatIaClient(ChatClient.Builder builder) {
        this.chatClient = builder.build();
    }

    public String chat(String question) {
        return this.chatClient.prompt()
                .user(question)
                .call()
                .content();
    }
}
