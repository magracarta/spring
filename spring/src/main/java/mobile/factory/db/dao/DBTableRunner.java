package mobile.factory.db.dao;


/**
 * <pre>
 * 이 클래스는 DBTableDao 실행될때 insert, update 되기 전에 실행할 명령을 정의
 * </pre>
 * 
 * @author JeongY.Eom
 * @date 2014. 6. 27.
 * @time 오후 6:08:14
 **/
public interface DBTableRunner {
	/**
	 * insert 구문 생성전에 기술, 필드에 필요한 값 셋팅
	 * 
	 * @param beanObject
	 */
	void beforeInsert(BeanObject bean);

	/**
	 * update 구문 생성전에 기술, 필드에 필요한 값 셋팅
	 * @param beanObject
	 */
	void beforeUpdate(BeanObject bean);
	
	/**
	 * update 구문 생성시 update table_name set [여기생성될 문구] where xx
	 * @param bean
	 * @return
	 */
	String appendUpdateSQL(BeanObject bean);
}
// :)--