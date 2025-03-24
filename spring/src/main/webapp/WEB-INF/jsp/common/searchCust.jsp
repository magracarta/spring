<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%--
고객번호 필드 : s_cust_no   
	### param 설명 ###
<jsp:param name="required_field" value="s_cust_no"/>		==> 필수체크 할 필드 (value에 해당하는 name을 찾아서 required 속성 추가)
(팝업포함 검색조건)
<jsp:param name="execFuncName" value="fnMyExecFuncName"/>	==> 응답받을 function명
<jsp:param name="focusInFuncName" value="myFocusInFunc"/>	==> 포커스 인 됐을때 실행할 function명
<jsp:param name="focusInClearYn" value="N"/>				==> 포커스 인 내용 삭제 여부 (default "Y")
--%>
<c:set var="custRequiredField" value="${param.required_field}"/>
<c:set var="custExecFuncName" value="${param.execFuncName}"/>
<c:set var="custFocusInFuncName" value="${param.focusInFuncName}"/>
<c:set var="custFocusInClearYn" value="${empty param.focusInClearYn ? 'Y' : param.focusInClearYn}"/>
<script type="text/javascript">
	$(document).ready(function() {
		// 엔터
		$("input[name=s_cust_no]").keydown(function (key) {
	        if(key.keyCode == 13) {
	        	__goSearchCust();
	        	__custSearchFormClear();
	        };
		});
		
		// 입력폼으로 포커스 인
		$("#s_cust_no").focusin(function() {
			// 내용 삭제 여부
			if("${custFocusInClearYn}" == "Y") {
				__custSearchFormClear();
			}
			if("${custFocusInFuncName}" != "") {
				try {
					${custFocusInFuncName}(true);
				} catch(e) {
					alert("호출 페이지에서 ${custFocusInFuncName}() 함수를 구현해주세요.");
				}
			}
		});
		
		// 입력폼에서 포커스 아웃
		$("#s_cust_no").focusout(function(e) {
			if(e.relatedTarget != null && e.relatedTarget.name != null && e.relatedTarget.name == '__cust_search_btn') {
				__goSearchCustClick();
			} else {
				__custSearchFormClear();
			}
		});
	});

	// 고객조회 입력폼 초기화
	function __custSearchFormClear() {
		$M.clearValue({field:["s_cust_no", "___cust_name"]});
	}
	
	// 고객조회 엔터
	function __goSearchCust() {
		if($M.validation(null, {field:['s_cust_no']}) == false) { 
			return;
		}
		var url = "/comp/comp0301";
		var param = {
			"s_cust_no" : $M.getValue("s_cust_no")
		};
		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#s_cust_no").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							__custSearchFormClear();
							break;
						case 1 : 
							var getItem = list[0];
							$M.setValue("s_cust_no", getItem.cust_no);
							$M.setValue("___cust_name", getItem.real_cust_name);
							_goCustExecFunc(getItem);
							break;
						default :
							openSearchCustPanel('__fnSetCustInfo', $M.toGetParam(param));
						break;
					}
				}
			}
		);
	}
	
	// 고객조회 클릭
	function __goSearchCustClick() {
		var param = {
				"s_cust_no" : $M.getValue("s_cust_no")
			};
		openSearchCustPanel('__fnSetCustInfo', $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 고객정보 세팅
	function __fnSetCustInfo(data) {
		if( ($M.nvl(data.cust_no, "")) != "" ) {
			$M.setValue("s_cust_no", data.cust_no);			
			$M.setValue("___cust_name", data.real_cust_name);
			_goCustExecFunc(data);
		}
	}
	
	// 조회 후 실행함수
	function _goCustExecFunc(data) {
		if("${custExecFuncName}" != "") {
			try {
				${custExecFuncName}(data);
			} catch(e) {
				alert("호출 페이지에서 ${custExecFuncName}(data) 함수를 구현해주세요.");
			}
		}
	}
	
</script>
<div class="input-group">
	<input type="text" id="s_cust_no" name="s_cust_no" class="form-control border-right-0 width140px" value=""  placeholder="고객번호 / 고객명" alt="고객번호 / 고객명" minlength="2" ${fn:contains(custRequiredField, 's_cust_no') ? 'required="required"' : '' }>
	<button name="__cust_search_btn" type="button" class="btn btn-icon btn-primary-gra" onclick="__goSearchCustClick();"><i class="material-iconssearch"></i></button>
	<input type="text" id="___cust_name" name="___cust_name" class="form-control width160px ml5" value=""  placeholder="고객명" readonly="readonly" style="border-radius: 4px;">
</div>