package hello.core.beanfind;

import hello.core.AppConfig;
import hello.core.Member.MemberService;
import hello.core.Member.MemberServiceImpl;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.NoSuchBeanDefinitionException;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;

public class ApplicationContextBasicFindTest {
    AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(AppConfig.class);

    @Test
    @DisplayName("빈 이름으로 조회")
    void findBeanByName(){
        MemberService memberService = (MemberService) ac.getBean("memberService" , MemberService.class);
        System.out.println("memberService = "+ memberService);
        System.out.println("memberService.getClass() = " + memberService.getClass());
        assertThat(memberService).isInstanceOf(MemberServiceImpl.class);
    }

    @Test
    @DisplayName("이름 없이 타입으로만 조히")
    void findBeanByType(){
        MemberService memberService = (MemberService) ac.getBean(MemberService.class);
        System.out.println("memberService = "+ memberService);
    }

    @Test
    @DisplayName("구체 타입으로 조회")
    void findBeanByName2(){
        MemberService memberService = (MemberService) ac.getBean("memberService" , MemberServiceImpl.class);

        assertThat(memberService).isInstanceOf(MemberServiceImpl.class);
    }

    @Test
    @DisplayName("빈 이름으로 조회 X")
    void findBeanByNameX(){
        //ac.getBean("xxxx", MemberService.calss);
        //ac.getBean("xxxxx", MemberService.class);
        assertThrows(NoSuchBeanDefinitionException.class , ()->{
            ac.getBean("xxxxx", MemberServiceImpl.class);
        });
    }

}
