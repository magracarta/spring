package mobile.factory.util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * <pre>
 * 이 클래스는
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2016. 6. 6.
 * @time 오후 5:37:15
 **/
public class CookieUitl {
	public static void setCookie(HttpServletResponse res, String strCookieName, String strValue, int nMaxAge, String strComment) {
		Cookie cookie = new Cookie(strCookieName, strValue);
		cookie.setVersion(0);
		cookie.setSecure(false);
		cookie.setPath("/");
		cookie.setMaxAge(nMaxAge);
		cookie.setComment(strComment);
		res.addCookie(cookie);
	}

	public static void setCookie(HttpServletResponse res, String strCookieName, String strValue) {
		int nMaxAge = 60 * 60 * 24; // 하루
		String strComment = "";

		setCookie(res, strCookieName, strValue, nMaxAge, strComment);
	}

	public static String getCookie(HttpServletRequest req, String strCookieName) {
		Cookie cookies[] = req.getCookies();
		Cookie cookie = null;
		if (cookies != null) {
			for (int i = 0; i < cookies.length; ++i) {
				if (cookies[i].getName().equals(strCookieName)) {
					cookie = cookies[i];
					break;
				}
			}
		}
		String strValue = "";
		try {
			strValue = cookie.getValue();
		} catch (Exception e) {
		}
		return strValue;
	}

}
// :)--