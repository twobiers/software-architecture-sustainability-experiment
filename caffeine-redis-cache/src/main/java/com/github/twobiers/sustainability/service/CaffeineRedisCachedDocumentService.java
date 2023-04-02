package com.github.twobiers.sustainability.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.twobiers.sustainability.core.data.DocumentRepository;
import com.github.twobiers.sustainability.core.service.DocumentService;
import java.util.Optional;
import org.bson.Document;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;

@Component
public class CaffeineRedisCachedDocumentService implements DocumentService {
  private static final Cache<String, Optional<Document>> DOCUMENT_CACHE = Caffeine
      .newBuilder()
      .build();
  private final DocumentRepository listingRepository;
  private final ObjectMapper objectMapper;
  private final JedisPool jedisPool;

  public CaffeineRedisCachedDocumentService(DocumentRepository documentRepository,
      ObjectMapper objectMapper, JedisPool jedisPool) {
    this.listingRepository = documentRepository;
    this.objectMapper = objectMapper;
    this.jedisPool = jedisPool;
  }

  @Override
  public Optional<Document> findById(String id) {
    return DOCUMENT_CACHE.get(id, this::getFromRedis);
  }

  private Optional<Document> getFromRedis(String id) {
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
