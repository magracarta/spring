<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%--   
### 필드 설명 ###
직원ID : s_web_id
직원명 : ___mem_name
직원번호(hidden) : s_mem_no
### param 설명 ###
<jsp:param name="required_field" value="s_web_id"/>											==> 필수체크 할 필드 (value에 해당하는 name을 찾아서 required 속성 추가)
(팝업포함 검색조건)
<jsp:param name="s_org_code" value="3000"/>													==> 조직코드 (default "" => 전체)
<jsp:param name="s_work_status_cd" value="01"/>												==> 직원 상태코드 [ 01(default) : 재직, 02 : 휴직, 03 : 파견, 04 : 퇴직, 전체는 팝업에서 ]
<jsp:param name="readonly_field" value="s_org_code,s_mem_name,s_hp_no,s_work_status_cd"/>	==> 팝업 검색조건 readonly (default "" => readonly 없음)
																								s_org_code : 부서
																								s_work_status_cd : 재직상태
<jsp:param name="execFuncName" value="fnMyExecFuncName"/>									==> 응답받을 function명
<jsp:param name="focusInFuncName" value="myFocusInFunc"/>									==> 포커스 인 됐을때 실행할 function명
<jsp:param name="focusInClearYn" value="N"/>												==> 포커스 인 내용 삭제 여부 (default "Y")
--%>
<c:set var="memRequiredField" value="${param.required_field}"/>
<c:set var="memOrgCode" value="${param.s_org_code}"/>
<c:set var="memWorkStatusCd" value="${empty param.s_work_status_cd ? '01' : param.s_work_status_cd}"/>
<c:set var="memReadOnlyField" value="${param.readonly_field}"/>
<c:set var="memExecFuncName" value="${param.execFuncName}"/>
<c:set var="memFocusInFuncName" value="${param.focusInFuncName}"/>
<c:set var="memFocusInClearYn" value="${empty param.focusInClearYn ? 'Y' : param.focusInClearYn}"/>
<script type="text/javascript">
	$(document).ready(function() {
		// 엔터
		$("input[name=s_web_id]").keydown(function (key) {
	        if(key.keyCode == 13) {
	        	__goSearchMember();
	        	__memSearchFormClear();
	        };
		});
		
		// 입력폼으로 포커스 인
		$("#s_web_id").focusin(function() {
			// 내용 삭제 여부
			if("${memFocusInClearYn}" == "Y") {
				__memSearchFormClear();
			}
			// 실행함수
			if("${memFocusInFuncName}" != "") {
				try {
					${memFocusInFuncName}(true);
				} catch(e) {
					alert("호출 페이지에서 ${memFocusInFuncName}() 함수를 구현해주세요.");
				}
			}
		});
		
		// 입력폼에서 포커스 아웃
		$("#s_web_id").focusout(function(e) {
			if(e.relatedTarget != null && e.relatedTarget.name != null && e.relatedTarget.name == '__mem_search_btn') {
				__goSearchMemberClick();
			} else {
				__memSearchFormClear();
			}
		});
	});

	// 직원조회 입력폼 초기화
	function __memSearchFormClear() {
		$M.clearValue({field:["s_web_id", "___mem_name", "s_mem_no"]});
	}
	
	// 직원조회 엔터
	function __goSearchMember() {
		if($M.validation(null, {field:['s_web_id']}) == false) { 
			return;
		}
		var url = "/comp/comp0401";
		var param = {
			"s_mem_name" : $M.getValue("s_web_id")
			, "s_org_code" : "${memOrgCode}"
			, "s_work_status_cd" : "${memWorkStatusCd}"
			, "memReadOnlyField" : "${memReadOnlyField}"
		};
		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#s_web_id").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							__memSearchFormClear();
							break;
						case 1 : 
							var getItem = list[0];
							$M.setValue("s_web_id", getItem.web_id);
							$M.setValue("___mem_name", getItem.mem_name);
							$M.setValue("s_mem_no", getItem.mem_no);
							_goMemExecFunc(getItem);
							break;
						default :
							openSearchMemberPanel('__fnSetMemInfo', $M.toGetParam(param));
						break;
					}
				}
			}
		);
	}
	
	// 직원조회 클릭
	function __goSearchMemberClick() {
		var param = {
				"s_mem_name" : $M.getValue("s_web_id")
				, "s_org_code" : "${memOrgCode}"
				, "s_work_status_cd" : "${memWorkStatusCd}"
				, "memReadOnlyField" : "${memReadOnlyField}"
			};
		openSearchMemberPanel('__fnSetMemInfo', $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 직원정보 세팅
	function __fnSetMemInfo(data) {
		if( ($M.nvl(data.mem_no, "")) != "" ) {
			$M.setValue("s_web_id", data.web_id);			
			$M.setValue("___mem_name", data.mem_name);
			$M.setValue("s_mem_no", data.mem_no);
			_goMemExecFunc(data);
		}
	}
	
	// 조회 후 실행함수
	function _goMemExecFunc(data) {
		if("${memExecFuncName}" != "") {
			try {
				${memExecFuncName}(data);
			} catch(e) {
				alert("호출 페이지에서 ${memExecFuncName}(data) 함수를 구현해주세요.");
			}
		}
	}
	
</script>
<div class="input-group">
	<input type="text" id="s_web_id" name="s_web_id" class="form-control border-right-0 width120px" value=""  placeholder="아이디 / 직원번호 / 직원명" alt="아이디 / 직원번호 / 직원명" minlength="2" ${fn:contains(memRequiredField, 's_web_id') ? 'required="required"' : '' }>
	<input type="hidden" id="s_mem_no" name="s_mem_no" value="" >
	<button name="__mem_search_btn" type="button" class="btn btn-icon btn-primary-gra" onclick="__goSearchMemberClick();"><i class="material-iconssearch"></i></button>
	<input type="text" id="___mem_name" name="___mem_name" class="form-control width70px ml5" value=""  placeholder="성명" readonly="readonly" style="border-radius: 4px;">
</div>