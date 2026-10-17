package inuzuki.is.inujanken.game;

import java.security.SecureRandom;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.ResponseStatus;

import inuzuki.is.inujanken.room.GameRoomService;

@Service
public class GameRoundService {
  private final GameRoundMapper gameRoundMapper;
  private final SecureRandom random = new SecureRandom();

  public GameRoundService(GameRoundMapper gameRoundMapper) {
    this.gameRoundMapper = gameRoundMapper;
  }

  @Transactional
  public GameRoundView load(String username) {
    ensureRound(username);
    completeIfReady();
    return buildView(username);
  }

  @Transactional
  public GameRoundView submitHand(String username, Hand hand) {
    ensureRound(username);
    int updated = gameRoundMapper.saveHand(GameRoomService.DEFAULT_ROOM_ID, username, hand.name());
    if (updated == 0) {
      throw new RoundAlreadyCompleteException();
    }
    completeIfReady();
    return buildView(username);
  }

  private void ensureRound(String username) {
    String roomStatus = gameRoundMapper.selectRoomStatus(GameRoomService.DEFAULT_ROOM_ID);
    if (!"STARTED".equals(roomStatus)) {
      throw new RoomNotStartedException();
    }
    if (gameRoundMapper.countRoomParticipant(GameRoomService.DEFAULT_ROOM_ID, username) == 0) {
      throw new NotRoundParticipantException();
    }
    if (gameRoundMapper.countRound(GameRoomService.DEFAULT_ROOM_ID) == 0) {
      gameRoundMapper.insertRound(GameRoomService.DEFAULT_ROOM_ID);
      gameRoundMapper.insertRoundParticipants(GameRoomService.DEFAULT_ROOM_ID);
    }
  }

  private void completeIfReady() {
    long roomId = GameRoomService.DEFAULT_ROOM_ID;
    GameRound round = gameRoundMapper.selectRound(roomId);
    if (round.getDogHand() == null && gameRoundMapper.countUnsubmitted(roomId) == 0) {
      Hand dogHand = Hand.values()[random.nextInt(Hand.values().length)];
      gameRoundMapper.completeRound(roomId, dogHand.name());
    }
  }

  private GameRoundView buildView(String username) {
    GameRound round = gameRoundMapper.selectRound(GameRoomService.DEFAULT_ROOM_ID);
    Hand dogHand = round.getDogHand() == null ? null : Hand.valueOf(round.getDogHand());
    List<GameRoundView.ParticipantView> participants = gameRoundMapper
        .selectRoundParticipants(GameRoomService.DEFAULT_ROOM_ID)
        .stream()
        .map(participant -> {
          Hand hand = participant.getHand() == null ? null : Hand.valueOf(participant.getHand());
          Outcome outcome = hand == null || dogHand == null ? null : hand.resultAgainst(dogHand);
          return new GameRoundView.ParticipantView(participant.getUsername(), hand, outcome);
        })
        .toList();
    return new GameRoundView(username, round, participants, dogHand);
  }

  @ResponseStatus(HttpStatus.FORBIDDEN)
  public static class RoomNotStartedException extends RuntimeException {
    private static final long serialVersionUID = 1L;
  }

  @ResponseStatus(HttpStatus.FORBIDDEN)
  public static class NotRoundParticipantException extends RuntimeException {
    private static final long serialVersionUID = 1L;
  }

  @ResponseStatus(HttpStatus.CONFLICT)
  public static class RoundAlreadyCompleteException extends RuntimeException {
    private static final long serialVersionUID = 1L;
  }
}