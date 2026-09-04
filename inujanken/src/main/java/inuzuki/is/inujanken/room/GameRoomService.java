package inuzuki.is.inujanken.room;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class GameRoomService {
  public static final long DEFAULT_ROOM_ID = 1L;
  public static final int MAX_PARTICIPANTS = 10;

  private final GameRoomMapper gameRoomMapper;

  public GameRoomService(GameRoomMapper gameRoomMapper) {
    this.gameRoomMapper = gameRoomMapper;
  }

  @Transactional
  public GameRoomView joinAndLoad(String username) {
    GameRoom room = getRoom();
    if (gameRoomMapper.countParticipant(DEFAULT_ROOM_ID, username) == 0) {
      if (gameRoomMapper.countParticipants(DEFAULT_ROOM_ID) >= MAX_PARTICIPANTS) {
        throw new RoomFullException();
      }
      gameRoomMapper.insertParticipant(DEFAULT_ROOM_ID, username);
    }
    return load(username);
  }

  @Transactional
  public GameRoomView markReady(String username) {
    GameRoomView current = joinAndLoad(username);
    if (!current.isStarted()) {
      gameRoomMapper.markStarted(DEFAULT_ROOM_ID, username);
      List<GameParticipant> participants = gameRoomMapper.selectParticipants(DEFAULT_ROOM_ID);
      if (participants.size() >= 2 && participants.stream().allMatch(GameParticipant::isStarted)) {
        gameRoomMapper.markRoomStarted(DEFAULT_ROOM_ID);
      }
    }
    return load(username);
  }

  public GameRoomView load(String username) {
    return new GameRoomView(getRoom(), gameRoomMapper.selectParticipants(DEFAULT_ROOM_ID), username);
  }

  private GameRoom getRoom() {
    GameRoom room = gameRoomMapper.selectRoom(DEFAULT_ROOM_ID);
    if (room == null) {
      throw new RoomNotFoundException();
    }
    return room;
  }

  public static class RoomFullException extends RuntimeException {
    private static final long serialVersionUID = 1L;
  }

  public static class RoomNotFoundException extends RuntimeException {
    private static final long serialVersionUID = 1L;
  }
}
