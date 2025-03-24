package mobile.factory.db.vendor;

import org.springframework.dao.DataAccessException;

import mobile.factory.db.dao.BeanObject;
import mobile.factory.db.dao.JdbcDBTable;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 13
 */
public class MsSQLTable extends JdbcDBTable {

    /**
     * MS-SQL date세팅
     */
    public String getParamString(BeanObject bean, String szFieldName) {
        return "?";
    }

    /**
     * PK 시퀀스는 세팅하지 않고 자동증가 값이고 인서트시 인서트된 시퀀스를 반환한다. 시퀀스가 없다면 0을 반환한다
     */
	public long insert(BeanObject bean) throws DataAccessException {
		long insertId = super.insert(bean);

		String sql = "SELECT @@IDENTITY AS 'IDENTITY'";
		
		return insertId;
//		return getJdbcTemplate().queryForObject(sql, Long.class);
	}

    @Override
    public String getCountLimitString() {
        return " AND rownum <= ";
    }

    protected void setDbKind() {
        tableInfo.setDbKind(DB_MSSQL);
    }

	@Override
	public long insertForLongKey(BeanObject bean) throws DataAccessException {
		// TODO Auto-generated method stub
		return 0;
	}
}
// :)--
