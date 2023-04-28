package com.github.twobiers.sustainability.core.data;

import com.mongodb.client.MongoClient;
import java.util.Optional;
import org.bson.Document;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class DocumentRepositoryImpl implements DocumentRepository {
  private final MongoClient mongoClient;
  private final String databaseName;
  private final String collectionName;

  public DocumentRepositoryImpl(
      MongoClient mongoClient,
      @Value("${mongo.database}")
      String database,
      @Value("${mongo.collection}")
      String collection
  ) {
    this.mongoClient = mongoClient;
    this.collectionName = collection;
    this.databaseName = database;
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
