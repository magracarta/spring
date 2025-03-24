package mobile.factory.db.vendor;

import java.util.Map;

/**
 * <pre>
 * 이클래스는 AES로 암화
 * </pre>
 *
 * @author JY.Eom
 * @date 2017-06-30
 * @time 13:44:90
 */
public interface DBDecryptManager {
	/**
	 * 복호화
	 * 
	 * @param field
	 * @param val TODO
	 * @return
	 */
	public String decrypt(String field, String val);
	
	/**
	 * 앞3자리, 나머지는 뒤에 하는 cell_no => cell_no1, cell_no2 로 변경이 필요한 필드들
	 * @param field 체크필드
	 * @return
	 */
	public boolean isSubstrField(String field);
	
	/**
	 * 한컬럼이 여러컬럼으로 분리될 필요가 있는거 가공
	 * @param key
	 * @param value
	 * @param map 
	 */
	public void setSplitColumn(String key, String value, Map<String, Object> map);
	
	/**
	 * 암호화 필드 체크
	 * @param field
	 * @return
	 */
	public boolean containsEncryptField(String field);
}
// :)--