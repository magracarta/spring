package hello.core2;

import hello.core2.Order.OrderService;
import hello.core2.Order.OrderServiceImpl;
import hello.core2.member.MemberRepository;
import hello.core2.member.MemoryMemberRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;

@Configuration
@ComponentScan (
//        basePackages = "hello.core2", //시작할 때 이 패키지를 포함해서 하위 패키지를 모두 탐색.
//        basePackageClasses = AutoAppConfig.class, //지정한 클래스의 패키지를 탐색 시작위치로 지정.
        excludeFilters = @ComponentScan.Filter (type = FilterType.ANNOTATION, classes = Configuration.class)
)
public class AutoAppConfig {

//    @Bean(name = "memoryMemberRepository")
//    public MemberRepository memberRepository() {
//        return new MemoryMemberRepository();
//    }

}
