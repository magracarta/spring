package mobile.factory.db.vendor;

import org.springframework.dao.DataAccessException;

import mobile.factory.db.dao.BeanObject;
import mobile.factory.db.dao.JdbcDBTable;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 13
 */
public class SqliteTable extends JdbcDBTable {
    protected void setDbKind() {
        tableInfo.setDbKind(DB_SQLITE);
    }

	@Override
	public long insertForLongKey(BeanObject bean) throws DataAccessException {
		// TODO Auto-generated method stub
		return 0;
	}
}
// :)--
