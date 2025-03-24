<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%--   
### 필드 설명 ###
모델명 필드 : s_machine_name
장비번호(hidden) : s_machine_plant_seq
### param 설명 ###
<jsp:param name="required_field" value="s_machine_name"/>											==> 필수체크 필드
(팝업포함 검색조건)
<jsp:param name="s_maker_cd" value="27"/>															==> 메이커 (default "" => 전체)
<jsp:param name="s_machine_type_cd" value="02"/>													==> 기종 (default "" => 전체)
<jsp:param name="s_sale_yn" value="Y"/>																==> 거래정지미포함여부 (default "Y" => 거래정지 미포함)
<jsp:param name="readonly_field" value="s_machine_name,s_maker_cd,s_machine_type_cd,s_sale_yn"/>	==> 팝업 검색조건 readonly (default "" => readonly 없음)
																										s_maker_cd : 메이커
																										s_machine_type_cd : 기종
																										s_sale_yn : 거래정지 미포함 여부
<jsp:param name="execFuncName" value="fnMyExecFuncName"/>											==> 응답받을 function명
<jsp:param name="focusInFuncName" value="myFocusInFunc"/>											==> 포커스 인 됐을때 실행할 function명
<jsp:param name="focusInClearYn" value="N"/>														==> 포커스 인 내용 삭제 여부 (default "Y")
--%>
<c:set var="machineRequiredField" value="${param.required_field}"/>
<c:set var="machineMakerCd" value="${param.s_maker_cd}"/>
<c:set var="machineTypeCd" value="${param.s_machine_type_cd}"/>
<c:set var="machineSaleYn" value="${empty param.s_sale_yn or param.s_sale_yn == 'Y' ? 'Y' : param.s_sale_yn}"/>
<c:set var="machineReadOnlyField" value="${param.readonly_field}"/>
<c:set var="machineExecFuncName" value="${param.execFuncName}"/>
<c:set var="machineFocusInFuncName" value="${param.focusInFuncName}"/>
<c:set var="machineFocusInClearYn" value="${empty param.focusInClearYn ? 'Y' : param.focusInClearYn}"/>
<script type="text/javascript">
	$(document).ready(function() {
		// 엔터
		$("input[name=s_machine_name]").keydown(function (key) {
	        if(key.keyCode == 13) {
	        	__goSearchMachine();
	        	__machineSearchFormClear();
	        };
		});
		
		// 입력폼으로 포커스 인
		$("#s_machine_name").focusin(function() {
			// 내용 삭제 여부
			if("${machineFocusInClearYn}" == "Y") {
				__machineSearchFormClear();
			}
			if("${machineFocusInFuncName}" != "") {
				try {
					${machineFocusInFuncName}(true);
				} catch(e) {
					alert("호출 페이지에서 ${machineFocusInFuncName}() 함수를 구현해주세요.");
				}
			}
		});
		
		// 입력폼에서 포커스 아웃
		$("#s_machine_name").focusout(function(e) {
			if(e.relatedTarget != null && e.relatedTarget.name != null && e.relatedTarget.name == '__machine_search_btn') {
				__goSearchMachineClick();
			} else {
				__machineSearchFormClear();
			}
		});
	});

	// 장비조회 입력폼 초기화
	function __machineSearchFormClear() {
		$M.clearValue({field:["s_machine_name", "s_machine_plant_seq"]});
	}
	
	// 장비조회 엔터
	function __goSearchMachine() {
		if($M.validation(null, {field:['s_machine_name']}) == false) { 
			return;
		}
		var url = "/comp/comp0501";
		var s_machine_name = $M.getValue("s_machine_name");
		var param = {
			"s_machine_name" : s_machine_name
			, "s_maker_cd" : "${machineMakerCd}"
			, "s_machine_type_cd" : "${machineTypeCd}"
			, "s_sale_yn" : "${machineSaleYn}"
			, "machineReadOnlyField" : "${machineReadOnlyField}"
		};
		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#s_machine_name").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							__machineSearchFormClear();
							break;
						case 1 : 
							var getItem = list[0];
							$M.setValue("s_machine_name", getItem.machine_name);
							$M.setValue("s_machine_plant_seq", getItem.machine_plant_seq);
							_goMachineExecFunc(getItem);
							break;
						default :
							openSearchModelPanel('__fnSetMachineInfo', 'N', $M.toGetParam(param));
						break;
					}
				}
			}
		);
	}
	
	// 장비조회 클릭
	function __goSearchMachineClick() {
		var param = {
			"s_machine_name" : $M.getValue("s_machine_name")
			, "s_maker_cd" : "${machineMakerCd}"
			, "s_machine_type_cd" : "${machineTypeCd}"
			, "s_sale_yn" : "${machineSaleYn}"
			, "machineReadOnlyField" : "${machineReadOnlyField}"
		};
		openSearchModelPanel('__fnSetMachineInfo', 'N', $M.toGetParam(param));
	}
	
	// 장비조회 팝업창에서 받아온 정보 세팅
	function __fnSetMachineInfo(data) {
		if( ($M.nvl(data.machine_name, "")) != "" ) {
			$M.setValue("s_machine_name", data.machine_name);
			$M.setValue("s_machine_plant_seq", data.machine_plant_seq);
			_goMachineExecFunc(data);
		};
	}

	// 조회 후 실행함수
	function _goMachineExecFunc(data) {
		if("${machineExecFuncName}" != "") {
			try {
				${machineExecFuncName}(data);
			} catch(e) {
				alert("호출 페이지에서 ${machineExecFuncName}(data) 함수를 구현해주세요.");
			}
		}
	}
	

</script>
<div class="input-group">
	<input type="text" id="s_machine_name" name="s_machine_name" class="form-control border-right-0 width160px" value=""  placeholder="모델명" alt="모델명" minlength="2" ${fn:contains(machineRequiredField, 's_machine_name') ? 'required="required"' : '' }>
	<input type="hidden" id="s_machine_plant_seq" name="s_machine_plant_seq" value="" >
	<button name="__machine_search_btn" type="button" class="btn btn-icon btn-primary-gra" onclick="__goSearchMachineClick();"><i class="material-iconssearch"></i></button>
</div>