package hello.core2.common;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.springframework.context.annotation.Scope;
import org.springframework.context.annotation.ScopedProxyMode;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@Scope(value = "request" , proxyMode = ScopedProxyMode.TARGET_CLASS)
public class MyLogger {
    private String uuid;
    private String requestURL;

    public void setRequestURL(String requestURL){
        this.requestURL = requestURL;
    }

    public void log(String msg){
        System.out.println("["+uuid+"]["+requestURL+"] "+msg);
    }

    @PostConstruct
    public void init(){
      uuid =  UUID.randomUUID().toString();
        System.out.println("["+uuid+"] request scope bean create : "+ this);
    }

    @PreDestroy
    public void close(){
        System.out.println("["+uuid+"] request scope bean close : "+ this);
    }


}
