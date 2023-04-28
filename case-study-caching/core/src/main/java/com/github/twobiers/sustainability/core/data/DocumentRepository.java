package com.github.twobiers.sustainability.core.data;

import java.util.Optional;
import org.bson.Document;
import org.springframework.data.repository.NoRepositoryBean;

@NoRepositoryBean
public interface DocumentRepository {
  Optional<Document> findById(String id);
}
