package inuzuki.is.inujanken.game;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class GameRoundController {
  private final GameRoundService gameRoundService;

  public GameRoundController(GameRoundService gameRoundService) {
    this.gameRoundService = gameRoundService;
  }

  @GetMapping("/game/round")
  public String showRound(Authentication authentication, Model model) {
    model.addAttribute("gameRound", gameRoundService.load(authentication.getName()));
    model.addAttribute("hands", Hand.values());
    return "game-round";
  }

  @PostMapping("/game/round/hand")
  public String submitHand(Authentication authentication, @RequestParam("hand") Hand hand) {
    gameRoundService.submitHand(authentication.getName(), hand);
    return "redirect:/game/round";
  }
}