package mobile.factory.db.dao;

import mobile.factory.db.handlers.MofacColumnMapRowMapper;
import mobile.factory.db.vendor.DBDecryptManager;
import mobile.factory.spring.beans.BeanResultProcedure;
import mobile.factory.util.CollectionUtil;
import mobile.factory.util.DBUtil;
import mobile.factory.util.StringUtil;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.jdbc.core.support.JdbcDaoSupport;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 이클래스는 DB에 쿼리를 수행하는 최상위 클래스
 *
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 12
 */

@Component
public class JdbcEntityTable extends JdbcDaoSupport implements EntityDao {
    private final Log logger = LogFactory.getLog(JdbcEntityTable.class);

    private String dbVendor;

    private final String WITH_UR = " \n WITH UR ";
    private final String SQL_KEY = "sql";
    private final String SQL_PARAM = "params";

    @Autowired(required = false)
    @Qualifier(value = "dbDecryptManager")
    private DBDecryptManager dbDecryptManager;

    /**
     * DB vendor 셋팅
     *
     * @param dbVendor ORACLE, MYSQL, MSSQL, DB2
     * @see DBTableDao
     */
    public void setDbVendor(String dbVendor) {
        this.dbVendor = dbVendor;
    }

    /**
     * 객체 배열의 내용을 , 로 구분한 String으로 만들어 주는 메소드
     *
     * @param objArray : 구분할 객체 배열
     * @return , 로 구분된 String
     */
    public static String toArrayString(Object[] objArray) {
        if (objArray == null) {
            return "null";
        }

        StringBuffer str = new StringBuffer();
        for (int i = 0; i < objArray.length; i++) {
            str.append(objArray[i]);
            if (i + 1 < objArray.length) {
                str.append(", ");
            }
        }
        return str.toString();
    }

    /**
     * 쿼리생성
     *
     * @param sql    [field]를 참조하는 것을 ? 로 변경할 쿼리
     * @param params field에 대응하는 값저장
     * @return sql : [field]를 ? 로 변환한 쿼리 params : param
     */
    private Map<String, Object> makeQuery(String sql, Map<String, String> params) {
        Map<String, Object> map = new HashMap<String, Object>();

        String[] fields = StringUtils.substringsBetween(sql, "[", "]");
        Object[] paramObj = new Object[fields.length];
        for (int i = 0, n = fields.length; i < n; i++) {
            String key = fields[i];
            sql = StringUtils.replaceOnce(sql, "[" + key + "]", " ? ");
            paramObj[i] = params.get(key);
        }

        map.put(SQL_KEY, sql);
        map.put(SQL_PARAM, paramObj);
        return map;
    }

    @Override
    public int runBatchQuery(String sql, List<Map<String, String>> paramList) throws DataAccessException {
        String[] batchQuery = new String[paramList.size()];
        String[] fields = StringUtils.substringsBetween(sql, "[", "]");
        String runSql = "";

        int idx = 0;
        for (Map<String, String> map : paramList) {
            Set<String> set = map.keySet();
            runSql = new String(sql);

            for (String fieldKey : fields) {
                if (set.contains(fieldKey)) {

                    String val = map.get(fieldKey).toString();
                    val = StringUtils.remove(val, "'");

                    val = DBUtil.toDBChar(val);
                    runSql = StringUtils.replaceOnce(runSql, "[" + fieldKey + "]", val);
                }
            }
            batchQuery[idx++] = runSql;
        }
        return runBatchQuery(batchQuery);
    }

    @Override
    public int runBatchQueryPrepared(String sql, List<Map<String, String>> paramList) throws DataAccessException {
        return runBatchQueryPrepared(sql, paramList, 0);
    }

    @Override
    public int runBatchQueryPrepared(String sql, List<Map<String, String>> paramList, int commitSize) throws DataAccessException {
        String[] fields = StringUtils.substringsBetween(sql, "[", "]");
        String runSql = sql;

        for (String item : fields) {
            runSql = StringUtils.replaceOnce(runSql, "[" + item + "]", " ? ");
        }

        List<Object[]> objList = new ArrayList<>();
        for (Map<String, String> item : paramList) {
            List<Object> itemList = new ArrayList<>();
            for (String row : fields) {
                itemList.add(item.get(row));
            }
            objList.add(itemList.toArray(new Object[]{}));
        }

        int result = 0;
        for (Object[] item : objList) {
            result += runQuery(runSql, item);
            if(commitSize > 0 && result % commitSize == 0) {
                runQuery("commit");
            }
        }

        if(commitSize > 0) {
            runQuery("commit");
        }

        return result;
    }

    @Override
    public int runBatchQuery(String[] sql) throws DataAccessException {
        if (sql == null || sql.length == 0) {
            return -1;
        }

        if (logger.isDebugEnabled()) {
            logger.debug(sql[0]);
        }

        if (sql.length == 1) {
            return getJdbcTemplate().update(sql[0], new Object[]{});
        } else {
            int[] resultCnt = getJdbcTemplate().batchUpdate(sql);
            return resultCnt.length;
        }

    }

    @Override
    public int runQuery(PreparedWhereMaker pwm) throws DataAccessException {
        return runQuery(pwm, false);
    }

    @Override
    public int runQuery(PreparedWhereMaker pwm, boolean commit) throws DataAccessException {
        int retInt = runQuery(pwm.toString(), pwm.toParamObj());
        if(commit) {
            runQuery("commit");
        }

        return retInt;
    }

    @Override
    public int runQuery(String sql) throws DataAccessException {
        return runQuery(sql, new Object[]{});
    }

    @Override
    public int runQuery(String sql, Map<String, String> params) throws DataAccessException {
        Map<String, Object> map = makeQuery(sql, params);

        return runQuery(map.get(SQL_KEY).toString(), (Object[]) map.get(SQL_PARAM));
    }

    @Override
    public int runQuery(String sql, Object[] params) throws DataAccessException {
        return getJdbcTemplate().update(sql, params);
    }

    @Override
    public List<Map<String, Object>> select(PreparedWhereMaker pwm) throws DataAccessException {
        return select(pwm.toString(), pwm.toParamObj());
    }

    @Override
    public List<String> selectKeySet(PreparedWhereMaker pwm) throws DataAccessException {
        return selectKeySet(pwm.toString(), pwm.toParamObj());
    }

    @Override
    public List<Map<String, Object>> select(String sql) throws DataAccessException {
        return select(sql, new Object[]{});
    }

    @Override
    public List<Map<String, Object>> select(String sql, Map<String, String> params) throws DataAccessException {
        Map<String, Object> map = makeQuery(sql, params);

        return select(map.get(SQL_KEY).toString(), (Object[]) map.get(SQL_PARAM));
    }

    @Override
    public List<Map<String, Object>> select(String sql, Object[] params) throws DataAccessException {
        MofacColumnMapRowMapper rowMapper = new MofacColumnMapRowMapper();
        if (dbDecryptManager != null) {
            rowMapper.setDbDecryptManager(dbDecryptManager);
        }

        sql = appendPostFix(sql);

        long start = System.currentTimeMillis();

        List<Map<String, Object>> resultList = (List) getJdbcTemplate().query(sql, params, rowMapper);

        long end = System.currentTimeMillis();


        if (end - start > (1000 * 3)) {  // 0.5초에서 3초로 수정함
            logger.info("bad sql >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> select time = " + (end - start));
            logger.info("sql : " + "\n" + sql.toString() + "\n");
            String paramStr = "";

            for (Object obj : params) {
                paramStr += obj.toString() + ", ";
            }

            if (paramStr.length() >= 2) {
                paramStr = paramStr.substring(0, paramStr.length() - 2);
            }

            logger.info("param info : " + paramStr + "\n");
            logger.info(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        }

        if (logger.isDebugEnabled()) {
            String paramStr = "";

            for (Object obj : params) {
                paramStr += obj.toString() + ", ";
            }

            if (paramStr.length() >= 2) {
                paramStr = paramStr.substring(0, paramStr.length() - 2);
            }
            logger.debug("########## param info : " + paramStr);

            if (logger.isDebugEnabled() && resultList != null) {
                logger.debug("########## resultList.size() = " + resultList.size());
                if (resultList.size() > 0) {

                    Map<String, Object> first = resultList.get(0);
                    StringBuilder sb = new StringBuilder();
                    first.keySet().forEach(item -> {
                        Object val = first.get(item);
                        sb.append(String.format("%s=%s | ", item, val == null ? "" : StringUtils.substring(val.toString(), 0, 500)));
                    });
                    logger.debug("########## resultList.get(0) = " + sb.toString());
                }
            }

            if (end - start > 500) {
                logger.debug(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> select time = " + (end - start));
            } else {
                logger.debug("########## select time = " + (end - start));
            }
        }

        return resultList;
    }

    private List<String> selectKeySet(String sql, Object[] params) throws DataAccessException {
        sql = appendPostFix(sql);

        long start = System.currentTimeMillis();

        List<String> resultList = getJdbcTemplate().queryForList(sql, params, String.class);

        long end = System.currentTimeMillis();

        if (logger.isDebugEnabled()) {
            if (resultList != null) {
                logger.debug("########## resultList.size() = " + resultList.size());
                if (resultList.size() > 0) {
                    logger.debug("########## resultList.get(0) = " + resultList.get(0));
                }
            }

            if (end - start > 500) {
                logger.debug(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> select time = " + (end - start));
            } else {
                logger.debug("########## select time = " + (end - start));
            }
        }

        return resultList;
    }

    @Override
    public Object selectAValue(PreparedWhereMaker pwm) throws DataAccessException {
        return selectAValue(pwm.toString(), pwm.toParamObj());
    }

    @Override
    public Object selectAValue(String sql) throws DataAccessException {
        return selectAValue(sql, null);
    }

    @Override
    public Object selectAValue(String sql, Object[] params) throws DataAccessException {
        Object obj = getJdbcTemplate().queryForObject(sql, params, new SingleColumnRowMapper());
        return obj;
    }

    @Override
    public int selectCount(String sql) throws DataAccessException {
        sql = "SELECT count(0) FROM ( \n" + DBUtil.processCountQuery(sql) + "\n ) countQuery ";
        sql = appendPostFix(sql);

        Object obj = selectAValue(sql);
        return Integer.parseInt(obj.toString());
    }

    @Override
    public int selectCount(String sql, Object[] params) throws DataAccessException {
        sql = "SELECT count(0) as cnt FROM ( \n" + DBUtil.processCountQuery(sql) + "\n ) ttt ";

        List<Map<String, Object>> list = select(sql, params);
        int cnt = Integer.parseInt(((Map<String, Object>) list.get(0)).get("cnt").toString());

        return cnt;
    }

    @Override
    public int selectCount(PreparedWhereMaker pwm) throws DataAccessException {
        return selectCount(pwm.toString(), pwm.toParamObj());
    }

    @Override
    public Map<String, Object> selectFirst(PreparedWhereMaker pwm) throws DataAccessException {
        return selectFirst(pwm.toString(), pwm.toParamObj());
    }

    @Override
    public Map<String, Object> selectFirst(String sql) throws DataAccessException {
        return selectFirst(sql, new Object[]{});
    }

    @Override
    public Map<String, Object> selectFirst(String sql, Map<String, String> params) throws DataAccessException {
        Map<String, Object> map = null;
        List<Map<String, Object>> list = select(sql, params);
        if (list != null && list.size() > 0) {
            map = list.get(0);
        }

        return map;
    }

    @Override
    public Map<String, Object> selectFirst(String sql, Object[] params) throws DataAccessException {
        List<Map<String, Object>> list = select(sql, params);

        Map<String, Object> map = null;
        if (list != null && list.size() > 0) {
            map = list.get(0);
        }
        return map;
    }

    public List<Map<String, Object>> selectList(ListNavigation listNavi, PreparedWhereMaker pwm) throws DataAccessException {
        if (listNavi.getIsUse() == true) {
            String sql = pwm.toString();
            Object[] params = pwm.toParamObj();

            listNavi.setDB_KIND(this.dbVendor);
            String listQuery = listNavi.getListSeqQuery(sql);

            List<Map<String, Object>> listSeq = this.select(listQuery, params);

            long limit = 0;
            if (listSeq.size() <= 0) {
                limit = 0;
            } else {
                limit = Long.parseLong(listSeq.get(0).get("rownum").toString());
            }

            return select(listNavi.getListQuery(sql, limit), params);
        } else {
            return select(pwm);
        }

    }

    /**
     * seq 정보가 없는 데이터 더보기
     * @param listNavi
     * @param pwm
     * @return
     * @throws DataAccessException
     */
    private List<Map<String, Object>> selectListNoKeySet(ListNavigation listNavi, PreparedWhereMaker pwm) throws DataAccessException {
        if (listNavi.getIsUse() == true) {
            String sql = pwm.toString();
            Object[] params = pwm.toParamObj();

            //max page return;
            listNavi.setMaxPage(selectCount(sql, params));

            return select(listNavi.getListQuery(sql, listNavi.getNextPage()), params);

        } else {
            return select(pwm);
        }

    }

    @Override
    public List<Map<String, Object>> selectPageList(PageNavigation pageNavi, PreparedWhereMaker pwm) throws DataAccessException {
        return selectPageList(pageNavi, pwm.toString(), pwm.toParamObj());
    }

    @Override
    public List<Map<String, Object>> selectPageList(PageNavigation pageNavi, String sql) throws DataAccessException {
        return selectPageList(pageNavi, sql, new Object[]{});
    }

    @Override
    public List<Map<String, Object>> selectPageList(PageNavigation pageNavi, String sql, Map<String, String> params) throws DataAccessException {
        Map<String, Object> map = makeQuery(sql, params);

        return selectPageList(pageNavi, map.get(SQL_KEY).toString(), (Object[]) map.get(SQL_PARAM));
    }

    @Override
    public List<Map<String, Object>> selectPageList(PageNavigation pageNavi, String sql, Object[] params) throws DataAccessException {
        if (pageNavi == null) {
            return select(sql, params);
        }

        PreparedWhereMaker totalPwm = pageNavi.getTotalPwm();
        if (totalPwm != null) {
            int totalCnt = StringUtil.toNumber(selectAValue(totalPwm));
            pageNavi.setTotalElementCount(totalCnt);
        } else {
            pageNavi.setTotalElementCount(selectCount(sql, params));
        }

        pageNavi.setTotalElementCount(selectCount(sql, params));

        if (pageNavi.getTotalElementCount() == 0) {
            return new ArrayList<>();
        }

        List<Map<String, Object>> list = select(pageNavi.getListQuery(sql), params);
        pageNavi.setCurListCount(list.size());

        return list;
    }

    @Override
    public List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, PreparedWhereMaker pwm) throws DataAccessException {
        return selectPageListMore(pageNavi, pwm.toString(), pwm.toParamObj());
    }

    @Override
    public List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, String sql) throws DataAccessException {
        return selectPageListMore(pageNavi, sql, new Object[]{});
    }

    @Override
    public List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, String sql, Map<String, String> params) throws DataAccessException {
        Map<String, Object> map = makeQuery(sql, params);

        return selectPageListMore(pageNavi, map.get(SQL_KEY).toString(), (Object[]) map.get(SQL_PARAM));
    }

    @Override
    public List<Map<String, Object>> selectPageListMore(PageNavigation pageNavi, String sql, Object[] params) throws DataAccessException {
        if (pageNavi == null) {
            return select(sql, params);
        }

        PreparedWhereMaker totalPwm = pageNavi.getTotalPwm();
        if (totalPwm != null) {
            int totalCnt = StringUtil.toNumber(selectAValue(totalPwm));
            pageNavi.setTotalElementCount(totalCnt);
        } else {
            pageNavi.setTotalElementCount(selectCount(sql, params));
        }

        if (pageNavi.getTotalElementCount() == 0) {
            return new ArrayList<>();
        }

        pageNavi.setMoreMode(true);
        // 마지막 리스트에 하나더 가져와서 기본사이즈 보다 클경우 more 를 셋팅한다.
        List<Map<String, Object>> list = select(pageNavi.getListQuery(sql), params);

        int maxListCount = pageNavi.getMaxListCount();
        if (list != null && list.size() > maxListCount) {
            pageNavi.setHasNext(true);
            list = list.subList(0, maxListCount);
        } else {
            pageNavi.setHasNext(false);
        }

        return list;
    }

    /**
     * 쿼리 실행시 공통으로 뒤에 붙일것들 정의
     *
     * @param sql
     */
    private String appendPostFix(String sql) {
        if (DBTableDao.DB_DB2.equals(this.dbVendor)) {
            sql += WITH_UR;
        }

        return sql;
    }

    @Override
    public void excute(String sql) throws DataAccessException {
        if (logger.isDebugEnabled()) {
            logger.debug(sql);
        }
        getJdbcTemplate().execute(sql);
    }

    @Override
    public void excute(String[] sql) throws DataAccessException {
        for (String item : sql) {
            excute(item);
        }
    }

    @Override
    public Map<String, Object> executeProcedure(String procedureName, Map<String, ?> param) throws DataAccessException {
        return executeProcedure(procedureName, param, null);
    }

    @Override
    public Map<String, Object> executeProcedure(String procedureName, Map<String, ?> param, SqlParameter[] sqlParameters) throws DataAccessException {
        procedureName = procedureName.toUpperCase();
        param = CollectionUtil.convertUpperMapKey(param);

        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(getJdbcTemplate()).withProcedureName(procedureName);

        Map<String, Object> resultMap = null;

        // 프로세스 Meta 컬럼 정보를 자동으로 가져오면, 실행시점에서 두번의 성능저하가 오므로
        // Meta 정보를 지정해서 사용하는것을 권고함.
        if (sqlParameters != null) {
            jdbcCall.withoutProcedureColumnMetaDataAccess().declareParameters(sqlParameters);

            for (SqlParameter item : sqlParameters) {
                if (item instanceof SqlOutParameter) {
                    SqlOutParameter out = (SqlOutParameter) item;
                    String outName = out.getName();
                    if (param.containsKey(outName) == false) {
                        param.put(outName, null);
                    }
                }
            }
        } else {
            logger.warn("!!! You must ProcedureColumnMetaData Define !!!");
        }

        SqlParameterSource in = new MapSqlParameterSource(param);
        resultMap = jdbcCall.execute(in);

        // key가 대문자로 반환되는걸 소문자로 변환
        Map<String, Object> reustLowerMap = CollectionUtil.convertLowerMapKey(resultMap);

        String paramResult = String.format("procedureName => %s, param => %s, result => %s", procedureName, param, reustLowerMap);
        if (logger.isDebugEnabled()) {
            logger.debug(paramResult);
        } else {
            logger.info(paramResult);
        }

        return reustLowerMap;
    }

    @Override
    public BeanResultProcedure executeProcedureBean(String procedureName, Map<String, ?> param) throws DataAccessException {
        return executeProcedureBean(procedureName, param, null);
    }

    @Override
    public BeanResultProcedure executeProcedureBean(String procedureName, Map<String, ?> param, SqlParameter[] sqlParameters) throws DataAccessException {
        Map<String, Object> map = executeProcedure(procedureName, param, sqlParameters);

        BeanResultProcedure procedure = new BeanResultProcedure();
        procedure.setResultCode(map.containsKey("p_result_code") && map.get("p_result_code") != null ? map.get("p_result_code").toString() : "");
        procedure.setResultMsg(map.containsKey("p_result_msg") && map.get("p_result_msg") != null ? map.get("p_result_msg").toString() : "");
        procedure.setResultValue(map.containsKey("p_result_value") && map.get("p_result_value") != null ? map.get("p_result_value").toString() : "");

        return procedure;
    }

    @Override
    public BeanResultProcedure executeProcedureBean(BeanSpcObject bean) throws DataAccessException {
        BeanResultProcedure result = null;
        try {
            result = executeProcedureBean(bean.getProcedureName(), bean.getParamMap(), bean.getSqlParameter());
        } catch (Exception e) {
            logger.error(e);
        }

        return result;
    }
}//:)--
