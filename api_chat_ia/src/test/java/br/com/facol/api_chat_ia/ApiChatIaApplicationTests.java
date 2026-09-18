package br.com.facol.api_chat_ia;

import com.jayway.jsonpath.JsonPath;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ApiChatIaApplicationTests {

    private static final LinkedBlockingQueue<String> ollamaRequests = new LinkedBlockingQueue<>();
    private static HttpServer ollama;

    @Value("${local.server.port}")
    private int port;

    @DynamicPropertySource
    static void configureOllama(DynamicPropertyRegistry registry) throws IOException {
        ollama = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        ollama.createContext("/api/chat", exchange -> {
            try (exchange) {
                ollamaRequests.add(new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8));
                byte[] body = """
                        {"model":"tinyllama","created_at":"2026-09-18T00:00:00Z",
                         "message":{"role":"assistant","content":"Olá! Sou o assistente."},
                         "done":true,"done_reason":"stop","prompt_eval_count":10,"eval_count":6}
                        """.getBytes(StandardCharsets.UTF_8);
                exchange.getResponseHeaders().set("Content-Type", "application/json");
                exchange.sendResponseHeaders(200, body.length);
                exchange.getResponseBody().write(body);
            }
        });
        ollama.start();
        registry.add("spring.ai.ollama.base-url", () -> "http://127.0.0.1:" + ollama.getAddress().getPort());
        registry.add("spring.ai.ollama.chat.model", () -> "tinyllama");
        registry.add("spring.ai.ollama.init.pull-model-strategy", () -> "never");
    }

    @AfterAll
    static void stopOllama() {
        if (ollama != null) {
            ollama.stop(0);
        }
    }

    @Test
    void contextLoads() {
    }

    @Test
    void askPreservesFlutterContractAndCallsOllamaThroughSpringAi() throws Exception {
        try (HttpClient client = HttpClient.newHttpClient()) {
            var request = HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/ask"))
                    .timeout(Duration.ofSeconds(10))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString("""
                            {"question":"Olá! Explique {exemplo}."}
                            """))
                    .build();

            var response = client.send(request, HttpResponse.BodyHandlers.ofString());

            assertThat(response.statusCode()).isEqualTo(200);
            assertThat(JsonPath.<String>read(response.body(), "$.response"))
                    .isEqualTo("Olá! Sou o assistente.");
            String ollamaRequest = ollamaRequests.poll(1, TimeUnit.SECONDS);
            assertThat(ollamaRequest).isNotNull();
            assertThat(JsonPath.<String>read(ollamaRequest, "$.model")).isEqualTo("tinyllama");
            assertThat(JsonPath.<Boolean>read(ollamaRequest, "$.stream")).isFalse();
            assertThat(JsonPath.<String>read(ollamaRequest, "$.messages[0].role")).isEqualTo("user");
            assertThat(JsonPath.<String>read(ollamaRequest, "$.messages[0].content"))
                    .isEqualTo("Olá! Explique {exemplo}.");
        }
    }
}
