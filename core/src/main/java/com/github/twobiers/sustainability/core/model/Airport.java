package com.github.twobiers.sustainability.core.model;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.Map;
import lombok.Data;

@Data
@Table(name = "airports_data")
@Entity
public class Airport {
  @Id
  @Column(name = "airport_code")
  private String airportCode;
  private String airportName;
  private String coordinates;
  @Convert(converter = JpaConverterJson.class)
  private Map<String, Object> city;
  private String timezone;
}
