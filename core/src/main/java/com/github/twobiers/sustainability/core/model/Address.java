package com.github.twobiers.sustainability.core.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class Address {
  public String country;
  public String countryCode;
  public String governmentArea;
  public String location;
  public String market;
  public String street;
  public String suburb;
}
