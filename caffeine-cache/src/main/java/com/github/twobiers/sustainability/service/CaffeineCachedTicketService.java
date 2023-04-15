package com.github.twobiers.sustainability.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.twobiers.sustainability.core.data.TicketRepository;
import com.github.twobiers.sustainability.core.model.Ticket;
import com.github.twobiers.sustainability.core.service.TicketService;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
public class CaffeineCachedTicketService implements TicketService {
  private static final Cache<String, Optional<Ticket>> DOCUMENT_CACHE = Caffeine
      .newBuilder()
      .build();

  private final TicketRepository ticketRepository;

  public CaffeineCachedTicketService(TicketRepository ticketRepository) {
    this.ticketRepository = ticketRepository;
  }

  @Override
  public Optional<Ticket> findById(String id) {
    return DOCUMENT_CACHE.get(id, ticketRepository::findById);
  }
}
