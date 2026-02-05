package hello.springmvc.basic;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
public class LogTestController {

    @RequestMapping("/log-test")
    public String logTest() {
        String name = "Spring";

        System.out.println("name = " + name);

        //+ 텍스트로 하게 되면 문자열 + 문자열로 연산을 하게 되어 쓸데없는 메모리 낭비가 된다 .
        // 해서 + 보다는 {} 로 바인딩 해주는게 좋다.
        //log.trace("trace ="+name);
        log.trace("trace ={}",name);
        log.debug("debug ={}",name);
        log.info("info={}", name);
        log.warn("warn={}", name);
        log.error("error={}", name);

        return "ok";
    }
}
