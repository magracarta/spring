package hello.core2.order;

import hello.core2.AppConfig;
import hello.core2.Order.Order;
import hello.core2.Order.OrderService;
import hello.core2.Order.OrderServiceImpl;
import hello.core2.discount.FixDiscountPolicy;
import hello.core2.member.*;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

public class OrderServiceTest {
    MemberService memberService;
    OrderService orderService;

    @BeforeEach
    public void beforeEach(){
        AppConfig appConfig = new AppConfig();
        memberService = appConfig.memberService();
        orderService = appConfig.orderService();
    }

    @Test
    void CreateOrder() {
        Long memberId = 1L;
        Member member = new Member(memberId, "memberA", Grade.VIP);
        memberService.join(member);

        Order order = orderService.createOrder(memberId, "itemA", 20000);
        Assertions.assertThat(order.getDiscountPrice()).isEqualTo(2000);

    }

    @Test
    void fieldInjectionTest(){

    }}
