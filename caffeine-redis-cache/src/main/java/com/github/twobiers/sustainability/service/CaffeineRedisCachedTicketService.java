package com.github.twobiers.sustainability.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.twobiers.sustainability.core.data.TicketRepository;
import com.github.twobiers.sustainability.core.service.TicketService;
import java.util.Optional;
import com.github.twobiers.sustainability.core.model.Ticket;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;

@Component
public class CaffeineRedisCachedTicketService implements TicketService {
  private static final Cache<String, Optional<Ticket>> DOCUMENT_CACHE = Caffeine
      .newBuilder()
      .build();
  private final TicketRepository ticketRepository;
  private final ObjectMapper objectMapper;
  private final JedisPool jedisPool;

  public CaffeineRedisCachedTicketService(TicketRepository ticketRepository,
      ObjectMapper objectMapper, JedisPool jedisPool) {
    this.ticketRepository = ticketRepository;
    this.objectMapper = objectMapper;
    this.jedisPool = jedisPool;
  }

  @Override
  public Optional<Ticket> findById(String id) {
    return DOCUMENT_CACHE.get(id, this::getFromRedis);
  }

  private Optional<Ticket> getFromRedis(String id) {
    try (var jedis = jedisPool.getResource()) {
      var value = jedis.get(id);
      if (value != null) {
        return Optional.of(objectMapper.readValue(value, Ticket.class));
      }

      var result = ticketRepository.findById(id);
      if (result.isPresent()) {
        jedis.set(id, objectMapper.writeValueAsString(result.get()));
      }
      return result;
    } catch (JsonProcessingException e) {
      throw new RuntimeException(e);
    }
  }
}
