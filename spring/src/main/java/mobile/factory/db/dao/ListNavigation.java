package mobile.factory.db.dao;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import mobile.factory.RequestDataSet;


/**
 * 이 클래스는 게시판과 같은 페이지의 하단 인덱싱을 위한 처리를 해주는 클래스 이다.
 *
 * @author JeongY.Eom
 * @date 2014.05.07
 * @since 2007. 09. 18
 */
public class ListNavigation {
	public static final String LIST_HEADER = "#list_header#";
	public static final String LIST_INIT = "#list_init#"; 

    private String DB_KIND = RequestDataSet.getDbVendor();
    private Map<String, String> mapKey = new HashMap<String, String>();
    private int pagePerMaxList = 10;
    private boolean isUse = true;
    private int nextPage = 0;
    private int maxPage = 0;
    
    public ListNavigation(String dB_KIND) {
    	this.DB_KIND = dB_KIND;
    }
    
    public ListNavigation(boolean isUse) {
    	this.isUse = isUse;
    }
    
    public ListNavigation(String dB_KIND, int pagePerMaxList) {
    	this.DB_KIND = dB_KIND;
    	this.pagePerMaxList = pagePerMaxList;
    }
    
    public void setDB_KIND(String dB_KIND) {
        DB_KIND = dB_KIND;
    }

	public void setMaxListCount(int pagePerMaxList) {
		this.pagePerMaxList = pagePerMaxList;
	}
	
	public int getMaxListCount(){
		return this.pagePerMaxList;
	}
	
	public void setNextPage(int nextPage) {
		this.nextPage = nextPage;
	}
	
	public void setMaxPage(int maxPage){
		this.maxPage = maxPage;
	}
	
	public int getNextPage(){
		return this.nextPage - this.pagePerMaxList;
	}
	
	public boolean getIsUse() {
		return this.isUse;
	}
    
	public void addKeyCol(String key, String value) {
		this.mapKey.put(key, value);
	}

	public String getListSeqQuery(String sql) {
        return this.getListSeqQueyrHeader() + sql + this.getListSeqQueryTail();
        
	}
	
	public int getMaxPage(){ //다음페이지 여부 1, 다음페이지 없음 0
		if((this.maxPage / this.pagePerMaxList) == 0){
			return 0;
		}else if((this.maxPage / this.pagePerMaxList) > 0){
			return (this.maxPage % this.pagePerMaxList) > 0 ? (this.maxPage / this.pagePerMaxList)+1:(this.maxPage / this.pagePerMaxList);
		}else{
			return (this.maxPage / this.pagePerMaxList);
		}
	}
	
	public String getListSeqQueyrHeader() {
		String listQueryHeader = "";
        if (DBTableDao.DB_ORACLE.equals(this.DB_KIND)) {
        	listQueryHeader = "SELECT rownum as rownum  FROM ( ";
        } else if (DBTableDao.DB_MYSQL.equals(this.DB_KIND)) {
        	listQueryHeader = "SELECT * FROM (SELECT CAST(@ROWNUM := @ROWNUM + 1 as UNSIGNED) AS rownum";
        	listQueryHeader += ",list_seq.*";
        	listQueryHeader += "FROM (SELECT @ROWNUM := 0) row";
        	listQueryHeader += ",(";
        	
        } 
        
		return listQueryHeader;
	}
    
	public String getListSeqQueryTail() {
		String listQueryTail = "";
		
        if (DBTableDao.DB_ORACLE.equals(this.DB_KIND)) {
        	listQueryTail = " ) list_seq ";
        } else if (DBTableDao.DB_MYSQL.equals(this.DB_KIND)) {
        	listQueryTail = " LIMIT 18446744073709551615) list_seq) list_seq WHERE 1 = 1 ";
        	
        } 		
		
		
		
		Set<String> keySet = this.mapKey.keySet();
		
		for (String key : keySet) {
			listQueryTail += " AND " + key + " = '" + mapKey.get(key) + "' \n";
		}			
	
		
		return listQueryTail;
	}
    
	
	public String getListQuery(String sql, long limnt) {
        return this.getListQueyrHeader() + sql + this.getListQueryTail(limnt);
	}
    
	
	public String getListQueyrHeader() {
		String listQueryHeader = "SELECT * FROM (\n";
		
        if (DBTableDao.DB_ORACLE.equals(this.DB_KIND)) {
        	//listQueryHeader = "SELECT rownum as rownum  FROM ( ";
        } else if (DBTableDao.DB_MYSQL.equals(this.DB_KIND)) {
        	listQueryHeader += "SELECT @ROWNUM := @ROWNUM + 1 AS rownum";
        	listQueryHeader += ",list_seq.*";
        	listQueryHeader += "FROM (SELECT @ROWNUM := 0) row";
        	listQueryHeader += ",(";
        	
        } 
        
		return listQueryHeader;
	}
    
	public String getListQueryTail(long limnt) {
		String listQueryTail = "";
		
        if (DBTableDao.DB_ORACLE.equals(this.DB_KIND)) {
        	//listQueryTail = " ) list_seq ";
        } else if (DBTableDao.DB_MYSQL.equals(this.DB_KIND)) {
        	listQueryTail += " LIMIT 18446744073709551615) list_seq";
    		listQueryTail += ") list_seq WHERE rownum > " + limnt + "\n";
    		listQueryTail += " LIMIT 0, " + this.pagePerMaxList;        	
        } 			
		
		return listQueryTail;
	}
	
	public String getLimitQuery() {
		String listQueryTail = "";
		
        if (DBTableDao.DB_ORACLE.equals(this.DB_KIND)) {
        	//listQueryTail = " ) list_seq ";
        } else if (DBTableDao.DB_MYSQL.equals(this.DB_KIND)) {
    		listQueryTail += " LIMIT 0, " + this.pagePerMaxList;        	
        }
        
        return listQueryTail;
	}

}
