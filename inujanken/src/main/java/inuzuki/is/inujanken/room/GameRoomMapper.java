package inuzuki.is.inujanken.room;

import java.util.List;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface GameRoomMapper {
  @Select("SELECT id, name, status FROM game_room WHERE id = #{roomId}")
  GameRoom selectRoom(long roomId);

  @Select("SELECT username, started FROM game_participant WHERE room_id = #{roomId} ORDER BY joined_at, username")
  List<GameParticipant> selectParticipants(long roomId);

  @Select("SELECT COUNT(*) FROM game_participant WHERE room_id = #{roomId}")
  int countParticipants(long roomId);

  @Select("SELECT COUNT(*) FROM game_participant WHERE room_id = #{roomId} AND started = TRUE")
  int countStartedParticipants(long roomId);

  @Select("SELECT COUNT(*) FROM game_participant WHERE room_id = #{roomId} AND username = #{username}")
  int countParticipant(long roomId, String username);

  @Insert("INSERT INTO game_participant (room_id, username, started) VALUES (#{roomId}, #{username}, FALSE)")
  int insertParticipant(long roomId, String username);

  @Update("UPDATE game_participant SET started = TRUE WHERE room_id = #{roomId} AND username = #{username}")
  int markStarted(long roomId, String username);

  @Update("UPDATE game_room SET status = 'STARTED' WHERE id = #{roomId} AND status = 'WAITING'")
  int markRoomStarted(long roomId);
}
