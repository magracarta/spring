package mobile.factory;

import com.clipsoft.org.apache.commons.lang.ArrayUtils;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import lombok.Setter;
import mobile.factory.db.dao.DBTableDao;
import mobile.factory.db.dao.PageNavigation;
import mobile.factory.exception.XCheckException;
import mobile.factory.spring.beans.LoginUser;
import mobile.factory.util.AppUtil;
import mobile.factory.util.CollectionUtil;
import mobile.factory.util.DateUtil;
import mobile.factory.util.StringUtil;
import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.security.authentication.RememberMeAuthenticationToken;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.util.WebUtils;
import sunnyyk.erp.common.util.CodeDefine;
import sunnyyk.erp.web.core.db.security.SecureUser;
import sunnyyk.erp.web.core.db.security.SecureUserDetailsService;

import jakarta.servlet.http.HttpServletRequest;
import java.io.Serializable;
import java.security.Principal;
import java.util.*;

/**
 * 페이지에서 넘어온 입력데이터를 가공한다.
 * 
 * @author JeongY.Eom
 * @date 2007. 09. 20
 * @time 오후 4:45:23
 */
public class RequestDataSet implements Serializable {
	private static final long serialVersionUID = -5150785283791142489L;

	private final Log logger = LogFactory.getLog(getClass());
	
	private LoginUser loginUser;
	
	private transient ResponseLogger responseLogger;
	
	private DataBound dataBound;
	public void setDataBound(DataBound dataBound) {
		this.dataBound = dataBound;
	}

	private static String dbVendor = DBTableDao.DB_ORACLE;
	public static String getDbVendor() {
		return dbVendor;
	}
	
	private static int defaultListRow;
	public static int getDefaultListRow() {
		return defaultListRow;
	}
	
	private PageNavigation pageNavi;
	private boolean paramSessionSave = true;

	public RequestDataSet(String dbKind, int defaultListRow) {
		init(dbKind, defaultListRow, true);
	}
	
	public RequestDataSet() {	
		init(DBTableDao.DB_ORACLE, 50, true);
	}
	
	public void setResponseLogger(ResponseLogger responseLogger) {
		this.responseLogger = responseLogger;
	}

	@Setter
	private SecureUserDetailsService userService;

	/**
	 * request 데이터 가공
	 * @param dbKind
	 * @param defaultListRow
	 * @param sessionSave inputParam 이름으로 세션이 저장할지 여부
	 */
	public RequestDataSet(String dbKind, int defaultListRow, boolean sessionSave) {
		init(dbKind, defaultListRow, sessionSave);
	}
	
	private void init(String dbKind, int defaultListRow, boolean sessionSave) {
		this.dbVendor = dbKind;
		this.defaultListRow = defaultListRow;
		this.paramSessionSave = sessionSave;
		
		this.pageNavi = new PageNavigation(this.dbVendor);
	}

	/**
	 * inputParam
	 */
	private Map<String, Object> input = new HashMap<String, Object>();

	public boolean ajaxRequest() {
		return inGetString("ctrl_next_page").indexOf("common/ajaxResult") > -1 ? true : false;
	}

	/**
	 * 입력 파라매터를 추출한다.
	 * 
	 * @param request
	 * @return
	 * @throws XCheckException
	 *             입력데이터의 유효성 체크 예외
	 */
	public void arrangeInputParameters(HttpServletRequest request) throws RuntimeException {
		Map<String, String[]> paramMap = request.getParameterMap();

		// 전에 입력했던 파라매터 저장
//		String[] ctrlRetainParams = (String[]) paramMap.get("ctrl_retain_params");
//		if (ctrlRetainParams != null && ctrlRetainParams[0].equals("true") && WebUtils.getSessionAttribute(request, "inputParam") != null) {
//			input = new HashMap((Map<String, Object>) WebUtils.getSessionAttribute(request, "inputParam"));
//		} else {
			input.clear();
//		}

		// 기본적인 폼에 담긴 데이터 추출
		Set<String> set = paramMap.keySet();
		for (String key : set) {
			if (key.equals("ctrl_var_string") == false) {
				String[] valArray = (String[]) paramMap.get(key);
				
				if("sort".equals(key)){
					key = "s_sort_key";
				} else if("order".equals(key)){
					key = "s_sort_method";
				} else if("page".equals(key)){
					key = "ctrl_page_num";
				} else if("rows".equals(key)){
					key = "ctrl_max_list_count";
				}
				
				String lowerKey = key.toLowerCase();
				
				input.put(key, getParamValue(key, valArray));
				input.put(lowerKey, getParamValue(key, valArray));

				// 값이 배열로 넘어왔을때는 String 으로 변환시켜주며, #으로 구분자를 줌..
				// 키는 기본이름에 _str 를 붙임.
				if (valArray.length > 1) {
					String arrayStrKey = String.format("%s_str", lowerKey);

					if (input.containsKey(arrayStrKey) == false) {
						StringBuilder sb = new StringBuilder();
						for (String item : valArray) {
							sb.append(item + "#");
						}
						input.put(arrayStrKey, StringUtils.removeEnd(sb.toString(), "#"));
					}
				} else if (lowerKey.endsWith("_str")) {
					// _str 로 끝나는 키가 있으면 _str을 제거하고 키로 값을 셋팅
					// angular에서 배열로 되는 키를 넘기지 못하므로...
					String arrayKey = StringUtils.left(lowerKey, lowerKey.length() - 4);
					if (input.containsKey(arrayKey) == false && input.get(lowerKey) != null) {
						String originStr = input.get(lowerKey).toString();
						// ##12 => size(3), 공백이 있어도 split 해줌
						int cnt = StringUtils.countMatches(originStr, "#");
						String[] valueArray = originStr.split("#", cnt + 1);

						input.put(arrayKey, valueArray);
					}
				}
			}
		}
		// param으로 넘어온 데이터 추출
		if (paramMap.get("ctrl_var_string") != null) {
			String param = ((String[]) paramMap.get("ctrl_var_string"))[0];
			String[] paramStrings = StringUtils.split(param, "&");
			for (String val : paramStrings) {
				String key = StringUtils.substringBefore(val, "=");
				String value = StringUtils.substringAfter(val, "=");
			
				input.put(key, getParamValue(key, value));
				input.put(key.toLowerCase(), getParamValue(key, value));
			}
		}

		if (paramSessionSave) {
			request.setAttribute("inputParam", input);
//			WebUtils.setSessionAttribute(request, "inputParam", input);
		}

		setBaseInput(request, input);
	}

	public void clearInput() {
		input.clear();
	}

	/**
	 * 페이지 정보만 남기고 나머지 데이터는 삭제한다.
	 */
	public void clearParam() {
		Object ctrlNextPage = input.get("ctrl_next_page");

		clearInput();
		input.put("ctrl_next_page", ctrlNextPage);
	}

	public Map<String, Object> getInput() {
		return this.input;
	}
	
	public String getOriginInput() {
		StringBuilder sb = new StringBuilder();

		Map<String, String> map = new HashMap<String, String>();
		for (String key : input.keySet()) {
			String val = input.get(key) == null ? "" : input.get(key).toString();
			map.put(key.toUpperCase(), val);
		}

		for (String key : map.keySet()) {
			sb.append(key + "=" + map.get(key) + "&");
		}

		return sb.toString();
	}

	// ############# Getter #############
	public PageNavigation getPageNavi() {
		return this.pageNavi;
	}

	/**
	 * 페이지에서 넘어온 값 가공
	 * 
	 * @param key
	 * @param value
	 * @return
	 */
	private Object getParamValue(String key, Object value) {
		Object paramValue = value.toString();
		if (value instanceof String[]) {
			String[] array = (String[]) value;
			paramValue = array.length > 1 ? array : array[0];
		}

		return paramValue;
	}

	public String getPrintPageIndex() {
		return this.pageNavi.getPrintPageIndex();
	}

	public int inGetInt(String key) {
		return inGetInt(key, 0);
	}
	
	public long inGetLong(String key) {
		return StringUtil.toNumberLong(inGetString(key, "0"));
	}

	public int inGetInt(String key, int defaultInt) {
		String strVal = inGetString(key, "0");
		String sign = "";
		if (strVal.startsWith("-")) {
			sign = "-";
			strVal = strVal.substring(1);
		}

		int retInt = 0;
		if (StringUtils.isNumeric(strVal)) {
			retInt = Integer.parseInt(sign + strVal);
		} else {
			retInt = defaultInt;
		}

		return retInt;
	}

	public Object inGetObject(String key) {
		return input.get(key);
	}

	public String inGetString(String key) {
		return inGetString(key, "");
	}

	/**
	 * 입력 키 값 가져오기
	 * @param key
	 * @param defaultString
	 * @return 키값이 없으면, "" 반환
	 */
	public String inGetString(String key, String defaultString) {
		if(input.containsKey(key) == false) {
			return defaultString;
		}
		
		Object val = input.get(key);
		String retString;
		if (val instanceof String[]) {
			retString = ((String[]) val)[0];
		} else {
			retString = (String) val;
		}
		return StringUtils.defaultIfEmpty(retString, defaultString);
	}

	public String[] inGetStringArray(String key) {
		Object obj = inGetObject(key);
		if (obj == null)
			return new String[] {};

		if (obj instanceof String[]) {
			return (String[]) obj;
		} else {
			return new String[] { (String) obj };
		}
	}
	
	public Map<String, String> inGetMap() {
		return CollectionUtil.toStringMap(new HashMap<>(input));
	}

	// ############### Setter #####################
	/**
	 * 무조건 키값 입력
	 * @param key
	 * @param val
	 */
	public void inSet(String key, Object val) {
		this.input.put(key, val);
	}
	
	/**
	 * input에 해당 키에 값이 없으면 입력
	 * @param key
	 * @param val
	 */
	public void inSetIfBlank(String key, Object val) {
		if (this.input.containsKey(key)) {
			if (StringUtils.isBlank(inGetString(key))) {
				inSet(key, val);
			}
		} else {
			inSet(key, val);
		}
	}
	
	/**
	 * input에 해당 키가 없으면 입력
	 * @param key
	 * @param val
	 */
	public void inSetIfNotKey(String key, Object val) {
		if(this.input.containsKey(key) == false) {
			inSet(key, val);
		}
	}

	/**
	 * Map 데이터를 셋팅
	 * 
	 * @param data
	 */
	public void inSetMap(Map<String, Object> data) {
		Set<String> set = data.keySet();
		for (Iterator<String> it = set.iterator(); it.hasNext();) {
			String key = it.next();
			// 23.04.12 황빛찬 Integer 타입의 형변환시 ClassCastException으로 인하여 String.valueOf로 변경
//			String val = (String) data.get(key);
			String val = String.valueOf(data.get(key));
			inSet(key, val);
		}
	}

	public void inSetObject(String key, Object obj) {
		input.put(key, obj);
	}

	/**
	 * 입력받은 값으로 URL Param을 생성한다.
	 * 
	 * @param items
	 * @return
	 */
	public String makeParam(String[] items) {
		StringBuffer sb = new StringBuffer();
		for (String item : items) {
			String val = input.containsKey(item) ? inGetString(item, "") : "";
			sb.append(item + "=" + val + "&");
		}
		return sb.substring(0, sb.length() - 1).toString();
	}

	public String nextPage() {
		return nextPage("");
	}

	public String nextPage(String nextPage) {
		String inputNextPage = StringUtils.defaultIfEmpty(inGetString("ctrl_next_page"), "");
		if (StringUtils.isBlank(inputNextPage)) {
			inputNextPage = StringUtils.defaultIfEmpty(inGetString("ctrl_action_url"), "");
		}

		inputNextPage = StringUtils.remove(inputNextPage, inGetString("ctrl_host"));

		nextPage = inputNextPage;
		nextPage = nextPage.startsWith("/") ? nextPage.substring(1) : nextPage;
		nextPage = nextPage.endsWith(".jsp") ? nextPage.substring(0, nextPage.indexOf(".jsp")) : nextPage;
		nextPage = nextPage.endsWith(".html") ? nextPage.substring(0, nextPage.indexOf(".html")) : nextPage;
		nextPage = nextPage.endsWith(".htm") ? nextPage.substring(0, nextPage.indexOf(".htm")) : nextPage;
		nextPage = nextPage.endsWith(".do") ? nextPage.substring(0, nextPage.indexOf(".do")) : nextPage;

		nextPage = nextPage.equals("") ? null : nextPage;
		
		return nextPage;
	}

	public String printInputParams() {
		return this.input.toString();
	}

	public void remove(String key) {
		input.remove(key);
	}

	/**
	 * 기본적으로 셋팅되어야 하는 값
	 * 
	 * @param request
	 * @param map
	 * @return
	 */
	private void setBaseInput(HttpServletRequest request, Map<String, Object> map) {
		map.put("ctrl_ip", request.getRemoteAddr());

		String url = request.getRequestURL().toString();

		String uri = request.getRequestURI();
		// 80번 기본포트를 사용하는거에 WebToBe는 뒤에 :80을 붙이므로..
		String host = StringUtils.removeEnd(url, uri);
		host = StringUtils.endsWith(host, ":80") ? StringUtils.removeEnd(host, ":80") : host;

//		map.put("ctrl_request_uri", uri);
		// 끝에 "/" 붙으면 t_menu의 url에서 찾지 못하기 때문에 제거함(trunk 동일반영했음). 2023-02-24 김상덕
		map.put("ctrl_request_uri", StringUtils.removeEnd(uri, "/"));
		map.put("ctrl_request_url", url);
		map.put("ctrl_host", host);
		map.put("ctrl_method", request.getMethod());
		map.put("ctrl_query_string", request.getQueryString());
		
		// forLog
		map.put("ctrl_req_date", DateUtil.getCurrentDate("yyMMddHHmmssSSS"));
		
		if ("#".equals(inGetString("ctrl_action_url"))) {
			inSet("ctrl_action_url", uri);
		}

		// 페이지 리스트 일때 셋팅
		pageNavi.initPageNum();
		pageNavi.setCurPageNum(inGetInt("ctrl_page_num") == 0 ? 1 : inGetInt("ctrl_page_num"));
		pageNavi.setMaxListCount(inGetInt("ctrl_max_list_count") == 0 ? PageNavigation.DEFAULT_LIST_COUNT : inGetInt("ctrl_max_list_count"));
		pageNavi.setMaxPageCount(inGetInt("ctrl_max_page_count") == 0 ? PageNavigation.DEFAULT_PAGE_COUNT : inGetInt("ctrl_max_page_count"));
		
		// 기본정보 셋팅
		inSetIfBlank("data_source_cd", CodeDefine.CD_DATA_SOURCE_ERP_WEB);
		// 접속정보
		String deviceTypeCd = AppUtil.IS_PC.equals(AppUtil.getDeviceType(request)) ? "WIN" : "AND";
		inSetIfBlank("device_type_cd", deviceTypeCd);

		// API서버요청이면 강제로그인
		SecureUser secureUser = null;
		if(CodeDefine.CD_DATA_SOURCE_ERP_API.equals(inGetString("data_source_cd"))) {
			// 로그인세션 유지로 인해 메인 진입시 세션에 저장된 사용자 정보 재셋팅
			String userId = inGetString("login_web_id");
			try {
				secureUser = userService.getSecureUser(userId);
			} catch (Exception ignore) {
				logger.warn("", ignore);
			}
		}

		// 로그인한 사용자 정보 셋팅
		Principal principal = request.getUserPrincipal();
		if (principal != null || secureUser != null) {
			if (principal instanceof RememberMeAuthenticationToken) {
//				secureUser = (SecureUser) ((RememberMeAuthenticationToken) principal).getPrincipal();
//				secureUser.setAuto_login_yn("Y");
				
				// 2.9차 인사고과등 비밀번호체크 팝업 정상작동 안함. 20220624 김상덕
				/*
				 * 비밀번호 입력시 SecureUser passMenu 변수에 add하는데 
				 * 자동로그인일경우 무조건 principal SecureUser를 사용하여 (위의 passMenu가 add된 SecureUser와 다름..)
				 * 자동로그인이여도 세션에 저장된 SecureUser가 있으면 사용하도록 수정함.
				 */
				secureUser = (SecureUser) WebUtils.getSessionAttribute(request, "SecureUser");
				if (secureUser == null) {
					secureUser = (SecureUser) ((RememberMeAuthenticationToken) principal).getPrincipal();
				}
				secureUser.setAuto_login_yn("Y");
			} else if(secureUser == null) {
				secureUser = (SecureUser) WebUtils.getSessionAttribute(request, "SecureUser");
			}

			// 로그인 했으면 로그인 아이디 셋팅
			inSetIfBlank("mem_no", secureUser.getMem_no());
			inSetIfBlank("org_code", secureUser.getOrg_code());
			// 로그인 사용자 셋팅(사용자를 변경하는 경우에는 로그인한 사용자 아이디를 사용해야함)
			inSetIfBlank("login_mem_no", secureUser.getMem_no());
			inSetIfBlank("login_org_code", secureUser.getOrg_code());
			inSetIfBlank("appr_org_code", secureUser.getAppr_org_code());
			inSetIfBlank("login_grade_cd", secureUser.getGrade_cd());

			// true가 되야 마스킹 없어짐

//			boolean noMasking = "Y".equals(secureUser.getNoMasking()) && "N".equals(inGetString("s_masking_yn"));
//			secureUser.setApplyMasking(noMasking == false);
			String defaultMaskingYn = StringUtils.defaultIfEmpty(inGetString("s_masking_yn"), inGetString("default_masking_yn"));
			if (!StringUtils.isEmpty(defaultMaskingYn)) {
				secureUser.setApplyMasking("Y".equals(defaultMaskingYn));
			}

			// 사용자 Action 날짜 저장
			if (!Arrays.asList(ignoreSetDateURIList).contains(uri)) {
				secureUser.setUser_action_date(DateUtil.getCurrentDatetime());
			}

			setSecureUser(secureUser);
			
			WebUtils.setSessionAttribute(request, "SecureUser", secureUser);
		}
		
		if(dataBound != null) {
			dataBound.preDataBound(request, map);
		}
	}
	/**
	 * 날짜 저장 무시할 URI 목록
	 */
	private String[] ignoreSetDateURIList = {
		"/mmyy/mmyy0102/cnt",
		"/session/check",
		"/action/setDate",
		"/logout/limitMin",
		"/mmyy/mmyy010201/search"
	};
	
	/**
	 * JSON 생성
	 * 
	 * @param collectionObject
	 * @param exception 
	 * @return
	 */
	public ModelAndView resultToJSON(Object collectionObject, Exception exception) {
		// 페이징 일때(리스트) 데이터가 없으면 없다는 내용 팝업
		// 리스트 더보기가 있는지 여부로 판단
		if (collectionObject instanceof Map) {
			Map<String, Object> retObj = (Map<String, Object>) collectionObject;
			if (StringUtils.isNotBlank(inGetString("s_sort_key"))) {
				boolean isEmpty = false;
				for (String key : retObj.keySet()) {
					Object obj = retObj.get(key);
					if (obj instanceof List && isEmpty == false) {
						isEmpty = (obj == null || ((List) obj).size() == 0);
					}
				}
				// 메시지를 셋팅하지 않았으면, 결과없음 메시지 셋팅
				if (isEmpty && "N".equals(retObj.get("result_show_yn").toString())) {
					if("Y".equals(inGetString("no_result_show_yn", "Y"))) {
						retObj.put("result_msg", "검색된 결과가 없습니다.");
						retObj.put("result_show_yn", "Y");
					}
				}
				
				// 정렬방법 셋팅
				retObj.put("s_sort_key", inGetString("s_sort_key"));
				retObj.put("s_sort_method", inGetString("s_sort_method"));
			}
		}
		Gson gson = new GsonBuilder().setDateFormat(DateUtil.DB_DATE_STR).create();
		String result = gson.toJson(collectionObject);
		
		// 로그 저장
		if(responseLogger != null) {
			if(exception != null) { // 에러는 무조건 저장
				responseLogger.errorSave(getInput(), exception);
			} else {
				if(responseLogger.saveDB() && responseLogger.onlyError() == false && responseLogger.ignoreUri(getInput()) == false) {
					responseLogger.outSave(getInput(), result);
				}
			}
		}
		
		return new ModelAndView("common/ajaxResult", "result", result);
	}
	
	/**
	 * JSON 생성
	 * @param collectionObject
	 * @return
	 */
	public ModelAndView resultToJSON(Object collectionObject) {
		return resultToJSON(collectionObject, null);
	}
	
	/**
	 * 페이지에서 넘어온 필드 필수 값 체크
	 * @param notBlankField
	 */
	public void requiredFieldCheck(String... notBlankField) {
		// 필수 Param 체크
		for (String item : notBlankField) {
			if (StringUtils.isBlank(inGetString(item))) {
				throw new XCheckException("-100", "필수 Param에 값이 없습니다.(" + item + ")");
			}
		}
	}
	
	public LoginUser getLoginUser() {
		return loginUser;
	}

	public void setSecureUser(LoginUser loginUser) {
		this.loginUser = loginUser;
	}
	
	/**
	 * 로그인 사용자정보 가져옴(사이트마다 사용자 셋팅 정보는 다름)
	 * @return
	 */
	public SecureUser getSecureUser() {
		return (SecureUser) loginUser;
	}
	
	/**
	 * 입력데이터 trim
	 * 
	 * @param fieldName 
	 */
	public void trim(String... fieldName) {
		if (ArrayUtils.isEmpty(fieldName)) {
			fieldName = input.keySet().toArray(new String[] {});
		}

		for (String key : fieldName) {
			if (input.containsKey(key)) {
				Object val = input.get(key);
				
				if(val instanceof String[]) {	// 배열일 경우 요소 모두를 trim
					String[] valueArray = (String[]) val;
					String[] newArray = new String[valueArray.length];
					
					for(int i=0, n=valueArray.length; i<n; i++) {
						newArray[i] = StringUtils.trim(valueArray[i]);
					}
					
					input.put(key, newArray);
				} else if(val != null) {
					input.put(key, StringUtils.trim(val.toString()));
				}
			}
		}
	}
	
	/**
	 * 입력데이터에 값 삭제
	 * 
	 * @param symbol
	 *            삭제할 값
	 * @param fieldName
	 */
	public void removeSymbol(String symbol, String... fieldName) {
		if (ArrayUtils.isEmpty(fieldName)) {
			return;
		}

		for (String key : fieldName) {
			if (input.containsKey(key)) {
				Object val = input.get(key);

				if (val instanceof String[]) { // 배열일 경우 요소 모두를 remove
					String[] valueArray = (String[]) val;
					String[] newArray = new String[valueArray.length];

					for (int i = 0, n = valueArray.length; i < n; i++) {
						newArray[i] = StringUtils.remove(valueArray[i], symbol);
					}

					input.put(key, newArray);
				} else if (val != null) {
					input.put(key, StringUtils.remove(val.toString(), symbol));
				}
			}
		}
	}

	/**
	 * API 요청인지 확인.
	 * @return
	 */
	public boolean apiRequest() {
		return CodeDefine.CD_DATA_SOURCE_ERP_API.equals(inGetString("data_source_cd"));
	}

	/**
	 * CUST API 요청인지 확인.
	 * @return
	 */
	public boolean custApiRequest() {
		return CodeDefine.CD_DATA_SOURCE_ERP_CUST_API.equals(inGetString("data_source_cd"));
	}
	
	/**
	 * 입력데이터 모두 trim 처리
	 */
	public void trim() {
		trim(new String[] {});
	}

	//########################################################################
	/**
	 * DataSet에 request 에서 데이터를 셋팅할때 사이트 특성에 따라 셋팅할 항목들 셋팅
	 *
	 * @author JeongY.Eom
	 * @date 2014. 6. 21. 
	 * @time 오전 12:43:30
	 */
	public interface DataBound {
		void preDataBound(HttpServletRequest request, Map<String, Object> map);
		void postDataBound(HttpServletRequest request, Map<String, Object> map);
	}
}
// :)--
