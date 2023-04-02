package com.github.twobiers.sustainability.core.data;

import com.mongodb.client.MongoClient;
import java.util.Optional;
import org.bson.Document;
import org.springframework.stereotype.Component;

@Component
public class DocumentRepositoryImpl implements DocumentRepository {
  private final MongoClient mongoClient;
  private final String databaseName = "airbnb";
  private final String collectionName = "listingsAndReviews";

  public DocumentRepositoryImpl(MongoClient mongoClient) {
    this.mongoClient = mongoClient;
  }

  @Override
  public Optional<Document> findById(String id) {
    var result = mongoClient.getDatabase(databaseName)
        .getCollection(collectionName)
        .find(
            Document.parse(
                """
                {
                  "_id": "%s"
                }
                """.formatted(id)
            )
        ).first();

    return Optional.ofNullable(result);
  }
}
