package mobile.factory.util;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import jakarta.servlet.http.HttpServletRequest;
import java.net.InetAddress;
import java.net.UnknownHostException;

public class AppUtil {
    private final static Log logger = LogFactory.getLog(AppUtil.class);

    /**
     * host 주소 구하기
     *
     * @param request
     * @return
     */
    public static String getHost(HttpServletRequest request) {
        String url = request.getRequestURL().toString();
        String uri = request.getRequestURI();
        // 80번 기본포트를 사용하는거에 WebToBe는 뒤에 :80을 붙이므로..
        String host = StringUtils.removeEnd(url, uri);
        host = StringUtils.endsWith(host, ":80") ? StringUtils.removeEnd(host, ":80") : host;

        return host;
    }

    /**
     * 서버 아이피 구하기
     * @return 없으면 ""
     */
    public static String getServerIp() {
        String result = "";
        try {
            result = InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException ignore) {
            logger.warn("", ignore);
        }
        return result;
    }

    public static final String IS_MOBILE = "MOBILE";
    private static final String IS_PHONE = "PHONE";
    private static final String IS_ANDROID = "ANDROID";
    private static final String IS_IPHONE = "IPHONE";
    public static final String IS_TABLET = "TABLET";
    public static final String IS_PC = "PC";

    /**
     * 모바일,타블렛,PC구분
     *
     * @param req
     * @return AppUtil.IS_MOBILE, AppUtil.IS_TABLET, AppUtil.IS_PC
     */
    public static String getDeviceType(HttpServletRequest req) {
        Object agentObj = req.getHeader("User-Agent");
        if(agentObj == null) {
            return IS_PC;
        }

        String userAgent = agentObj.toString().toUpperCase();

        if (userAgent.indexOf(IS_MOBILE) > -1 || userAgent.indexOf(IS_ANDROID) > -1 || userAgent.indexOf(IS_IPHONE) > -1) {
            if (userAgent.indexOf(IS_IPHONE) > -1) {
                return "IOS";
            } else if (userAgent.indexOf(IS_ANDROID) > -1) {
                return "AND";
            } else {
                return IS_TABLET;
            }
        } else {
            return IS_PC;
        }
    }
}
