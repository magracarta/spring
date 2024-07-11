package hello.core.scan;

import hello.core.AutoConfig;
import hello.core.Member.MemberService;
import hello.core.Member.MemberServiceImpl;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class AutoAppConfigTest {
    @Test
    void besicScan(){
        AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(AutoConfig.class);
        MemberService memberService = ac.getBean(MemberService.class);

        String [] beanDefintionNames  = ac.getBeanDefinitionNames();
        for(String beanDefintionName : beanDefintionNames ){
            BeanDefinition beanDefinition = ac.getBeanDefinition(beanDefintionName);
            if(beanDefinition.getRole() == BeanDefinition.ROLE_APPLICATION){
                System.out.println("bean => " +beanDefintionName );
            }
        }
        Assertions.assertThat(memberService).isInstanceOf(MemberService.class);

    }
}
