package inuzuki.is.inujanken.game;

public enum Outcome {
  WIN("勝ち"),
  LOSE("負け"),
  DRAW("引き分け");

  private final String label;

  Outcome(String label) {
    this.label = label;
  }

  public String getLabel() {
    return label;
  }
}