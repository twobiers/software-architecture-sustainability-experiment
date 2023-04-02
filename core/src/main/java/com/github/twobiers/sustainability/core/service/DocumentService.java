package com.github.twobiers.sustainability.core.service;

import java.util.Optional;
import org.bson.Document;

public interface DocumentService {
  Optional<Document> findById(String id);
}
