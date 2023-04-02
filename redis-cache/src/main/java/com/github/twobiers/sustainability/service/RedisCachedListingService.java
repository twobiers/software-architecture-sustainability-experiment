package com.github.twobiers.sustainability.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.twobiers.sustainability.core.data.ListingRepository;
import com.github.twobiers.sustainability.core.model.Listing;
import com.github.twobiers.sustainability.core.service.ListingService;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;

@Component
public class RedisCachedListingService implements ListingService {
  private final ListingRepository listingRepository;
  private final JedisPool jedisPool;
  private final ObjectMapper objectMapper;

  public RedisCachedListingService(ListingRepository listingRepository, JedisPool jedisPool,
      ObjectMapper objectMapper) {
    this.listingRepository = listingRepository;
    this.jedisPool = jedisPool;
    this.objectMapper = objectMapper;
  }

  @Override
  public Optional<Listing> findById(String id) {
    try (var jedis = jedisPool.getResource()) {
      var value = jedis.get(id);
      if (value != null) {
        return Optional.of(objectMapper.readValue(value, Listing.class));
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
