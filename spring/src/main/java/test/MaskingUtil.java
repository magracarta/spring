package test;

import java.util.*;

/**
 * <pre>
 * 이 클래스는 요소의 값을 마스킹(*)로 만드는 유틸
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2020. 11. 4.
 * @time 오후 8:30:40
 **/
public class MaskingUtil {
	/**
	 * 마스킹
	 * 
	 * @param bean
	 *            대상 데이터
	 * @param noFieldName
	 *            마스킹 제외할 목록
	 * @param propMap
	 *            마스킹 방법, if null all masking
	 * @return
	 */
	public static Map<String, Object> makeMasking(Map<String, Object> bean, Set<String> noFieldName, Map<String, Masking> propMap) {
		if (bean == null || bean.isEmpty()) {
			return bean;
		}

		Map<String, Object> retMap = new HashMap<String, Object>();
		for (String key : bean.keySet()) {
			Object valObj = bean.get(key);
			if (valObj == null || valObj instanceof String == false) {
				retMap.put(key, valObj);
				continue;
			}

			String valStr = valObj.toString();
			// 마스킹 제외인가?
			if (noFieldName != null && noFieldName.contains(key)) {
				retMap.put(key, valObj);
				continue;
			}

			// 마스킹 설정이 있는가?
			if (propMap != null && propMap.containsKey(key)) {
				Masking prop = propMap.get(key);
				retMap.put(key, prop.getMasking(valStr));
			} else {
				retMap.put(key, FormatUtil.asterisk(valStr, 0, valStr.length()));
			}
		}

		return retMap;
	}

	public static Map<String, Object> makeMasking(Map<String, Object> bean, Set<String> noFieldName) {
		return makeMasking(bean, noFieldName, null);
	}

	public static Map<String, Object> makeMasking(Map<String, Object> bean, Map<String, Masking> propMap) {
		return makeMasking(bean, null, propMap);
	}

	/**
	 * 마스킹
	 * 
	 * @param bean
	 *            대상 데이터
	 * @param noFieldName
	 *            마스킹 제외할 목록
	 * @param propMap
	 *            마스킹 방법, if null all masking
	 * @return
	 */
	public static List<Map<String, Object>> makeMasking(List<Map<String, Object>> list, Set<String> noFieldName, Map<String, Masking> propMap) {
		if (list == null || list.isEmpty()) {
			return list;
		}

		List<Map<String, Object>> retList = new ArrayList<Map<String, Object>>();
		for (Map<String, Object> bean : list) {
			retList.add(makeMasking(bean, noFieldName, propMap));
		}
		return retList;
	}

	public static List<Map<String, Object>> makeMasking(List<Map<String, Object>> list, Set<String> noFieldName) {
		return makeMasking(list, noFieldName, null);
	}

	public static List<Map<String, Object>> makeMasking(List<Map<String, Object>> list, Map<String, Masking> propMap) {
		return makeMasking(list, null, propMap);
	}

	public static class Masking {
		/**
		 * 첫문자부터
		 */
		boolean first = true;
		/**
		 * 마스킹할 글자수(0이면 전체)
		 */
		int maskingCnt = 0;
		/**
		 * 시작위치(뒤에서하면 뒤에서 부터)
		 */
		int startIdx = 0;

		public Masking(boolean first, int startIdx, int maskingCnt) {
			super();
			this.first = first;
			this.startIdx = startIdx < 0 ? 0 : startIdx;
			this.maskingCnt = maskingCnt < 0 ? 0 : maskingCnt;
		}

		public Masking(boolean first, int startIdx) {
			super();
			this.first = first;
			this.startIdx = startIdx < 0 ? 0 : startIdx;
		}

		public boolean isFirst() {
			return first;
		}

		public int getMaskingCnt() {
			return maskingCnt;
		}

		public int getStartIdx() {
			return startIdx;
		}

		/**
		 * 마스킹 처리
		 * @param str
		 * @return
		 */
		public String getMasking(String str) {
			String retVal = str;
			
			int length = str.length();
			// 마스킹할 글자수 제한
			int maskingLimit = length - getStartIdx();
			maskingLimit = maskingLimit < 0 ? 0 : maskingLimit;
			
			int maskingCnt = this.maskingCnt < 0 ? 0 : this.maskingCnt;
			maskingCnt = this.maskingCnt > maskingLimit ? maskingLimit : this.maskingCnt;
			
			int maskingStartIdx = 0;
			if(this.first) {
				maskingStartIdx = this.startIdx;
			} else {
				maskingStartIdx = length - this.startIdx - maskingCnt;
			}
			
			retVal = FormatUtil.asterisk(str, maskingStartIdx, maskingCnt);
			
			return retVal;
		}
	}
}
// :)--