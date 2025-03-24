package mobile.factory.db.dao;

import java.util.List;
import java.util.Map;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.SqlParameter;

import mobile.factory.spring.beans.BeanResultProcedure;

/**
 * @author JeongY.Eom
 * @date 2014. 05. 07
 * @since 2007.09.12
 */
public interface EntityDao {
	/**
	 * batch 쿼리를 날릴때 쓰는 메소드
	 *
	 * @param sql
	 *            인자는 '[field]'로 중괄호로 감싼다.
	 * @param paramList
	 *            '[field]'의 값이 key로 값이 들어있음.
	 * @throws DataAccessException
	 */
	int runBatchQuery(String sql, List<Map<String, String>> paramList) throws DataAccessException;

	/**
	 * batch 쿼리를 날릴때 쓰는 메소드, 실행인자를 preparedstatement로 변환하여 실행
	 *
	 * @param sql
	 *            인자는 '[field]'로 중괄호로 감싼다.
	 * @param paramList
	 *            '[field]'의 값이 key로 값이 들어있음.
	 * @return
	 * @throws DataAccessException
	 */
	int runBatchQueryPrepared(String sql, List<Map<String, String>> paramList) throws DataAccessException;

	/**
	 * batch 쿼리를 날릴때 쓰는 메소드, 실행인자를 preparedstatement로 변환하여 실행
	 *
	 * @param sql
	 *            인자는 '[field]'로 중괄호로 감싼다.
	 * @param paramList
	 *            '[field]'의 값이 key로 값이 들어있음.
	 * @param commitSize 커밋사이즈
	 * @return
	 * @throws DataAccessException
	 */
	int runBatchQueryPrepared(String sql, List<Map<String, String>> paramList, int commitSize) throws DataAccessException;

	int runBatchQuery(String[] sql) throws DataAccessException;

	int runQuery(PreparedWhereMaker pwm) throws DataAccessException;

	int runQuery(PreparedWhereMaker pwm, boolean commit) throws DataAccessException;

	/**
	 * connect의 excute 와 동일 DDL 생성시 사용(create...)
	 *
	 * @param sql
	 * @return
	 * @throws DataAccessException
	 */
	void excute(String sql) throws DataAccessException;

	/**
	 * connect의 excute 와 동일 DDL 생성시 사용(create...)
	 *
	 * @param sql
	 * @return
	 * @throws DataAccessException
	 */
	void excute(String[] sql) throws DataAccessException;

	/**
	 * select 를 제외한 쿼리(insert, update, delete)를 그냥 날리기 위한 메소드.
	 *
	 * @param sql
	 */
	int runQuery(String sql) throws DataAccessException;

	/**
	 * 쿼리 인자를 [field] 으로 표기하여 실행함
	 *
	 * @param sql
	 *            인자를 [field] 형식으로 들어있음.
	 * @param params
	 *            [field] 의 값이 들어있는 것으로 filed 가 맵의 키로 존재해야함
	 * @throws DataAccessException
	 */
	int runQuery(String sql, Map<String, String> params) throws DataAccessException;

	int runQuery(String sql, Object... params) throws DataAccessException;

	List<Map<String, Object>> select(PreparedWhereMaker pwm) throws DataAccessException;

	List<String> selectKeySet(PreparedWhereMaker pwm) throws DataAccessException;

	/**
	 * 파라메터 안주고 select 쿼리를 날릴 때 쓰는 메소드.
	 *
	 * @param sql
	 * @return
	 */
	List<Map<String, Object>> select(String sql) throws DataAccessException;

	/**
	 * 쿼리 인자를 [field] 으로 표기하여 실행함
	 *
	 * @param sql
	 *            인자를 [field] 형식으로 들어있음.
	 * @param params
	 *            [field] 의 값이 들어있는 것으로 filed 가 맵의 키로 존재해야함
	 * @throws DataAccessException
	 */
	List<Map<String, Object>> select(String sql, Map<String, String> params) throws DataAccessException;

	List<Map<String, Object>> select(String sql, Object[] params) throws DataAccessException;

	Object selectAValue(PreparedWhereMaker pwm) throws DataAccessException;

	Object selectAValue(String sql) throws DataAccessException;

	Object selectAValue(String sql, Object... params) throws DataAccessException;

	int selectCount(String sql) throws DataAccessException;

	int selectCount(String sql, Object[] params) throws DataAccessException;

	int selectCount(PreparedWhereMaker pwm) throws DataAccessException;

	Map<String, Object> selectFirst(PreparedWhereMaker pwm) throws DataAccessException;

	Map<String, Object> selectFirst(String sql) throws DataAccessException;

	Map<String, Object> selectFirst(String sql, Map<String, String> params) throws DataAccessException;

	Map<String, Object> selectFirst(String sql, Object[] params) throws DataAccessException;

	List<Map<String, Object>> selectPageList(PageNavigation pageNavi, PreparedWhereMaker pwm) throws DataAccessException;

	List<Map<String, Object>> selectPageList(PageNavigation pageNavi, String sql) throws DataAccessException;

	List<Map<String, Object>> selectPageList(PageNavigation pageNavi, String sql, Map<String, String> params) throws DataAccessException;

	List<Map<String, Object>> selectPageList(PageNavigation pageNavi, String sql, Object[] params) throws DataAccessException;

	List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, PreparedWhereMaker pwm) throws DataAccessException;

	List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, String sql) throws DataAccessException;

	List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, String sql, Map<String, String> params) throws DataAccessException;

	List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, String sql, Object[] params) throws DataAccessException;

	/**
	 * 프로시저 실행
	 * 
	 * @param procedureName
	 *            프로시저 명(대문자)
	 * @param param
	 *            param 프로시저 IN param
	 * @return out의 result
	 * @throws DataAccessException
	 */
	Map<String, Object> executeProcedure(String procedureName, Map<String, ?> param) throws DataAccessException;

	/**
	 * 프로시저 실행
	 * 
	 * @param procedureName
	 *            프로시저 명
	 * @param param
	 *            param 프로시저 IN param
	 * @param sqlParameters
	 *            mapper
	 * @return out의 result
	 * @throws DataAccessException
	 */
	Map<String, Object> executeProcedure(String procedureName, Map<String, ?> param, SqlParameter[] sqlParameters) throws DataAccessException;

	/**
	 * 프로시저 실행
	 * 
	 * @param procedureName
	 *            프로시저 명
	 * @param param
	 *            param 프로시저 IN param
	 * @param sqlParameters
	 *            mapper
	 * @return out의 resultBean
	 * @throws DataAccessException
	 */
	BeanResultProcedure executeProcedureBean(String procedureName, Map<String, ?> param, SqlParameter[] sqlParameters) throws DataAccessException;

	/**
	 * 프로시저 실행
	 * 
	 * @param procedureName
	 *            프로시저 명
	 * @param param
	 *            param 프로시저 IN param
	 * @return out의 resultBean
	 * @throws DataAccessException
	 */
	BeanResultProcedure executeProcedureBean(String procedureName, Map<String, ?> param) throws DataAccessException;

	/**
	 * 프로시저 실행
	 * @param bean
	 * @return
	 * @throws DataAccessException
	 */
	BeanResultProcedure executeProcedureBean(BeanSpcObject bean) throws DataAccessException;

}// :)--
