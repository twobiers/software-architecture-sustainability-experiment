package com.github.twobiers.sustainability.service;

import com.github.twobiers.sustainability.core.data.DocumentRepository;
import com.github.twobiers.sustainability.core.service.DocumentService;
import java.util.Optional;
import org.bson.Document;
import org.springframework.stereotype.Component;

@Component
public class UncachedDocumentService implements DocumentService {
  private final DocumentRepository documentRepository;

  public UncachedDocumentService(DocumentRepository documentRepository) {
    this.documentRepository = documentRepository;
  }

  @Override
  public Optional<Document> findById(String id) {
    return documentRepository.findById(id);
  }
}
