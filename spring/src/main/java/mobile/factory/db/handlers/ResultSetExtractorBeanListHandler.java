package mobile.factory.db.handlers;

import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.commons.dbutils.BasicRowProcessor;
import org.apache.commons.dbutils.RowProcessor;
import org.apache.commons.dbutils.handlers.BeanListHandler;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;

import mobile.factory.db.dao.BeanObject;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 13
 */
public class ResultSetExtractorBeanListHandler implements ResultSetExtractor {
    BeanObject tableInfo;

    public ResultSetExtractorBeanListHandler(BeanObject tableInfo) {
        super();
        this.tableInfo = tableInfo;
    }

    public Object extractData(ResultSet rs) throws SQLException, DataAccessException {
        RowProcessor rowProcessor = new BasicRowProcessor(new MofacBeanProcessor());
        BeanListHandler handler = new BeanListHandler(tableInfo.getClass(), rowProcessor);

        return handler.handle(rs);
    }

}
