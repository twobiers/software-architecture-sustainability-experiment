package com.github.twobiers.sustainability.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.twobiers.sustainability.core.data.TicketRepository;
import com.github.twobiers.sustainability.core.model.Ticket;
import com.github.twobiers.sustainability.core.service.TicketService;
import java.util.Optional;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;

@Component
public class RedisCachedTicketService implements TicketService {
  private final TicketRepository listingRepository;
  private final JedisPool jedisPool;
  private final ObjectMapper objectMapper;

  public RedisCachedTicketService(TicketRepository ticketRepository, JedisPool jedisPool,
      ObjectMapper objectMapper) {
    this.listingRepository = ticketRepository;
    this.jedisPool = jedisPool;
    this.objectMapper = objectMapper;
  }

  @Override
  public Optional<Ticket> findById(String id) {
    try (var jedis = jedisPool.getResource()) {
      var value = jedis.get(id);
      if (value != null) {
        return Optional.of(objectMapper.readValue(value, Ticket.class));
      }

      var result = listingRepository.findById(id);
      if (result.isPresent()) {
        jedis.set(id, objectMapper.writeValueAsString(result.get()));
      }
      return result;
    } catch (JsonProcessingException e) {
      throw new RuntimeException(e);
    }
  }
}
