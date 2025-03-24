package mobile.factory.db.handlers;

import java.io.Reader;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.jdbc.core.ColumnMapRowMapper;

import mobile.factory.db.vendor.DBDecryptManager;

/**
 * ColumnMapRowMapper가 clob 타입을 제대로 가져 오지 못해서 제수정
 * 
 * @author JeongY.Eom
 * @date 2014.05.07
 * 
 * @since 2007. 09. 12
 */
public class MofacColumnMapRowMapper extends ColumnMapRowMapper {
	private final Log logger = LogFactory.getLog(getClass());
	
	private DBDecryptManager dbDecryptManager;

	public void setDbDecryptManager(DBDecryptManager dbDecryptManager) {
		this.dbDecryptManager = dbDecryptManager;
	}

	public Map<String, Object> mapRow(ResultSet rs, int rowNum) throws SQLException {
		ResultSetMetaData rsmd = rs.getMetaData();
		int columnCount = rsmd.getColumnCount();

		Map<String, Object> mapOfColValues = createColumnMap(columnCount);
		for (int i = 1; i <= columnCount; i++) {
			String key = getColumnKey(rsmd.getColumnLabel(i));
			String className = rsmd.getColumnTypeName(i);

			Object obj = null;
			if (className.equals("CLOB")) {
				obj = readClob(rs, i);
			} else if (className.endsWith("BINARY")) {
				obj = new String((byte[]) getColumnValue(rs, i));
			} else if (className.endsWith("TIMESTAMP")) {
				Object resultObj = getColumnValue(rs, i);

				if (resultObj != null) {
					obj = new MofacTimestamp(((Timestamp) resultObj).getTime());
				}
			} else {
				obj = getColumnValue(rs, i);
			}

			if (obj == null) {
				obj = "";
			}

			// 암호화 필드인 경우 복호화 진행
			if (dbDecryptManager != null && obj instanceof String) {
				obj = dbDecryptManager.decrypt(key, obj.toString());

				dbDecryptManager.setSplitColumn(key, obj.toString(), mapOfColValues);
			}

			mapOfColValues.put(key.toLowerCase(), obj);
		}
		return mapOfColValues;
	}

	protected Object readClob(ResultSet rs, int idx) {
		StringBuffer stringbuffer = new StringBuffer();
		char[] charbuffer = new char[1024];
		int read = 0;

		Reader reader = null;
		String result = null;
		try {
			reader = rs.getCharacterStream(idx);
			while ((read = reader.read(charbuffer, 0, 1024)) != -1)
				stringbuffer.append(charbuffer, 0, read);

			result = stringbuffer.toString();
		} catch (Exception ignore) {
			// logger.debug(ignore);
		} finally {
			if (reader != null)
				try {
					reader.close();
				} catch (Exception e) {
				}
		}

		return result;
	}

	protected String convert2CamelCase(String underScore) {
		if (underScore.indexOf('_') < 0 && Character.isLowerCase(underScore.charAt(0))) {
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

	class MofacTimestamp extends Timestamp {
		private static final long serialVersionUID = 1L;

		public MofacTimestamp(long time) {
			super(time);
			// TODO Auto-generated constructor stub
		}

		@Override
		public String toString() {
			// TODO Auto-generated method stub
			return StringUtils.substringBeforeLast(super.toString(), ".");
		}
	}
}
