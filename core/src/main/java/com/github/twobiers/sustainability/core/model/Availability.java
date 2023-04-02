package com.github.twobiers.sustainability.core.model;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class Availability {
  public String availability30;
  public String availability365;
  public String availability60;
  public String availability90;
}
