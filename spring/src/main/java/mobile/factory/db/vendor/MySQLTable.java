package mobile.factory.db.vendor;

import java.util.Date;

import org.springframework.dao.DataAccessException;

import mobile.factory.db.dao.BeanObject;
import mobile.factory.db.dao.JdbcDBTable;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 13
 */

public class MySQLTable extends JdbcDBTable {
    /**
     * PK가 자동증가(auto incrementable) 할수 있다면 insert를 한 후에 insert된 id(PK값)을 반환한다.
     */
    public long insert(BeanObject bean) throws DataAccessException {
        int insertId = -1;
        super.insert(bean);
        String val = selectAValue("select LAST_INSERT_ID()").toString();
        insertId = Integer.parseInt(val);

        return insertId;
    }
    
    public long insertForLongKey(BeanObject bean) throws DataAccessException {
    	long insertId = -1;
    	super.insert(bean);
    	String val = selectAValue("select LAST_INSERT_ID()").toString();
    	insertId = Long.parseLong(val);
    	
    	return insertId;
    }

    /**
     * MySQL에서는 갯수제한을 지정할 때 limit 을 준다. where 조건의 " and rownum = 1 " 을 MySQL에서는
     * " limit 1 " 과 같이 한다.
     */
    public String getCountLimitString() {
        return " limit ";
    }

    protected void setDbKind() {
        tableInfo.setDbKind(DB_MYSQL);
    }
    
    /**
     * Oracle에서는 date값을 String으로 바로 insert가 안되기 때문에 TO_DATE 함수를 쓰도록 함.
     */
    public String getParamString(BeanObject bean, String szFieldName) {
        String out;
        String fieldName = bean.getDBColumnType(szFieldName);
        if (fieldName.equals("TIMESTAMP")) {
            // 날짜일 때는 세팅되어 있는 값의 길이에 따라 다르게 String을 만듦.
            String value = "";
            
        	if (bean.get(szFieldName) instanceof Date) {
        		out = " TIMESTAMP(?) ";
        	}else {
        		out = " ? ";
        	}
     
        } else {
            out = " ? ";
        }
        return out;
    }    
}
// :)--
