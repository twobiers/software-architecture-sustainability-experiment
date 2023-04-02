package com.github.twobiers.sustainability.core.model;

import java.time.Instant;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class Review {
  public String comments;
  public Instant date;
  public String listingId;
  public String reviewerId;
  public String reviewerName;
}
