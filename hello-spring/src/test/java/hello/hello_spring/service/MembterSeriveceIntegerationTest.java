package hello.hello_spring.service;

import hello.hello_spring.domain.Member;
import hello.hello_spring.repository.MemberRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Commit;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

@SpringBootTest
@Transactional
class MemberServiceIntegrationTest {

    @Autowired MemberSerivece memberSerivece;
    @Autowired MemberRepository memberRepository;


    @Test
    void 회원가입() throws Exception {
        //given
        Member member = new Member();
        member.setName("Spring2");
        System.out.println("--------------------------"+member);
        //when
        Long saveId = memberSerivece.join(member);
        //then
        Member findMember = memberSerivece.findone(saveId).get();
        assertThat(member.getName()).isEqualTo(findMember.getName());


    }

    @Test
    public void 중복_확인_예외(){
        //given
        Member member1 = new Member();
        member1.setName("Spring");
        Member member2 = new Member();
        member2.setName("Spring");
        //when
        memberSerivece.join(member1);
        IllegalStateException e = assertThrows(IllegalStateException.class, () -> memberSerivece.join(member2));
        assertThat(e.getMessage()).isEqualTo("이미 존재하는 회원입니다.");

        //then
    }

}