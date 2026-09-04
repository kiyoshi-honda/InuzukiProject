package inuzuki.is.inujanken.room;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.security.core.userdetails.UserDetailsService;

@SpringBootTest
@AutoConfigureMockMvc
@Sql(statements = {
    "DELETE FROM game_participant",
    "UPDATE game_room SET status = 'WAITING' WHERE id = 1"
})
class GameRoomControllerTest {
  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private GameRoomMapper gameRoomMapper;

  @Autowired
  private UserDetailsService userDetailsService;

  @Test
  void configuredUsersCanBeLoaded() {
    assertThat(userDetailsService.loadUserByUsername("yamada")).isNotNull();
    assertThat(userDetailsService.loadUserByUsername("kodai")).isNotNull();
    assertThat(userDetailsService.loadUserByUsername("oit")).isNotNull();
  }

  @Test
  void authenticatedUserJoinsPredefinedRoom() throws Exception {
    mockMvc.perform(get("/game").with(user("alice")))
        .andExpect(status().isOk())
        .andExpect(content().string(org.hamcrest.Matchers.containsString("みんなのわんこルーム")))
        .andExpect(content().string(org.hamcrest.Matchers.containsString("name=\"_csrf\"")))
        .andExpect(content().string(org.hamcrest.Matchers.containsString("alice")));

    assertThat(gameRoomMapper.countParticipant(1L, "alice")).isEqualTo(1);
  }

  @Test
  void fullRoomRejectsNewParticipant() throws Exception {
    for (int index = 1; index <= GameRoomService.MAX_PARTICIPANTS; index++) {
      gameRoomMapper.insertParticipant(1L, "player" + index);
    }

    mockMvc.perform(get("/game").with(user("new-player")))
        .andExpect(status().isOk())
        .andExpect(content().string(org.hamcrest.Matchers.containsString("ルームが満員のため参加できません。")));

    assertThat(gameRoomMapper.countParticipant(1L, "new-player")).isZero();
  }

  @Test
  void oneParticipantStartingLeavesRoomWaiting() throws Exception {
    mockMvc.perform(get("/game").with(user("alice")))
        .andExpect(status().isOk());

    mockMvc.perform(post("/game/start").with(user("alice")).with(csrf()))
        .andExpect(status().isOk())
        .andExpect(content().string(org.hamcrest.Matchers.containsString("他の参加者を待っています。")));

    assertThat(gameRoomMapper.selectRoom(1L).getStatus()).isEqualTo("WAITING");
  }

  @Test
  void allParticipantsStartingBeginsRoomBeforeItIsFull() throws Exception {
    mockMvc.perform(get("/game").with(user("alice")))
        .andExpect(status().isOk());
    mockMvc.perform(post("/game/start").with(user("alice")).with(csrf()))
        .andExpect(status().isOk());

    mockMvc.perform(get("/game").with(user("bob")))
        .andExpect(status().isOk());
    mockMvc.perform(post("/game/start").with(user("bob")).with(csrf()))
        .andExpect(status().isOk())
        .andExpect(content().string(org.hamcrest.Matchers.containsString("対戦開始")));

    assertThat(gameRoomMapper.selectRoom(1L).getStatus()).isEqualTo("STARTED");
    assertThat(gameRoomMapper.countParticipants(1L)).isEqualTo(2);
  }
}
