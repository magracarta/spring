package mobile.factory.db.handlers;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

import org.springframework.jdbc.core.BatchPreparedStatementSetter;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 13
 */
public class MofacBatchPreparedStatementSetter implements BatchPreparedStatementSetter {

    private List<Object[]> paramList = null;

    public MofacBatchPreparedStatementSetter(List<Object[]> paramList) {
        super();
        this.paramList = paramList;
    }

    public int getBatchSize() {
        return paramList.size();
    }

    public void setValues(PreparedStatement pstmt, int idx) throws SQLException {
        Object[] row = paramList.get(idx);

        for (int i = 0, n = row.length; i < n; i++) {
            int psIdx = i + 1;
            Object item = row[i];
            if (item instanceof String) {
                pstmt.setString(psIdx, (String) item);
            } else if (item instanceof Integer) {
                pstmt.setInt(psIdx, (Integer) item);
            }

        }
    }
}
// :)--