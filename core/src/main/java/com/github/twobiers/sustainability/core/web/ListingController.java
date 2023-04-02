package com.github.twobiers.sustainability.core.web;

import com.github.twobiers.sustainability.core.model.Listing;
import com.github.twobiers.sustainability.core.service.ListingService;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ListingController {
  private final ListingService listingService;

  public ListingController(ListingService listingService) {
    this.listingService = listingService;
  }

  @GetMapping("/listings/{id}")
  public ResponseEntity<Listing> getListing(@PathVariable String id) {
    return listingService.findById(id)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }
}
