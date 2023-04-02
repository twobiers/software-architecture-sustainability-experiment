package com.github.twobiers.sustainability.core.service;

import com.github.twobiers.sustainability.core.model.Listing;
import java.util.Optional;

public interface ListingService {
  Optional<Listing> findById(String id);
}
