package hello.core.autowired;

import hello.core.AutoConfig;
import hello.core.Member.Grade;
import hello.core.Member.Member;
import hello.core.discount.DiscountPolicy;
import lombok.RequiredArgsConstructor;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

public class AllBeanTest {
    @Test
    void findAllBean(){
        ApplicationContext ac = new AnnotationConfigApplicationContext(AutoConfig.class ,DiscountService.class);

        DiscountService discountService = ac.getBean(DiscountService.class);
        Member member = new Member(1L, "userA", Grade.VIP);
        int discountPrice = discountService.discount(member, 10000 , "fixDiscountPolicy");

        assertThat(discountService).isInstanceOf(DiscountService.class);
        assertThat(discountPrice).isEqualTo(1000);

        int rateDisocuntPrice = discountService.discount(member,20000,"rateDiscountPolicy");
        assertThat(rateDisocuntPrice).isEqualTo(2000);
    }

    @RequiredArgsConstructor
    static class DiscountService{
        private final Map<String , DiscountPolicy> policyMap;
        private final List<DiscountPolicy> policies;

//        @Autowired
//        public DiscountService(Map<String , DiscountPolicy> policyMap, List<DiscountPolicy> policies) {
//            this.policyMap = policyMap;
//            this.policies = policies;
//
//        }

        public int discount(Member member, int price, String discountCode) {
            System.out.println("policyMap = " + policyMap);
            System.out.println("policies = " + policies);
            DiscountPolicy discountPolicy = policyMap.get(discountCode);
            return  discountPolicy.discount(member,price);
        }
    }
}
