package mobile.factory.db;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;

import mobile.factory.db.dao.EntityDao;

/**
 * 이 클래스는 service 클래스의 최상위 클래스이다.
 *
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 11. 08
 */
public abstract class ControlService {
	@Autowired
	@Qualifier("entityDao")
	protected EntityDao entityDao;
}
// :)--
