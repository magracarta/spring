<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%--
사업자번호 필드 : s_cust_breg_no   
	### param 설명 ###
<jsp:param name="required_field" value="s_cust_breg_no"/>			==> 필수체크 할 필드 (value에 해당하는 name을 찾아서 required 속성 추가)
(팝업포함 검색조건)
<jsp:param name="cust_no_field_name" value="myCustNoFieldName"/>	==> 고객번호로 사용할 field name (필수)
<jsp:param name="execFuncName" value="fnMyExecFuncName"/>			==> 응답받을 function명
<jsp:param name="focusInFuncName" value="myFocusInFunc"/>			==> 포커스 인 됐을때 실행할 function명
<jsp:param name="focusInClearYn" value="N"/>						==> 포커스 인 내용 삭제 여부 (default "Y")
--%>
<c:set var="custBregRequiredField" value="${param.required_field}"/>
<c:set var="custBregCustNoFieldName" value="${param.cust_no_field_name}"/>
<c:set var="custBregExecFuncName" value="${param.execFuncName}"/>
<c:set var="custBregFocusInFuncName" value="${param.focusInFuncName}"/>
<c:set var="custBregFocusInClearYn" value="${empty param.focusInClearYn ? 'Y' : param.focusInClearYn}"/>
<script type="text/javascript">
	$(document).ready(function() {
		// 고객번호로 사용할 필드체크
		if("${custBregCustNoFieldName}" == "") {
			alert('jsp:param name="cust_no_field_name"의 value를 지정해주세요.');
		}
		
		// 엔터
		$("input[name=s_cust_breg_no]").keydown(function (key) {
	        if(key.keyCode == 13) {
	        	__goSearchCustBreg();
	        	__custBregSearchFormClear();
	        };
		});
		
		// 입력폼으로 포커스 인
		$("#s_cust_breg_no").focusin(function() {
			// 내용 삭제 여부
			if("${custBregFocusInClearYn}" == "Y") {
				__custBregSearchFormClear();
			}
			if("${custBregFocusInFuncName}" != "") {
				try {
					${custBregFocusInFuncName}(true);
				} catch(e) {
					alert("호출 페이지에서 ${custBregFocusInFuncName}() 함수를 구현해주세요.");
				}
			}
		});
		
		// 입력폼에서 포커스 아웃
		$("#s_cust_breg_no").focusout(function(e) {
			if(e.relatedTarget != null && e.relatedTarget.name != null && e.relatedTarget.name == '__custBreg_search_btn') {
				__goSearchCustBregClick();
			} else {
				__custBregSearchFormClear();
			}
		});
	});

	// 고객사업자조회 입력폼 초기화
	function __custBregSearchFormClear() {
		$M.clearValue({field:["s_cust_breg_no", "___cust_breg_name"]});
	}
	
	// 고객사업자조회 엔터
	function __goSearchCustBreg() {
		if($M.getValue("${custBregCustNoFieldName}") == "") {
			alert('고객번호를 지정 후 조회해주세요.');
			return false;
		}
		if($M.validation(null, {field:['s_cust_breg_no']}) == false) { 
			return;
		}
		var url = "/comp/comp0303/";
		var param = {
			"s_breg_no" : $M.getValue("s_cust_breg_no")
// 			, "cust_no" : $M.getValue("s_bcust_no")
			, "ctrl_next_page" : "common/ajaxResult"
		};
		$M.goNextPageAjax(url + $M.getValue("${custBregCustNoFieldName}"), $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#s_cust_breg_no").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							__custBregSearchFormClear();
							break;
						case 1 : 
							var getItem = list[0];
							$M.setValue("s_cust_breg_no", getItem.breg_no);
							$M.setValue("___cust_breg_name", getItem.breg_name);
							_goCustBregExecFunc(getItem);
							break;
						default :
							var _param = {
								"s_breg_no" : $M.getValue("s_cust_breg_no")
								, "s_cust_no" : $M.getValue("${custBregCustNoFieldName}")
							};
							openSearchBregSpecPanel('__fnSetCustBregInfo', $M.toGetParam(_param));
						break;
					}
				}
			}
		);
	}
	
	// 고객사업자조회 클릭
	function __goSearchCustBregClick() {
		if($M.getValue("${custBregCustNoFieldName}") == "") {
			alert('고객번호를 지정 후 조회해주세요.');
			return false;
		}
		var param = {
				"s_breg_no" : $M.removeHyphenFormat($M.getValue("s_cust_breg_no"))
				, "s_cust_no" : $M.getValue("${custBregCustNoFieldName}")
			};
		openSearchBregSpecPanel('__fnSetCustBregInfo', $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 고객사업자정보 세팅
	function __fnSetCustBregInfo(data) {
		if( ($M.nvl(data.breg_no, "")) != "" ) {
			$M.setValue("s_cust_breg_no", data.breg_no);			
			$M.setValue("___cust_breg_name", data.breg_name);
			_goCustBregExecFunc(data);
		}
	}
	
	// 조회 후 실행함수
	function _goCustBregExecFunc(data) {
		if("${custBregExecFuncName}" != "") {
			try {
				${custBregExecFuncName}(data);
			} catch(e) {
				alert("호출 페이지에서 ${custBregExecFuncName}(data) 함수를 구현해주세요.");
			}
		}
	}
	
	
</script>
<div class="input-group">
	<input type="text" id="s_cust_breg_no" name="s_cust_breg_no" class="form-control border-right-0 width100px" value=""  placeholder="사업자번호 / 업체명" alt="사업자번호 / 업체명" minlength="2" ${fn:contains(custBregRequiredField, 's_cust_breg_no') ? 'required="required"' : '' }>
	<button name="__custBreg_search_btn" type="button" class="btn btn-icon btn-primary-gra" onclick="__goSearchCustBregClick();"><i class="material-iconssearch"></i></button>
	<input type="text" id="___cust_breg_name" name="___cust_breg_name" class="form-control width160px ml5" value=""  placeholder="업체명" readonly="readonly" style="border-radius: 4px;">
</div>