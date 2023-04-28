package com.github.twobiers.sustainability.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.twobiers.sustainability.core.data.DocumentRepository;
import com.github.twobiers.sustainability.core.service.DocumentService;
import java.util.Optional;
import org.bson.Document;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;

@Component
public class RedisCachedDocumentService implements DocumentService {
  private final DocumentRepository listingRepository;
  private final JedisPool jedisPool;
  private final ObjectMapper objectMapper;

  public RedisCachedDocumentService(DocumentRepository listingRepository, JedisPool jedisPool,
      ObjectMapper objectMapper) {
    this.listingRepository = listingRepository;
    this.jedisPool = jedisPool;
    this.objectMapper = objectMapper;
  }

  @Override
  public Optional<Document> findById(String id) {
    try (var jedis = jedisPool.getResource()) {
      var value = jedis.get(id);
      if (value != null) {
        return Optional.of(objectMapper.readValue(value, Document.class));
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
