package com.github.twobiers.sustainability.core.model;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.util.Map;
import lombok.Data;

@Data
@Table(name = "aircrafts_data")
@Entity
public class Aircraft {
  @Id
  @Column(name = "aircraft_code")
  private String aircraftCode;
  @Convert(converter = JpaConverterJson.class)
  private Map<String, Object> model;
  private Integer range;
}
