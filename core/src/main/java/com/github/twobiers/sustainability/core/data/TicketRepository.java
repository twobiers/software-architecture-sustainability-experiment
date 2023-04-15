package com.github.twobiers.sustainability.core.data;

import com.github.twobiers.sustainability.core.model.Ticket;
import org.springframework.data.repository.CrudRepository;

public interface TicketRepository extends CrudRepository<Ticket, String> {
}
