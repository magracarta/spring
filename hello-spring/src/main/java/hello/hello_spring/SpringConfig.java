package hello.hello_spring;

import hello.hello_spring.aop.TimeTraceAop;
import hello.hello_spring.repository.*;
import hello.hello_spring.service.MemberSerivece;
import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class SpringConfig{
    private final MemberRepository memberRepository;

    public SpringConfig(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }


    @Bean
    public MemberSerivece memberSerivece(){
        return  new MemberSerivece(memberRepository);
    }


    //    private EntityManager em;
//
//    @Autowired
//    public SpringConfig(EntityManager em) {
//        this.em = em;
//    }
    //    private DataSource dataSource;
//
//    @Autowired
//    public SpringConfig(DataSource dataSource) {
//        this.dataSource = dataSource;
//    }



    /*@Bean
    public MemberRepository memberRepository(){
        // return new MemoryMemberRepository();
       //return  new JdbcMemberRepository(dataSource);
       //return  new JdbcTemplateMemberRepository(dataSource);
       //return  new JpaMemberRepository(em);

    }

     */

}
