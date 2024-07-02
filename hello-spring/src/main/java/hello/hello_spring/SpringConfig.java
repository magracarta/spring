package hello.hello_spring;

import hello.hello_spring.repository.MemberRepository;
import hello.hello_spring.repository.MemoryMemberRepository;
import hello.hello_spring.service.MemberSerivece;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SpringConfig {
    @Bean
    public MemberSerivece memberSerivece(){
        return  new MemberSerivece(memberRepository());
    }
    @Bean
    public MemberRepository memberRepository(){
        return  new MemoryMemberRepository();
    }

}
