package inuzuki.is.inujanken.game;

public class GameRound {
  private long roomId;
  private String dogHand;
  private String status;

  public long getRoomId() {
    return roomId;
  }

  public void setRoomId(long roomId) {
    this.roomId = roomId;
  }

  public String getDogHand() {
    return dogHand;
  }

  public void setDogHand(String dogHand) {
    this.dogHand = dogHand;
  }

  public String getStatus() {
    return status;
  }

  public void setStatus(String status) {
    this.status = status;
  }
}