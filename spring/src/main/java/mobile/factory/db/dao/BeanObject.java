package mobile.factory.db.dao;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.beanutils.PropertyUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import mobile.factory.exception.FrameException;
import mobile.factory.util.DateUtil;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 10
 */
public abstract class BeanObject implements Cloneable {

	private static Log logger = LogFactory.getLog(BeanObject.class);

	private String dbKind = "";

	private DBTableRunner tableRunner = null;

	protected Map<String, String> inputParam = new HashMap<>();

	public abstract boolean isEncryptionField(int i);

	public abstract boolean isPrimaryKey(int i);

	public abstract boolean isPrimaryKey(String col);

	public abstract int getDBColumnSize(String colName);

	public abstract String getDBColumnType(int i);

	public abstract String getDBColumnType(String colName);

	public abstract String getDBColumnComment(String col);

	public abstract String[] getFieldArray();

	/**
	 * <pre>
	 * 	컬럼을 확장했을때,
	 * 	테이블 컬럼외에 추가된 컬럼이 있는 경우가 있음.
	 * 	이경우에는 CUD에서 빠져야 하므로 CUD에서는 getFieldArray 사용하고,
	 * 	추가컬럼 관리에는 해당 메소드를 사용함.
	 * </pre>
	 * @return
	 */
	public String[] getRealFieldArray() {
		return getFieldArray();
	}

	public abstract Set<String> getFieldSet();

	public abstract List<String> getPrimaryKeyList();

	public abstract String getTableName();

	public abstract boolean isSetField(int i);

	private boolean isSelectedOne = false;

	/**
	 * 컬럼인덱스 구하기
	 * @param colName
	 * @return
	 */
	public abstract int getDBColumnIndex(String colName);

	/**
	 * 셋팅정보 지우기(입력/수정에서 제외됨)
	 * @param idx
	 */
	public abstract void clearSetField(int idx);

	/**
	 * 셋팅정보 지우기(입력/수정에서 제외됨)
	 * @param colName
	 */
	public abstract void clearSetField(String colName);

	/**
	 * 값이 셋팅된 필드 구하기
	 *
	 * @return
	 */
	public String[] getSetFieldArray() {
		Set<String> setCol = new LinkedHashSet<String>();

		for (int i = 0, n = getFieldArray().length; i < n; i++) {
			if (isSetField(i)) {
				setCol.add(getFieldArray()[i]);
			}
		}

		return setCol.toArray(new String[] {});
	}

	/**
	 * 셋팅된 inputParam 에 Bean에 있는 값을 덮어서 가져옴
	 *
	 * @return
	 */
	public Map<String, Object> getInputParamWithSetValue() {
		Map<String, Object> map = new HashMap<String, Object>(getInputParam());

		for (String colName : getSetFieldArray()) {
			Object colValue = getParamValue(colName);
			map.put(colName, colValue);
		}

		return map;
	}

	private String cmd = "";

	public String getCmd() {
		return cmd;
	}

	public void setCmd(String cmd) {
		this.cmd = cmd;
	}

	public Map<String, String> getInputParam() {
		return inputParam;
	}

	public void setInputParam(Map<String, String> inputParam) {
		this.inputParam = inputParam;
	}

	public void setTableRunner(DBTableRunner tableRunner) {
		this.tableRunner = tableRunner;
	}

	public void beforeInsert(BeanObject bean) {
		if (bean.tableRunner != null) {
			bean.tableRunner.beforeInsert(bean);
		}

	}

	public void beforeUpdate(BeanObject bean) {
		if (bean.tableRunner != null) {
			bean.tableRunner.beforeUpdate(bean);
		}
	}

	public String appendUpdateSql(BeanObject bean) {
		if (bean.tableRunner != null) {
			String result = bean.tableRunner.appendUpdateSQL(bean);
			return result == null ? "" : result;
		} else {
			return "";
		}
	}

	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public boolean equals(Object obj) {
		return this.toString().equals(obj.toString());
	}

	public Object get(String colName) {
		Object value = getParamValue(colName);
		if (value instanceof Timestamp) {
			value = DateUtil.toDefaultDateFormat((Timestamp) value);
		}
		if (value == null) {
			value = "";
		}
		return value;
	}

	/**
	 * prepare statement 용 insert 쿼리에 써먹을 파라메터 value를 만들어주는 메소드
	 *
	 * @return 파라메터 value를 담은 오브젝트 베열.
	 */
	public Object[] getInsertParams() {
		String[] fields = getFieldArray();
		List<Object> paramList = new ArrayList<Object>();

		for (int i = 0; i < fields.length; i++) {
			if (isSetField(i)) {
				Object obj = getParamValue(fields[i]);
				String val = obj == null ? "" : obj.toString();
				if ("dbo.fn_sysdate()".equals(val) == false) { // &&
					// "TIMESTAMP".equals(getDBColumnType(i))
					// == false) {
					paramList.add(getParamValue(fields[i]));
				}
			}
		}
		return paramList.toArray();
	}

	private Object getParamValue(String szFieldName) {
		Object value;
		try {
			value = PropertyUtils.getProperty(this, szFieldName);
		} catch (Exception e) {
			logger.error("", e);
			throw new FrameException(e.getMessage());
		}
		return value;
	}

	protected List<Object> getPKParams() {
		if (!isAllPKSet()) {
			throw new FrameException("ITI: All primary key must be set before query!!");
		}

		List<Object> keyParams = new ArrayList<Object>();
		String[] fields = getFieldArray();
		Object[] params = new Object[fields.length];

		for (int i = 0; i < params.length; i++) {
			Object value = null;
			if (isPrimaryKey(i)) {
				value = getParamValue(fields[i]);
				keyParams.add(value);
			}
		}

		return keyParams;
	}

	/**
	 * index에 값에 해당하는 column의 value를 String형태로 가져오는 메소드로 int 값이라 할지라도 값이 setting
	 * 되어 있지 않으면 "" 스트링을 return한다. 세팅이 되어 있으면, 그 값을 String형태로 변환하여 반환한다.
	 *
	 * @param index
	 *            이 값은 해당 Bean의 상수로 정의되어 있는 값만 사용가능하다. 예 :
	 *            person.getPrintVal(BeanPerson.ID)
	 * @return
	 */
	public String getPrintVal(int index) {
		String retVal = "";
		if (isSetField(index)) {
			try {
				retVal = BeanUtils.getSimpleProperty(this, getFieldArray()[index]);
			} catch (Exception e) {
				logger.error("", e);
				throw new FrameException(e.getMessage());
			}
		}
		return retVal;
	}

	public String[] getSetFields() {
		String[] fields = getFieldArray();
		List<String> list = new ArrayList<String>();
		for (int i = 0; i < fields.length; i++) {
			if (isSetField(i)) {
				list.add(fields[i]);
			}
		}

		String[] arr = new String[list.size()];
		for (int i = 0, n = list.size(); i < n; i++) {
			arr[i] = list.get(i);
		}
		return arr;
	}

	public List<Object> getSetValueParam() {
		List<Object> valueParams = new ArrayList<Object>();

		String[] fields = getFieldArray();
		Object[] params = new Object[fields.length];

		try {
			for (int i = 0; i < params.length; i++) {
				Object value = null;
				if (isSetField(i)) {
					value = getParamValue(fields[i]);
					valueParams.add(value);
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			throw new RuntimeException(" Failed to extracting Parameter value");
		}
		return valueParams;
	}

	/**
	 * PK가 하나이면 해당 PK이름을 반환하고 PK가 없거나 2개 이상이면 null을 반환.
	 *
	 * @return
	 */
	public String getThePKName() {
		List<String> pkList = getPrimaryKeyList();
		if (pkList.size() == 1) {
			return (String) pkList.get(0);
		}
		return null;
	}

	/**
	 * Setting된 값 + PK값을 파라메터로 사용하기 위하여 Object[]로 반환.
	 *
	 * @return
	 * @throws Exception
	 */
	protected Object[] getUpdateAllColumnParams() {
		Object[] setParams = getUpdateParams(getSetFields());

		List<Object> params = new ArrayList<Object>();
		for (int i = 0; i < setParams.length; i++) {
			params.add(setParams[i]);
		}
		params.addAll(getPKParams());
		return params.toArray();
	}

	protected Object[] getUpdateParams(Object[] paramFields) {
		return getUpdateParams(paramFields, false);
	}

	protected Object[] getUpdateParams(Object[] paramFields, boolean containPK) {
		List<Object> valueParams = new ArrayList<Object>();

		for (int i = 0; i < paramFields.length; i++) {
			String szFieldName = (String) paramFields[i];
			Object value = getParamValue(szFieldName);

			String szFieldType = getDBColumnType(szFieldName);

			boolean add = true;
			// 컬럼 타입이 날짜이고, null 로 셋팅이 되었으면 셋팅안함
			if("DATE".equals(szFieldType) && value == null) {
				add = true;
			}

			if (containPK && add) {
				valueParams.add(value);
			} else {
				if (!isPrimaryKey((String) paramFields[i]) && add) {
					valueParams.add(value);
				}
			}
		}

		return valueParams.toArray();
	}

	void haveSelected() {
		isSelectedOne = true;
	}

	public boolean isAllPKSet() {
		Iterator<?> iter = getPrimaryKeyList().iterator();
		while (iter.hasNext()) {
			String col = (String) iter.next();
			if (!isSetField(col)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * 이 테이블의 PK가 하나이며 int type이라면 true 아니라면 false;
	 *
	 * @return
	 */
	public boolean isAutoIncrementable() {
		try {
			String pkName = getThePKName();
			Class<?> clazz = PropertyUtils.getPropertyType(this, pkName);
			if (clazz == long.class) {
				return true;
			}
		} catch (Exception e) {
			logger.error("# Could not configure column type!", e);
		}

		return false;
	}

	public boolean isSelected() {
		return isSelectedOne;
	}

	public boolean isSetField(String col) {
		Object[] fields = getFieldArray();
		for (int i = 0; i < fields.length; i++) {
			if (fields[i].equals(col)) {
				return isSetField(i);
			}
		}
		return false;
	}

	public void setValuesFrom(BeanObject bean) {
		try {
			BeanUtils.copyProperties(this, bean);
		} catch (Exception e) {
			logger.error("", e);
			throw new FrameException(e.getMessage());
		}
	}

	public Map<String, String> toStringMap() {
		Map<String, String> map = new HashMap<String, String>();

		for (String col : getFieldArray()) {
			try {
				String val = BeanUtils.getProperty(this, col);
				map.put(col, val);
			} catch (Exception ignore) {
				logger.error(ignore);
			}
		}
		return map;
	}

	/**
	 * 하나의 구조체 멤버를 | 로 구분한 String으로 변환
	 */
	public String toString() {
		String[] fields = getFieldArray();

		StringBuilder out = new StringBuilder();

		for (int i = 0; i < fields.length; i++) {
			try {
				out.append(StringUtils.substring(BeanUtils.getSimpleProperty(this, fields[i]), 0, 500));
				out.append(" | "); // 열 구분
			} catch (Exception e) {
				logger.error("", e);
			}
		}
		return out.toString();
	}

	/**
	 * 맵으로 전환
	 *
	 * @param onlySet
	 *            셋팅여부
	 * @return
	 */
	public Map<String, Object> toMap(boolean onlySet) {
		Map<String, Object> map = new HashMap<String, Object>();

		String[] fieldAray = onlySet ? getSetFieldArray() : getFieldArray();

		for (String col : fieldAray) {
			try {
				String val = BeanUtils.getProperty(this, col);
				map.put(col, val);
			} catch (Exception ignore) {
				logger.error(ignore);
			}
		}

		return map;
	}

	/**
	 * 맵으로 전환
	 *
	 * @return
	 */
	public Map<String, Object> toMap() {
		return toMap(false);
	}

	public String getDbKind() {
		return dbKind;
	}

	public void setDbKind(String dbKind) {
		this.dbKind = dbKind;
	}

	/**
	 * 컬럼 인덱스 구함
	 *
	 * @param col
	 * @return 존재하면 컬럼 순번, 없으면 -1
	 */
	public int getFieldIndex(String col) {
		for (int i = 0, n = this.getFieldArray().length; i < n; i++) {
			if (this.getFieldArray()[i].equals(col)) {
				return i;
			}
		}
		return -1;
	}
}
