package mobile.factory.db.dao;

import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.jdbc.core.SqlParameter;

/**
 * <pre>
 * 이클래스는 procedure 호출을 위한 Param 및 실행 정보를 담고있다.
 * </pre>
 *
 * @author JY.Eom
 * @date 2017-05-12
 * @time 15:47:85
 */
public abstract class BeanSpcObject {
	private static Log logger = LogFactory.getLog(BeanSpcObject.class);
	
	/**
	 * 등록 action
	 */
	public static String CMD_CREATE = DBTableDao.CMD_CREATE;
	/**
	 * 수정 action
	 */
	public static String CMD_UPDATE = DBTableDao.CMD_UPDATE;
	/**
	 * 삭제 action
	 */
	public static String CMD_DELETE = DBTableDao.CMD_DELETE;

	/**
	 * param 속성
	 * 
	 * @return
	 */
	public abstract SqlParameter[] getSqlParameter();

	/**
	 * 프로시저명
	 * 
	 * @return
	 */
	public abstract String getProcedureName();

	/**
	 * 필드목록
	 * 
	 * @return
	 */
	public abstract String[] getFieldArray();

	/**
	 * 프로시저 전달 인자
	 * 
	 * @return
	 * @throws NoSuchMethodException 
	 * @throws InvocationTargetException 
	 * @throws IllegalAccessException 
	 */
	public Map<String, ?> getParamMap() throws IllegalAccessException, InvocationTargetException, NoSuchMethodException {
		Map<String, Object> map = new HashMap<>();

		for (String item : getFieldArray()) {
			String val = BeanUtils.getProperty(this, item);
			map.put(item, val);
		}

		return map;
	}
}
// :)--