package test;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * <pre>
 *  이 클래스는 콘솔명령어 실행
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2024.03.04
 * @time 11:19
**/
public class CmdUtil {
    private final static Log log = LogFactory.getLog(CmdUtil.class);

    /**
     * 명령어 실행
     * @param cmd
     * @return
     */
    public static String exec(String cmd) {
        String osName = System.getProperty("os.name").toLowerCase();
        String[] command = null;
        if (osName.contains("win")) {
            cmd = StringUtils.replace(cmd, "'", "\"");
            command = new String[]{"cmd", "/c", cmd};
        } else {
            command = new String[]{"/bin/sh", "-c", cmd};
        }

        StringBuilder sb = new StringBuilder();
        try {
            Process process = Runtime.getRuntime().exec(command);

            log.debug(ArrayUtils.toString(command));

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line = null;

            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        } catch (Exception ignore) {
            log.warn("", ignore);
        }

        return sb.toString();
    }
}
