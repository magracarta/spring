package hello.core2.order;

import hello.core2.Order.Order;
import hello.core2.Order.OrderService;
import hello.core2.Order.OrderServiceImpl;
import hello.core2.member.Grade;
import hello.core2.member.Member;
import hello.core2.member.MemberService;
import hello.core2.member.MemberServiceImpl;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;

public class OrderServiceTest {
    MemberService memberService = new MemberServiceImpl();
    OrderService orderService = new OrderServiceImpl();

    @Test
    void CreateOrder() {
        Long memberId = 1L;
        Member member = new Member(memberId, "memberA", Grade.VIP);
        memberService.join(member);

        Order order = orderService.createOrder(memberId, "itemA", 1000);
        Assertions.assertThat(order.getDiscountPrice()).isEqualTo(1000);

    }
}
