package mobile.factory.util;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.StringUtils;

import mobile.factory.RequestDataSet;
import mobile.factory.db.dao.DBTableDao;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 10
 */
public class DBUtil {
	/**
	 * 인자로 받은 변수 val을 DB 쿼리의 값으로 사용할수 있는 String으로 바꾸어준다. "abc'cde" 라는 문자라면
	 * "'abc''cde'" 로 만들어 준다.
	 *
	 * @param val
	 * @return
	 */
	public static String toDBChar(String val) {
		// return "'" + StringEscapeUtils.escapeJava(val) + "'";
		String[] targetStr = new String[] { "'", "\"" };
		for (String target : targetStr) {
			val = StringUtils.replace(val, target, "\\" + target);
		}
		return String.format("'%s'", val);
	}

	public static String TO_DATE = " TO_DATE(";
	public static String DATE_FORMAT_SHORT = String.format(",'YYYY%sMM%sDD') ", DateUtil.DATE_DIV, DateUtil.DATE_DIV);
	public static String DATE_FORMAT_LONG = String.format(",'YYYY%sMM%sDD HH24:MI:SS') ", DateUtil.DATE_DIV, DateUtil.DATE_DIV);

	public static String toDBDate(String val) {
		if (StringUtils.isBlank(val)) {
			return "";
		}

		if (val.length() == String.format("YYYY%sMM%sDD", DateUtil.DATE_DIV, DateUtil.DATE_DIV).length()) {
			return toOnlyDate(val);
		} else {
			return toDateTime(val);
		}
	}

	public static String toOnlyDate(String val) {
		return TO_DATE + val + DATE_FORMAT_SHORT;
	}

	public static String toDateTime(String val) {
		return TO_DATE + val + DATE_FORMAT_LONG;
	}

	/**
	 * 실행쿼리를 생성해 준다.
	 *
	 * @param sql
	 *            파라메터는 []로 감싸준다.
	 * @param param
	 *            []에 들어가는 필드랑 변환될 값 맵
	 * @return
	 */
	public static String makeQuery(String sql, Map<String, String> param) {
		String[] fields = StringUtils.substringsBetween(sql, "[", "]");

		param = CollectionUtil.null2Blank(new HashMap<String, Object>(param));
		Set<String> set = param.keySet();
		for (String fieldKey : fields) {
			if (set.contains(fieldKey)) {
				Object obj = param.get(fieldKey);
				String val = obj.toString();
				val = DBUtil.toDBChar(val);
				sql = StringUtils.replaceOnce(sql, "[" + fieldKey + "]", val);
			}
		}
		return sql;
	}

	/**
	 * 행에대한 제한을 TOP 을 사용해야 하므로, select => select top 10
	 *
	 * @param sql
	 * @return
	 */
	public static String processCountQuery(String sql) {
		return processCountQuery(sql, 1000000);
	}

	public static String processCountQuery(String sql, int count) {
		if (DBTableDao.DB_MSSQL.equals(RequestDataSet.getDbVendor())) {
			sql = sql.toUpperCase();
			sql = StringUtils.replaceOnce(sql, "SELECT", "SELECT TOP " + count + " ");
		}
		return sql;
	}

	/**
	 * 날짜 2016-05-23 로 된걸 '-' 없앰
	 * 
	 * @param str
	 * @return
	 */
	public String toDtFormat(String str) {
		return StringUtils.isNotBlank(str) ? StringUtils.replace(str, DateUtil.DATE_DIV, "") : "";
	}

}
