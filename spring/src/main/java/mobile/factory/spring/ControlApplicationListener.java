package mobile.factory.spring;

import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;

/**
 * <pre>
 * 이 클래스는 Application이 시작/종료 될때 호출되는 기능을 정의 
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2019. 12. 30. 
 * @time 오전 10:56:41
**/
public abstract class ControlApplicationListener implements ApplicationListener<ContextRefreshedEvent> {

}
//:)--