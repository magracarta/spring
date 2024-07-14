package hello.core.order;

import hello.core.Member.Member;
import hello.core.Member.MemberRepository;
import hello.core.Member.MemoryMemberRepository;
import hello.core.annotaion.MainDiscountPolicy;
import hello.core.discount.DiscountPolicy;
import hello.core.discount.FixDiscountPolicy;
import hello.core.discount.RateDiscountPolicy;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;


@Component
//@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {
//    private final MemberRepository memberRepository;
//    private final DiscountPolicy discountPolicy;
    private final MemberRepository memberRepository;
    private final DiscountPolicy discountPolicy;



    public OrderServiceImpl(MemberRepository memberRepository, @MainDiscountPolicy DiscountPolicy discountPolicy) {
        //System.out.println("discountPolicy / discountPolicy = " + discountPolicy + discountPolicy);
        this.memberRepository = memberRepository;
        this.discountPolicy = discountPolicy;
    }

    @Override
    public Order createOrder(Long memberId, String itemName, int itemPrice) {
        Member member = memberRepository.findById(memberId);
        int discountPrice= discountPolicy.discount(member , itemPrice);
        return new Order(memberId, itemName , itemPrice, discountPrice );
    }

    //테스트 용도
    public MemberRepository getMemberRepository() {
        return memberRepository;
    }
}
