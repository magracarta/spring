package mobile.factory.db.dao;

import org.springframework.dao.DataAccessException;

import java.util.List;

/**
 * @author JeongY.Eom
 * @date 2014. 05. 07
 * @since 2007.09.12
 */

public interface DBTableDao {

    String DB_ORACLE = "ORACLE";

    String DB_MYSQL = "MYSQL";

    String DB_MSSQL = "MSSQL";

    String DB_DB2 = "DB2";

    String DB_SQLITE = "SQLITE";

    /**
     *
     */
    String CMD_CREATE = "C";
    String CMD_UPDATE = "U";
    String CMD_DELETE = "D";

    int deleteByPK(BeanObject bean) throws DataAccessException;

    int deleteByWhere(String where) throws DataAccessException;

    /**
     * 삭제
     *
     * @param where  where xxx = ?
     * @param params ? 객체
     * @return
     * @throws DataAccessException
     */
    int deleteByWhere(String where, Object... params) throws DataAccessException;

    String getSeqNextVal() throws DataAccessException;

    /**
     * bean의 내용을 가지고 insert문을 만들고 insert를 수행한다.
     *
     * @param bean
     * @return 결과는 insert한 행의 id 값 (PK가 하나이고 emumerable할 때만)을 return하게 되어 있으나
     * default로 그냥 -1 (insert한 id값 모름)을 return한다. 이걸 정확한 값으로 반환 하려면 이
     * 메소드를 override해서 각 DB에 맞게 처리를 해줘야 한다.
     */
    long insert(BeanObject bean) throws DataAccessException;

    /**
     * 입력하기 전에 필요한 데이터를 체크후 셋팅함
     *
     * @param bean
     * @return
     * @throws DataAccessException
     */
    void setDefaultValueBeforeInsert(BeanObject bean) throws DataAccessException;

    /**
     * PK로 된 정보가 존재하면 PK로 갱신, 아니면 수정
     *
     * @param bean
     * @return insert, updateByPk 결과와 같음
     * @throws DataAccessException
     */
    long insertIfExistsUpdatebypk(BeanObject bean) throws DataAccessException;

    /**
     * 리스트로 insert(내부적으로 insert호출)
     *
     * @param list 요소는 모두 같은 정보를 셋팅하고 있어야 함.(각 행마다 셋팅된 갯수가 같음)
     * @return 입력된 숫자
     * @throws DataAccessException
     */
    int insert(List<? extends BeanObject> list) throws DataAccessException;

    long insertForLongKey(BeanObject bean) throws DataAccessException;

    List<BeanObject> select(String sql, Object[] params) throws DataAccessException;

    List<BeanObject> selectAll() throws DataAccessException;

    Object selectAValue(String sql) throws DataAccessException;

    Object selectAValue(String sql, BeanObject whereBean) throws DataAccessException;

    BeanObject selectByPK(BeanObject bean) throws DataAccessException;

    List<? extends BeanObject> selectBySetValue(BeanObject bean) throws DataAccessException;

    List<BeanObject> selectBySetValue(BeanObject bean, int count) throws DataAccessException;

    List<BeanObject> selectByWhere(String where) throws DataAccessException;

    List<BeanObject> selectByWhere(String where, int count) throws DataAccessException;

    int selectCount(String sql) throws DataAccessException;

    int selectCountByWhere(String where) throws DataAccessException;

    boolean selectExists(BeanObject bean) throws DataAccessException;

    BeanObject selectFirst(BeanObject bean) throws DataAccessException;

    /**
     * 지정된 PK조건에 의해서 한행만 update하는 메소드 이 메소드를 사용하기 전에 setter에 의해 모든 PK 컬럼은
     * setting되어 있어야 하고, PK이외에 setter로 지정한 컬럼은 update 항목으로 본다.
     */
    int updateByPK(BeanObject bean) throws DataAccessException;

    /**
     * PK로 수정
     *
     * @param list
     * @return
     * @throws DataAccessException
     */
    int updateByPK(List<? extends BeanObject> list) throws DataAccessException;

    int updateByWhere(BeanObject bean, BeanObject whereBean) throws DataAccessException;

    int updateByWhere(BeanObject bean, String where) throws DataAccessException;

    /**
     * <pre>
     * Bean CMD에 정의한 메소드 실행
     * cmd(C) : insert : bean.insert(bean)
     * cmd(U) : update : bean.updateByPk(bean)
     * cmd(D) : delete : bean.deleteByPk(bean)
     * </pre>
     *
     * @param list
     * @return 정상 처리된 수
     * @throws DataAccessException
     */
    long processBeanCmd(List<? extends BeanObject> list) throws DataAccessException;

    /**
     * <pre>
     * Bean CMD에 정의한 메소드 실행
     * cmd(C) : insert : bean.insert(bean)
     * cmd(U) : update : bean.updateByPk(bean)
     * cmd(D) : delete : bean.deleteByPk(bean)
     * </pre>
     *
     * @param bean
     * @return insert시 자동증가 PK를 주거나, update,delete에는 업데이트된 수
     * @throws DataAccessException
     */
    long processBeanCmd(BeanObject bean) throws DataAccessException;

    /**
     * <pre>
     *  Bean CMD에 정의한 메소드 실행,
     *  단. 입력할 값들이 모두 셋팅되어 있어야 함.
     *  insert 할때 자동증가 시퀀스 값도 셋팅되어 있어야 함.
     *  cmd(C) : insert : bean.insert(bean)
     *  cmd(U) : update : bean.updateByPk(bean)
     *  cmd(D) : delete : bean.deleteByPk(bean)
     * </pre>
     *
     * @param list
     * @return
     * @throws DataAccessException
     */
    long processBeanBulkCmd(List<? extends BeanObject> list) throws DataAccessException;
}