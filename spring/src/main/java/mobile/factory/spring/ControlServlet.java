package mobile.factory.spring;

import jakarta.servlet.ServletException;

import org.springframework.beans.BeansException;
import org.springframework.web.servlet.DispatcherServlet;

/**
 * <pre>
 * 이 클래스는 servlet이 초기화 될때 실행할 기능을 정의함
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2016. 5. 12.
 * @time 오후 7:50:35
 **/
public abstract class ControlServlet extends DispatcherServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = -6618024472784190164L;

	@Override
	protected void initFrameworkServlet() throws ServletException, BeansException {
		super.initFrameworkServlet();
		initContextObject();
	}

	/**
	 * 서버가 초기화 되고 나서 실행할 액션기술(최초한번만) 예)코드값셋팅, 리스트 row 셋팅
	 */
	protected abstract void initContextObject();
}
// :)--