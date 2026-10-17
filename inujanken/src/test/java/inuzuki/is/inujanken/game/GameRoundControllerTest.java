package inuzuki.is.inujanken.game;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@Sql(statements = {
    "DELETE FROM game_round_participant",
    "DELETE FROM game_round",
    "DELETE FROM game_participant",
    "UPDATE game_room SET status = 'WAITING' WHERE id = 1",
    "INSERT INTO game_participant (room_id, username, started) VALUES (1, 'alice', TRUE)",
    "INSERT INTO game_participant (room_id, username, started) VALUES (1, 'bob', TRUE)",
    "UPDATE game_room SET status = 'STARTED' WHERE id = 1"
})
class GameRoundControllerTest {
  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private GameRoundMapper gameRoundMapper;

  @Test
  void submittedHandIsSavedAndResultRemainsHiddenUntilEveryoneSubmits() throws Exception {
    mockMvc.perform(post("/game/round/hand").with(user("alice")).with(csrf()).param("hand", "ROCK"))
        .andExpect(status().is3xxRedirection())
        .andExpect(redirectedUrl("/game/round"));

    List<GameRoundParticipant> savedParticipants = gameRoundMapper.selectRoundParticipants(1L);
    assertThat(savedParticipants).filteredOn(p -> p.getUsername().equals("alice"))
        .extracting(GameRoundParticipant::getHand).containsExactly("ROCK");

    mockMvc.perform(get("/game/round").with(user("alice")))
        .andExpect(status().isOk())
        .andExpect(content().string(org.hamcrest.Matchers.containsString("あなたの手を受け付けました")))
        .andExpect(content().string(org.hamcrest.Matchers.containsString("入力待ち")))
        .andExpect(content().string(org.hamcrest.Matchers.not(org.hamcrest.Matchers.containsString("犬の手:"))));
    assertThat(gameRoundMapper.selectRound(1L).getDogHand()).isNull();
  }

  @Test
  void allSubmissionsRevealOnePersistedDogHandAndEachParticipantOutcome() throws Exception {
    mockMvc.perform(post("/game/round/hand").with(user("alice")).with(csrf()).param("hand", "ROCK"))
        .andExpect(status().is3xxRedirection());
    mockMvc.perform(post("/game/round/hand").with(user("bob")).with(csrf()).param("hand", "PAPER"))
        .andExpect(status().is3xxRedirection());

    assertThat(gameRoundMapper.selectRoundParticipants(1L))
        .extracting(GameRoundParticipant::getHand)
        .containsExactly("ROCK", "PAPER");
    String persistedDogHand = gameRoundMapper.selectRound(1L).getDogHand();
    assertThat(persistedDogHand).isNotNull();
    assertThat(Hand.values()).contains(Hand.valueOf(persistedDogHand));

    String aliceResult = mockMvc.perform(get("/game/round").with(user("alice")))
        .andExpect(status().isOk())
        .andExpect(content().string(org.hamcrest.Matchers.containsString("結果")))
        .andExpect(content().string(org.hamcrest.Matchers.containsString("alice")))
        .andExpect(content().string(org.hamcrest.Matchers.containsString("bob")))
        .andReturn().getResponse().getContentAsString();
    String bobResult = mockMvc.perform(get("/game/round").with(user("bob")))
        .andExpect(status().isOk())
        .andReturn().getResponse().getContentAsString();

    String dogLabel = Hand.valueOf(persistedDogHand).getLabel();
    assertThat(aliceResult).contains("犬の手: <strong>" + dogLabel + "</strong>");
    assertThat(bobResult).contains("犬の手: <strong>" + dogLabel + "</strong>");
    assertThat(gameRoundMapper.selectRound(1L).getStatus()).isEqualTo("COMPLETE");
  }

  @Test
  void nonParticipantCannotAccessRoundAndInvalidHandIsRejected() throws Exception {
    mockMvc.perform(get("/game/round").with(user("charlie")))
        .andExpect(status().isForbidden());

    mockMvc.perform(post("/game/round/hand").with(user("alice")).with(csrf()).param("hand", "LIZARD"))
        .andExpect(status().isBadRequest());
  }
}