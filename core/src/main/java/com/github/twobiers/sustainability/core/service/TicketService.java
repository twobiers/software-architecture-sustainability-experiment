package com.github.twobiers.sustainability.core.service;

import com.github.twobiers.sustainability.core.model.Ticket;
import java.util.Optional;

public interface TicketService {
  Optional<Ticket> findById(String id);
}
