package mobile.factory.db.vendor;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.dao.DataAccessException;

import mobile.factory.db.dao.BeanObject;
import mobile.factory.db.dao.JdbcDBTable;
import mobile.factory.exception.FrameException;
import mobile.factory.util.BeanUtil;
import mobile.factory.util.DBUtil;
import mobile.factory.util.StringUtil;

/**
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 13
 */
public class OracleTable extends JdbcDBTable {
    /**
     * PK가 1개로만 되어 있고 세팅되어 있지 않고 자동증가 할수 있다면.. Sequence로부터 값을 가져와서 자동으로 세팅한후
     * insert 동작을 수행한다. inesrt가 정상적으로 끝나면 (즉 Exception이 나지 않게 되면) 방금전 insert된
     * id(PK값)을 반환한다.
     */
	public long insert(BeanObject bean) {
		setDefaultValueBeforeInsert(bean);

		long insertId = super.insert(bean); // default로 -1을 return한다.

		String pkName = tableInfo.getThePKName();
		String pkVal = "";
		if (pkName != null) {
			try {
				pkVal = BeanUtils.getProperty(bean, pkName);
			} catch (Exception e) {
				logger.error("File to get property " + pkName + " value =" + pkVal, e);
				throw new FrameException(e.getMessage());
			}
		}

		return "".equals(pkVal) == false ? StringUtil.toNumberLong(pkVal) : insertId;
	}
    
    @Override
    public void setDefaultValueBeforeInsert(BeanObject bean) throws DataAccessException {
        String val = null;
        String pkName = tableInfo.getThePKName();

        if (pkName != null) {
            String pkVal = "";
            try {
                pkVal = BeanUtils.getProperty(bean, pkName);
            } catch (Exception e) {
                logger.error("File to get property " + pkName + " value =" + pkVal, e);
                throw new FrameException(e.getMessage());
            }

            if (pkName != null && (!bean.isSetField(pkName) || "0".equals(pkVal)) && tableInfo.isAutoIncrementable()) {
                val = getSeqNextVal();
                try {
                    BeanUtils.setProperty(bean, pkName, val);
                } catch (Exception e) {
                    logger.error("File to set property " + pkName + " value =" + val, e);
                    throw new FrameException(e.getMessage());
                }
            }
        } else  {
        	
        	for(String seqName : tableInfo.getPrimaryKeyList()) {
        		if(seqName.endsWith("seq_no")) {
        			String seqVal = BeanUtil.getProperty(bean, seqName);
        			
        			if("0".equals(seqVal)) {
                		String nextSeqNo = getSequenceSeqNoNextVal(bean, seqName);
                		BeanUtil.setProperty(bean, seqName, nextSeqNo);
                	}
        			break;
        		}
        	}
        }
    }

    /**
     * Oracle에서는 date값을 String으로 바로 insert가 안되기 때문에 TO_DATE 함수를 쓰도록 함.
     */
    public String getParamString(BeanObject bean, String szFieldName) {
        String out;
        String fieldName = bean.getDBColumnType(szFieldName);
        if (fieldName.equals("DATE") || fieldName.equals("DATETIME")) {
            // 날짜일 때는 세팅되어 있는 값의 길이에 따라 다르게 String을 만듦.
            String value = "";
            try {
                value = BeanUtils.getSimpleProperty(bean, szFieldName);
            } catch (Exception e) {
                logger.error("", e);
            }

            if (value.length() > 10) {
                out = DBUtil.toDateTime("?");
            } else {
                out = DBUtil.toOnlyDate("?");
            }
        } else {
            out = " ? ";
        }
        return out;
    }

    protected void setDbKind() {
        tableInfo.setDbKind(DB_ORACLE);
    }

	@Override
	public long insertForLongKey(BeanObject bean) throws DataAccessException {
		// TODO Auto-generated method stub
		return 0;
	}
}
// :)--
