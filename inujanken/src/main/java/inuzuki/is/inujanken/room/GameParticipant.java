package inuzuki.is.inujanken.room;

public class GameParticipant {
  private String username;
  private boolean started;

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public boolean isStarted() {
    return started;
  }

  public void setStarted(boolean started) {
    this.started = started;
  }
}
