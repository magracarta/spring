package hello.hello_spring.service;

import hello.hello_spring.domain.Member;
import hello.hello_spring.repository.MemoryMemberRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.junit.jupiter.api.Assertions.*;

class MembterSeriveceTest {
    MemberSerivece memberSerivece;
    MemoryMemberRepository memoryMemberRepository;

    @BeforeEach
    public void beforEach(){
        memoryMemberRepository = new MemoryMemberRepository();
        memberSerivece = new MemberSerivece(memoryMemberRepository);
    }


    @AfterEach
    public void afterEach(){
        memoryMemberRepository.clearStore();
    }

    @Test
    void 회원가입() {
        //given
        Member member = new Member();
        member.setName("Spring");
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

    @Test
    void findMembers() {
    }

    @Test
    void findone() {
    }
}