package com.github.twobiers.sustainability.service;

import com.github.twobiers.sustainability.core.data.ListingRepository;
import com.github.twobiers.sustainability.core.model.Listing;
import com.github.twobiers.sustainability.core.service.ListingService;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Component;

@Component
public class UncachedListingService implements ListingService {
  private final ListingRepository listingRepository;

  public UncachedListingService(ListingRepository listingRepository) {
    this.listingRepository = listingRepository;
  }

  @Override
  public Optional<Listing> findById(String id) {
    return listingRepository.findById(id);
  }
}
