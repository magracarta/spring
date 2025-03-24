package mobile.factory.util;

import java.util.List;
import java.util.Map;

import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

/**
 * <pre>
 * 이클래스는 단위 테스트를 하기 위한 Param을 가공
 * </pre>
 *
 * @author JY.Eom
 * @date 2017-02-10
 * @time 11:55:48
 */
public class UnitTestUtil {
	/**
	 * MockMvc params를 생성
	 * @param param value : String, String[] 만 생성
	 * @return
	 */
	public static MultiValueMap<String, String> toParam(Map<String, Object> param) {
		MultiValueMap<String, String> params =new LinkedMultiValueMap<>();

		for(String key : param.keySet()) {
			Object obj = param.get(key);
			List<String> list = null;
			
			if(obj instanceof String) {
				list = CollectionUtil.toStringList(new String[]{obj.toString()});
			} else if(obj instanceof String[]) {
				list = CollectionUtil.toStringList((String[]) obj);
			}
			
			params.put(key, list);
		}
		
		return params;
	}
}
// :)--