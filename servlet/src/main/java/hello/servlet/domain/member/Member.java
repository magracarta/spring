package hello.servlet.domain.member;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class Member {
    private Long id;
    private String username;
    private int age;

    public Member(String username, int i) {
        this.username = username;
        this.age = i;
    }
}
