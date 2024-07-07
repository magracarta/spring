package hello.hello_spring.aop;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class TimeTraceAop {
    @Around("execution(* hello.hello_spring.service..*(..))")
    public  Object exeute(ProceedingJoinPoint joinPoint) throws  Throwable{
        long start = System.currentTimeMillis();
        System.out.println("START : "+ joinPoint.toLongString());
        try {
            return joinPoint.proceed();
        }finally {
            long finish = System.currentTimeMillis();
            long timms = finish - start;
           System.out.println("END : "+ joinPoint.toLongString() + " " + timms + "ms");
        }
    }

}
