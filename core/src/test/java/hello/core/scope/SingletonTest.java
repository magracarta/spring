package hello.core.scope;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Scope;

public class SingletonTest {
    @Test
    void singletonBeanFind(){
        AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(SingletonBean.class);
        SingletonBean singeltonBean1 = ac.getBean(SingletonBean.class);
        SingletonBean singeltonBean2 = ac.getBean(SingletonBean.class);

        System.out.println("singeltonBean1 = " + singeltonBean1);
        System.out.println("singeltonBean2 = " + singeltonBean2);

        Assertions.assertThat(singeltonBean1).isSameAs(singeltonBean2);

        ac.close();
    }

    @Scope("singleton")
    static class  SingletonBean{
        @PostConstruct
        public void init(){
            System.out.println("SingletonBean.init");
        }

        @PreDestroy
        public void destroy(){
            System.out.println("SingletonBean.destroy");
        }
    }
}
