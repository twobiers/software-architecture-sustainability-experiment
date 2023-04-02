package com.github.twobiers.sustainability.core.model;

import java.time.Instant;
import java.util.List;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@NoArgsConstructor
@Document(collection = "listingsAndReviews")
public class Listing {
  @Id
  private String id;

  private String access;
  private Integer accommodates;
  private Address address;
  private List<String> amenities;
  private Availability availability;
  private Double bathrooms;
  private String bedType;
  private Integer bedrooms;
  private Integer beds;
  private Instant calendarLastScraped;
  private String cancellationPolicy;
  private Double cleaningFee;
  private String description;
  private Double extraPeople;
  private Instant firstReview;
  private Double guestsIncluded;
  private Host host;
  private String houseRules;
  private Images images;
  private String interaction;
  private Instant lastReview;
  private Instant lastScraped;
  private String listingUrl;
  private String maximumNights;
  private String minimumNights;
  private Double monthlyPrice;
  private String name;
  private String neighbourhoodOverview;
  private String notes;
  private Integer numberOfReviews;
  private Double price;
  private String propertyType;
  private List<ReviewScore> reviewScores;
  private List<Review> reviews;
  private String roomType;
  private Double securityDeposit;
  private String space;
  private String summary;
  private String transit;
  private Double weeklyPrice;
}
