package com.github.twobiers.sustainability.core.model;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.util.List;
import java.util.Map;
import lombok.Data;

@Data
@Entity
@Table(name = "tickets")
public class Ticket {
  @Id
  @Column(name = "ticket_no")
  private String ticketNumber;

  private String passengerId;
  private String passengerName;
  @Convert(converter = JpaConverterJson.class)
  private Map<String, Object> contactData;

  @OneToMany(mappedBy = "ticket", fetch = FetchType.EAGER)
  //@JoinColumn(table = "ticket_flights", name = "ticket_no", referencedColumnName = "ticket_no")
  private List<FlightRef> flights;

  @OneToOne(fetch = FetchType.EAGER)
  @JoinColumn(name = "book_ref", referencedColumnName = "book_ref")
  private Booking booking;
}
