package mobile.factory.spring.beans;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;

/**
 * <pre>
 * 이클래스는 프로시저 결과 정보를 담고 있음.
 * </pre>
 *
 * @author JY.Eom
 * @date 2017-04-24
 * @time 09:24:31
 */
public class BeanResultProcedure {
	/**
	 * 프로시저 성공 결과 코드
	 */
	public static final String RESULT_SUCCESS = "00000";

	private String resultCode = "";
	private String resultMsg = "";
	private String resultValue = "";

	public boolean success() {
		return StringUtils.equals(RESULT_SUCCESS, getResultCode());
	}

	public String getResultCode() {
		return resultCode;
	}

	public void setResultCode(String resultCode) {
		this.resultCode = resultCode;
	}

	public String getResultMsg() {
		return resultMsg;
	}

	public void setResultMsg(String resultMsg) {
		this.resultMsg = resultMsg;
	}

	public String getResultValue() {
		return resultValue;
	}

	public void setResultValue(String resultValue) {
		this.resultValue = resultValue;
	}

	/**
	 * 맵으로 변환
	 * 
	 * @return
	 */
	public Map<String, Object> toMap() {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("resultCode", getResultCode());
		map.put("resultMsg", getResultMsg());
		map.put("resultValue", getResultValue());
		
		return map;
	}
}
// :)--