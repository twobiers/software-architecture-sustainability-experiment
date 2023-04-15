package com.github.twobiers.sustainability.core.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.time.Instant;
import lombok.Data;

@Table(name = "flights")
@Entity
@Data
public class Flight {
  @Id
  @Column(name = "flight_id")
  private Long flightId;

  @Column(name = "flight_no")
  private String flightNumber;

  @ManyToOne(fetch = FetchType.EAGER)
  @JoinColumn(name = "departure_airport", referencedColumnName = "airport_code")
  private Airport departureAirport;
  @ManyToOne(fetch = FetchType.EAGER)
  @JoinColumn(name = "arrival_airport", referencedColumnName = "airport_code")
  private Airport arrivalAirport;

  private Instant scheduledDeparture;
  private Instant scheduledArrival;
  private Instant actualDeparture;
  private Instant actualArrival;

  private String status;
  @ManyToOne
  @JoinColumn(name = "aircraft_code", referencedColumnName = "aircraft_code")
  private Aircraft aircraft;
}
