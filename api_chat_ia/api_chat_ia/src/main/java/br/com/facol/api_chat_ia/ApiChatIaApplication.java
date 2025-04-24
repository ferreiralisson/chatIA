package br.com.facol.api_chat_ia;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"br.com.facol", "org.springframework.ai.chat.client"})
public class ApiChatIaApplication {

    public static void main(String[] args) {
        SpringApplication.run(ApiChatIaApplication.class, args);
    }

}
