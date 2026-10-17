package inuzuki.is.inujanken.game;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class HandTest {
  @Test
  void everyHandCombinationProducesExpectedOutcome() {
    assertThat(Hand.ROCK.resultAgainst(Hand.ROCK)).isEqualTo(Outcome.DRAW);
    assertThat(Hand.ROCK.resultAgainst(Hand.SCISSORS)).isEqualTo(Outcome.WIN);
    assertThat(Hand.ROCK.resultAgainst(Hand.PAPER)).isEqualTo(Outcome.LOSE);

    assertThat(Hand.SCISSORS.resultAgainst(Hand.ROCK)).isEqualTo(Outcome.LOSE);
    assertThat(Hand.SCISSORS.resultAgainst(Hand.SCISSORS)).isEqualTo(Outcome.DRAW);
    assertThat(Hand.SCISSORS.resultAgainst(Hand.PAPER)).isEqualTo(Outcome.WIN);

    assertThat(Hand.PAPER.resultAgainst(Hand.ROCK)).isEqualTo(Outcome.WIN);
    assertThat(Hand.PAPER.resultAgainst(Hand.SCISSORS)).isEqualTo(Outcome.LOSE);
    assertThat(Hand.PAPER.resultAgainst(Hand.PAPER)).isEqualTo(Outcome.DRAW);
  }
}