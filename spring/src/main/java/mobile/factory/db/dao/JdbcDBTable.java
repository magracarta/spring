package mobile.factory.db.dao;

import mobile.factory.db.handlers.ResultSetExtractorBeanHandler;
import mobile.factory.db.handlers.ResultSetExtractorBeanListHandler;
import mobile.factory.db.vendor.EncryptManager;
import mobile.factory.exception.FrameException;
import mobile.factory.util.BeanUtil;
import mobile.factory.util.DBUtil;
import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.support.JdbcDaoSupport;
import org.springframework.security.access.method.P;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 이 클래스는 DB 테이블 별로 쿼리를 수행하는 클래스
 * 
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 10
 */
public abstract class JdbcDBTable extends JdbcDaoSupport implements DBTableDao {

	protected static Log logger = LogFactory.getLog(JdbcDBTable.class);

	public static final String WHERE_ONE_TO_ONE = " WHERE 1 = 1 ";

	public static final String AND = " AND ";

	public static final int ALL_COUNT = -1;

	private boolean throwEx = true;
	
	/**
	 * 디비계정을 다르게 데이터를 관리하고, 일련번호등 번호등은 한개로 관리해야할때 기준이 되는 스키마
	 */
	@Value("${spring.datasource.username}")
	private String dbSchema;

	@Autowired
	@Qualifier("encryptManager")
	private EncryptManager encryptManager;

	@Autowired(required=false)
	private DBTableRunner tableRunner;
	
	public void setTableRunner(DBTableRunner tableRunner) {
		this.tableRunner = tableRunner;
	}
	
	protected BeanObject tableInfo;

	public void setTableInfo(BeanObject tableInfo) {
		this.tableInfo = tableInfo;
		if(tableRunner != null) {
			this.tableInfo.setTableRunner(tableRunner);
		}
		setDbKind();
	}
	// ####################################################################
	abstract protected void setDbKind();
	
	public String getSelectSQL() {
		return String.format(" SELECT %s FROM %s ", makeSelectAllColumnSQL(), tableInfo.getTableName());
	}
	
	/**
	 * select 컬럼 생성, 암호화 컬럼 존재시 복호화 함수 감쌈.
	 * @return
	 */
	private String makeSelectAllColumnSQL() {
		Set<String> fieldSet = new LinkedHashSet<>();

		boolean containEncrypt = false;
		for (String item : tableInfo.getFieldArray()) {
			boolean isEncrypt = tableInfo.isEncryptionField(tableInfo.getFieldIndex(item));

			String fieldName = item;
			if (isEncrypt) {
				fieldName = String.format("fnc_decrypt_var(%s) as %s", item, item);
				containEncrypt = true;
			}

			fieldSet.add(fieldName);
		}

		return containEncrypt ? StringUtils.join(fieldSet.toArray(new String[] {}), ", ") : " * ";
	}

	public String getCountSQL() {
		return String.format(" SELECT count(0) as cnt FROM %s ", tableInfo.getTableName());
	}

	public String getPKWhereStatement(BeanObject bean) {
		String[] fields = tableInfo.getFieldArray();
		StringBuilder where = new StringBuilder(WHERE_ONE_TO_ONE);

		for (int i = 0, n = fields.length; i < n; i++) {
			if (tableInfo.isPrimaryKey(i)) {
				where.append(AND + fields[i] + " = " + getParamString(bean, fields[i], false));
			}
		}
		return where.toString();
	}

	public String getSetValueWhereStatement(BeanObject whereBean) {
		String[] fields = whereBean.getFieldArray();
		StringBuffer where = new StringBuffer(WHERE_ONE_TO_ONE);

		for (int i = 0, n = fields.length; i < n; i++) {
			// Setting된 값으로만 조건을 만든다.
			if (whereBean.isSetField(i)) {
				where.append(AND + fields[i] + " = " + getParamString(whereBean, fields[i], false));
			}
		}
		return where.toString();
	}

	/**
	 * Oracle에서는 date값을 String으로 바로 insert가 안되기 때문에 TO_DATE 함수를 쓰도록 함.
	 * 
	 * @param bean
	 * @param szFieldName
	 * @param update 업데이트일 경우 날자 형식에 대해 null로 셋팅하기 위해 정보 전달
	 * @return
	 */
	public String getParamString(BeanObject bean, String szFieldName, boolean update) {
		String out;
		String fieldName = bean.getDBColumnType(szFieldName);

		if (fieldName.equals("DATE") || fieldName.equals("DATETIME")) {
			// 날짜일 때는 세팅되어 있는 값의 길이에 따라 다르게 String을 만듦.
			String value = "";
			try {
				value = BeanUtils.getSimpleProperty(bean, szFieldName);
			} catch (Exception e) {
				logger.error("", e);
			}
			
			// 날짜타입에 값이 null이면 null로 업데이트
			if(update && value == null) {
				out = " ? ";
			} else {
				if (value.length() > 10) {
					out = DBUtil.toDateTime(" ? ");
				} else {
					out = DBUtil.toOnlyDate(" ? ");
				}
			}
		} else {
			out = " ? ";
		}
		return out;
	}

	public String getCountLimitString() {
		// Default 는 Oracle에 맞춰놓음.
		return " AND rownum <= ";
	}

	public String getSeqNextVal() throws DataAccessException {
		String tableName = tableInfo.getTableName();

		String seqName;
		if (tableName.startsWith("T_")) {
			// T_ 로 시작하는 테이블은 SEQ_로 바꿔줌.
			seqName = tableName.replaceAll("^T_", "SEQ_");
		} else {
			seqName = "SEQ_" + tableName;
		}
		
		if(StringUtils.isNotBlank(dbSchema)) {
			seqName = String.format("%s.%s", dbSchema, seqName);
		}

		Object val = selectAValue(String.format(" SELECT %s.nextval FROM dual ", seqName));

		return val.toString();
	}
	
	/**
	 * PK리스트중에 seq_no가 있고, 순차 증가일때, seq_no 값이 0이면 새로 발번한다.
	 * @return
	 * @throws DataAccessException
	 */
	public String getSequenceSeqNoNextVal(BeanObject bean) throws DataAccessException {
		return getSequenceSeqNoNextVal(bean, "seq_no");
	}
	
	/**
	 * PK리스트중에 fieldName 이 있고, 순차 증가일때, fieldName 의 값이 0이면 새로 발번한다.
	 * @param bean
	 * @param fieldName
	 * @return
	 * @throws DataAccessException
	 */
	public String getSequenceSeqNoNextVal(BeanObject bean, String fieldName) throws DataAccessException {
		String seqNoField = StringUtils.defaultIfBlank(fieldName, "seq_no");
		
		List<String> pkList = new ArrayList<String>(tableInfo.getPrimaryKeyList());
		pkList.remove(seqNoField);
		
		StringBuilder sb = new StringBuilder();
		sb.append( String.format(" select nvl(max(%s), 0) + 1 as val from %s where 1=1 ", seqNoField, tableInfo.getTableName()));
		
		for(String item : pkList) {
			sb.append(String.format(" and %s = '%s' ", item, BeanUtil.getProperty(bean, item)));
		}
		
		Object val = selectAValue(sb.toString());
		
		return val.toString();
	}

	// ####################################################################

	// ########### Start Of Select ##########

	public BeanObject selectByPK(BeanObject bean) throws DataAccessException {
		String sql = getSelectSQL() + getPKWhereStatement(bean);

		BeanObject resultBean = null;
		Object[] params = bean.getPKParams().toArray();

		ResultSetExtractor resultSetExtractor = new ResultSetExtractorBeanHandler(tableInfo);

		Object obj = getJdbcTemplate().query(sql, params, resultSetExtractor);
		if (obj != null) {
			resultBean = (BeanObject) getJdbcTemplate().query(sql, params, resultSetExtractor);
		}

		if (logger.isDebugEnabled() && resultBean != null) {
			logger.debug("########## resultBean = " + resultBean.toString());
		}
		return resultBean;
	}

	public BeanObject selectFirst(BeanObject bean) throws DataAccessException {
		List list = selectBySetValue(bean, 1);
		if (list.size() > 0) {
			return (BeanObject) list.get(0);
		} else
			return null;
	}

	public Object selectAValue(String sql, BeanObject whereBean) throws DataAccessException {
		sql += getSetValueWhereStatement(whereBean);

		Object[] params = whereBean.getSetValueParam().toArray();

		Object object = getJdbcTemplate().queryForObject(sql, params, new SingleColumnRowMapper());

		return object;
	}

	public Object selectAValue(String sql) throws DataAccessException {

		Object obj = getJdbcTemplate().queryForObject(sql, new SingleColumnRowMapper());
		return obj;
	}

	public int selectCountByWhere(String where) throws DataAccessException {
		long count = ((Long) selectAValue(getCountSQL() + where)).longValue();
		return (int)count;
	}

	public List<BeanObject> select(String sql, Object[] params) throws DataAccessException {
		ResultSetExtractor resultSetExtractor = new ResultSetExtractorBeanListHandler(tableInfo);
		List<BeanObject> resultList = (List<BeanObject>) getJdbcTemplate().query(sql, params, resultSetExtractor);

		if (logger.isDebugEnabled()) {
			if (resultList != null) {
				logger.debug("########## resultBeanList.size() = " + resultList.size());
				if (resultList.size() > 0)
					logger.debug("########## resultBeanList.get(0) = " + resultList.get(0));
			}
		}

		return resultList;
	}

	public List<BeanObject> selectByWhere(String where) throws DataAccessException {
		return selectByWhere(where, ALL_COUNT);
	}

	public List<BeanObject> selectByWhere(String where, int count) throws DataAccessException {
		if (StringUtils.isEmpty(where)) {
			where = WHERE_ONE_TO_ONE;
		}

		String sql = "SELECT * FROM " + tableInfo.getTableName() + " " + where;
		if (count != ALL_COUNT) {
			if (DBTableDao.DB_MSSQL.equals(tableInfo.getDbKind())) {
				sql = DBUtil.processCountQuery(sql, count);
			} else {
				sql += getCountLimitString() + count;
			}
		}

		return select(sql, null);
	}

	public List<BeanObject> selectBySetValue(BeanObject bean) throws DataAccessException {
		return selectBySetValue(bean, ALL_COUNT);
	}

	public List<BeanObject> selectBySetValue(BeanObject bean, int count) throws DataAccessException {
		String sql = getSelectSQL() + getSetValueWhereStatement(bean);
		if (count != ALL_COUNT) {
			if (DBTableDao.DB_MSSQL.equals(tableInfo.getDbKind())) {
				sql = DBUtil.processCountQuery(sql, count);
			} else {
				sql += getCountLimitString() + count;
			}
		}
		List<Object> param = bean.getSetValueParam();
		return select(sql, param.toArray());
	}

	public List<BeanObject> selectAll() throws DataAccessException {
		return selectByWhere(null, ALL_COLUMN);
	}

	// ########### End Of Select ##########

	// ########### Start Of Insert ##########

	/**
	 * 
	 */
	public long insert(BeanObject bean) throws DataAccessException {
		bean = createInsertBean(bean);

		BeanUtil.validateSetValueLength(bean, throwEx);

		getJdbcTemplate().update(getInsertSQL(bean), bean.getInsertParams());
		return -1;
	}
	
	/**
	 * 등록직전 빈 정보를 셋팅함
	 * @param bean
	 * @return
	 */
	private BeanObject createInsertBean(BeanObject bean) {
		bean.setDbKind(tableInfo.getDbKind());		
		bean.setTableRunner(tableRunner);
		
		tableInfo.beforeInsert(bean);
		
		return bean;
	}
	
	private String createStamentSql(String sql, Object[] param) {
		for (Object item : param) {
			String value = null;
			if (item == null) {
				value = "null";
			} else if (item instanceof Number) {
				value = item.toString();
			} else {
				value = String.format("'%s'", item);
			}

			sql = StringUtils.replaceOnce(sql, "?", value);
		}

		return sql;
	}
	
	public int insert(List<? extends BeanObject> valueList) throws DataAccessException {
		int count = 0;
		if (valueList == null) {
			return count;
		}

//		List<String> list = new ArrayList<>();
//		for (BeanObject bean : valueList) {
//			setDefaultValueBeforeInsert(bean);
//			bean = createInsertBean(bean);
//
//			String sql = createStamentSql(getInsertSQL(bean), bean.getInsertParams());
//			if (StringUtils.isNotBlank(sql)) {
//				list.add(sql);
//			}
//		}
//
//		if (list.isEmpty() == false) {
//			int[] result = getJdbcTemplate().batchUpdate(list.toArray(new String[] {}));
//			return result.length;
//		} else {
//			return 0;
//		}
		
		for (BeanObject bean : valueList) {
			insert(bean);
			count++;
		}
		
		return count;
	}

	/**
	 * insert SQL 문장을 만들어 주는 메소드.
	 * 
	 * @param bean
	 * @return
	 */
	public String getInsertSQL(BeanObject bean) {
		boolean hasSetAColumn = false;
		String[] fields = bean.getFieldArray();
		StringBuffer sql = new StringBuffer();

		sql.append("INSERT INTO " + tableInfo.getTableName() + " ( ");
		int i = 0;
		for (; i < fields.length; i++) {
			// 모든 column을 처리하도록 되어 있을 때나
			// 그렇지 않을 때는 세팅한 값에 대해서만 insert 구문을 만듦.

			if (bean.isSetField(i)) {
				if (hasSetAColumn) {
					sql.append(", ");
				}
				hasSetAColumn = true;
				sql.append(fields[i]);
			}
		}

		sql.append(" ) VALUES ( ");

		i = 0;
		hasSetAColumn = false;
		for (; i < fields.length; i++) {
			if (bean.isSetField(i)) {
				if (hasSetAColumn) {
					sql.append(", ");
				}
				hasSetAColumn = true;

				if (bean.isEncryptionField(i)) {
					sql.append(encryptManager.getEncryptQuery(getParamString(bean, fields[i], false)));
				} else {
					sql.append(getParamString(bean, fields[i], false));
				}
			}
		}
		sql.append(" ) ");
		return sql.toString();
	}

	// ########### End Of Insert ##########

	// ########### Start Of Update ##########
	public int updateByPK(BeanObject bean) throws DataAccessException {
		String sql = getUpdateSQL(bean) + getPKWhereStatement(bean);

		BeanUtil.validateSetValueLength(bean, throwEx);

		int updateCount = getJdbcTemplate().update(sql, bean.getUpdateAllColumnParams());

		return updateCount;

	}

	public int updateByWhere(BeanObject bean, BeanObject whereBean) throws DataAccessException {
		return updateByWhere(bean, getSetValueWhereStatement(whereBean), whereBean);
	}

	public int updateByWhere(BeanObject bean, String where, BeanObject whereBean) throws DataAccessException {
		Object[] arrUpdateParam = bean.getUpdateParams(bean.getSetFields());
		Object[] arrWhereParam = whereBean.getUpdateParams(whereBean.getSetFields(), true);
		
		Object[] arrParam = new Object[arrUpdateParam.length + arrWhereParam.length];
		
		int step = 0;
		for (Object obj : arrUpdateParam) {
			arrParam[step++] = obj;
		}
		for (Object obj : arrWhereParam) {
			arrParam[step++] = obj;
		}

		BeanUtil.validateSetValueLength(bean, throwEx);
		
		int updateCount = getJdbcTemplate().update(getUpdateSQL(bean) + where, arrParam);
		return updateCount;
		
	}
	
	public int updateByWhere(BeanObject bean, String where) throws DataAccessException {
		BeanUtil.validateSetValueLength(bean, throwEx);

		int updateCount = getJdbcTemplate().update(getUpdateSQL(bean) + where, bean.getUpdateParams(bean.getSetFields()) );
		return updateCount;

	}

	/**
	 * setter에 의해 setting된 PK값에 해당하는 Row를 PK값 이외에 setting된 value로 update하기위한
	 * prepare statement용 쿼리를 만드는.
	 * 
	 * @return where 조건없음.
	 */
	public String getUpdateSQL(BeanObject bean) {
		bean.setDbKind(tableInfo.getDbKind());
		bean.setTableRunner(tableRunner);
		
		tableInfo.beforeUpdate(bean);

		String[] fields = bean.getFieldArray();
		if (fields.length == 0) {
			throw new FrameException("There is no Setting Fields!! ");
		}

		StringBuffer sql = new StringBuffer();
		sql.append("UPDATE " + bean.getTableName() + " SET ");
		
		String appendUpdateSql = String.format(" %s ", tableInfo.appendUpdateSql(bean));

		StringBuilder sb = new StringBuilder();
				
		boolean hasSetAColumn = false;
		for (int i = 0; i < fields.length; i++) {
			// PK는 update할수 없으므로 제외 시킨다.
			if (!bean.isPrimaryKey(fields[i]) && bean.isSetField(fields[i])) {
				if (hasSetAColumn) {
					sb.append(", ");
				}
				hasSetAColumn = true;

				if (bean.isEncryptionField(i)) {
					sb.append(fields[i] + " = " + encryptManager.getEncryptQuery(getParamString(bean, (String) fields[i], true)));
				} else {
					sb.append(fields[i] + " = " + getParamString(bean, (String) fields[i], true));
				}
			}
		}
		
		if(sb.length() == 0) {
			appendUpdateSql = StringUtils.removeEnd(appendUpdateSql.trim(), ",") + " ";
		}
		sql.append(appendUpdateSql);
		sql.append(sb.toString());		

		return sql.toString() + " ";
	}

	// ########### End Of Update ##########

	// ########### Start Of Delete ##########
	public static final int ALL_COLUMN = -1;
	public static final int SEL_COLUMN = 0;

	public int deleteByPK(BeanObject bean) throws DataAccessException {
		if(deletePKContition(bean) == false) {
			return 0;
		}

		String sql  = getDeleteSQL() + getPKWhereStatement(bean);
		List<Object> param = bean.getPKParams();

		int deleteCount = getJdbcTemplate().update(sql, param.toArray());
		return deleteCount;
	}

	/**
	 * PK로 삭제시 PK여부를 체크
	 * @param bean
	 * @return
	 * @throws DataAccessException
	 */
	private boolean deletePKContition(BeanObject bean) throws DataAccessException {
		if (bean.getPrimaryKeyList().size() < 1) {
			logger.warn("PK가 없는 테이블 입니다!!!");
			return false;
		}

		List<Object> param = bean.getPKParams();
		if (CollectionUtils.isEmpty(param) || StringUtils.isBlank(param.get(0) + "")) {
			logger.warn("PK로 delete하려는 파라메터가 없습니다. param=" + param);
			return false;
		}

		return true;
	}

	public int deleteByWhere(String where) throws DataAccessException {
		return deleteByWhere(where, new Object[] {});
	}

	public int deleteByWhere(String where, Object... params) throws DataAccessException {
		String deleteSQL = getDeleteSQL();
		int deleteCount = getJdbcTemplate().update(deleteSQL + where, params);
		return deleteCount;
	}

	/**
	 * 이 Bean의 테이블의 삭제하는 delete 쿼리를 만듦 where 조건 없음.
	 * 
	 * @return
	 */
	public String getDeleteSQL() {
		return "DELETE FROM " + tableInfo.getTableName() + " ";
	}
	
	// ########### End Of Delete ##########

	public boolean selectExists(BeanObject bean) throws DataAccessException {
		return selectFirst(bean) == null ? false : true;
	}

	public int selectCount(String sql) throws DataAccessException {
		Object obj = selectAValue(" SELECT count(0) FROM ( " + DBUtil.processCountQuery(sql) + " ) T ");
		return Integer.parseInt(obj.toString());
	}
	
	@Override
	public long processBeanCmd(List<? extends BeanObject> list) throws DataAccessException {
		long resultCnt = 0;
		for (BeanObject bean : list) {

			long resultValue = processBeanCmd(bean);
			if (resultValue == -1 || resultValue > 0) {
				resultCnt++;
			}
		}

		return resultCnt;
	}
	
	@Override
	public long processBeanCmd(BeanObject bean) throws DataAccessException {
		long resultValue = 0;
		switch (bean.getCmd()) {
		case DBTableDao.CMD_CREATE:
			resultValue = insert(bean);
			break;
		case DBTableDao.CMD_UPDATE:
			resultValue = updateByPK(bean);
			break;
		case DBTableDao.CMD_DELETE:
			// 삭제일 경우 테이블에 use_yn이 있을경우, 사용여부를 N으로 업데이트
			if (bean.getDBColumnType("use_yn") != null) {
				try {
					BeanUtils.setProperty(bean, "use_yn", "N");
					resultValue = updateByPK(bean);
				} catch (Exception ignore) {
					logger.warn("", ignore);
				}
			} else {
				resultValue = deleteByPK(bean);
			}

			break;
		}
		
		return resultValue;
	}
	
	@Override
	public int updateByPK(List<? extends BeanObject> list) throws DataAccessException {
		int cnt = 0;
		for (BeanObject bean : list) {
			cnt += updateByPK(bean);
		}

		return cnt;
	}
	
	@Override
	public long insertIfExistsUpdatebypk(BeanObject bean) throws DataAccessException {
		if (bean.isAllPKSet() == false || selectByPK(bean) == null) {
			return insert(bean);
		} else {
			return updateByPK(bean);
		}
	}
	
	@Override
	public void setDefaultValueBeforeInsert(BeanObject bean) throws DataAccessException {
	}

	@Override
	public long processBeanBulkCmd(List<? extends BeanObject> list) throws DataAccessException {
		List<String> sqlList = new ArrayList<>();

		for (BeanObject bean : list) {
			String sql = null;
			Object[] param = null;
			switch (bean.getCmd()) {
				case DBTableDao.CMD_CREATE:
					bean = createInsertBean(bean);
					sql = getInsertSQL(bean);
					param = bean.getInsertParams();

					sqlList.add(convertStatement(sql, param));
					break;
				case DBTableDao.CMD_UPDATE:
					sql = getUpdateSQL(bean) + getPKWhereStatement(bean);
					param = bean.getUpdateAllColumnParams();

					sqlList.add(convertStatement(sql, param));
					break;
				case DBTableDao.CMD_DELETE:
					if (deletePKContition(bean)) {
						sql = getDeleteSQL() + getPKWhereStatement(bean);
						param = bean.getPKParams().toArray();

						sqlList.add(convertStatement(sql, param));
					}
					break;
			}
		}

		int executeCnt = 0;
		if (sqlList.size() > 0) {
			int[] result = getJdbcTemplate().batchUpdate(sqlList.toArray(new String[]{}));
			for (int i : result) {
				executeCnt += i;
			}
		}

		return executeCnt;
	}

	/**
	 * '?' 로 되어 있는걸 statement 로 변환
	 * @param sql
	 * @param param
	 * @return
	 */
	private String convertStatement(String sql, Object[] param) {
		String retVal = sql;
		for(Object item : param) {
			String value = item == null ? "" : item.toString();
			String bracket = item instanceof Number ? "" : "'";

			retVal = StringUtils.replaceOnce(retVal, "?", String.format("%s%s%s", bracket, value, bracket));
		}
		return retVal;
	}


} // :)--
