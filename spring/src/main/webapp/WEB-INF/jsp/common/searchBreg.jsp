<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%--
사업자번호 필드 : s_breg_no   
	### param 설명 ###
<jsp:param name="required_field" value="s_breg_no"/>										==> 필수체크 할 필드 (value에 해당하는 name을 찾아서 required 속성 추가)
(팝업포함 검색조건)
<jsp:param name="s_breg_rep_name" value=""/>												==> 대표자명 (default "" => 전체)
<jsp:param name="s_breg_type_cd" value=""/>													==> 사업자구분 [default "" => 전체, PER : 주민번호, COR : 법인, GTAX : 개인]
<jsp:param name="readonly_field" value="s_breg_rep_name,s_breg_type_cd"/>	==> 팝업 검색조건 readonly (default "" => readonly 없음)
																								s_breg_rep_name : 대표자명
																								s_breg_type_cd : 사업자구분
<jsp:param name="execFuncName" value="fnMyExecFuncName"/>									==> 응답받을 function명
<jsp:param name="focusInFuncName" value="myFocusInFunc"/>									==> 포커스 인 됐을때 실행할 function명
<jsp:param name="focusInClearYn" value="N"/>												==> 포커스 인 내용 삭제 여부 (default "Y")
--%>
<c:set var="bregRequiredField" value="${param.required_field}"/>
<c:set var="bregRepName" value="${param.s_breg_rep_name}"/>
<c:set var="bregTypeCd" value="${param.s_breg_type_cd}"/>
<c:set var="bregReadOnlyField" value="${param.readonly_field}"/>
<c:set var="bregExecFuncName" value="${param.execFuncName}"/>
<c:set var="bregFocusInFuncName" value="${param.focusInFuncName}"/>
<c:set var="bregFocusInClearYn" value="${empty param.focusInClearYn ? 'Y' : param.focusInClearYn}"/>
<script type="text/javascript">
	$(document).ready(function() {
		// 엔터
		$("input[name=s_breg_no]").keydown(function (key) {
	        if(key.keyCode == 13) {
	        	__goSearchbreg();
	        	__bregSearchFormClear();
	        };
		});
		
		// 입력폼으로 포커스 인
		$("#s_breg_no").focusin(function() {
			// 내용 삭제 여부
			if("${bregFocusInClearYn}" == "Y") {
				__bregSearchFormClear();
			}
			if("${bregFocusInFuncName}" != "") {
				try {
					${bregFocusInFuncName}(true);
				} catch(e) {
					alert("호출 페이지에서 ${bregFocusInFuncName}() 함수를 구현해주세요.");
				}
			}
		});
		
		// 입력폼에서 포커스 아웃
		$("#s_breg_no").focusout(function(e) {
			if(e.relatedTarget != null && e.relatedTarget.name != null && e.relatedTarget.name == '__breg_search_btn') {
				__goSearchbregClick();
			} else {
				__bregSearchFormClear();
			}
		});
	});

	// 사업자조회 입력폼 초기화
	function __bregSearchFormClear() {
		$M.clearValue({field:["s_breg_no", "___breg_name"]});
	}
	
	// 사업자조회 엔터
	function __goSearchbreg() {
		if($M.validation(null, {field:['s_breg_no']}) == false) { 
			return;
		}
		var url = "/comp/comp0302";
		var param = {
			"s_breg_no" : $M.getValue("s_breg_no")
			, "s_breg_rep_name" : "${bregRepName}"
			, "s_breg_type_cd" : "${bregTypeCd}"
			, "bregReadOnlyField" : "${bregReadOnlyField}"
		};
		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#s_breg_no").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							__bregSearchFormClear();
							break;
						case 1 : 
							var getItem = list[0];
							$M.setValue("s_breg_no", getItem.breg_no);
							$M.setValue("___breg_name", getItem.breg_name);
							_gobregExecFunc(getItem);
							break;
						default :
							openSearchBregInfoPanel('__fnSetbregInfo', $M.toGetParam(param));
						break;
					}
				}
			}
		);
	}
	
	// 사업자조회 클릭
	function __goSearchbregClick() {
		var param = {
				"s_breg_no" : $M.removeHyphenFormat($M.getValue("s_breg_no"))
				, "s_breg_rep_name" : "${bregRepName}"
				, "s_breg_type_cd" : "${bregTypeCd}"
				, "bregReadOnlyField" : "${bregReadOnlyField}"
			};
		openSearchBregInfoPanel('__fnSetbregInfo', $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 사업자정보 세팅
	function __fnSetbregInfo(data) {
		if( ($M.nvl(data.breg_no, "")) != "" ) {
			$M.setValue("s_breg_no", data.breg_no);			
			$M.setValue("___breg_name", data.breg_name);
			_gobregExecFunc(data);
		}
	}
	
	// 조회 후 실행함수
	function _gobregExecFunc(data) {
		if("${bregExecFuncName}" != "") {
			try {
				${bregExecFuncName}(data);
			} catch(e) {
				alert("호출 페이지에서 ${bregExecFuncName}(data) 함수를 구현해주세요.");
			}
		}
	}
	
</script>
<div class="input-group">
	<input type="text" id="s_breg_no" name="s_breg_no" class="form-control border-right-0 width100px " value=""  placeholder="사업자번호 / 업체명" alt="사업자번호 / 업체명" minlength="2" ${fn:contains(bregRequiredField, 's_breg_no') ? 'required="required"' : '' }>
	<button name="__breg_search_btn" type="button" class="btn btn-icon btn-primary-gra" onclick="__goSearchbregClick();"><i class="material-iconssearch"></i></button>
	<input type="text" id="___breg_name" name="___breg_name" class="form-control width160px ml5" value=""  placeholder="업체명" readonly="readonly" style="border-radius: 4px;">
</div>