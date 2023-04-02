package com.github.twobiers.sustainability.core.model;

import java.util.List;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class Host {
  private String hostAbout;
  private Boolean hostHasProfilePic;
  private String hostId;
  private String hostIdentityVerified;
  private String hostIsSuperhost;
  private Integer hostListingsCount;
  private String hostLocation;
  private String hostName;
  private String hostNeighbourhood;
  private String hostPictureUrl;
  private Integer hostResponseRate;
  private String hostResponseTime;
  private String hostThumbnailUrl;
  private Integer hostTotalListingsCount;
  private String hostUrl;
  private List<String> hostVerifications;
}
