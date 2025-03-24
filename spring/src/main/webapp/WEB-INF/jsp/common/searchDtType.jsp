<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%--   
### 기능 설명 ###
날짜 검색시 기본 날짜를 셋팅해줌
### param 설명 ###
<jsp:param name="st_field_name" value="s_start_dt"/>	==> 생략시 s_start_dt	
<jsp:param name="ed_field_name" value="e_end_dt"/>	==> 생략시 s_end_dt
<jsp:param name="click_exec_yn" value="Y"/>	==> 생략시 N(선택후 아무작업 안함)
<jsp:param name="exec_func_name" value="goSearch()"/>	==> 생략시 goSearch()
--%>
<c:set var="s_start_dt" value="${empty param.st_field_name ? 's_start_dt' : param.st_field_name}"/>
<c:set var="s_end_dt" value="${empty param.ed_field_name ? 's_end_dt' : param.ed_field_name}"/>
<c:set var="clickExecYn" value="${empty param.click_exec_yn ? 'N' : param.click_exec_yn}"/>
<c:set var="execFuncName" value="${empty param.exec_func_name ? 'goSearch();' : param.exec_func_name}"/><%--완전한 메소드명 뒤에 ; 포함 --%>
<script type="text/javascript">

	$(document).mouseup(function(e) {
	    var container = $(".dev_search_dt_type_cd_str_div");
	    if (!container.is(e.target) && container.has(e.target).length === 0) {
	    	if (container.is(":visible")) {
	    		container.toggleClass('dpn');
	    	}
	    }
	});

	var pre_search_st_dt = '${searchDtMap.pre_search_st_dt}';	// 직전조회 시작일
	var pre_search_ed_dt = '${searchDtMap.pre_search_ed_dt}';	// 직전조회 종료일

	$(document).ready(function() {
		$('.dev_popover_activator').click(function(event) {
			var container = $('.dev_search_dt_type_cd_str_div');
			container.toggleClass('dpn');
        });
		
		// 엔터
		$M.setValue("${s_start_dt}", "${searchDtMap.s_start_dt}");
		$M.setValue("${s_end_dt}", "${searchDtMap.s_end_dt}");

		$('input[type=radio][name=_s_search_dt_type_cd]').click(function(event) {
			console.log(event);
			console.log('CTRL pressed during click:', event.ctrlKey);
			var today = "${inputParam.s_current_dt}";
			var st = today;
			var ed = $M.getValue("${s_end_dt}");
	        if (ed == "") {
	        	ed = today;
	        }
	        // 당일 기준일 경우, 당일 기준이 아닌 끝날자 기준일 경우 주석처리
	        if (event.ctrlKey == false) {
	        	ed = today;
	        }
	        
	        var edDate = $M.toDate(ed);
	        
	        var s_val = this.value;
	        var dt_cnt = $M.toNum(s_val.substr(0, 1));
	        var dt_type = s_val.substr(1, 2);

	        switch(s_val) {
				case 'BB' : st = pre_search_st_dt; ed = pre_search_ed_dt; break;
				case '00' : st = ""; ed = ""; break;
				case '0D' : st = ed; break;
				case 'BD' : st =  $M.addDates(edDate, -1);
							ed =  st; break;
				case '0M' : st = ed.substr(0, 6) || '01'; break;
				default :
					switch(dt_type) {
						case 'W' : st = $M.addDates(edDate, -7 * dt_cnt); break;
						case 'M' : st = $M.addMonths(edDate, -1 * dt_cnt); break;
						case 'Y' : st = $M.addMonths(edDate, -12 * dt_cnt); break;
						default : st =  ed.substr(0, 6) || '01'; break;
					}
					break;
	        }
		    $M.setValue("${s_start_dt}", st);
	        $M.setValue("${s_end_dt}", ed);

	        $M.setValue("s_search_dt_type_cd", this.value);

	        $('.dev_search_dt_type_cd_str_div').toggleClass('dpn');

			<c:if test="${clickExecYn eq 'Y'}">${execFuncName}</c:if>
		});
	});

	/**
	 * 검색조건에 따른 추가
	 * @param params 전달데이터
	 * @param startFieldName 시작일자 필드명
	 * @param endFieldName 종료일자 필드명
	 * @private
	 */
	function _fnAddSearchDt(params, startFieldName, endFieldName) {
		params.s_search_dt_type_cd = $M.getValue("s_search_dt_type_cd");
		params.s_search_st_dt = $M.getValue(startFieldName);
		params.s_search_ed_dt = $M.getValue(endFieldName);
		params.this_page = this_page;

		if(params.s_search_dt_type_cd == 'BB') {
			pre_search_st_dt = params.s_search_st_dt;
			pre_search_ed_dt = params.s_search_ed_dt;
		}
	}
</script>
<input type="hidden" id="s_search_dt_type_cd" name="s_search_dt_type_cd" value="${searchDtMap.search_dt_type_cd }"/>
<div class="dev_search_dt_type_cd_str_wrap">
	<button type="button" class="ui-datepicker-trigger btn btn-primary-gra dev_popover_activator"><i class="material-iconsmore_horiz text-dark" ></i></button>
	<div class="con-info dev_search_dt_type_cd_str_div dpn" title="컨트롤 키를 누른채 클릭하면 끝 날짜 기준으로 설정됩니다." style="transform: translateX(0) translateY(0);">
	<c:forEach items="${codeMap['SEARCH_DT_TYPE']}" var="item">  
		 <c:if test="${fn:contains(searchDtMap.search_dt_type_cd_str, item.code_value)}">
		<label><input type="radio" name="_s_search_dt_type_cd" value="${item.code_value }" ${item.code_value eq searchDtMap.search_dt_type_cd ? 'checked' : '' }>${item.code_name }</label></c:if>
	</c:forEach>
	</div>
</div>