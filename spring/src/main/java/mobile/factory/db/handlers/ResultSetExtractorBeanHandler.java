package mobile.factory.db.handlers;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.commons.dbutils.BasicRowProcessor;
import org.apache.commons.dbutils.RowProcessor;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;

import mobile.factory.db.dao.BeanObject;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 13
 */
public class ResultSetExtractorBeanHandler implements ResultSetExtractor {
    BeanObject tableInfo;

    public ResultSetExtractorBeanHandler(BeanObject tableInfo) {
        super();
        this.tableInfo = tableInfo;
    }

    public Object extractData(ResultSet rs) throws SQLException, DataAccessException {
        RowProcessor rowProcessor = new BasicRowProcessor(new MofacBeanProcessor());
        BeanHandler handler = new BeanHandler(tableInfo.getClass(), rowProcessor);

        return handler.handle(rs);
    }

}
