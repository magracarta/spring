package hello.core2.discount;

import hello.core2.member.Grade;
import hello.core2.member.Member;
import org.springframework.stereotype.Component;

@Component
public class FixDiscountPolicy implements DiscountPolicy {
    private int discountFixAmount = 1000;

    @Override
    public int discount(Member member, int Price) {
        if(member.getGrade() == Grade.VIP){
            return  discountFixAmount;
        }
        return 0;
    }
}
