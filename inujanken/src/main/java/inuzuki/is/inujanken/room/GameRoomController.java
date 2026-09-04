package inuzuki.is.inujanken.room;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class GameRoomController {
  private final GameRoomService gameRoomService;

  public GameRoomController(GameRoomService gameRoomService) {
    this.gameRoomService = gameRoomService;
  }

  @GetMapping("/game")
  public String showRoom(Authentication authentication, Model model) {
    return show(authentication.getName(), model, null);
  }

  @PostMapping("/game/start")
  public String start(Authentication authentication, Model model) {
    try {
      return show(authentication.getName(), model, gameRoomService.markReady(authentication.getName()));
    } catch (GameRoomService.RoomFullException exception) {
      return show(authentication.getName(), model, "ルームが満員のため参加できません。");
    }
  }

  private String show(String username, Model model, Object stateOrError) {
    GameRoomView view;
    if (stateOrError instanceof GameRoomView roomView) {
      view = roomView;
    } else {
      try {
        view = gameRoomService.joinAndLoad(username);
      } catch (GameRoomService.RoomFullException exception) {
        view = gameRoomService.load(username);
        model.addAttribute("errorMessage", "ルームが満員のため参加できません。");
      }
    }
    model.addAttribute("gameRoom", view);
    if (stateOrError instanceof String errorMessage) {
      model.addAttribute("errorMessage", errorMessage);
    }
    return "game-room";
  }
}
