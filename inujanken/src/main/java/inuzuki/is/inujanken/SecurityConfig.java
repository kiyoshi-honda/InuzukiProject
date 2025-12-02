package inuzuki.is.inujanken;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Spring Security の新しい設定方式（WebSecurityConfigurerAdapter 非推奨/削除対応）。
 * - in-memory にユーザを登録（yamada / taro）
 * - BCrypt を使ってパスワードをエンコード
 * - デフォルトのログインページを使用
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

  @Bean
  public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  @Bean
  public UserDetailsService userDetailsService(PasswordEncoder passwordEncoder) {
    UserDetails user = User.withUsername("yamada")
        .password(passwordEncoder.encode("taro"))
        .roles("USER")
        .build();
    return new InMemoryUserDetailsManager(user);
  }

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests(auth -> auth
            // 静的リソースは公開
            .requestMatchers(
                "/", "/index.html", "/favicon.ico",
                "/css/**",
                "/js/**",
                "/images/**",
                "/webjars/**")
            .permitAll()
            // その他は認証を要求
            .anyRequest().authenticated())
        // デフォルトのフォームログインを使用
        .formLogin(form -> form.permitAll())
        .logout(logout -> logout.permitAll());

    return http.build();
  }
}
