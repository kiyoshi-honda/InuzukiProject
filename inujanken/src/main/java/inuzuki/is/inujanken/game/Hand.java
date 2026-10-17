package inuzuki.is.inujanken.game;

public enum Hand {
  ROCK("グー"),
  SCISSORS("チョキ"),
  PAPER("パー");

  private final String label;

  Hand(String label) {
    this.label = label;
  }

  public String getLabel() {
    return label;
  }

  public Outcome resultAgainst(Hand opponent) {
    if (this == opponent) {
      return Outcome.DRAW;
    }
    boolean wins = this == ROCK && opponent == SCISSORS
        || this == SCISSORS && opponent == PAPER
        || this == PAPER && opponent == ROCK;
    return wins ? Outcome.WIN : Outcome.LOSE;
  }
}