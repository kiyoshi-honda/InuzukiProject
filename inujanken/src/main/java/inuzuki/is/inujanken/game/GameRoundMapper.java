package inuzuki.is.inujanken.game;

import java.util.List;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface GameRoundMapper {
  @Select("SELECT status FROM game_room WHERE id = #{roomId}")
  String selectRoomStatus(long roomId);

  @Select("SELECT COUNT(*) FROM game_participant WHERE room_id = #{roomId} AND username = #{username}")
  int countRoomParticipant(@Param("roomId") long roomId, @Param("username") String username);

  @Select("SELECT COUNT(*) FROM game_round WHERE room_id = #{roomId}")
  int countRound(long roomId);

  @Insert("INSERT INTO game_round (room_id, status) VALUES (#{roomId}, 'WAITING')")
  int insertRound(long roomId);

  @Insert("INSERT INTO game_round_participant (room_id, username) "
      + "SELECT room_id, username FROM game_participant WHERE room_id = #{roomId}")
  int insertRoundParticipants(long roomId);

    @Select("SELECT room_id AS roomId, dog_hand AS dogHand, status "
            + "FROM game_round WHERE room_id = #{roomId}")
  GameRound selectRound(long roomId);

  @Select("SELECT rp.username, rp.hand FROM game_round_participant rp "
      + "JOIN game_participant gp ON gp.room_id = rp.room_id AND gp.username = rp.username "
      + "WHERE rp.room_id = #{roomId} ORDER BY gp.joined_at, rp.username")
  List<GameRoundParticipant> selectRoundParticipants(long roomId);

  @Update("UPDATE game_round_participant SET hand = #{hand} "
      + "WHERE room_id = #{roomId} AND username = #{username} "
      + "AND EXISTS (SELECT 1 FROM game_round WHERE room_id = #{roomId} AND dog_hand IS NULL)")
  int saveHand(@Param("roomId") long roomId, @Param("username") String username, @Param("hand") String hand);

  @Select("SELECT COUNT(*) FROM game_round_participant WHERE room_id = #{roomId} AND hand IS NULL")
  int countUnsubmitted(long roomId);

  @Update("UPDATE game_round SET dog_hand = #{dogHand}, status = 'COMPLETE' "
      + "WHERE room_id = #{roomId} AND dog_hand IS NULL")
  int completeRound(@Param("roomId") long roomId, @Param("dogHand") String dogHand);
}