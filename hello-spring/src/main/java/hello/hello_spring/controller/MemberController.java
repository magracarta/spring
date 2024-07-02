package hello.hello_spring.controller;

import hello.hello_spring.service.MemberSerivece;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

@Controller
public class MemberController {
    private final MemberSerivece memberSerivece;

    @Autowired
    public MemberController(MemberSerivece memberSerivece) {
        this.memberSerivece = memberSerivece;
    }

}
