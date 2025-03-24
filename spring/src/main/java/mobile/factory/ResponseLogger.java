package mobile.factory;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * <pre>
 * 이클래스는 response 보낼때 처리할 로그 기능을 정의함 
 * </pre>
 *
 * @author JY.Eom
 * @date 2017-08-02
 * @time 11:11:90
 */
public interface ResponseLogger {
	/**
	 * 입력 로그 저장
	 * @param inMap
	 */
	public void inSave(Map<String, Object> inMap, HttpServletRequest req);
	
	/**
	 * 출력로그 저장
	 * @param inMap
	 * @param result
	 */
	public void outSave(Map<String, Object> inMap, String result);
	
	/**
	 * 에러로그 저장
	 * @param inMap
	 * @param result
	 */
	public void errorSave(Map<String, Object> inMap, Exception exception);
	
	/**
	 * 로그저장할지 체크
	 * @param inMap
	 * @return
	 */
	public boolean ignoreUri(Map<String, Object> inMap);
	
	/**
	 * 로그저장할지 체크
	 * @param inMap
	 * @return
	 */
	public boolean ignoreUri(String uri);
	
	/**
	 * 디비에 로그저장여부
	 * @return
	 */
	public boolean saveDB();
	
	/**
	 * 에러만 처리할지 여부
	 * @return
	 */
	public boolean onlyError();
}
//:)--