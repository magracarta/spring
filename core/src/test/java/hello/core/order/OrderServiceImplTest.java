package hello.core.order;

import hello.core.Member.Grade;
import hello.core.Member.Member;
import hello.core.Member.MemoryMemberRepository;
import hello.core.discount.FixDiscountPolicy;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class OrderServiceImplTest {
    @Test
    void createOrder() {
        MemoryMemberRepository memoryMemberRepository = new MemoryMemberRepository();
        memoryMemberRepository.save(new Member(1L, "name" , Grade.VIP));

        OrderServiceImpl orderService = new OrderServiceImpl(new MemoryMemberRepository(), new FixDiscountPolicy());
        Order order = orderService.createOrder(1L , "itemA", 10000);
        orderService.createOrder(1L, "itmeA", 10000);

        Assertions.assertThat(order.getDicountPrice()).isEqualTo(1000);

    }

}