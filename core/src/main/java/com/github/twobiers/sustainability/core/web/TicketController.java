package com.github.twobiers.sustainability.core.web;

import com.github.twobiers.sustainability.core.model.Ticket;
import com.github.twobiers.sustainability.core.service.TicketService;
import jakarta.transaction.Transactional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Transactional
public class TicketController {
  private final TicketService ticketService;

  public TicketController(TicketService ticketService) {
    this.ticketService = ticketService;
  }

  @GetMapping("/tickets/{id}")
  public ResponseEntity<Ticket> getListing(@PathVariable String id) {
    return ticketService.findById(id)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
  }
}
