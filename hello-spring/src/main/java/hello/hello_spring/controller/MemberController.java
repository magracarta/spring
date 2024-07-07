package hello.hello_spring.controller;

import hello.hello_spring.domain.Member;
import hello.hello_spring.service.MemberSerivece;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.List;

@Controller
public class MemberController {
    private final MemberSerivece memberSerivece;

    @Autowired
    public MemberController(MemberSerivece memberSerivece) {
        this.memberSerivece = memberSerivece;

        System.out.println("memberSerice = "+ memberSerivece.getClass());
    }


    @GetMapping("/members/new")
    public String createForm() {
        return "member/createMemberForm";
    }

    @PostMapping("/members/new")
    public String create(MemberForm form){
        Member member = new Member();
        member.setName(form.getName());

        System.out.println("member = " + member.getName() );

        memberSerivece.join(member);

        return "redirect:/";
    }

    @GetMapping("/members")
    public String list(Model model){
        List<Member> members = memberSerivece.findMembers();
        model.addAttribute("members", members);
        return "member/listMembers";
    }
}
