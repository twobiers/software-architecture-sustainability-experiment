package com.github.twobiers.sustainability.core.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ReviewScore {
  private Integer reviewScoresAccuracy;
  private Integer reviewScoresCheckin;
  private Integer reviewScoresCleanliness;
  private Integer reviewScoresCommunication;
  private Integer reviewScoresLocation;
  private Integer reviewScoresRating;
  private Integer reviewScoresValue;
}
