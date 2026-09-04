package inuzuki.is.inujanken.room;

import java.util.List;

public class GameRoomView {
  private final GameRoom room;
  private final List<GameParticipant> participants;
  private final String username;
  private final boolean currentUserStarted;
  private final boolean full;

  public GameRoomView(GameRoom room, List<GameParticipant> participants, String username) {
    this.room = room;
    this.participants = participants;
    this.username = username;
    this.currentUserStarted = participants.stream()
        .filter(participant -> participant.getUsername().equals(username))
        .findFirst()
        .map(GameParticipant::isStarted)
        .orElse(false);
    this.full = participants.size() >= GameRoomService.MAX_PARTICIPANTS;
  }

  public GameRoom getRoom() {
    return room;
  }

  public List<GameParticipant> getParticipants() {
    return participants;
  }

  public String getUsername() {
    return username;
  }

  public boolean isCurrentUserStarted() {
    return currentUserStarted;
  }

  public boolean isFull() {
    return full;
  }

  public boolean isStarted() {
    return "STARTED".equals(room.getStatus());
  }

  public boolean isWaiting() {
    return !isStarted();
  }

  public boolean isEveryoneStarted() {
    return participants.size() >= 2
        && participants.stream().allMatch(GameParticipant::isStarted);
  }
}
