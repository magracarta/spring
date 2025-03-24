package mobile.factory.ui.easyui;

import java.util.Map;

/**
 * <pre>
 * 이 클래스는 easiui 컴포넌트 정보를 셋팅하기 위한 객체
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2020. 1. 16.
 * @time 오후 1:02:10
 **/
public abstract class EasyuiObject {
	public static final String COMBO_GRID = "combogrid";

	protected String compName = "";
	protected String compType = "";

	/**
	 * 컴포넌트 타입 반환
	 * 
	 * @return
	 */
	public abstract String getCompType();

	/**
	 * 컴포넌트 명
	 * 
	 * @return
	 */
	public abstract String getComeName();
	
	/**
	 * 컴포넌트 정보 셋팅
	 * @param compMap
	 */
	public abstract void setCompData(Map<String, Object> compMap);
}
// :)--