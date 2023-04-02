package com.github.twobiers.sustainability.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.twobiers.sustainability.core.data.ListingRepository;
import com.github.twobiers.sustainability.core.model.Listing;
import com.github.twobiers.sustainability.core.service.ListingService;
import java.util.Optional;
import org.springframework.stereotype.Component;
import redis.clients.jedis.JedisPool;

@Component
public class CaffeineRedisCachedListingService implements ListingService {
  private static final Cache<String, Optional<Listing>> LISTING_CACHE = Caffeine
      .newBuilder()
      .build();
  private final ListingRepository listingRepository;
  private final ObjectMapper objectMapper;
  private final JedisPool jedisPool;

  public CaffeineRedisCachedListingService(ListingRepository listingRepository,
      ObjectMapper objectMapper, JedisPool jedisPool) {
    this.listingRepository = listingRepository;
    this.objectMapper = objectMapper;
    this.jedisPool = jedisPool;
  }

  @Override
  public Optional<Listing> findById(String id) {
    return LISTING_CACHE.get(id, this::getFromRedis);
  }

  private Optional<Listing> getFromRedis(String id) {
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
