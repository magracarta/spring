package hello.core2.reflection;

import hello.core2.member.MemberService;
import hello.core2.member.MemberServiceImpl;
import org.junit.jupiter.api.Test;

public class TestClassInterface {

    @Test
    public void test() {
        Class ms = MemberServiceImpl.class;
        System.out.println(ms.getName());
        Class[] interfaces = ms.getInterfaces();

        for (Class i : interfaces) {
            System.out.println(i);
        }
    }
}
