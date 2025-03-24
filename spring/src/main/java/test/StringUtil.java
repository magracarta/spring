package test;

import org.apache.commons.lang3.CharUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 문자열 가공
 * @author JeongY.Eom
 * @date   2013. 1. 9. 
 * @time   오후 3:18:42
 **/
public class StringUtil {
	private static Log logger = LogFactory.getLog(StringUtil.class);
	
	public static final String stillcutPath = "^/attachFiles/[a-zA-Z0-9]*/[a-zA-Z0-9]*/[a-zA-Z0-9]*/[a-zA-Z0-9]*/[a-zA-Z0-9-_]*.jpg$";

	/**
	 * 앞에 ., .. 를 삭제한다.
	 * 
	 * @param str
	 * @param deli
	 *            구분자.
	 * @return
	 */
	public static String removeDot(String str, String deli) {
		String retStr = "";
		String[] array = StringUtils.split(str, deli);

		for (String item : array) {
			if (StringUtils.isNotBlank(item) && !StringUtils.startsWith(item, "..") && !StringUtils.startsWith(item, ".")) {
				retStr += (deli + item);
			}
		}
		return retStr;
	}

	public static String removeDot(String str) {
		return removeDot(str, "/");
	}

	/**
	 * 검색하려고 하는 문자가 있는지 체크
	 * 
	 * @param str
	 * @param regularExpression 정규식
	 * @return
	 */
	public static boolean contains(String str, String regularExpression) {
		if (StringUtils.isBlank(str)) {
			return false;
		}

		String convertStr = str.replaceAll(regularExpression, "");
		if (convertStr.length() != str.length()) {
			return true;
		} else {
			return false;
		}
	}

	public static boolean containsIgnoreCase(String str, String regularExpression) {
		return contains(StringUtils.upperCase(str), StringUtils.upperCase(regularExpression));
	}
	
	/**
	 * 검색하려고 하는 문자가 있는지 체크
	 * @param str
	 * @param strings
	 * @return 포함하는지 여부
	 */
	public static boolean contains(String str, String[] strings) {
		return contains(str, strings, false);
	}
	
	/**
	 * 포함여부
	 * @param str
	 * @param strings
	 * @param isSame 동일해야 포함Y
	 * @return
	 */
	public static boolean contains(String str, String[] strings, boolean isSame) {
		boolean result = false;
		for (String item : strings) {
			if(isSame) {
				if (StringUtils.equals(str, item)) {
					result = true;
					break;
				}
			} else {
				if (StringUtils.contains(str, item)) {
					result = true;
					break;
				}
			}
		}
		return result;
	}

	/**
	 * <pre>
	 * 문자에서 숫자만 추출
	 * 문자에 , 제거후, -, . 인정
	 * 10px -> 10, 1,000 -> 1000, -10.23ex -> -10.23
	 * </pre>
	 * 
	 * @param val
	 * @param defaultValue
	 * @return
	 */
	public static String extractNumber(String val, String defaultValue) {
		if(StringUtils.isBlank(val)) {
			return defaultValue;
		}
		
		boolean sign = false;
		int dotIdx = 0;
		
		val = val.replaceAll("[,]", "");

		if (val.startsWith("-")) {
			sign = true;
			val = StringUtils.removeStart(val, "-");
		}

		dotIdx = val.indexOf(".");
		if (dotIdx > -1) {
			val = StringUtils.removeStart(val, ".");
		}

		String convertStr = "";
		for (int i = 0, n = val.length(); i < n; i++) {
			if (CharUtils.isAsciiNumeric(val.charAt(i)) || val.charAt(i) == 46) {	// .
				convertStr += val.charAt(i);
			} else {
				break;
			}
		}
		
		String[] arrays = StringUtils.split(convertStr, ".");
		if(arrays.length > 1) {
			convertStr = arrays[0] + "." + arrays[1];
		}

		convertStr = (sign ? "-" : "") + convertStr;

		return StringUtils.defaultIfBlank(convertStr, defaultValue);
	}
	
	/**
	 * 문자에서 숫자만 추출
	 * @param val
	 * @return default is 0
	 */
	public static String extractNumber(String val) {
		return extractNumber(val, "0");
	}
	
	/**
	 * 숫자로 변환(변환하려는 범위가 int 최대값을 넘을경우 앞에서 9자리가지 추출)
	 * @param val
	 * @return int
	 */
	public static int toNumber(Object val) {
		if (val == null) {
			return 0;
		}
		String valStr = val.toString();
		String intStr = extractNumber(valStr, "0");
		intStr = intStr.length() > 9 ? intStr.substring(0, 9) : intStr;
		
		return Integer.parseInt(intStr);
	}
	
	/**
	 * 숫자로 변환(정수)
	 * @param val
	 * @return long
	 */
	public static long toNumberLong(Object val) {
		if (val == null) {
			return 0;
		}
		
		if (val instanceof Float) {
			return BigDecimal.valueOf((float) val).longValue();
		} else if (val instanceof Double) {
			return BigDecimal.valueOf((double) val).longValue();
		}
		String valStr = val.toString();
		String intStr = extractNumber(valStr, "0");
		
		if(StringUtils.contains(intStr, ".")) {
			intStr = StringUtils.substringBefore(intStr, ".");
		}
		
		return Long.parseLong(intStr);
	}
	
	/**
	 * 숫자로 변환(소수점)
	 * 
	 * @param val
	 * @return
	 */
	public static double toNumberDouble(Object val) {
		if (val == null) {
			return 0;
		}

		// (23.06.13) 반올림되어 double로 변경되는 현상 FIX
		if (val instanceof Float) {
			return BigDecimal.valueOf((float) val).doubleValue();
		} else if (val instanceof Double) {
			return BigDecimal.valueOf((double) val).doubleValue();
		}
		String valStr = val.toString();
		String intStr = extractNumber(valStr, "0");

		return Double.parseDouble(intStr);
	}
	
	/**
	 * 숫자인지 판단
	 * -, . 까지 비교
	 * @param val if blank is false
	 * @return
	 */
	public static boolean isNumber(String val) {
		return val.equals(extractNumber(val));
	}
	
	/**
	 * get 형식을 map형식으로 반환
	 * @param val request 의 get 형식 a=23&b=3223&c=232
	 * @return
	 */
	public static Map<String, String> getParamToMap(String val) {
		Map<String, String> map = new HashMap<String, String>();
		String[] param = StringUtils.split(val, "&");
		for(String item : param) {
			String key = StringUtils.substringBefore(item, "=").trim();
			String value = StringUtils.substringAfter(item, "=").trim();
			
			map.put(key, value);
		}
		return map;
	}
	
	/**
	 * 문자로만 되어있는지 확인
	 * @param str
	 * @return
	 */
	public static boolean isString(String str) {
		if (str.compareToIgnoreCase("") == 0) {
			return false;
		}
		
		str = str.trim();

		for (int i = 0; i < str.length(); i++) {
			if (!Character.isLetter(str.charAt(i))) {
				return false;
			}
		}
		return true;
	}
	
	/**
	 * 
	 * @param str
	 * @param startIdx
	 * @param ch
	 * @return
	 */
	public static String convertChar(String str, int startIdx, char ch) {
		int maxLength = StringUtils.length(str);
		if(startIdx > maxLength) {
			return str;
		} else {
			return convertChar(str, startIdx, maxLength - startIdx, ch);
		}
	}
	
	/**
	 * 
	 * @param str
	 * @param startIdx
	 * @param length
	 * @param ch
	 * @return
	 */
	public static String convertChar(String str, int startIdx, int length, char ch) {
		String retStr = str;
		
		String convertStr = StringUtils.substring(str, startIdx, (startIdx+ length));
		String targetStr = StringUtils.repeat(ch, convertStr.length());
		
		retStr = StringUtils.replace(retStr, convertStr, targetStr);
		
		return retStr;
	}
	
	/**
	 * 랜덤인 숫자구하기.
	 * @param max 최대범위
	 * @return
	 */
	public static int random(int max) {
		return (int)(Math.random() * max) + 1;
	}
	
	/**
	 * 랜덤 문자 구하기
	 * @param max 숫자로 생성될 최대범위
	 * @param disit 자리수
	 * @return
	 */
	public static String random(int max, int disit) {
		String retVal = "";
		String val = random(max) + "";

		if (val.length() > disit) {
			retVal = StringUtils.right(val, disit);
		} else {
			retVal = StringUtils.rightPad(val, disit, "0");
		}

		return retVal;
	}
	
	/**
	 * 한글을 2바이트로 계산하여 글자수를 취한다.
	 * @param str
	 * @param digit 가져오려는 글자수
	 * @return
	 */
	public static String substring(String str, int digit) {
		if(lengthByte(str) < digit) {
			return str;
		}
		
		int eos = 0;
		int i = 0;
		int cnt = 0;
		byte[] temp = str.getBytes(); // 스트링을 바이트열로 변환한다.

		for (i = 0; i < digit; i++) {
			// 바이트중에 음수값인것을 카운트 한다.
			if (temp[i] < 0) {
				cnt++;
			}
		}
		if (cnt % 2 != 0) { // 한글 미완성 . 현재 바이트 포함시키지 않음
			eos = digit - 1;
		} else {
			eos = digit;
		}

		String s = new String(temp, 0, eos); // 임시 바이트열을 다시 스트링으로 변환
		return s;
	}
	
	/**
	 * 한글포함한 문자열 자르기
	 * @param source
	 * @param cutLength
	 * @return
	 */
	public static String subStrBytes(String str, int digit) {
		if(!str.isEmpty()) {
			str = str.trim();
	        if(str.getBytes().length <= digit) {
	        	return str;
	        } else {
	            StringBuffer sb = new StringBuffer(digit);
	            int cnt = 0;
	            for(char ch : str.toCharArray()){
	            	cnt += String.valueOf(ch).getBytes().length;
	                if(cnt > digit) 
	                	break;
	            }
	            return sb.toString();
	        }
	    } else {
	    	return "";
	    }
	}
	
	/**
	 * 한글을 utf-8로 계산한 바이트 글자수(
	 * @param str
	 * @return
	 */
	public static int lengthByte(String str) {
		return lengthByte(str, "utf-8");
	}

	/**
	 * 한글을 포함해서 계산한 글자수
	 * @param str
	 * @param charset utf-8 : 한글3바이트, euc-kr : 한글2바이트
	 * @return
	 */
	public static int lengthByte(String str, String charset) {
		int result = 0;

		// 오류로 인해 발생해서 임시 처리
		if (StringUtils.isBlank(str)) {
			return result;
		}

		try {
			result = str.getBytes(charset).length;
		} catch (Exception e) {
			result = str.getBytes().length;
		}
		return result;
	}
	
	/**
	 * String을 카멜 표기법으로 변경
	 * @param underScore
	 * @return
	 */
	public static String convert2CamelCase(String underScore) {
		if (underScore.indexOf('_') < 0
			&& Character.isLowerCase(underScore.charAt(0))) {
			return underScore;
		}
		StringBuilder result = new StringBuilder();
		boolean nextUpper = false;
		int len = underScore.length();
	
		for (int i = 0; i < len; i++) {
			char currentChar = underScore.charAt(i);
			if (currentChar == '_') {
				nextUpper = true;
			} else {
				if (nextUpper) {
					result.append(Character.toUpperCase(currentChar));
					nextUpper = false;
				} else {
					result.append(Character.toLowerCase(currentChar));
				}
			}
		}
		return result.toString();
	}
	
	/**
	 * toString
	 * 
	 * @param is
	 * @return
	 */
	public static String toString(InputStream is) {
		BufferedReader br = null;
		StringBuilder sb = new StringBuilder();

		String line;
		try {
			br = new BufferedReader(new InputStreamReader(is));
			while ((line = br.readLine()) != null) {
				sb.append(line);
				sb.append("\n");
			}

		} catch (IOException e) {
			logger.error("", e);
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					logger.error("", e);
				}
			}
		}

		return sb.toString();
	}

	/**
	 * 특수문자 제거
	 * @param str
	 * @return
	 */
	public static String removeSpecialChar(String str) {
		String match = "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]";
		str = str.replaceAll(match, " ");
		return str;
	}

	/**
	 * 이메일 패턴 체크
	 * @param email
	 * @return
	 */
	public static boolean isEmailPattern(String email) {
		Pattern pattern = Pattern.compile("\\w+[@]\\w+\\.\\w+");
		Matcher match = pattern.matcher(email);
		return match.find();
	}

	// 연속 스페이스 제거
	public static String continueSpaceRemove(String str) {
		String match2 = "\\s{2,}";
		str = str.replaceAll(match2, " ");
		return str;
	}

	// a에 b에 문자열이 포함이 되는지 확인
	public static boolean containStr(String a, String b) {
		return a.contains(b);
	}

	// a에 b에 문자열이 포함이 되는지 확인
	public static boolean startsWithStr(String a, String b) {
		return a.startsWith(b);
	}

	// 패스 체크 정규식 a 정규식 b는 값
	public static boolean regexChkStr(String regex, String str) {
		return Pattern.matches(regex, str);
	}
	public static String lengthFormat(int value, String regStr, int length){
		StringBuffer buf = new StringBuffer();
		buf.append("%");
		buf.append(regStr);
		buf.append(Integer.toString(length));
		buf.append("d");
		String result = String.format(buf.toString(), value);
		return result;
	}
	
	public static String isNullorEmptyChangeValue(String orgVal, String retVal) {
		return (StringUtils.isBlank(orgVal)) ? retVal : orgVal ;
	}
}
//:)--