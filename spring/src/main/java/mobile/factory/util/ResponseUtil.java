package mobile.factory.util;

import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
/**
 * <pre>
 * 이 클래스는 Response 관련 유틸 모음
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2016. 6. 10.
 * @time 오후 12:56:23
 **/
public class ResponseUtil {
	public static final int ERR_ = -1;

	/**
	 * 결과 json 을 생성할 기본 맵 생성
	 * 
	 * @param resultCode
	 *            결과 코드 HttpServletResponse.SC_XX 코드 참조
	 * @param resultMsg
	 *            결과 메시지
	 * @param resultShow
	 *            결과 메시지를 보여줄지 여부
	 * @return
	 */
	public static Map<String, Object> result(int resultCode, String resultMsg, boolean resultShow) {
		Map<String, Object> map = new LinkedHashMap<String, Object>();
		map.put("result_code", resultCode + "");
		map.put("result_msg", resultMsg);
		map.put("result_show_yn", resultShow ? "Y" : "N");

		return map;
	}

	/**
	 * 처리성공
	 * 
	 * @param resultMsg
	 *            결과 메시지(""이면 기본 성공 메시지)
	 * @param resultShow
	 *            결과 메시지를 보여줄지 여부
	 * @return
	 */
	public static Map<String, Object> successResult(String resultMsg, boolean resultShow) {
		resultMsg = StringUtils.defaultIfBlank(resultMsg, MessageDefine.MSG_PROC_SUCC);
		return result(HttpServletResponse.SC_OK, resultMsg, resultShow);
	}

	/**
	 * 처리성공
	 * 
	 * @param resultMsg
	 *            결과 메시지, 무조건 메시지 보여줌
	 * @return
	 */
	public static Map<String, Object> successResult(String resultMsg) {
		return successResult(resultMsg, StringUtils.isNoneBlank(resultMsg));
	}

	/**
	 * 처리성공
	 * 
	 * @return 처리성공 상태만 셋팅, 메시지 없음
	 */
	public static Map<String, Object> successResult() {
		return successResult(MessageDefine.MSG_PROC_SUCC, false);
	}
	
	/**
	 * 처리성공
	 * 
	 * @param data
	 *            추가로 header에 넣을 메시지
	 * @param field
	 *            보여줄 필드
	 * @return 처리성공 상태만 셋팅, 메시지 없음
	 */
	public static Map<String, Object> successResult(Map<String, Object> data, String... field) {
		Map<String, Object> result = successResult(MessageDefine.MSG_PROC_SUCC, false);
		if (data != null) {
			if (field != null) {
				for (String item : field) {
					String val = data.containsKey(item) ? data.get(item).toString() : "";
					result.put(item, val);
				}
			} else {
				result.putAll(data);
			}
		}
		return result;
	}

	/**
	 * 처리성공
	 * 
	 * @param data
	 *            data 추가로 header에 넣을 메시지
	 * @return 처리성공 상태만 셋팅, 메시지 없음
	 */
	public static Map<String, Object> successResult(Map<String, Object> data) {
		return successResult(data, null);
	}
	
	/**
	 * 성공후 메시지 추가
	 * 
	 * @param resultMsg
	 * @param date
	 * @return
	 */
	public static Map<String, Object> successResult(String resultMsg, boolean resultShow, Map<String, Object> date) {
		Map<String, Object> map = successResult(resultMsg, resultShow);
		map.putAll(date);

		return map;
	}

	/**
	 * body 에 리스트로 생성
	 * 
	 * @param keyName
	 *            키값
	 * @param list
	 * @return
	 */
	public static Map<String, Object> successResult(String keyName, List<Map<String, Object>> list) {
		Map<String, Object> result = successResult();
		if("list".equals(keyName) && result.containsKey("total_cnt") == false) {
			result.put("total_cnt", (list != null && list.isEmpty() == false) ? list.size() : 0);
		}
		// 조회 결과가 없을 때, 클라이언트에서 그리드가 갱신안되고 undefined 나는 문제 수정 by 김태훈
		if (list == null) {
			list = Collections.emptyList();
		}
		result.put(keyName, list);

		return result;
	}

	/**
	 * body 에 리스트로 생성 기본키값은 list
	 * 
	 * @param list
	 * @return
	 */
	public static Map<String, Object> successResult(List<Map<String, Object>> list) {
		return successResult("list", list);
	}

	/**
	 * 처리 오류
	 * 
	 * @param resultCode
	 *            결과 코드 (200 이외의 값)
	 * @param resultMsg
	 *            오류메시지
	 * @return
	 */
	public static Map<String, Object> failResult(int resultCode, String resultMsg) {
		return result(resultCode, resultMsg, true);
	}

	/**
	 * 처리 오류
	 * 
	 * @param resultMsg
	 * @return
	 */
	public static Map<String, Object> failResult(String resultMsg) {
		return failResult(-1, resultMsg);
	}

	/**
	 * 처리오류(오류메시지 셋팅)
	 * 
	 * @return
	 */
	public static Map<String, Object> failResult() {
		return failResult(MessageDefine.MSG_PROC_FAIL);
	}

	/**
	 * 페이징되는 그리드에 성공 결과 반환
	 * 
	 * @param list
	 *            화면에 뿌려질 리스트
	 * @param totalCnt
	 *            그리드 전체 카운트
	 * @return
	 */
	public static Map<String, Object> successResult(List<Map<String, Object>> list, int totalCnt) {
		Map<String, Object> gridMap = new HashMap<>();
		gridMap.put("rows", list);
		gridMap.put("total", totalCnt);

		Map<String, Object> result = successResult();
		result.put("list", gridMap);

		return result;
	}

	/**
	 * 처리실패
	 *
	 * @param data
	 *            data 추가로 header에 넣을 메시지
	 * @return 처리실패 상태만 셋팅, 메시지 없음
	 */
	public static Map<String, Object> failResult(Map<String, Object> data) {
		Map<String, Object> result = failResult(MessageDefine.MSG_PROC_FAIL);
		if (data != null) {
			result.put("result", data);
		}
		return result;
	}
}
// :)--