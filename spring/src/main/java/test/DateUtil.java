package test;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.Year;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 10
 */
public class DateUtil {
    private static Log log = LogFactory.getLog(DateUtil.class);

    /**
     * 날짜 구분자 2014/12/21, "/" or "-"
     */
    public static final String DATE_DIV = "-";

    public static final String LONG_DATE_STR = "yyyyMMddHHmmss";
    public static final String LONG_MILISECOND_DATE_STR = "yyyyMMddHHmmssSSS";
    public static final String MEDIUM_DATE_STR = "yyyyMMdd HH:mm";
    public static final String SHORT_DATE_STR = "yyyyMMdd";

    public static final String SHORT_MONTH_STR = "yyyyMM";
    public static final String SHORT_TIME_STR = "HH:mm";
    public static final String DB_DATE_STR = String.format("yyyy%sMM%sdd HH:mm:ss", DATE_DIV, DATE_DIV);
    public static final SimpleDateFormat DEFAULT_DATETIME_FORMAT = new SimpleDateFormat(LONG_DATE_STR);
    public static final SimpleDateFormat MEDIUM_DATETIME_FORMAT = new SimpleDateFormat(MEDIUM_DATE_STR);
    public static final SimpleDateFormat LONG_MILISECOND_DATETIME_FORMAT = new SimpleDateFormat(LONG_MILISECOND_DATE_STR);
    
    public static final SimpleDateFormat DB_DATETIME_FORMAT = new SimpleDateFormat(DB_DATE_STR);

    public static final SimpleDateFormat MIN_DATE_FORMAT = new SimpleDateFormat(SHORT_DATE_STR);
    public static final SimpleDateFormat DEFAULT_DATE_FORMAT = new SimpleDateFormat(SHORT_DATE_STR);

    public static final SimpleDateFormat DEFAULT_MONTH_FORMAT = new SimpleDateFormat(SHORT_MONTH_STR);

    public static final SimpleDateFormat DEFAULT_TIME_FORMAT = new SimpleDateFormat(SHORT_TIME_STR);

    public static final int MILLI_SEC_A_DAY = 1000 * 60 * 60 * 24;
    public static final int MILLI_SEC_A_TIME = 1000 * 60 * 60;

    /**
     * 날짜를 구분하는 구분자
     */
    public static final String DATE_DIV_REGEXP = "[/년월일\\-\\.:시분초]";

    /**
     * LONG_DATE_STR("yyyyMMddHHmmss") 포멧으로 날짜를 구해오는 메소드
     *
     * @return
     */
    public static String getCurrentDatetime() {
        return DEFAULT_DATETIME_FORMAT.format(new Date());
    }
    
    /**
     * yyyyMMddHHmmssSSS 포멧으로 날짜 구함
     * @return
     */
    public static String getCurrentDatetimeMilisecond() {
    	return LONG_MILISECOND_DATETIME_FORMAT.format(new Date());
    }

    public static String getCurrentMediumDatetime() {
        return MEDIUM_DATETIME_FORMAT.format(new Date());
    }

    public static String getCurrentDate() {
        return DEFAULT_DATE_FORMAT.format(new Date());
    }

    public static String getCurrentDate(int i) {
        long now = System.currentTimeMillis();
        now += (i * MILLI_SEC_A_DAY);
        return DEFAULT_DATE_FORMAT.format(new Date(now));
    }

    public static String getCurrentDate(String format) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(format);
        long now = System.currentTimeMillis();
        return dateFormat.format(new Date(now));
    }

    /**
     * 날짜를 지정된 포멧에 맞게 변경시켜주는 메소드.
     *
     * @param date   - yyyyMMdd
     * @param format
     * @return
     */
    public static String getConvertFormatDate(String dateStr, String format) {
        int year = Integer.parseInt(dateStr.substring(0, 4));
        int month = Integer.parseInt(dateStr.substring(4, 6)) - 1;
        int date = Integer.parseInt(dateStr.substring(6));

        Calendar cal = Calendar.getInstance();
        cal.set(year, month, date);

        SimpleDateFormat dateFormat = new SimpleDateFormat(format);
        return dateFormat.format(cal.getTime());
    }

    /**
     * String 형의 날짜를 포멧형식으로 반환
     *
     * @param dateStr - yy.m.d
     * @return
     */
    public static String getConvertStringToDate(String dateStr, String format) throws Exception {
        String[] dateSplit = dateStr.split("\\.");
        int year = Integer.parseInt("20" + dateSplit[0].replaceAll(" ", ""));
        int month = Integer.parseInt(dateSplit[1].replaceAll(" ", "")) - 1;
        int day = Integer.parseInt(dateSplit[2].replaceAll(" ", ""));

        Calendar cal = Calendar.getInstance();
        cal.set(year, month, day);

        SimpleDateFormat dateFormat = new SimpleDateFormat(format);
        return dateFormat.format(cal.getTime());
    }

    /**
     * 날짜 String을 Calendar 객체로 변환해주는 메소드.
     *
     * @param dateStr
     * @return
     */
    public static Calendar toCalendar(String dateStr) {
        DateFormat format = getProperFormat(dateStr);

        Date convDate = null;
        try {
            convDate = format.parse(dateStr);
        } catch (ParseException e) {
            log.error("", e);
            return null;
        }
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(convDate);

        return calendar;
    }

    /**
     * 날짜 String의 길이에 따라 적절한 DateFormat을 반환하는 메소드.
     *
     * @param dateStr
     * @return
     */
    private static DateFormat getProperFormat(String dateStr) {
        DateFormat format;
        if (dateStr.length() == SHORT_DATE_STR.length()) {
            format = DEFAULT_DATE_FORMAT;
        } else if(dateStr.length() == SHORT_MONTH_STR.length()) {
            format = DEFAULT_MONTH_FORMAT;
        } else {
            format = DEFAULT_DATETIME_FORMAT;
        }
        return format;
    }

    /**
     * 날짜 String을 받아서 i 값에서 지정한 날짜만큼 더한 날짜 String을 반환하는 메소드.
     *
     * @param dateStr
     * @param i
     * @return
     */
    public static String add(String dateStr, int i) {
        String retStr = dateStr;
        if (!StringUtils.isEmpty(dateStr) && dateStr.length() >= SHORT_DATE_STR.length()) {
            dateStr = dateStr.trim();
            Calendar calendar = toCalendar(dateStr);
            calendar.add(Calendar.DATE, i);
            retStr = getProperFormat(dateStr).format(calendar.getTime());
        }

        return retStr;
    }

    /**
     * 월을 연산한다.
     *
     * @param dateStr yyyyMM or yyyyMMdd
     * @param i
     * @return dateStr 길이에 따라 같은 형식 반환
     */
    public static String addMonth(String dateStr, int i) {
        String retStr = dateStr;

        if (StringUtils.isNotBlank(dateStr) && retStr.length() >= 6) {
            retStr = retStr.trim();
            if (retStr.length() == 6) {
                retStr += "01";
            }
            Calendar calendar = toCalendar(retStr);
            calendar.add(Calendar.MONTH, i);
            retStr = getProperFormat(dateStr).format(calendar.getTime());

            retStr = dateStr.length() == 6 ? retStr.substring(0, 6) : retStr;
        }
        return retStr;
    }

    /**
     * "YYYYMMDD" -> "YYYY/MM/DD"
     *
     * @param date
     * @return
     */
    public static String toDefaultDateFormat(String srcDate) {
        Date date = null;
        try {
            date = MIN_DATE_FORMAT.parse(srcDate);
        } catch (ParseException e) {
            log.error("", e);
            return srcDate;
        }
        return DEFAULT_DATE_FORMAT.format(date);
    }

    public static String toDefaultDateFormat(Timestamp datetime) {
        Date date = new Date(datetime.getTime());
        return DEFAULT_DATE_FORMAT.format(date);
    }
    
    /**
     * timestamp to DB Date format
     * @param timestamp
     * @return
     */
    public static String toDBDateFormat(long timestamp) {
    	Date date = new Date(timestamp);
    	return DB_DATETIME_FORMAT.format(date);
    }
    
    /**
     * 날짜차이를 구한다 시작과 종료일을 포함 예) 2008-03-05 - 2008-03-02 날짜차이는 4일
     *
     * @param destDate
     * @param srcDate
     * @return
     */
    public static long dateDiff(String destDate, String srcDate) {
        return dateDiff(destDate, srcDate, true);
    }

    /**
     * 날짜차이구함
     *
     * @param destDate
     * @param srcDate
     * @param containStartEndDt 시작,종료일 포함 true: 2008-03-05 - 2008-03-02 => 4 false: 2008-03-05
     *                          - 2008-03-02 => 3
     * @return
     */
    public static long dateDiff(String destDate, String srcDate, boolean containStartEndDt) {
        long diffDate = 0;
        try {
            if (StringUtils.isNotEmpty(destDate) && destDate.length() >= SHORT_DATE_STR.length() && StringUtils.isNotEmpty(srcDate) && srcDate.length() >= SHORT_DATE_STR.length()) {
                Date destDt = DEFAULT_DATE_FORMAT.parse(destDate);
                Date srcDt = DEFAULT_DATE_FORMAT.parse(srcDate);

                diffDate = Long.valueOf((destDt.getTime() - srcDt.getTime()) / MILLI_SEC_A_DAY);

                if (containStartEndDt) {
                    diffDate += 1;
                }
            }
        } catch (Exception ignore) {
        }
        return diffDate;
    }

    /**
     * 두 날짜 사이의 개월 수 차이를 구한다 예) 202210 - 202208 개월 수 차이는 2
     *
     * @param destMonth
     * @param srcMonth
     * @return
     */
    public static long monthDiff(String destMonth, String srcMonth) {
        return monthDiff(destMonth, srcMonth, false);
    }

    /**
     * 날짜차이구함
     *
     * @param destMonth
     * @param srcMonth
     * @param containStartEndMon 시작,종료월 포함 true: 202210 - 202208 => 3 false: 202210 - 202208 => 2
     * @return
     */
    public static long monthDiff(String destMonth, String srcMonth, boolean containStartEndMon) {
        long diffMonth = 0;

        try {
            if(StringUtils.isNotEmpty(destMonth) && destMonth.length() >= SHORT_MONTH_STR.length() && StringUtils.isNotEmpty(srcMonth) && srcMonth.length() >= SHORT_MONTH_STR.length()) {
                Calendar destCal = toCalendar(destMonth);
                Calendar srcCal = toCalendar(srcMonth);
                diffMonth = destCal.get(Calendar.YEAR) * 12 + destCal.get(Calendar.MONTH) - ( srcCal.get(Calendar.YEAR) * 12 + srcCal.get(Calendar.MONTH));
            }

            if (containStartEndMon) {
                diffMonth += 1;
            }
        } catch (Exception ignore) {
        }

        return diffMonth;
    }

    /**
     * 시작과 종료일의 년도 구하기
     *
     * @param fromDt
     * @param toDt
     * @return
     */
    public static String[] calBetweenYear(String fromDt, String toDt) {
        if (StringUtils.isBlank(fromDt) || StringUtils.isBlank(toDt)) {
            return null;
        }
        String[] retArray = new String[0];

        Calendar fromCal = toCalendar(fromDt);
        Calendar toCal = toCalendar(toDt);

        int fromYear = fromCal.get(Calendar.YEAR);
        int toYear = toCal.get(Calendar.YEAR);

        for (; fromYear <= toYear; fromYear++) {
            retArray = (String[]) ArrayUtils.add(retArray, fromYear + "");
        }

        return retArray;
    }

    /**
     * 시작과 종료일의 년도/월 구하기
     *
     * @param fromDt
     * @param toDt
     * @return
     */
    public static String[] calBetweenYearMonth(String fromDt, String toDt) {
        if (StringUtils.isBlank(fromDt) || StringUtils.isBlank(toDt)) {
            return null;
        }
        String[] retArray = new String[0];

        Calendar fromCal = toCalendar(fromDt);
        Calendar toCal = toCalendar(toDt);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMM");

        int fromYM = 0;
        int toYM = 0;
        do {
            fromYM = Integer.parseInt(sdf.format(fromCal.getTime()));
            toYM = Integer.parseInt(sdf.format(toCal.getTime()));

            retArray = (String[]) ArrayUtils.add(retArray, fromYM + "");
            fromCal.add(Calendar.MONTH, 1);
        } while (fromYM < toYM);

        return retArray;
    }

    /**
     * 달의 마지막 날짜를 구함.
     *
     * @param yyyy .mm.dd
     * @return
     */
    public static int getLastDayOfMonth(String dateStr) {
        dateStr = StringUtils.length(dateStr) == 6 ? dateStr + "01" : dateStr;
        Calendar calendar = toCalendar(dateStr);
        return calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
    }

    /**
     * 달의 마지막 날짜를 구함.
     *
     * @param dateStr yyyyMM or yyyyMMdd
     * @return yyyyMMdd
     */
    public static String getLastDateOfMonth(String dateStr) {
        if (dateStr == null || dateStr.length() < 6) {
            return "";
        }

        String str = dateStr.substring(0, 6) + "01";

        return dateStr.substring(0, 6) + StringUtils.leftPad(getLastDayOfMonth(str) + "", 2, "0");
    }

    /**
     * 첫번째 날짜의 요일을 구함.
     *
     * @param dateStr 201301, 20130101
     * @return
     */
    public static int getFirstDayOfWeek(String dateStr) {
        if (dateStr == null || dateStr.length() < 6) {
            return -1;
        }
        String str = dateStr.substring(0, 6) + "01";

        Calendar cal = toCalendar(str);
        return cal.get(Calendar.DAY_OF_WEEK);
    }

    /**
     * 해당 날짜의 요일을 구함.
     *
     * @param dateStr
     * @return
     */
    public static String getDayOfWeek(String dateStr) {
        String str = dateStr;

        Calendar cal = toCalendar(str);

        switch (cal.get(Calendar.DAY_OF_WEEK)) {
            case 1:
                str = "일";
                break;
            case 2:
                str = "월";
                break;
            case 3:
                str = "화";
                break;
            case 4:
                str = "수";
                break;
            case 5:
                str = "목";
                break;
            case 6:
                str = "금";
                break;
            case 7:
                str = "토";
                break;
        }

        return str;
    }

    /**
     * <pre>
     *  해당되는 날이 그달의 마지막에 차이가 나는 날만큼 연산 결과 날도 동일하게 계산됨
     *  입력 : 마지막날 (31) - 들어온날(30) = 차이(1)
     *  출력 : 목표 날에서 무조건 차이만큼 빼서 계산
     * </pre>
     *
     * @param ymd   yyyyMMdd
     * @param month
     * @return 20130131 -> 20130228
     */
    public static String getLastRemindDate(String ymd, int month) {
        String lastDate = getLastDateOfMonth(ymd);

        int thisDiff = (int) (Long.parseLong(lastDate) - Long.parseLong(ymd));

        String targetDate = addMonth(ymd, month);

        String retStr = (Long.parseLong(getLastDateOfMonth(targetDate)) - thisDiff) + "";

        return retStr;
    }

    /**
     * <pre>
     * 해당되는 달의 날짜에 해당하는 날을 다음달도 같은 날짜로 반환한다.
     * 1월31에 한달 더하면 2월31이되야 하는데 날짜가 없으므로, 2월 28일로 반환
     * </pre>
     *
     * @param ymd
     * @param month
     * @return 20130131 -> 20130228
     */
    public static String getSameMonthDate(String ymd, int month) {
        String target = addMonth(ymd, month);

        String retStr = target;

        if ((Long.parseLong(target) - Long.parseLong(ymd)) != (100 * month)) {
            retStr = getLastRemindDate(ymd, month);
        }

        return retStr;
    }

    public static long getCurrentDateLong(String format) {
        return Long.parseLong(getCurrentDate(format));
    }

    public static int getCurrentDateInt(String format) {
        return Integer.parseInt(getCurrentDate(format));
    }
    
    /**
     * 디비에 입력하는 양식으로 변환
     * @return yyyy-MM-dd HH:mm:ss
     */
    public static String getCurrentDateDBStr() {
    	return getCurrentDate(DB_DATE_STR);
    }

    /**
     * 시간차이를 구한다 시작과 종료일을 포함 예) 08:00 - 17:00 시간차이는 9시간
     * @param destTime
     * @param srcTime
     * @return double
     */
    public static double timeDiff(String destTime, String srcTime) {
        double diffTime = 0;
        try {
            if(StringUtils.isNotEmpty(destTime) && destTime.length() >= SHORT_TIME_STR.length() && StringUtils.isNotEmpty(srcTime) && srcTime.length() >= SHORT_TIME_STR.length()) {
                Date destTi = DEFAULT_TIME_FORMAT.parse(destTime);
                Date srcTi = DEFAULT_TIME_FORMAT.parse(srcTime);

                diffTime = Double.valueOf((destTi.getTime() - srcTi.getTime()) / MILLI_SEC_A_TIME);
            }
        } catch (Exception ignore) {
        }
        return diffTime;
    }
    
    /**
     * [timeDiff랑 다름]시간차이를 구한다, sec(초), min(분), hr(시간)
     * 1200 - 1300 = 1, 60, 3600
     * @param startTime 1200
     * @param stopTime 1300
     * @param type (sec, min, hr - 기본값 시간)
     * @return long (더블아님)
     */
    public static long timeDiffTo(String startTime, String stopTime, String type) {
    	String returnType = type.toUpperCase();
        long diffTime = 0;
        try {
        	if (startTime.indexOf(":") == -1) {
        		startTime = startTime.substring(0, 2)+ ":" + startTime.substring(2, startTime.length());
        	}
        	if (stopTime.indexOf(":") == -1) {
        		stopTime = stopTime.substring(0, 2)+ ":" + stopTime.substring(2, stopTime.length());
        	}
        	Date d1 = DEFAULT_TIME_FORMAT.parse(startTime);
            Date d2 = DEFAULT_TIME_FORMAT.parse(stopTime);
            long diff = d2.getTime() - d1.getTime();
            switch (returnType) {
			case "SEC":
				diffTime = diff / 1000;
				break;
			case "MIN":
				diffTime = diff / (60 * 1000);
				break;
			default:
				diffTime = diff / (60 * 60 * 1000);
				break;
			}
        } catch (Exception ignore) {
        }
        return diffTime;
    }
    
    /**
     * strDt -> date
     * @param strDt
     * @param format default yyyy-MM-dd
     * @return
     */
    public static Date toDate(String strDt, String format) {
    	if (strDt == null) {
    		return null;
    	} else {
    		if (format == null) {
    			format = "yyyy-MM-dd";
    		}
    		try {
    			SimpleDateFormat sdf = new SimpleDateFormat(format);
    			return sdf.parse(strDt);
    		} catch (Exception e) {
				return null;
			}
    	}
    }
    
 
    
    public static String calcDate(String dt, int year, int month, int day) {

        String dateStr = dt;

        Calendar cal = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd", Locale.getDefault());
        try {
            cal.setTime(sdf.parse(dateStr));
        } catch (ParseException e) {
            throw new IllegalArgumentException("Invalid date format: " + dateStr);
        }

        if (year != 0)
            cal.add(Calendar.YEAR, year);
        if (month != 0)
            cal.add(Calendar.MONTH, month);
        if (day != 0)
            cal.add(Calendar.DATE, day);
        return sdf.format(cal.getTime());
    }

    /**
     * 시간을 계산한 dateStr을 구한다.
     *
     * @param dt
     * @param hh
     * @param mm
     * @param ss
     * @return
     */
    public static String calcTime(String dt, int hh, int mm, int ss) {

        String dateStr = dt;

        Calendar cal = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat(LONG_DATE_STR, Locale.getDefault());
        try {
            cal.setTime(sdf.parse(dateStr));
        } catch (ParseException e) {
            throw new IllegalArgumentException("Invalid date format: " + dateStr);
        }

        if (hh != 0)
            cal.add(Calendar.HOUR, hh);
        if (mm != 0)
            cal.add(Calendar.MINUTE, mm);
        if (ss != 0)
            cal.add(Calendar.SECOND, ss);
        return sdf.format(cal.getTime());
    }

    /**
     * utc time을 gmt로 변경
     * @param utcTime 2023-04-16T11:13:29.000Z
     * @return 2023-04-16 20:13:29
     */
    public static String utcToGmtDBStr(String utcTime) {
        Instant instant = Instant.parse(utcTime);
        ZonedDateTime zonedDateTime = instant.atZone(ZoneId.of("Asia/Seoul"));

        return zonedDateTime.format(DateTimeFormatter.ofPattern(DB_DATE_STR));
    }

    /**
     * GMT시간을 utc로 변경
     * @param yyyymmdd
     * @return 2023-04-17T00:00+09:00
     */
    public static String gmtToUtc(String yyyymmdd) {
        String yyyy = StringUtils.substring(yyyymmdd, 0, 4);
        String mm = StringUtils.substring(yyyymmdd, 4, 6);
        String dd = StringUtils.substring(yyyymmdd, 6, 8);

        int yyyyInt = StringUtil.toNumber(yyyy);
        int mmInt = StringUtil.toNumber(mm);
        mmInt = mmInt == 0 ? 1 : mmInt;
        int ddInt = StringUtil.toNumber(dd);
        ddInt = ddInt == 0 ? 1 : ddInt;

        ZonedDateTime zonedDateTime = Year.of(yyyyInt).atMonth(mmInt).atDay(ddInt).atTime(0,0).atZone(ZoneId.of("Asia/Seoul"));

        return zonedDateTime.toOffsetDateTime().toString();
    }

    /**
     * 해당 날짜의 YK회계연도 첫날을 구한다
     * @param dateStr yyyymmdd / yyyymm
     * @return yyyymmdd
     */
    public static String getFirstDayOfYk(String dateStr) {
        String firstDay = "";

        // 해당 날짜가 12월이라면 해당년도의 12월 1일, 아니라면 전년도의 12월 1일
		if ("12".equals(dateStr.substring(4, 6))) {
			firstDay = dateStr.substring(0, 6) + "01";
		} else {
			firstDay = (StringUtil.toNumber(dateStr.substring(0, 4)) - 1) + "1201";
		}

        return firstDay;
    }

    /**
     * 현재날짜의 YK회계년도 첫날을 구한다
     * @return yyyymmdd
     */
    public static String getFirstDayOfYk() {
        return getFirstDayOfYk(getCurrentDate());
    }

    /**
     * <p>해당 날짜 범위 내에 해당 날짜가 포함되어있는지 여부</p>
     * <pre>
     * containDateBetween("20240601", "20240630", "20240601") = true
     * containDateBetween("20240601", "20240630", "20240630") = true
     * containDateBetween("20240521", "20240630", "20240630") = false
     * </pre>
     * @param startRange 시작범위 날짜 (yyyymmdd)
     * @param endRange 종료범위 날짜 (yyyymmdd)
     * @param targetDate 해당 날짜 (yyyymmdd)
     * @return 해당 범위 내에 해당 날짜가 포함되어있다면 {@code true} 아니라면 {@code false}
     */
    public static boolean containDateBetween(String startRange, String endRange, String targetDate) {
        // param length must be...
        int length = SHORT_DATE_STR.length();
        if (startRange.length() != length || endRange.length() != length || targetDate.length() != length) {
            return false;
        }
        // target date - start date >= 0
        if (DateUtil.dateDiff(targetDate, startRange, false) >= 0) {
            // end date - target date >= 0
            return DateUtil.dateDiff(endRange, targetDate, false) >= 0;
        }
        return false;
    }
}
