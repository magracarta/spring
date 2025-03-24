package mobile.factory.db.dao;

import java.util.*;

import mobile.factory.util.CollectionUtil;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import mobile.factory.RequestDataSet;
import mobile.factory.db.vendor.DBDecryptManager;
import mobile.factory.util.DBUtil;
import mobile.factory.util.DateUtil;
import mobile.factory.util.StringUtil;

public class PreparedWhereMaker {
	private BeanObject bean;
	private StringBuilder where = new StringBuilder();
	private List<Object> paramObj = new ArrayList<Object>();
	private List<Object> inParamObj = new ArrayList<Object>();

	/**
	 * IN 쿼리생성시 최대 Param 갯수
	 */
	public static final int IN_SQL_LIMIT = 1000;

	private String DATE_DIV = DateUtil.DATE_DIV;
	
	@Autowired(required = false)
	@Qualifier(value = "dbDecryptManager")
	private DBDecryptManager dbDecryptManager;

	/**
	 * whereAppend 생성 기본 where 1=1 붙임
	 * @param bean
	 */
	public PreparedWhereMaker(BeanObject bean) {
		init(bean, true);
	}
	
	/**
	 * 
	 * @param bean
	 * @param whereAppend where 1=1 붙임여부
	 */
	public PreparedWhereMaker(BeanObject bean, boolean whereAppend) {
		init(bean, whereAppend);
	}

	private void init(BeanObject bean, boolean whereAppend) {
		this.bean = bean;

		if (whereAppend) {
			where.append(" WHERE 1 = 1 ");
		}
	}

	String getDBColumnType(String colName) {
		return bean.getDBColumnType(colName);
	}

	int getDBColumnSize(String colName) {
		return bean.getDBColumnSize(colName);
	}

	/**
	 * DB컬럼의 타입별로 value값을 변환해주는 메소드
	 * 
	 * @param colName
	 * @param colValue
	 * @return
	 */
	private String getDBValue(String colName, String colValue) {
		String colType = getDBColumnType(colName);
		if ("NUMBER".equals(colType) || "INTEGER".equals(colType) || "FLOAT".equals(colType)) {
			return colValue;
		} else if ("DATE".equals(colType) || "DATETIME".equals(colType)) {
			return DBUtil.toDBDate(colValue);
		} else { // CHAR or VARCHAR2
			return DBUtil.toDBChar(colValue);
		}
	}

	/**
	 * where and 조건 추가 기본 메소드. 주: colValue가 null이거나 "" 이면 조건을 추가하지 않는다.
	 * 
	 * @param COMPARE_OP
	 *            비교 연산자
	 * @param colName
	 *            컬럼 이름
	 * @param colValue
	 *            비교 값
	 * @return
	 */
	public String and(String colName, final String COMPARE_OP, String colValue) {
		return append(" AND ", colName, COMPARE_OP, colValue);
	}

	public void and(String compString) {
		append(" AND ");
		appendWithCR(compString);
	}

	/**
	 * where or 조건 추가 기본 메소드. 주: colValue가 null이거나 "" 이면 조건을 추가하지 않는다.
	 * 
	 * @param COMPARE_OP
	 *            비교 연산자
	 * @param colName
	 *            컬럼 이름
	 * @param colValue
	 *            비교 값
	 * @return
	 */
	public String or(String colName, final String COMPARE_OP, String colValue) {
		return append(" OR ", colName, COMPARE_OP, colValue);
	}

	public void or(String compString) {
		append(" OR ");
		appendWithCR(compString);
	}

	/**
	 * 비교문 추가 메소드.
	 * 
	 * @param CAT_OP
	 *            : and , or 등이 옴.
	 * @param colName
	 *            : DB 컬럼 명.
	 * @param COMPARE_OP
	 *            : 비교 연산자 =, <> 등이 옴.
	 * @param colValue
	 *            : 컬럼 값.
	 * @return 실제 비교 문장을 반환.
	 */
	public String append(String CAT_OP, String colName, final String COMPARE_OP, String colValue) {
		if (StringUtils.isBlank(colValue)) {
			return "";
		}

		String condition = "";
		String theValue = colValue;
		if (StringUtils.contains(colValue, "TO_DATE") == false) {
			String compareOP = COMPARE_OP.toUpperCase().trim();
			if (StringUtil.contains(compareOP, new String[] { "IN", "NOT IN" }, true)) {
				// in 의 경우에는 이미 검증된 value들이 들어옴.
				theValue = colValue;
				this.paramObj.addAll(this.inParamObj);
			} else {
				theValue = " ? ";
				this.paramObj.add(colValue);
			}
		} else {
			String dateVal = StringUtils.substringBetween(colValue, "TO_DATE(", ", 'yyyy");
			if (StringUtils.isBlank(dateVal) || "NULL".equals(dateVal)) {
				return "";
			}
			theValue = StringUtils.replace(colValue, dateVal, " ? ");
			this.paramObj.add(dateVal);
		}

		condition = CAT_OP + colName + " " + COMPARE_OP + " " + theValue;

		appendWithCR(condition);

		return condition;
	}

	/**
	 * " and colName = colValue " 비교 조건 추가. colValue이 null이거나 "" 이면 조건을 추가하지
	 * 않는다.
	 * 
	 * @param colName
	 * @param colValue
	 * @return
	 */
	public String andEqual(String colName, String colValue) {
		return andEqual(colName, colValue, false);
	}

	/**
	 * " and colName = colValue " 비교 조건 추가.
	 * 
	 * @param colName
	 * @param colValue
	 *            값이 필수가 아닐때 [EMPTY]를 추가한다.
	 * @param isEssential
	 *            필수 여부
	 * @return
	 */
	public String andEqual(String colName, String colValue, boolean isEssential) {
		if (isEssential) {
			if (StringUtils.isBlank(colValue)) {
				colValue = ":[EMPTY]";
			}
		}

		return and(colName, " = ", colValue);
	}

	public String andNotEqual(String colName, String colValue, boolean isEssential) {
		if (isEssential) {
			if (StringUtils.isBlank(colValue)) {
				colValue = ":[EMPTY]";
			}
		}

		return and(colName, " <> ", colValue);
	}

	public String andNotEqual(String colName, String colValue) {
		return andNotEqual(colName, colValue, false);
	}

	public void andDateRange(String colName, String fromDate, String toDate) {
		appendDateRange(" AND ", colName, fromDate, toDate);
	}

	public void orDateRange(String colName, String fromDate, String toDate) {
		appendDateRange(" OR ", colName, fromDate, toDate);
	}

	public void appendDateRange(String CAT_OP, String colName, String fromDate, String toDate) {
		boolean isDateType = false;

		String orgColName = colName.indexOf(DATE_DIV) > 0 ? StringUtils.substringAfter(colName, DATE_DIV) : colName;
		orgColName = StringUtils.contains(orgColName, ".") ? StringUtils.substringAfter(orgColName, ".") : orgColName;
		String colType = getDBColumnType(orgColName);
		
		if ("DATETIME".equals(colType) || "VARCHAR".equals(colType) || "NVARCHAR".equals(colType) || "VARCHAR2".equals(colType) || "TIMESTAMP".equals(colType)) {
			isDateType = false;
		} else if ("DATE".equals(colType)) {
			isDateType = true;
		} else {
			// throw new FrameException(colName + " 은 DATE타입이 아닙니다!!!");
			isDateType = false;
		}

		// 컬럼명에 _date 포함하고 있으면 날짜형식으로 변환
		if(isDateType == false) {
			if(StringUtils.containsIgnoreCase(colName, "_date")) {
				isDateType = true;
			}
		}

		// 천지양 프로젝트는 ms-sql 이고, 날짜 형식을 14자리로 String 으로 사용하여서 따로 가공
		int orgColSize = 0;
		try {
			orgColSize = getDBColumnSize(orgColName);
		} catch (Exception ignore) {
		}

		fromDate = StringUtils.remove(fromDate, DATE_DIV);
		toDate = StringUtils.remove(toDate, DATE_DIV);
		toDate = DateUtil.add(toDate, 1);

		if (isDateType == false && orgColSize == 14) {
			fromDate = StringUtils.isNotBlank(fromDate) ? StringUtils.rightPad(fromDate, 14, "0") : "";
			toDate = StringUtils.isNotBlank(toDate) ? StringUtils.rightPad(toDate, 14, "0") : "";

			append(CAT_OP, colName, " >= ", fromDate);
			append(CAT_OP, colName, " < ", toDate);
		} else {
			if (isDateType && DBTableDao.DB_ORACLE.equals(RequestDataSet.getDbVendor())) {
				append(CAT_OP, colName, " >= ", String.format("TO_DATE(%s, 'yyyymmdd')", fromDate));
				append(CAT_OP, colName, " < ", String.format("TO_DATE(%s, 'yyyymmdd')", toDate));
			} else {
//				append(CAT_OP, colName, " >= ", FormatUtil.date(fromDate, String.format("yyyy%sMM%sdd", DATE_DIV, DATE_DIV)));
//				append(CAT_OP, colName, " < ", FormatUtil.date(toDate, String.format("yyyy%sMM%sdd", DATE_DIV, DATE_DIV)));
				append(CAT_OP, colName, " >= ", fromDate);
				append(CAT_OP, colName, " < ", toDate);
			}
		}
	}

	/**
	 * " and colName like '%colValue%' " 비교 조건 추가. 주의 할 것은 내부부에서 % 가 앞뒤로 자동적으로
	 * 붙으므로, colValue에는 % 없는 변수만 넘긴다. 섬세함 like 검색을 하고 싶다면 아래와 같이 colValue의 값을
	 * check한후 append 메소드를 사용한다. if (StringUtils.isEmpty(colValue) {
	 * append(" and " + colName + " like " + DBUtil.toDBChar("__" + colValue +
	 * "%")); }
	 * 
	 * @param colName
	 * @param colValue
	 * @return
	 */
	public String andLike(String colName, String colValue) {
		return appendLike(" AND ", colName, "%", colValue, "%");
	}

	public String andLikeL(String colName, String colValue) {
		return appendLike(" AND ", colName, "%", colValue, "");
	}

	public String andLikeR(String colName, String colValue) {
		return appendLike(" AND ", colName, "", colValue, "%");
	}

	public String orLike(String colName, String colValue) {
		return appendLike(" OR ", colName, "%", colValue, "%");
	}

	public String orLikeL(String colName, String colValue) {
		return appendLike(" OR ", colName, "%", colValue, "");
	}

	public String orLikeR(String colName, String colValue) {
		return appendLike(" OR ", colName, "", colValue, "%");
	}

	private String appendLike(String CAT_OP, String colName, String PRE_P, String colValue, String POST_P) {
		if (StringUtils.isBlank(colValue)) {
			return "";
		}

		String condition = "";
		String dbVendor = RequestDataSet.getDbVendor();
		if ("%".equals(PRE_P) && "%".equals(POST_P)) {
			if (DBTableDao.DB_MSSQL.equals(dbVendor)) { 
				condition = CAT_OP + " charindex( ? , " + colName + " ) > 0 ";
			} else {
				condition = CAT_OP + " instr( upper( " + colName + " ) , upper( ? ) ) > 0 ";
			}

		} else {
//			if(DBTableDao.DB_MYSQL.equals(dbVendor)) {
				String preLike = StringUtils.isBlank(PRE_P) ? "" : DBUtil.toDBChar(PRE_P) + " , ";
				String postLike = StringUtils.isBlank(POST_P) ? "" : " , " + DBUtil.toDBChar(POST_P);

				condition = CAT_OP + colName + " LIKE concat( " + preLike + " ? " + postLike + " ) ";
//			} else {
//				String preLike = StringUtils.isBlank(PRE_P) ? "" : DBUtil.toDBChar(PRE_P) + " || ";
//				String postLike = StringUtils.isBlank(POST_P) ? "" : " || " + DBUtil.toDBChar(POST_P);
//
//				condition = CAT_OP + colName + " LIKE " + preLike + " ? " + postLike;
//			}
		}

		this.paramObj.add(colValue);

		appendWithCR(condition);
		return condition;
	}

	public String orEqual(String colName, String colValue) {
		return or(colName, " = ", colValue);
	}
	
	private String makeInString(String[] values) {
		String[] uniqueValues = CollectionUtil.unique(values);
		if(ArrayUtils.isEmpty(uniqueValues)) {
			return null;
		}

		// IN param 검증 완료후 쿼리생성
		this.inParamObj.clear();
		this.inParamObj.addAll(Arrays.asList(uniqueValues));

		String[] valArray = new String[uniqueValues.length];
		Arrays.fill(valArray, "?");

		return "(" + StringUtils.join(valArray, ",") + ")";
	}

	/**
	 * " and code in ('11', '14', '17') 등과 같은 in 비교 문을 만듦.
	 * 
	 * @param colName
	 * @param colValues
	 * @return
	 */
	public String andIn(String colName, String[] colValues) {
		if(colValues == null) {
			return "";
		}

		String[] uniqueValues = CollectionUtil.unique(colValues);
		if(uniqueValues.length <= IN_SQL_LIMIT) {
			return and(colName, " IN ", makeInString(uniqueValues));
		} else {
			return makeInAction("AND", colName, " IN ", colValues);
		}
	}

	/**
	 * and not in ('11', '14', '17') 등과 같은 not in 비교 구문 만듦.
	 * 
	 * @param colName
	 * @param colValues
	 * @return
	 */
	public String andNotIn(String colName, String[] colValues) {
		String[] uniqueValues = CollectionUtil.unique(colValues);
		if(uniqueValues.length <= IN_SQL_LIMIT) {
			return and(colName, " NOT IN ", makeInString(uniqueValues));
		} else {
			return makeInAction("AND", colName, " NOT IN ", colValues);
		}
	}

	/**
	 * " or code in ('11', '14', '17') 등과 같은 in 비교 문을 만듦.
	 * 
	 * @param colName
	 * @param colValues
	 * @return
	 */
	public String orIn(String colName, String[] colValues) {
		String[] uniqueValues = CollectionUtil.unique(colValues);
		if(uniqueValues.length <= IN_SQL_LIMIT) {
			return or(colName, " IN ", makeInString(uniqueValues));
		} else {
			return makeInAction("OR", colName, " IN ", colValues);
		}
	}

	/**
	 * " or code not in ('11', '14', '17') 등과 같은 not in 비교 문을 만듦.
	 *
	 * @param colName
	 * @param colValues
	 * @return
	 */
	public String orNotIn(String colName, String[] colValues) {
		String[] uniqueValues = CollectionUtil.unique(colValues);
		if(uniqueValues.length <= IN_SQL_LIMIT) {
			return or(colName, " NOT IN ", makeInString(uniqueValues));
		} else {
			return makeInAction("OR", colName, " NOT IN ", colValues);
		}
	}

	/**
	 * in 쿼리 생성시 Parma이 1000개가 넘을시 추가 가공함
	 * @param andOr AND/OR
	 * @param colName
	 * @param compareOp
	 * @param colValues
	 * @return
	 */
	private String makeInAction(String andOr, String colName, String compareOp, String[] colValues) {
		String[] uniqueValues = CollectionUtil.unique(colValues);
		if(ArrayUtils.isEmpty(uniqueValues)) {
			return null;
		}

		if (uniqueValues.length <= IN_SQL_LIMIT) {
			if("AND".equals(andOr)) {
				return and(colName, compareOp, makeInString(uniqueValues));
			} else if("OR".equals(andOr)) {
				return or(colName, compareOp, makeInString(uniqueValues));
			}
		} else {
			StringBuilder inSql = new StringBuilder();

			// param이 in에 들어가는 최대 갯수보다 많을경우 여러번 나눠서 쿼리생성
			int valueGroupSize = uniqueValues.length / IN_SQL_LIMIT;
			int valueExtSize = uniqueValues.length % IN_SQL_LIMIT;

			int loopSize = valueExtSize > 0 ? valueGroupSize : valueGroupSize - 1;
			int lastSize = valueExtSize > 0 ? valueExtSize : IN_SQL_LIMIT;

			// 최대갯수 만큼 OR로 생성
			for (int i = 0; i < loopSize; i++) {
				String[] valArray = new String[IN_SQL_LIMIT];
				Arrays.fill(valArray, "?");

				String valueSql = "(" + StringUtils.join(valArray, ",") + ")";

				inSql.append(i==0 ? "" : " OR ");
				inSql.append(String.format(" %s %s %s", colName, compareOp, valueSql) + "\n");
			}
			// 마지막 그룹 추가
			String[] valArray = new String[lastSize];
			Arrays.fill(valArray, "?");

			String valueSql = "(" + StringUtils.join(valArray, ",") + ")";
			inSql.append(String.format(" OR %s %s %s", colName, compareOp, valueSql) + "\n");

			String runQuery = String.format(" %s  (\n %s \n) ", andOr, inSql.toString());

			appendWithParam(runQuery, uniqueValues);

			return runQuery;
		}

		return null;
	}

	/**
	 * order by 나 group by 등의 기타 절을 추가할 수 있는 메소드.
	 * 
	 * @param str
	 */
	public PreparedWhereMaker append(String str) {
		where.append(str);
		return this;
	}

	/**
	 * String.format
	 * 
	 * @param str
	 * @param args
	 * @return
	 */
	public PreparedWhereMaker appendFormat(String str, Object... args) {
		where.append(String.format(str, args));
		return this;
	}

	/**
	 * @param str     "?" or ":변수"가 있으면 내부적으로 appendWithParam 로 호출
	 * @param objects
	 */
	public void appendWithCR(String str, Object... objects) {
		if (StringUtils.contains(str, "?") || StringUtils.contains(str, ":")) {
			appendWithParam(str, objects);
		} else {
			where.append(String.format(str, objects));
			where.append("\n");
		}
	}

	public void appendWithCR(String str) {
		where.append(str);
		where.append("\n");
	}

	/**
	 * param 을 추가
	 * 
	 * @param str
	 *            string 에 ? 을 포함
	 * @param objects
	 *            ? 에 대응되는 수 만큼 param 객체
	 */
	public void appendWithParam(String str, Object... objects) {
		// ?는 이슈없지만 :변수 일대 :변수 앞에 공백이 없으면, 제대로 인식 안하는 문제 발생
		String appendStr = StringUtils.replace(str, ":", " :");
		appendWithCR(appendStr);
		for (Object obj : objects) {
			this.paramObj.add(obj);
		}
	}

	/**
	 * WhereMaker에 의해 만들어진 최종 where 쿼리를 반환한다.
	 */
	public String toString() {
		return where.toString();
	}

	public Object[] toParamObj() {
		return paramObj.toArray();
	}

	public Object[] toParamObj(Object[] arrayObj) {
		return ArrayUtils.addAll(toParamObj(), arrayObj);
	}

	/**
	 * 기본 select 쿼리와 where로 만든 쿼리를 반환
	 * 
	 * @param tableDao
	 *            해당 Dao
	 * @return
	 */
	public String toSelectAndSql(DBTableDao tableDao) {
		return ((JdbcDBTable) tableDao).getSelectSQL() + where.toString();
	}

	public void clear() {
		where.setLength(0);
		paramObj.clear();
		inParamObj.clear();
	}

	public String getFirstSelectQuery() {
		String sql = this.toString();

		if (RequestDataSet.getDbVendor().equals(DBTableDao.DB_MYSQL) == true) {
			sql = "SELECT * FROM (" + sql + ") t1 LIMIT 1";
		}

		return sql;
	}

	/**
	 * <pre>
	 * mybitis 스타일로 변수 바인딩
	 * 기본으로 이전에 바인딩 된 것을 지움
	 * </pre>
	 * 
	 * @param paramMap
	 * @return
	 */
	public PreparedWhereMaker convertMybatisStyle(Map<String, String> paramMap) {
		return convertMybatisStyle(paramMap, true);
	}

	/**
	 * <pre>
	 * mybitis 스타일로 변수 처리
	 * ${} : 해당되는 문자가 바로 매핑  select ${userSeq}, ttt => select 1, ttt
	 * #{} : 바인딩 변수로 대체 #{userSeq} => ?
	 * 
	 * 1. andXXX, orXXX 계열 처리
	 *  기존에는 andXXX, orXXX 함수를 사용하던것을 변경하고자하는 것에 주석 
	 *  /* and user_seq = [userSeq] \\/*으로 동일한 효과를 냄
	 * 2. 상수 변환
	 * 	쿼리에 #{field}를 참조하는 것을 ? 로 변경하여 pwm을 가공한다.
	 *  and user_seq = #{userSeq} 
	 * #주의 [field] 로 된 쿼리만 있어야함.. andEquals, andXXX류 함수를 썼으면 param 순서 꼬임..
	 * </pre>
	 * 
	 * @param paramMap
	 *            sql에 #{key}로 들어있는 값
	 * @param clearPwm
	 *            이전에 셋팅한 것을 지울지 여부
	 * 
	 */
	public PreparedWhereMaker convertMybatisStyle(Map<String, String> paramMap, boolean clearPwm) {
		String[] sql = StringUtils.split(this.where.toString(), "\r\n");
		List<String> convertSql = new ArrayList<String>();
		List<Object> params = new ArrayList<Object>();

		// 한줄씩 실행하면서 처리
		for (String row : sql) {
			// 바인딩 변수 추출
			String[] bindingVar = StringUtils.substringsBetween(row, "#{", "}");
			String[] commentVar = StringUtils.substringsBetween(row, "/*", "*/");
			if (bindingVar != null) {
				for (String item : bindingVar) {
					String paramStr = paramMap.get(item);
					boolean processParamStr = StringUtils.isNotBlank(paramStr);

					// 주석 포함 된 행 처리
					if (commentVar != null) {
						String searchTxt = String.format("#{%s}", item);
						
						String prefixTxt = StringUtils.substringBetween(row, "/*", searchTxt);
						// /* /* 가 여러개 있을 경우 대비
						if (StringUtils.contains(prefixTxt, "/*")) {
							prefixTxt = StringUtils.substringAfterLast(prefixTxt, "/*");
						}

						String postfixTxt = StringUtils.substringBetween(row, searchTxt, "*/");
						if (StringUtils.contains(postfixTxt, "*/")) {
							postfixTxt = StringUtils.substringBefore(postfixTxt, "*/");
						}

						String commentStr = String.format("%s%s%s", prefixTxt, searchTxt, postfixTxt);
						int commentIdx = ArrayUtils.indexOf(commentVar, commentStr);
						if (commentIdx > -1) {
							if (processParamStr) {
								String originStr = String.format("/*%s*/", commentStr);
								row = StringUtils.replaceOnce(row, originStr, commentStr);

								// 바인딩 치환
								row = StringUtils.replaceOnce(row, "#{" + item + "}", " ? ");
								params.add(paramMap.get(item));
							}
							commentVar = ArrayUtils.remove(commentVar, commentIdx);
						}
					}
					// 일반 바인딩 변수 처리
					else { // 일반 바인딩 변수 처리
						if (processParamStr == false) {
							throw new RuntimeException("paramMap 에 바인딩될 값이 없습니다.");
						}
						// 바인딩 치환
						row = StringUtils.replaceOnce(row, "#{" + item + "}", " ? ");
						params.add(paramMap.get(item));
					}

				}
			}

			// 일반변수 치환
			String[] fields = StringUtils.substringsBetween(row, "${", "}");
			if (fields != null) {
				for (String item : fields) {
					if (paramMap.containsKey(item)) {
						row = StringUtils.replaceOnce(row, "${" + item + "}", paramMap.get(item));
					}
				}
			}
			convertSql.add(row);
		}

		if (clearPwm) {
			clear();
			appendWithCR("");
		}

		for (String row : convertSql) {
			appendWithCR(row);
		}
		this.paramObj.addAll(params);

		return this;
	}

	// ---------------------------------------
	// static 메소드들
	// ---------------------------------------

	public static String andInt(String colName, String OP, String colValue) {
		if (colValue == null)
			return "";
		return " AND " + colName + " " + OP + " " + colValue;
	}

	public static String andChar(String colName, String OP, String colValue) {
		if (colValue == null)
			return "";
		return " AND " + colName + " " + OP + " '" + colValue + "' ";
	}

	public static String andLikeChar(String colName, String colValue) {
		if (colValue == null)
			return "";
		return " AND " + colName + " LIKE '%" + colValue + "%' ";
	}

	public static String andLikeChar2(String colName, String colValue) {
		if (colValue == null)
			return "";
		return " AND " + colName + " LIKE '" + colValue + "%' ";
	}

	public static String orLikeChar(String colName, String colValue) {
		if (colValue == null)
			return "";
		return " OR " + colName + " LIKE '%" + colValue + "%' ";
	}

	public static String orLikeChar2(String colName, String colValue) {
		if (colValue == null)
			return "";
		return " OR " + colName + " LIKE '" + colValue + "%' ";
	}
	
	/**
	 * in에서 사용할수 있게 '12', '34' 문자를 생성함
	 * 
	 * @param values
	 * @param addBracket 양쪽() 추가여부
	 * @return
	 */
	public static String makeInString(String[] values, boolean addBracket) {
		StringBuilder sb = new StringBuilder();

		for (String item : values) {
			sb.append(String.format("'%s' ,", item));
		}

		String retStr = StringUtils.removeEnd(sb.toString(), ",");

		if (addBracket) {
			retStr = String.format("( %s )", retStr);
		}

		return retStr;
	}
}
