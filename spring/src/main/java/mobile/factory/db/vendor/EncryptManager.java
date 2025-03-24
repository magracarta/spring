package mobile.factory.db.vendor;

import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Component;

import mobile.factory.RequestDataSet;
import mobile.factory.db.dao.DBTableDao;
import mobile.factory.db.vendor.type.EncryptType;

/**
 * DB 암호화 쿼리생성 매니져
 *
 * @author jolith514
 */
@Component(value = "encryptManager")
public class EncryptManager {
    private final String ENCRYPT_KEY = "mofac";
    private final String ENCRYPT_TYPE = "aes";

    private IEncrypter mVenderEncrypter = null;
    private EncryptType mEncryptType;

    /**
     * 생성자
     *
     * @param dbVendor
     */
    public EncryptManager() {
        if (mVenderEncrypter == null) {
            initialize(RequestDataSet.getDbVendor(), ENCRYPT_TYPE.toUpperCase());
        }
    }

    /**
     * 초기화
     *
     * @param dbKind
     */
    private void initialize(String dbKind, String encryptKind) {
        if (StringUtils.equals(dbKind, DBTableDao.DB_MYSQL)) {
            mVenderEncrypter = new EncryptMysql();
        } else if (StringUtils.equals(dbKind, DBTableDao.DB_ORACLE)) {
            mVenderEncrypter = new EncryptOracle();
        } else if (StringUtils.equals(dbKind, DBTableDao.DB_MSSQL)) {
            mVenderEncrypter = new EncryptMsSql();
        }

        if (StringUtils.equals(encryptKind, "AES")) {
            mEncryptType = EncryptType.AES_ENCRYPT;
        } else if (StringUtils.equals(encryptKind, "DES")) {
            mEncryptType = EncryptType.DES_ENCRYPT;
        }
    }

    /**
     * DataSet에 셋팅되어 있는 DB Type별 암호화 함수 쿼리 생성(암호화 타입 Default)
     *
     * @param sql
     * @param paramString
     * @return
     */
    public String getEncryptQuery(String paramString) {
        return getEncryptQuery(paramString, mEncryptType);
    }

    /**
     * DataSet에 셋팅되어 있는 DB Type별 암호화 함수 쿼리 생성(암호화 타입 입력)
     *
     * @param sql
     * @param paramString
     * @param type
     * @return
     */
    public String getEncryptQuery(String paramString, EncryptType type) {
        return mVenderEncrypter.convertEncryptQuery(paramString, type);
    }

    /**
     * 인터페이스
     *
     * @author jolith514
     */
    public interface IEncrypter {
        String convertEncryptQuery(String paramString, EncryptType type);
    }

    /**
     * MySql 전용 암호화 쿼리 클래스
     *
     * @author jolith514
     */
    public class EncryptMysql implements IEncrypter {
        public String convertEncryptQuery(String paramString, EncryptType type) {
            StringBuilder sql = new StringBuilder();
            if (EncryptType.AES_ENCRYPT == type) {
                sql.append("hex(aes_encrypt(");
                sql.append(StringUtils.equals(paramString.replaceAll(" ", ""), "?") ? paramString : "'" + paramString + "'");
                sql.append(", '" + ENCRYPT_KEY + "'))");
            } else if (EncryptType.DES_ENCRYPT == type) {
                sql.append("des_encrypt(");
                sql.append(StringUtils.equals(paramString.replaceAll(" ", ""), "?") ? paramString : "'" + paramString + "'");
                sql.append(", '" + ENCRYPT_KEY + "'))");
            }

            return sql.toString();
        }
    }

    /**
     * Oracle 전용 암호화 쿼리 클래스
     *
     * @author jolith514
     */
    public class EncryptOracle implements IEncrypter {
        public String convertEncryptQuery(String paramString, EncryptType type) {
            return String.format(" fnc_encrypt_var( ? ) ");
        }
    }

    /**
     * MsSql 전용 암호화 쿼리 클래스
     *
     * @author jolith514
     */
    public class EncryptMsSql implements IEncrypter {

        public String convertEncryptQuery(String paramString, EncryptType type) {
            return null;
        }
    }
}