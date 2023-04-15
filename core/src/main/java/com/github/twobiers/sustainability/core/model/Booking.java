package com.github.twobiers.sustainability.core.model;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import lombok.Data;

@Data
@Entity
@Table(name = "bookings")
public class Booking {
  @Id
  @Column(name = "book_ref")
  private String bookRef;

  private Instant bookDate;
  private Integer totalAmount;
}
