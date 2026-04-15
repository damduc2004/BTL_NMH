package com.example.product.config;

import java.io.File;

import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class TomcatConfig {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> docRootCustomizer() {
        return factory -> {
            String[] candidates = {
                "src/main/webapp",
                "product-service/src/main/webapp"
            };
            for (String candidate : candidates) {
                File docBase = new File(candidate);
                if (docBase.exists()) {
                    factory.setDocumentRoot(docBase.getAbsoluteFile());
                    return;
                }
            }
        };
    }
}
