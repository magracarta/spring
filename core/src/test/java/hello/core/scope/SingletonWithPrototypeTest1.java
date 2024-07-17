package hello.core.scope;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Scope;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

public class SingletonWithPrototypeTest1 {

    @Test
    void  prototypeFind(){
        AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(PrototypeBean.class);
        PrototypeBean prototypeBean1 = ac.getBean(PrototypeBean.class);
        prototypeBean1.addCount();
        assertThat(prototypeBean1.getCount()).isEqualTo(1);

        PrototypeBean prototypeBean2 = ac.getBean(PrototypeBean.class);
        prototypeBean2.addCount();
        assertThat(prototypeBean2.getCount()).isEqualTo(1);
    }

    @Test
    void singletonClientUserPrototype(){
        AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(ClinetBean.class , PrototypeBean.class);
        ClinetBean clientBean1 = ac.getBean(ClinetBean.class);
        int count1 = clientBean1.login();
        ClinetBean clientBean2 = ac.getBean(ClinetBean.class);
        int count2 = clientBean2.login();

        assertThat(count2).isEqualTo(2);
    }

    @Scope("singleton")
    @RequiredArgsConstructor
    static  class ClinetBean{
        private  final  PrototypeBean prototypeBean; //생성 시점에 주입

        public int login(){
            prototypeBean.addCount();
            return prototypeBean.getCount();
        }
    }

    @Scope("prototype")
    static class PrototypeBean{
        private int count = 0;

        public void addCount(){
            count++;
        }

        public int getCount(){
            return count;
        }

        @PostConstruct
        public void init(){
            System.out.println("PrototypeBean.init"+ this);
        }

        @PreDestroy
        public void destroy(){
            System.out.println("PrototypeBean.destroy");
        }
    }
}
