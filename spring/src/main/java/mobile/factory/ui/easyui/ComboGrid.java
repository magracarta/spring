package mobile.factory.ui.easyui;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.gson.Gson;

/**
 * <pre>
 * 이 클래스는
 * </pre>
 *
 * @author JeongY.Eom
 * @date 2020. 1. 16.
 * @time 오전 11:57:24
 **/
public class ComboGrid extends EasyuiObject {
	private List<Map<String, Object>> dataList = null;
	private List<Columns> columnsList = null;

	/**
	 * 
	 * @param compName
	 *            컴포넌트 명
	 * @param data
	 */
	public ComboGrid(String compName, List<Map<String, Object>> data) {
		super.compName = compName;
		this.dataList = data;
	}

	public String getCompName() {
		return compName;
	}
	
	/**
	 * 컬럼 정보 추가
	 * 
	 * @param field
	 * @param title
	 * @param width
	 * @param sortable
	 * @param hidden
	 */
	public void addColumns(String field, String title, int width, boolean sortable, boolean hidden) {
		Columns columns = new Columns(field, title, width, sortable, hidden);

		if (columnsList == null) {
			columnsList = new ArrayList<Columns>();
		}
		columnsList.add(columns);
	}

	/**
	 * 컬럼 정보 추가
	 * 
	 * @param field
	 * @param title
	 * @param width
	 * @param sortable
	 */
	public void addColumns(String field, String title, int width, boolean sortable) {
		Columns columns = new Columns(field, title, width, sortable);

		if (columnsList == null) {
			columnsList = new ArrayList<Columns>();
		}
		columnsList.add(columns);
	}

	/**
	 * 컬럼정보 추가
	 * 
	 * @param field
	 * @param title
	 * @param width
	 */
	public void addColumns(String field, String title, int width) {
		addColumns(field, title, width, false);
	}

	/**
	 * <pre>
	 * 
	 * </pre>
	 * 
	 * @return
	 */
	private String toDataJson() {
		String retVal = "";

		// 컬럼 체크
		if (columnsList == null || columnsList.isEmpty()) {
			return retVal;
		}
		// data가 있는 경우 컬럼에 있는 항목만
		if (dataList == null || dataList.isEmpty()) {
			retVal = new Gson().toJson(columnsList);
		} else {
			Set<String> columnField = new HashSet<>();
			for (Columns item : columnsList) {
				columnField.add(item.getField());
			}

			List<Map<String, Object>> list = new ArrayList<>();
			for (Map<String, Object> row : dataList) {
				Map<String, Object> map = new HashMap<>();
				for (String col : columnField) {
					if (row.containsKey(col)) {
						map.put(col, row.get(col));
					}
				}

				if (map.isEmpty() == false) {
					list.add(map);
				}
			}

			retVal = new Gson().toJson(list);
		}

		return retVal;
	}

	/**
	 * <pre>
	 * 컬럼정보를 json 타입으로 반환
	 * </pre>
	 * 
	 * @return
	 */
	private String toColumnsJson() {
		String retVal = "[]";
		// 컬럼 체크
		if (columnsList == null || columnsList.isEmpty()) {
			return retVal;
		}
		// data가 없는 경우 컬럼 반환
		if (dataList == null || dataList.isEmpty()) {
			retVal = new Gson().toJson(columnsList);
		} else {
			// data와 컬럼 모두 있으면, 데이터에 있는 항목만 컬럼 생성
			Map<String, Object> firstData = dataList.get(0);

			List<Columns> list = new ArrayList<>();
			for (Columns item : columnsList) {
				if (firstData.containsKey(item.getField())) {
					list.add(item);
				}
			}

			retVal = String.format("[%s]", new Gson().toJson(list));
		}
		return retVal;
	}

	/**
	 * ComboGrid 컬럼정보 가지고 있는 빈
	 * 
	 * @author sunjuhun
	 *
	 */
	private class Columns {
		private String field = "";
		private String title = "";
		private int width = 0;
		private boolean sortable = false;
		private boolean hidden = false;
		
		/**
		 * 
		 * @param field
		 *            data에 있는 키값
		 * @param title
		 *            표시이름
		 * @param width
		 *            px
		 * @param sortable
		 *            정렬 지원여부
		 */
		private Columns(String field, String title, int width, boolean sortable, boolean hidden) {
			super();
			init(field, title, width, sortable, hidden);
		}

		/**
		 * 
		 * @param field
		 *            data에 있는 키값
		 * @param title
		 *            표시이름
		 * @param width
		 *            px
		 * @param sortable
		 *            정렬 지원여부
		 */
		private Columns(String field, String title, int width, boolean sortable) {
			super();
			init(field, title, width, sortable, false);
		}

		/**
		 * 
		 * @param field
		 *            data에 있는 키값
		 * @param title
		 *            표시이름
		 * @param width
		 *            px
		 */
		private Columns(String field, String title, int width) {
			super();
			init(field, title, width, false, false);
		}

		/**
		 * 
		 * @param field
		 * @param title
		 * @param width
		 * @param sortable
		 */
		private void init(String field, String title, int width, boolean sortable, boolean hidden) {
			this.field = field;
			this.title = title;
			this.width = width;
			this.sortable = sortable;
			this.hidden = hidden;
		}

		public String getField() {
			return field;
		}

		public String getTitle() {
			return title;
		}

		public int getwidth() {
			return width;
		}

		public boolean isSortable() {
			return sortable;
		}
		
		public boolean isHidden() {
			return hidden;
		}

	}

	@Override
	public String getCompType() {
		return EasyuiObject.COMBO_GRID;
	}

	@Override
	public String getComeName() {
		return super.compName;
	}

	@Override
	public void setCompData(Map<String, Object> compMap) {
		compMap.put(String.format("%sCols", compName), this.toColumnsJson());
		compMap.put(String.format("%sData", compName), this.toDataJson());
	}
}
// :)--