package com.github.twobiers.sustainability.service;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.twobiers.sustainability.core.data.DocumentRepository;
import com.github.twobiers.sustainability.core.service.DocumentService;
import java.util.Optional;
import org.bson.Document;
import org.springframework.stereotype.Component;

@Component
public class CaffeineCachedDocumentService implements DocumentService {
  private static final Cache<String, Optional<Document>> DOCUMENT_CACHE = Caffeine
      .newBuilder()
      .build();

  private final DocumentRepository documentRepository;

  public CaffeineCachedDocumentService(DocumentRepository documentRepository) {
    this.documentRepository = documentRepository;
  }

  @Override
  public Optional<Document> findById(String id) {
    return DOCUMENT_CACHE.get(id, documentRepository::findById);
  }
}
