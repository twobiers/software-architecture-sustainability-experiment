package com.github.twobiers.sustainability.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

@Configuration
public class JedisConfig {
  @Value("${redis.host}")
  private String redisHost;
  @Bean
  public JedisPool jedis() {
    var config = new JedisPoolConfig();
    config.setJmxEnabled(false);
    return new JedisPool(config, redisHost, 6379);
  }
}
