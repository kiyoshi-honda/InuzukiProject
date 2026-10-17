package inuzuki.is.inujanken.game;

import java.util.List;

public class GameRoundView {
  private final String username;
  private final GameRound round;
  private final List<ParticipantView> participants;
  private final Hand dogHand;

  public GameRoundView(String username, GameRound round, List<ParticipantView> participants, Hand dogHand) {
    this.username = username;
    this.round = round;
    this.participants = participants;
    this.dogHand = dogHand;
  }

  public String getUsername() {
    return username;
  }

  public GameRound getRound() {
    return round;
  }

  public List<ParticipantView> getParticipants() {
    return participants;
  }

  public Hand getDogHand() {
    return dogHand;
  }

  public boolean isComplete() {
    return dogHand != null;
  }

  public boolean isCurrentUserSubmitted() {
    return participants.stream()
        .filter(participant -> participant.getUsername().equals(username))
        .findFirst()
        .map(participant -> participant.getHand() != null)
        .orElse(false);
  }

  public static class ParticipantView {
    private final String username;
    private final Hand hand;
    private final Outcome outcome;

    public ParticipantView(String username, Hand hand, Outcome outcome) {
      this.username = username;
      this.hand = hand;
      this.outcome = outcome;
    }

    public String getUsername() {
      return username;
    }

    public Hand getHand() {
      return hand;
    }

    public Outcome getOutcome() {
      return outcome;
    }
  }
}