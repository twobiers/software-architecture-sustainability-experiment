package com.github.twobiers.sustainability.service;

import com.github.twobiers.sustainability.core.data.TicketRepository;
import com.github.twobiers.sustainability.core.model.Ticket;
import com.github.twobiers.sustainability.core.service.TicketService;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
public class UncachedTicketService implements TicketService {
  private final TicketRepository ticketRepository;

  public UncachedTicketService(TicketRepository ticketRepository) {
    this.ticketRepository = ticketRepository;
  }

  @Override
  public Optional<Ticket> findById(String id) {
    return ticketRepository.findById(id);
  }
}
