package mobile.factory.util;

import java.io.UnsupportedEncodingException;

import org.apache.commons.lang3.StringUtils;

/**
 * <pre>
 * 이 클래스는 한글초성 변환
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2016. 8. 16.
 * @time 오후 4:38:38
 * 
 * @see http://blog.naver.com/PostView.nhn?blogId=sinsu2&logNo=120158103842
 * @see http://liveupdate.tistory.com/149
 **/
public class HangulUtil {

	/**
	 * 초성
	 */
	private static final char[] firstSounds = { 'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ' };
	// 한글 중성
	private static final char[] middleSounds = { 'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ' };
	// 한글 종성
	private static final char[] lastSounds = { ' ', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ' };

	/**
	 * 문자 하나가 한글인지 검사
	 * 
	 * @param c
	 *            검사 하고자 하는 문자
	 * @return 한글 여부에 따라 'true' or 'false'
	 */
	public static boolean isHangul(char c) {
		if (c < 0xAC00 || c > 0xD7A3)
			return false;
		return true;
	}

	/**
	 * 문자열이 한글인지 검사
	 * 
	 * @param str
	 *            검사 하고자 하는 문자열
	 * @return 한글 여부에 따라 'true' or 'false'
	 */
	public static boolean isHangul(String str) {
		if (str == null)
			return false;

		int len = str.length();
		if (len == 0)
			return false;

		for (int i = 0; i < len; i++) {
			if (!isHangul(str.charAt(i)))
				return false;
		}
		return true;
	}

	/**
	 * 한글 문자의 마지막 문자의 종성 코드값을 추출
	 * 
	 * @param c
	 *            추출 하고자 하는 문자
	 * @return 존재하지 않으면 '0', 존재하면 코드값 (한글이 아닐때 '-1')
	 */
	public static int getLastElementCode(char c) {
		if (!isHangul(c))
			return -1;
		return (c - 0xAC00) % 28;
	}

	/**
	 * 한글 문자열의 마지막 문자의 종성 코드값을 추출
	 * 
	 * @param str
	 *            추출 하고자 하는 문자열
	 * @return 존재하지 않으면 '0', 존재하면 코드값 (한글이 아닐때 '-1')
	 */
	public static int getLastElementCode(String str) {
		if (str == null)
			return -1;

		int len = str.length();
		if (len == 0)
			return -1;

		return getLastElementCode(str.charAt(len - 1));
	}

	/**
	 * 마지막 한글 문자의 종성이 존제하는 검사
	 * 
	 * @param c
	 *            검사 하고자 하는 문자
	 * @return 존재하지 않으면 'false', 존재하면 'true'
	 */
	public static boolean hasLastElement(char c) {
		if (getLastElementCode(c) > 0)
			return true;
		return false;
	}

	/**
	 * 한글 만자열의 마지막 문자의 종성이 존제하는 검사
	 * 
	 * @param str
	 *            검사 하고자 하는 문자열
	 * @return 존재하지 않으면 'false', 존재하면 'true'
	 */
	public static boolean hasLastElement(String str) {
		if (str == null)
			return false;

		int len = str.length();
		if (len == 0)
			return false;

		return hasLastElement(str.charAt(len - 1));
	}

	/**
	 * 한글 문자의 초성을 추출
	 * 
	 * @param c
	 *            첫번째 문자의 요소를 추출할 문자열
	 * @return 한글 문자의 초성
	 */
	public static char getFirstElement(char c) {
		if (!isHangul(c))
			return c;
		return firstSounds[(c - 0xAC00) / (21 * 28)];
	}

	/**
	 * 문자열의 첫번째 요소를 추출 (한글일 경우 초성을 추출)
	 * 
	 * @param str
	 *            첫번째 문자의 요소를 추출할 문자열
	 * @return 첫번째 요소 (한글일 경우 첫번째 문자의 자음)
	 */
	public static char getFirstElement(String str) {
		if (str == null)
			return '\u0000';

		int len = str.length();
		if (len == 0)
			return '\u0000';

		return getFirstElement(str.charAt(0));
	}

	/**
	 * 문자열을 'euc-kr' 로 인코딩.
	 * 
	 * @param str
	 *            인코딩할 문자열
	 * @return 인코딩된 문자열
	 */
	public static String convertCharset(String str) {
		try {
			if (str == null)
				return null;
			return new String(str.getBytes("8859_1"), "euc-kr");
		} catch (UnsupportedEncodingException _ex) {
			return "Encoding Error";
		}
	}

	/**
	 * 한글 한 글자(char)를 받아 초성, 중성, 종성의 위치를 int[]로 반환 한다.
	 * 
	 * @param char
	 *            : 한글 한 글자
	 * @return int[] : 한글 초, 중, 종성의 위치( ex:가 0,0,0 )
	 */
	public static int[] split(char c) {
		int[] sub = null;
		try {
			sub = new int[3];
			sub[0] = (c - 0xAC00) / (21 * 28); // 초성의 위치
			sub[1] = ((c - 0xAC00) % (21 * 28)) / 28; // 중성의 위치
			sub[2] = (c - 0xAC00) % (28);// 종성의 위치
		} catch (Exception ignore) {

		}

		return sub;
	}

	/**
	 * 한글 한 글자를 구성 할 초성, 중성, 종성을 받아 조합 후 char[]로 반환 한다.
	 * 
	 * @param int[]
	 *            : 한글 초, 중, 종성의 위치( ex:가 0,0,0 )
	 * @return char[] : 한글 한 글자
	 */
	public static char[] combine(int[] sub) {
		char[] ch = new char[1];
		ch[0] = (char) (0xAC00 + (sub[0] * 21 * 28) + (sub[1] * 28) + sub[2]);
		return ch;
	}
	
	/**
	 * 초성만 추출
	 * @param str
	 * @param removeBlank 중간에 blank 제거 여부
	 * @return
	 */
	public static String convertInitialSound(String str, boolean removeBlank) {
		if(StringUtils.isBlank(str)) {
			return "";
		}
		
		StringBuilder sb = new StringBuilder();
		try {
			for (int i = 0; i < str.length(); i++) {
				char aWord = str.charAt(i);

				if (aWord >= 0xAC00) { // 한글자모 시작
					int[] aArray = split(aWord);
					int idx = aArray[0];
					if (aArray != null && aArray.length > 0 && firstSounds.length > idx) {
						sb.append(firstSounds[aArray[0]]);
					} else {
						sb.append(aWord);
					}
				} else {
					String word = StringUtils.substring(str, i, i + 1);
					sb.append(removeBlank ? StringUtils.trim(word) : word);
				}
			}
		} catch (Exception ignore) {
			sb.append(str);
		}

		return sb.toString();
	}
	
	/**
	 * 초성만 추출(원본 그대로)
	 * @param str
	 * @return
	 */
	public static String convertInitialSound(String str) {
		return convertInitialSound(str, false);
	}

	/**
	 * 한글 초,중,종성 분리/조합 테스트 메소드
	 */
	public static void doSomething() {
		int[] x = null;
		String str = "그래도 살만한 세상이다. 아?? 구랗쥐 구람";
		int loop = str.length();
		char c;
//		System.out.println("============한글 분리============");
		for (int i = 0; i < loop; i++) {
			c = str.charAt(i);
			if (c >= 0xAC00) {
				x = split(c);
//				System.out.println(str.substring(i, i + 1) + " : 초=" + firstSounds[x[0]] + "t중=" + middleSounds[x[1]] + "t종=" + lastSounds[x[2]]);
			} else {
//				System.out.println(str.substring(i, i + 1));
			}
		}
//		System.out.println("rn============한글 조합============");
//		System.out.println("0,0,0 : " + new String(combine(new int[] { 0, 0, 0 })));
//		System.out.println("2,0,0 : " + new String(combine(new int[] { 2, 0, 0 })));
//		System.out.println("3,0,0 : " + new String(combine(new int[] { 3, 0, 0 })));
//		System.out.println("11,11,12 : " + new String(combine(new int[] { 11, 11, 10 })));
//		System.out.println("10,11,12 : " + new String(combine(new int[] { 10, 11, 14 })));
	}

	public static void main(String[] args) {
		if (args.length == 0) {
			System.err.println("java util.Hangul <문자열>");
			args = new String[1];
			args[0] = "테스트";
			// System.exit(0);
		}
		HangulUtil h = new HangulUtil();
//		System.out.println("getFirstElement(String): " + h.getFirstElement(args[0]));
//		System.out.println("getLastElementCode(String): " + h.getLastElementCode(args[0]));
//		System.out.println("hasLastElement(String): " + h.hasLastElement(args[0]));
//		System.out.println("isHangul(String): " + h.isHangul(args[0]));
		h.doSomething();
	}
}
// :)--