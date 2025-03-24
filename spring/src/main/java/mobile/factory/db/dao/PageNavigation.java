package mobile.factory.db.dao;

import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;

/**
 * 이 클래스는 게시판과 같은 페이지의 하단 인덱싱을 위한 처리를 해주는 클래스 이다.
 *
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 18
 */
public class PageNavigation implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = -5298881934862934437L;
	
	public static final int DEFAULT_LIST_COUNT = 50;
	public static final int DEFAULT_PAGE_COUNT = 10;

	// curPageNum : 현재 선택되어 있는 Page번호.
	// maxPageCount : 한 화면에 선택할 수 있는(표시되어지는) Page수의 최대값
	// maxListCount : 한 화면에 보여줄 최대 항목수
	// totalElementCount : select문에 의해 select된 항목의 총수.

	private int curPageNum = 1; // currentPage
	private int maxListCount = DEFAULT_LIST_COUNT; // rowSize
	private int maxPageCount = DEFAULT_PAGE_COUNT; // pageSize
	private int totalElementCount = 1; // totalCnt
	private int lastPageNumOfPage = 0; // 보여지는 페이지에 마지막 번호

	private int totalPage;// 총 페이지수
	private int startRow;// 페이지의 시작점
	private int endRow;// 페이지의 끝점
	
	private int curListCount = 0;	// 현재 데이터가 셋팅된 행수
	
    private boolean moreMode = false;	// 더보기 모드로 동작할 것인지 여부
    private boolean hasNext = false;	// 다음페이지여부(더보기)

	@Setter @Getter
	private PreparedWhereMaker totalPwm = null;	// 페이지 전체 갯수 구하는 preparedWhereMaker

	/**
	 * DB종류.. DB종류에 따라 쿼리가 달라지므로..
	 */
	private String dbVendor;
	// ##################################################################
	public PageNavigation(String dbVendor) {
		super();
		this.dbVendor = dbVendor;
	}
	
	public boolean isMoreMode() {
		return moreMode;
	}


	public void setMoreMode(boolean moreMode) {
		this.moreMode = moreMode;
	}


	public boolean isHasNext() {
		return hasNext;
	}


	public void setHasNext(boolean hasNext) {
		this.hasNext = hasNext;
	}
	
	/**
	 * 현재 페이지에서 첫번째 뿌려줄 항목의 index. 첫 페이지에서는 0 이됨.
	 * 
	 * @return
	 */
	public int getStartElementIndex() {
		return (curPageNum - 1) * maxListCount;
	}

	public int getEndElementIndex() {
		int endIndex = getStartElementIndex() + maxListCount;
		endIndex = Math.min(endIndex, totalElementCount);
		return endIndex;
	}

	/**
	 * curPhase : 현재 표시되는 Phase (Phase 는 Page List가 변하는 단위) 1 2 ... 10가 한
	 * Phase이고 다음 Phase는 11 12 ... 20 등이 될 수 있음. 첫번째 Phase는 0임.
	 * 
	 * @return
	 */
	public int getCurPhase() {
		return (curPageNum - 1) / maxPageCount;
	}

	/**
	 * 현재 Phase에서 시작하는 Page번호로 첫 Phase에서 시작 page 번호는 1임.
	 * 
	 * @return
	 */
	public int getCurPageStartNum() {
		return maxPageCount * getCurPhase() + 1;
	}

	public int getTotalPage() {
		return totalElementCount / maxListCount + (totalElementCount % maxListCount == 0 ? 0 : 1);
	}

	public int getMaxCurPage() {
		return getCurPhase() * maxPageCount;
	}

	public int getLoopCount() {
		return Math.min(getTotalPage() - getMaxCurPage(), maxPageCount);
	}
	
	private String printPageIndex = "";
	/**
	 * 페이지 리스트에 표기할 방법
	 * @param str &nbsp;<a href='javascript:navigatePage(%d);'><span>%d</span></a>
	 */
	public void setPrintPageIndex(String str) {
		this.printPageIndex = str;
	}
	
	private String printPageSamePage = "";
	/**
	 * 페이지가 같을때 표시할 방법
	 * @param str &nbsp;<strong>%d</strong>
	 */
	public void setPrintPageSamePage(String str) {
		this.printPageSamePage = str;
	}

	public String getPrintPageIndex() {
		StringBuilder out = new StringBuilder();

		int loopCount = getLoopCount();
		// if (loopCount == 0) {
		// printPageLink(out, 1, "1");
		// }

		for (int i = 0; i < loopCount; i++) {
			int indexPageNum = getCurPageStartNum() + i;
			// out.append("\n");

			// 페이지 처음일때 구분자표시
			// if(i == 0) {
			// out.append("｜");
			// }

			// 같은페이지
			if (curPageNum == indexPageNum) {
				out.append(String.format(this.printPageSamePage, indexPageNum));
			} else {
				String classStr = "";
				// 첫페이지
				classStr = i == 0 ? "class=\"liFirst\"" : classStr;
				// 마지막페이지
				classStr = (i != loopCount - 1) ? "class=\"liLast\"" : classStr;

//				printPageLink(out, indexPageNum, classStr);
				String displayTxt = String.format(this.printPageIndex, indexPageNum, indexPageNum);
				out.append(displayTxt);
			}

			// 마지막일때 제외
			if (i != loopCount - 1) {
				// out.append("｜");
			} else {
				lastPageNumOfPage = indexPageNum;
			}
		}

		return out.toString();
	}

	// Phase 이동 버튼 표시여부 채크하기 위한 메소드들.
	public boolean needToShowFirst() {
		return getCurPhase() > 0;
	}

	public boolean needToShowPrev() {
		return getCurPhase() > 0;
	}

	public boolean needToShowNext() {
		return getTotalPage() > maxPageCount;
	}

	public boolean needToShowLast() {
		return getTotalPage() > maxPageCount;
	}

	// Phase 이동 버튼(<<, < , >, >>) 으로 이동할 페이지 번호를 구하는 메소드들.

/**
	 * '<' 를 눌렀을 때의 페이지 번호.
	 */
	public int getPrevPageNum() {
		return Math.max(getCurPageStartNum() - maxPageCount, 0);
	}

	/**
	 * '>' 를 눌렀을 때의 페이지 번호.
	 */
	public int getNextPageNum() {
		return Math.min(getCurPageStartNum() + maxPageCount, getLastPageNum());
	}

	/**
	 * '>>' 를 눌렀을 때의 페이지 번호.
	 */
	public int getLastPageNum() {
		return getTotalPage();
	}

	// 멤버 변수에 대한 기본 getter / setter
	public int getCurPageNum() {
		return curPageNum;
	}

	public void setCurPageNum(int curPageNum) {
		this.curPageNum = curPageNum;
	}
	
	/**
	 * more 셋팅시에는 행 최대 사이즈를 보고 계산
	 * @param curPageNum
	 */
	public void setCurPageNumForMore(int curPageNum) {
		this.curPageNum = curPageNum;

		// 시작과 종료 페이지 셋팅
		int maxListCount = getMaxListCount();
		setStartRow((getCurPageNum() - 1) * maxListCount);
		setEndRow(getCurPageNum() * maxListCount);
	}

	public int getMaxListCount() {
		return maxListCount;
	}

	public void setMaxListCount(int maxListCount) {
		this.maxListCount = maxListCount;
	}

	public int getMaxPageCount() {
		return maxPageCount;
	}

	public void setMaxPageCount(int maxPageCount) {
		this.maxPageCount = maxPageCount;
	}

	public int getTotalElementCount() {
		return totalElementCount;
	}

	public void setTotalElementCount(int totalElementCount) {
		setTotalPwm(null);
		this.totalElementCount = totalElementCount;

		if (totalElementCount > 0) {
			this.totalPage = totalElementCount / maxListCount + (totalElementCount % maxListCount > 0 ? 1 : 0);

			if (curPageNum > totalPage)
				curPageNum = totalPage;

			startRow = curPageNum > 0 ? (curPageNum - 1) * maxListCount : 0;
			endRow = curPageNum > 0 ? curPageNum * maxListCount : maxListCount;
		}
	}

	public String getStartListQuery() {
		String oraSQL = " SELECT * FROM ( SELECT rownum as row_num, t.* FROM ( \n ";
		String mySQL = " SELECT * FROM ( SELECT t.* FROM ( \n ";
		String msSQL = "";
		String db2SQL = oraSQL;

		String result = "";

		if (DBTableDao.DB_ORACLE.equals(this.dbVendor)) {
			result = oraSQL;
		} else if (DBTableDao.DB_MYSQL.equals(this.dbVendor)) {
			result = mySQL;
		} else if (DBTableDao.DB_MSSQL.equals(this.dbVendor)) {
			result = msSQL;
		} else if (DBTableDao.DB_DB2.equals(this.dbVendor)) {
			result = db2SQL;
		}

		return result;
	}

	public String getEndListQuery() {
		// 더보기 모드에서는 전체 카운트가 필요없고 단지 더보기가 나올지 말지만 결정
    	int endRowQuery = endRow + (moreMode ? 1 : 0);
		
        String oraSQL = " \n ) t ) WHERE row_num > " + startRow + " AND row_num <= " + endRowQuery;
        String mySQL = " \n limit " + startRow + " , " + (endRowQuery - startRow);
        String msSQL = " \n  OFFSET " + startRow + " ROWS FETCH NEXT " + (endRowQuery - startRow) + " ROWS ONLY ";
        String db2SQL = oraSQL;

		String result = "";

		if (DBTableDao.DB_ORACLE.equals(this.dbVendor)) {
			result = oraSQL;
		} else if (DBTableDao.DB_MYSQL.equals(this.dbVendor)) {
			result = mySQL;
		} else if (DBTableDao.DB_MSSQL.equals(this.dbVendor)) {
			result = msSQL;
		} else if (DBTableDao.DB_DB2.equals(this.dbVendor)) {
			result = db2SQL;
		}

		return result;
	}

	public String getStartCntQuery() {
		return " SELECT COUNT(0) FROM ( \n ";
	}

	public String getEndCntQuery() {
		return " \n ) t ";
	}

	public String getListQuery(String sql) {
		StringBuffer sb = new StringBuffer();
		sb.append(getStartListQuery()).append(sql).append(getEndListQuery());
		return sb.toString();
	}

	public int getStartRow() {
		return startRow;
	}

	public void setStartRow(int startRow) {
		this.startRow = startRow;
	}

	public int getEndRow() {
		return endRow;
	}

	public void setEndRow(int endRow) {
		this.endRow = endRow;
	}

	/**
	 * NO나타내기 위한 변수로써 첫페이지를 시작으로 오름차순으로 나열된다.<br>
	 * 페이지에서는 이 메소드 호출과 + 현재 행을 더하면 된다.<br>
	 * ${pageNavi.noAescendingNum - listCnt.count}
	 * @return
	 */
	public int getNoAscendingNum() {
		return getCurPageNum() <= 1 ? 0 : (getCurPageNum() - 1) * getMaxListCount();
	}
	
	/**
	 * NO를 나타내기 위한 변수로 내림차순 정리<br>
	 * 페이지에서는 이 메소스 호출과 - 현재행을 빼면된다.<br>
	 * ${pageNavi.noDescendingNum - listCnt.index}
	 * 
	 * @return
	 */
	public int getNoDescendingNum() {
		return getCurPageNum() <= 1 ? getTotalElementCount() : getTotalElementCount() - ((getCurPageNum() - 1) * getMaxListCount());
	}

	public void initPageNum() {
		setTotalElementCount(0);
		setStartRow(0);
		setEndRow(0);
		setCurListCount(0);
	}

	public boolean isLastPage() {
		return lastPageNumOfPage == getLastPageNum() ? true : false;
	}
	
	public int getCurListCount() {
		return curListCount;
	}

	public void setCurListCount(int curListCount) {
		this.curListCount = curListCount;
	}

	/**
	 * 보여지는 pageRow에서 빈공백이 있는 행
	 * @return
	 */
	public int getEmptyListRow() {
		return getMaxListCount() - getCurListCount();
	}
}
// :)--
