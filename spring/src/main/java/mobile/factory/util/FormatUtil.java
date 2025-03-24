package mobile.factory.util;

import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import org.apache.commons.collections.MapUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;

/**
 * 이클래스는 검색된 결과에 데이터가 특정 포맷으로 변경시킬때 사용한다.
 *
 * @author JeongY.Eom
 * @date 2010. 4. 19.
 * @time 오후 5:13:38
 */
public class FormatUtil {
	public static final int SEC_MIN = 1 * 60;
	public static final int SEC_HOUR = SEC_MIN * 60;
	public static final int SEC_A_DAY = SEC_HOUR * 24;

	/**
	 * 전화번호 포맷
	 */
	public static final String REGEX_PHONE_NO = "^(02|0505|\\d{3})(\\d{3,4})(\\d{4})";
	/**
	 * 핸드폰번호 포맷
	 */
	public static final String REGEX_HANDPHONE_NO = "^(?:(010\\d{8})|(01[1|6|7|8|9]\\d{7,8}))$";
	/**
	 * 아이디 포맷
	 */
	public static final String REGEX_WEB_ID = "^[a-zA-Z0-9]{6,30}$";
	/**
	 * 문자날짜 포맷
	 */
	public static final String REGEX_DT = "(\\d{4})(\\d{2})(\\d{2})";
	/**
	 * 문자월 포맷
	 */
	public static final String REGEX_MON = "(\\d{4})(\\d{2})";
	/**
	 * 사업자번호 포맷
	 */
	public static final String REGEX_BIZ_NO = "(\\d{3})(\\d{2})(\\d{5})";
	/**
	 * 주민번호 포맷
	 */
	public static final String REGEX_RESI_NO = "(\\d{6})(\\d{7})";
	/**
	 * 카드번호 포맷
	 */
	public static final String REGEX_CARD_NO = "(\\d{4})(\\d{4})(\\d{4})(\\d{1,4})";

	/**
	 * 숫자포맷
	 */
	public static final DecimalFormat decimalFormat = new DecimalFormat("#,###");

	/**
	 * 날짜 포맷을 변경
	 * 
	 * @param dateObj
	 * @param format
	 * @return
	 */
	public static String data(Object dateObj, SimpleDateFormat format) {
		if (dateObj != null && dateObj instanceof Timestamp) {
			return format.format(dateObj);
		}
		return dateObj == null ? "" : dateObj.toString();
	}

	/**
	 * 날짜 포맷을 변경
	 * 
	 * @param dateObj
	 * @param dateFormat
	 * @return
	 */
	public static String data(Object dateObj, String dateFormat) {
		return data(dateObj, new SimpleDateFormat(dateFormat));
	}

	/**
	 * 날짜 포맷을 변경
	 * 
	 * @param list
	 * @param format
	 * @param field
	 *            변경할 필드
	 * @return
	 */
	public static List<Map<String, Object>> date(List<Map<String, Object>> list, SimpleDateFormat format, String... field) {
		List<Map<String, Object>> retList = new ArrayList<>();
		for (Map<String, Object> row : list) {
			retList.add(date(row, format, field));
		}

		return retList;
	}

	/**
	 * 날짜 포맷을 변경
	 * 
	 * @param list
	 * @param dateFormat
	 * @param field
	 * @return
	 */
	public static List<Map<String, Object>> date(List<Map<String, Object>> list, String dateFormat, String... field) {
		return date(list, new SimpleDateFormat(dateFormat), field);
	}

	/**
	 * 날짜 포맷 변경
	 * 
	 * @param list
	 * @param dateFormat
	 * @return
	 */
	public static List<Map<String, Object>> date(List<Map<String, Object>> list, String dateFormat) {
		if (list == null || list.isEmpty()) {
			return list;
		}
		String[] field = ((Map<String, Object>) list.get(0)).keySet().toArray(new String[] {});
		return date(list, new SimpleDateFormat(dateFormat), field);
	}

	/**
	 * <pre>
	 * 날짜 포맷을 변경
	 * 요소가 날짜 형식일때는 기본 입력한 데로 적용되고, 
	 * 요소가 _dt, _mon 으로 되어있을때는 DateUtil.DATE_DIV(/) 가 적용된 포맷으로 적용됨
	 * </pre>
	 * 
	 * @param map
	 * @param format
	 * @param field
	 *            변경할 필드, 날짜/문자 모두 포함
	 * @return
	 */
	public static Map<String, Object> date(Map<String, Object> map, SimpleDateFormat format, String... field) {
		Map<String, Object> retMap = new HashMap<>(map);

		for (String item : field) {
			Object fieldObj = map.get(item);
			if (fieldObj != null) {
				String fieldVal = fieldObj.toString();

				if (fieldObj instanceof Timestamp || fieldObj instanceof Date) {
					String val = format.format(fieldObj);
					retMap.put(item, val);
				} else if ((item.endsWith("dt") && fieldVal.length() == 8) || fieldVal.length() == 8) {
					String fmt = String.format("$1%s$2%s$3", DateUtil.DATE_DIV, DateUtil.DATE_DIV);
					String val = fieldVal.replaceAll(REGEX_DT, fmt);

					// 2023-03-03 _dt이면서 8자리이지만, 'yy-MM-dd' 로 포멧팅할경우 적용 - 황빛찬
					if ("yy-MM-dd".equals(format.toPattern())) {
						val = val.substring(2);
					}

					retMap.put(item, val);
				} else if (item.endsWith("mon") && fieldVal.length() == 6) {
					String fmt = String.format("$1%s$2", DateUtil.DATE_DIV);
					String val = fieldVal.replaceAll(REGEX_MON, fmt);

					retMap.put(item, val);
				}
			}
		}
		return retMap;
	}

	/**
	 * 날짜 포맷을 변경
	 * 
	 * @param map
	 * @param dateFormat
	 * @param field
	 * @return
	 */
	public static Map<String, Object> date(Map<String, Object> map, String dateFormat, String... field) {
		return date(map, new SimpleDateFormat(dateFormat), field);
	}

	/**
	 * 숫자 포매팅(field에 값이 없을때 무시함)(#,###)
	 * 
	 * @param map
	 * @param field
	 *            변환하려는 필드
	 * @return 123456.12 => 123,456
	 */
	public static Map<String, Object> number(Map<String, Object> map, String... field) {
		return number(map, 0, field);
	}

	/**
	 * 숫자 포매팅(field에 값이 없을때 무시함)(#,###)
	 * 
	 * @param map
	 * @param dotCnt
	 *            소수점이하 자리수
	 * @param field
	 *            변환하려는 필드
	 * @return 123456.12 => 123,456.12
	 */
	public static Map<String, Object> number(Map<String, Object> map, int dotCnt, String... field) {
		Map<String, Object> retMap = new HashMap<>(map);

		for (String key : field) {
			if (map.containsKey(key)) {
				retMap.put(key, number(map.get(key), dotCnt));
			}
		}

		return retMap;
	}

	/**
	 * 숫자 포매팅(#,###)
	 * 
	 * @param list
	 * @param field
	 * @return
	 */
	public static List<Map<String, Object>> number(List<Map<String, Object>> list, String... field) {
		return number(list, 0, field);
	}

	/**
	 * 숫자 포매팅
	 * 
	 * @param list
	 * @param dotCnt
	 *            소수점 이하 자리수
	 * @param field
	 * @return 1232.12 => 1,232.12
	 */
	public static List<Map<String, Object>> number(List<Map<String, Object>> list, int dotCnt, String... field) {
		List<Map<String, Object>> retList = new ArrayList<>();

		for (Map<String, Object> item : list) {
			retList.add(number(item, dotCnt, field));
		}

		return retList;
	}

	/**
	 * 날짜 포맷을 변경
	 * 
	 * @param map
	 * @param dateFormat
	 * @return
	 */
	public static Map<String, Object> date(Map<String, Object> map, String dateFormat) {
		return date(map, dateFormat, map.keySet().toArray(new String[] {}));
	}

	/**
	 * 날짜포맷
	 *
	 * @param dateStr
	 *            8자리 yyyyMMdd
	 * @param format
	 * @return
	 */
	public static String date(String dateStr, String format) {
		if (StringUtils.isBlank(dateStr)) {
			return dateStr;
		}

		String dd = dateStr;
		dd = dd.replaceAll(DateUtil.DATE_DIV_REGEXP, "");
		String[] invalidDate = new String[] { "00000000" };
		if (ArrayUtils.contains(invalidDate, dd)) {
			return dateStr;
		}

		SimpleDateFormat dateFormat = new SimpleDateFormat(format);
		long now = DateUtil.toCalendar(dd).getTimeInMillis();

		return dateFormat.format(new Date(now));
	}

	/**
	 * 초를 보여주는 시간단위로 변환
	 * 
	 * @param sec
	 *            초
	 * @return 하루가 넘을경우 1D 2:25:25 로 표기
	 */
	public static String time(int sec) {
		String retStr = "";
		int cSec = sec;

		int dDay = 0;
		int dHour = 0;
		int dMin = 0;
		int dSec = 0;

		// 날짜계산
		if (SEC_A_DAY <= cSec) {
			dDay = cSec / SEC_A_DAY;
			cSec = cSec % SEC_A_DAY;
		}

		// 시간계산
		if (SEC_HOUR <= cSec) {
			dHour = cSec / SEC_HOUR;
			cSec = cSec % SEC_HOUR;
		}

		// 분계산
		if (SEC_MIN <= cSec) {
			dMin = cSec / SEC_MIN;
			dSec = cSec % SEC_MIN;
		}

		String dMinStr = StringUtils.leftPad(dMin + "", 2, "0");
		String dSecStr = StringUtils.leftPad(dSec + "", 2, "0");

		if (dDay > 0) {
			retStr = String.format("%dD %d:%s:%s", dDay, dHour, dMinStr, dSecStr);
		} else if (dHour > 0) {
			retStr = String.format("%d:%s:%s", dHour, dMinStr, dSecStr);
		} else if (dMin > 0) {
			retStr = String.format("%d:%s", dMin, dSecStr);
		} else if (dSec > 0) {
			retStr = String.format("%d", dSec);
		}

		return retStr;
	}

	/**
	 * 전화번호에 구분자 표시
	 * 
	 * @param list
	 * @param field
	 *            변경하려고 하는 리스트 배열의 키값
	 * @return
	 */
	public static List<Map<String, Object>> phoneNumber(List<Map<String, Object>> list, String... field) {
		return phoneNumber(list, false, field);
	}

	/**
	 * 전화번호에 구분자 표시
	 * 
	 * @param list
	 * @param star
	 *            가운데 자리 별표 처리여부
	 * @param field
	 *            변경하려고 하는 리스트 배열의 키값
	 * @return
	 */
	public static List<Map<String, Object>> phoneNumber(List<Map<String, Object>> list, boolean star, String... field) {
		if (list == null) {
			return null;
		}

		for (Map<String, Object> map : list) {
			map = phoneNumber(map, star, field);
		}

		return list;
	}

	/**
	 * 사업자번호에 구분자 표시
	 * 
	 * @param list
	 * @param field
	 *            변경하려고 하는 리스트 배열의 키값
	 * @return
	 */
	public static List<Map<String, Object>> bizNo(List<Map<String, Object>> list, String... field) {
		return bizNo(list, false, field);
	}

	/**
	 * 사업자번호에 구분자 표시
	 * 
	 * @param list
	 * @param star
	 *            가운데 자리 별표 처리여부
	 * @param field
	 *            변경하려고 하는 리스트 배열의 키값
	 * @return
	 */
	public static List<Map<String, Object>> bizNo(List<Map<String, Object>> list, boolean star, String... field) {
		if (list == null) {
			return null;
		}

		for (Map<String, Object> map : list) {
			map = bizNo(map, star, field);
		}

		return list;
	}

	/**
	 * 주민번호에 구분자 표시(뒤1자리 이후 별표)
	 * 
	 * @param list
	 * @param field
	 *            변경하려고 하는 리스트 배열의 키값
	 * @return
	 */
	public static List<Map<String, Object>> resiNo(List<Map<String, Object>> list, String... field) {
		return resiNo(list, true, field);
	}

	/**
	 * 주민번호에 구분자 표시
	 * 
	 * @param list
	 * @param star
	 *            뒤1자리 이후 별표 여부
	 * @param field
	 *            변경하려고 하는 리스트 배열의 키값
	 * @return
	 */
	public static List<Map<String, Object>> resiNo(List<Map<String, Object>> list, boolean star, String... field) {
		if (list == null) {
			return null;
		}

		for (Map<String, Object> map : list) {
			map = resiNo(map, star, field);
		}

		return list;
	}

	/**
	 * 전화번호에 구분자 표시
	 * 
	 * @param map
	 * @param star
	 *            가운데 자리 별표 처리여부
	 * @param field
	 *            변경하려고 하는 키값
	 * @return
	 */
	public static Map<String, Object> phoneNumber(Map<String, Object> map, boolean star, String... field) {
		if (map == null) {
			return null;
		}
		for (String item : field) {
			if (map.containsKey(item)) {
				map.put(item, phoneNumber(map.get(item), star));
			}
		}

		return map;
	}

	/**
	 * 전화번호에 구분자 표시
	 * 
	 * @param map
	 * @param field
	 *            변경하려고 하는 키값
	 * @return
	 */
	public static Map<String, Object> phoneNumber(Map<String, Object> map, String... field) {
		return phoneNumber(map, false, field);
	}

	/**
	 * 사업자번호에 구분자 표시
	 * 
	 * @param map
	 * @param star
	 *            가운데 자리 별표 처리여부
	 * @param field
	 *            변경하려고 하는 키값
	 * @return
	 */
	public static Map<String, Object> bizNo(Map<String, Object> map, boolean star, String... field) {
		if (map == null) {
			return null;
		}
		for (String item : field) {
			if (map.containsKey(item)) {
				map.put(item, bizNo(map.get(item), star));
			}
		}

		return map;
	}

	/**
	 * 사업자번호에 구분자 표시
	 * 
	 * @param map
	 * @param field
	 *            변경하려고 하는 키값
	 * @return
	 */
	public static Map<String, Object> bizNo(Map<String, Object> map, String... field) {
		return bizNo(map, false, field);
	}

	/**
	 * 사업자번호에 구분자 표시
	 * 
	 * @param map
	 * @param star
	 *            뒤1자리 이후 별표표시 여부
	 * @param field
	 *            변경하려고 하는 키값
	 * @return
	 */
	public static Map<String, Object> resiNo(Map<String, Object> map, boolean star, String... field) {
		if (map == null) {
			return null;
		}
		for (String item : field) {
			if (map.containsKey(item)) {
				map.put(item, resiNo(map.get(item), star));
			}
		}

		return map;
	}

	/**
	 * 주민번호 구분자표시(뒤1자리 이후 별표표시)
	 * 
	 * @param map
	 * @param field
	 *            변경하려고 하는 키값
	 * @return
	 */
	public static Map<String, Object> resiNo(Map<String, Object> map, String... field) {
		return resiNo(map, true, field);
	}

	/**
	 * 전화번호에 구분자 표시
	 * 
	 * @param val
	 *            01212341234
	 * @param star
	 *            가운데 * 처리 여부
	 * @return 012-1234-1234
	 */
	public static String phoneNumber(Object valObj, boolean star) {
		if (valObj == null || StringUtils.isBlank(valObj.toString())) {
			return "";
		}
		String retVal = StringUtils.trim(valObj.toString());

		if (Pattern.matches(REGEX_PHONE_NO, retVal)) {
			retVal = retVal.replaceAll(REGEX_PHONE_NO, "$1-$2-$3");
		}

		if (star) {
			String[] numArray = StringUtils.split(retVal, "-");
			if (numArray != null && numArray.length > 2) {
				retVal = String.format("%s-%s-%s", numArray[0], asterisk(numArray[1], 0, 0), numArray[2]);
			}
		}

		return retVal;
	}

	/**
	 * 카드번호에 구분자 표시
	 * 
	 * @param val
	 *            9430030211119936
	 * @param star
	 *            가운데 * 처리 여부
	 * @return 9430-0302-1111-9936
	 */
	public static String cardNo(Object valObj, boolean star) {
		if (valObj == null || StringUtils.isBlank(valObj.toString())) {
			return "";
		}
		String retVal = StringUtils.trim(valObj.toString());

		if (Pattern.matches(REGEX_CARD_NO, retVal)) {
			retVal = retVal.replaceAll(REGEX_CARD_NO, "$1-$2-$3-$4");
		}

		if (star) {
			String[] numArray = StringUtils.split(retVal, "-");
			if (numArray != null && numArray.length > 3) {
				retVal = String.format("%s-%s-%s-%s", numArray[0], asterisk(numArray[1], 0, 0), numArray[2], numArray[3]);
			}
		}

		return retVal;
	}

	/**
	 * 사업자 번호 포맷
	 * 
	 * @param valObj
	 * @param star
	 *            가운데 자리 * 처리여부
	 * @return
	 */
	public static String bizNo(Object valObj, boolean star) {
		if (valObj == null || StringUtils.isBlank(valObj.toString())) {
			return "";
		}
		String retVal = StringUtils.trim(valObj.toString());

		if (Pattern.matches(REGEX_BIZ_NO, retVal)) {
			retVal = retVal.replaceAll(REGEX_BIZ_NO, "$1-$2-$3");

			if (star) {
				String[] numArray = StringUtils.split(retVal, "-");
				if (numArray != null && numArray.length > 2) {
					retVal = String.format("%s-%s-%s", numArray[0], asterisk(numArray[1], 0, 0), numArray[2]);
				}
			}
		}

		return retVal;
	}

	/**
	 * 사업자번호 포맷
	 * 
	 * @param valObj
	 * @return
	 */
	public static String bizNo(Object valObj) {
		return bizNo(valObj, false);
	}

	/**
	 * 주민번호 포맷(뒤1자리 이후에는 모두 별표)
	 * 
	 * @param valObj
	 * @return
	 */
	public static String resiNo(Object valObj) {
		return resiNo(valObj, true);
	}

	/**
	 * 주민번호 포맷
	 * 
	 * @param valObj
	 * @param star
	 *            뒤1자리 이후에는 모두 별표여부
	 * @return
	 */
	public static String resiNo(Object valObj, boolean star) {
		if (valObj == null || StringUtils.isBlank(valObj.toString())) {
			return "";
		}
		String retVal = StringUtils.trim(valObj.toString());

		if (Pattern.matches(REGEX_RESI_NO, retVal)) {
			retVal = retVal.replaceAll(REGEX_RESI_NO, "$1-$2");

			if (star) {
				String[] numArray = StringUtils.split(retVal, "-");
				if (numArray != null && numArray.length > 1) {
					retVal = String.format("%s-%s", numArray[0], asterisk(numArray[1], 1, 0));
				}
			}
		}
		return retVal;
	}

	/**
	 * 주민번호 유효성검사
	 * 
	 * @param resiNo
	 *            체크섬 검사 후 이상여부 리턴
	 * @return
	 */
	public static boolean resiNoValidCheck(String resiNo) {
		if (resiNo == null || StringUtils.isBlank(resiNo.toString())) {
			return false;
		}

		boolean result = false;
		String retVal = StringUtils.trim(resiNo.toString());

		if (Pattern.matches(REGEX_RESI_NO, retVal)) {

			// 곱해지는 수 배열 구성
			int[] chkSum = { 2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5 };
			int totalchkSum = 0;

			for (int i = 0; i < chkSum.length; i++) {
				totalchkSum += chkSum[i] * Integer.parseInt(retVal.substring(i, (i + 1)));
			}

			// int chkLastNum = 11 - (totalchkSum % 11);
			int chkLastNum = (11 - totalchkSum % 11) % 10;

			if (chkLastNum == Integer.parseInt(retVal.substring(12))) {
				result = true;
			}
		}

		return result;
	}

	/**
	 * 전화번호에 구분자 표시
	 * 
	 * @param val
	 *            01212341234
	 * @return 012-1234-1234
	 */
	public static String phoneNumber(Object valObj) {
		return phoneNumber(valObj, false);
	}

	/**
	 * 숫자 , 찍기
	 * 
	 * @param valObj
	 * @return
	 */
	public static String number(Object valObj) {
		return number(valObj, 0);
	}

	/**
	 * 숫자 , 찍기
	 * 
	 * @param valObj
	 * @param dotCnt
	 *            소수점 이하 자리수 이하는 무조건 버림
	 * @return
	 */
	public static String number(Object valObj, int dotCnt) {
		if (valObj == null || StringUtils.isBlank(valObj.toString())) {
			return "";
		}
		String retVal = valObj.toString();

		try {
			if (dotCnt == 0 || (dotCnt > 0 && StringUtils.contains(retVal, ".") == false)) {
				retVal = NumberFormat.getInstance().format(Long.parseLong(retVal));
			} else {
				float valFloat = Float.parseFloat(retVal);
				retVal = NumberFormat.getInstance().format(valFloat);

				if (StringUtils.contains(retVal, ".")) {
					String firstWord = StringUtils.substringBefore(retVal, ".");
					String lastWord = StringUtils.substringAfter(retVal, ".");

					int cnt = lastWord.length();
					int subCnt = dotCnt < cnt ? dotCnt : cnt;

					lastWord = StringUtils.substring(lastWord, 0, subCnt);

					retVal = String.format("%s.%s", firstWord, lastWord);
				}
			}

		} catch (Exception ignore) {
		}

		return retVal;
	}

	/**
	 * '*' 찍기
	 * 
	 * @param list
	 * @param beginIndex
	 *            이후 자리수 부터 * 처리
	 * @param asteriskCount
	 *            변환할 갯수(0이면 모두 처리)
	 * @param field
	 * @return
	 */
	public static List<Map<String, Object>> asterisk(List<Map<String, Object>> list, int beginIndex, int asteriskCount, String... field) {
		List<Map<String, Object>> convertList = new ArrayList<Map<String, Object>>();
		for (Map<String, Object> map : list) {
			map = asterisk(map, beginIndex, asteriskCount, field);
			convertList.add(map);
		}
		return convertList;
	}

	/**
	 * '*' 찍기
	 * 
	 * @param map
	 * @param beginIndex
	 *            이후 자리수 부터 * 처리
	 * @param asteriskCount
	 *            변환할 갯수(0이면 모두 처리)
	 * @param field
	 * @return
	 */
	public static Map<String, Object> asterisk(Map<String, Object> map, int beginIndex, int asteriskCount, String... field) {
		if (map == null) {
			return null;
		}

		for (String item : field) {
			if (map.containsKey(item)) {
				map.put(item, asterisk(map.get(item), beginIndex, asteriskCount));
			}
		}

		return map;
	}

	/**
	 * '*' 처리
	 * 
	 * @param valueObj
	 *            변환 대상
	 * @param beginIndex
	 *            시작 index, 시작 index보다 사이즈가 작으면 그냥 반환
	 * @param asteriskCount
	 *            처리할 갯수(0)이면 모두 처리
	 * @return
	 */
	public static String asterisk(Object valueObj, int beginIndex, int asteriskCount) {
		if (valueObj == null || StringUtils.isBlank(valueObj.toString())) {
			return "";
		}

		String str = valueObj.toString();

		if (str.length() < beginIndex) {
			return str;
		}

		// 1. 앞에 문자 추출
		String preStr = str.substring(0, beginIndex);
		// 2. 뒤에 문자 추출
		String postStr = asteriskCount > 0 ? StringUtils.substring(str, beginIndex + asteriskCount) : "";
		// 3. 별표 변환 대상 문자 추출
		String targetStr = "".equals(preStr) ? str : StringUtils.removeStart(str, preStr);
		targetStr = "".equals(postStr) ? targetStr : StringUtils.removeEnd(targetStr, postStr);

		String startStr = StringUtils.repeat("*", targetStr.length());

		return String.format("%s%s%s", preStr, startStr, postStr);
	}

	// 문자열에 문자 삽입
	public static String addChar(String str, String addChar, int index) {
		String[] splitStr = str.split("(?<=\\G.{" + index + "})");
		str = StringUtils.join(splitStr, addChar);
		return str;
	}

	/**
	 * 값이 0이면 "" 으로 변경
	 * 
	 * @param bean
	 * @param cols
	 */
	public static void setZeroToBlank(Map<String, Object> bean, String... cols) {
		for (String item : cols) {
			if (bean.containsKey(item) && bean.get(item) != null) {
				if ("0".equals(bean.get(item).toString())) {
					bean.put(item, "");
				}
			}
		}
	}

	/**
	 * 값이 0이면 "" 으로 변경
	 * 
	 * @param bean
	 *            키값 전체
	 */
	public static void setZeroToBlank(Map<String, Object> bean) {
		if (MapUtils.isEmpty(bean)) {
			return;
		}

		Set<String> cols = new HashSet<>();

		for (String item : bean.keySet()) {
			Object valObj = bean.get(item);
			if (valObj instanceof Number) {
				cols.add(item);
			}
		}

		if (cols.size() == 0) {
			return;
		}

		setZeroToBlank(bean, cols.toArray(new String[] {}));
	}

	/**
	 * 값이 0이면 "" 으로 변경
	 * 
	 * @param list
	 * @param cols
	 */
	public static void setZeroToBlank(List<Map<String, Object>> list, String... cols) {
		for (Map<String, Object> bean : list) {
			setZeroToBlank(bean, cols);
		}
	}

	/**
	 * 값이 0이면 "" 으로 변경
	 * 
	 * @param list
	 */
	public static void setZeroToBlank(List<Map<String, Object>> list) {
		for (Map<String, Object> bean : list) {
			setZeroToBlank(bean);
		}
	}

	/**
	 * 시간포맷
	 *
	 * @param timeStr
	 *            4자리 HHmm
	 * @return
	 */
	public static String hhmmTime(String timeStr) {
		if (StringUtils.isBlank(timeStr) || timeStr.length() != 4) {
			return timeStr;
		}
		String hh = timeStr.substring(0, 2);
		String mm = timeStr.substring(2, 4);

		return hh + ":" + mm;
	}

	/**
	 * 시간포맷
	 *
	 * @param map
	 * @param field
	 * @return
	 */
	public static Map<String, Object> hhmmTime(Map<String, Object> map, String... field) {
		Map<String, Object> retMap = new HashMap<>(map);

		for (String item : field) {
			Object fieldObj = map.get(item);
			if (fieldObj != null) {
				String fieldVal = fieldObj.toString();
				retMap.put(item, hhmmTime(fieldVal));
			}
		}
		return retMap;
	}

	/**
	 * 시간포맷
	 *
	 * @param list
	 * @param field
	 * @return
	 */
	public static List<Map<String, Object>> hhmmTime(List<Map<String, Object>> list, String... field) {
		List<Map<String, Object>> retList = new ArrayList<>();
		for (Map<String, Object> row : list) {
			retList.add(hhmmTime(row, field));
		}

		return retList;
	}
}
// :)--