package com.github.twobiers.sustainability.core.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.List;
import lombok.Data;

@Table(name = "ticket_flights")
@Data
@Entity
@IdClass(FlightRefId.class)
public class FlightRef {
  @Id
  @ManyToOne(fetch = FetchType.EAGER)
  @JoinColumn(name = "ticket_no", referencedColumnName = "ticket_no")
  @JsonIgnore
  private Ticket ticket;

  @Id
  @ManyToOne(fetch = FetchType.EAGER)
  @JoinColumn(name = "flight_id", referencedColumnName = "flight_id")
  private Flight flight;

  @Column(name =  "fare_conditions")
  private String fareConditions;

  private Integer amount;
}
