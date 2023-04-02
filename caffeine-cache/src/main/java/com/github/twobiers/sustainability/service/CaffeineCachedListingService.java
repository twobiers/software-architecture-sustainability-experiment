package com.github.twobiers.sustainability.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.twobiers.sustainability.core.data.ListingRepository;
import com.github.twobiers.sustainability.core.model.Listing;
import com.github.twobiers.sustainability.core.service.ListingService;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

@Component
public class CaffeineCachedListingService implements ListingService {
  private static final Cache<String, Optional<Listing>> LISTING_CACHE = Caffeine
      .newBuilder()
      .build();

  private final ListingRepository listingRepository;

  public CaffeineCachedListingService(ListingRepository listingRepository) {
    this.listingRepository = listingRepository;
  }

  @Override
  public Optional<Listing> findById(String id) {
    return LISTING_CACHE.get(id, listingRepository::findById);
  }
}
