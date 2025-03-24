<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%-- 
부품번호 필드 : s_part_no
	### param 설명 ###
<jsp:param name="required_field" value="s_part_no"/> 					 ==> 필수체크 할 필드
(팝업포함 검색조건)
<jsp:param name="s_cust_name" value="(주)가온유압"/>						 ==> 매입처 (default "" => 전체)
<jsp:param name="s_part_group_name" value="Hydraulic Cylinder 유압실린더"/> ==> 부품그룹 (default "" => 전체)
<jsp:param name="s_part_mng_cd" value=""/> 								 ==> 부품구분 (default "" => 전체)
<jsp:param name="readonly_field" value="s_part_mng_cd"/>		 		 ==> 팝업 검색조건 readonly (default "" => readonly 없음)
																			 s_part_mng_cd : 부품구분
<jsp:param name="execFuncName" value="fnMyExecFuncName"/>				 ==> 응답받을 function명
<jsp:param name="focusInFuncName" value="myFocusInFunc"/>				 ==> 포커스 인 됐을때 실행할 function명
<jsp:param name="focusInClearYn" value="N"/>							==> 포커스 인 내용 삭제 여부 (default "Y")
--%>
<c:set var="partRequiredField" value="${param.required_field}"/>
<c:set var="partCustName" value="${param.s_cust_name}"/>
<c:set var="partGroupName" value="${param.s_part_group_name}"/>
<c:set var="partMngCd" value="${param.s_part_mng_cd}"/>
<c:set var="partOnlyWarehouseYn" value="${param.s_only_warehouse_yn}"/>
<c:set var="partWarehouseCd" value="${param.s_warehouse_cd}"/>
<c:set var="partReadOnlyField" value="${param.readonly_field}"/>
<c:set var="partExecFuncName" value="${param.execFuncName}"/>
<c:set var="partFocusInFuncName" value="${param.focusInFuncName}"/>
<c:set var="partFocusInClearYn" value="${empty param.focusInClearYn ? 'Y' : param.focusInClearYn}"/>
<script type="text/javascript">
	$(document).ready(function() {
		// 엔터
		$("input[name=s_part_no]").keydown(function (key) {
	        if(key.keyCode == 13) {
	        	__goSearchPart();
	        	__partSearchFormClear();
	        };
		});
		
		// 입력폼으로 포커스 인
		$("#s_part_no").focusin(function() {
			// 내용 삭제 여부
			if("${partFocusInClearYn}" == "Y") {
				__partSearchFormClear();
			}
			if("${partFocusInFuncName}" != "") {
				try {
					${partFocusInFuncName}(true);
				} catch(e) {
					alert("호출 페이지에서 ${partFocusInFuncName}() 함수를 구현해주세요.");
				}
			}
		});
		
		// 입력폼에서 포커스 아웃
		$("#s_part_no").focusout(function(e) {
			if(e.relatedTarget != null && e.relatedTarget.name != null && e.relatedTarget.name == "__part_search_btn") {
				__goSearchPartClick();
			} else {
				__partSearchFormClear();
			}
		});
	});

	// 부품조회 입력폼 초기화
	function __partSearchFormClear() {
		$M.clearValue({field:["s_part_no", "__part_name"]});
	}
	
	// 부품조회 엔터
	function __goSearchPart() {
		if($M.validation(null, {field:["s_part_no"]}) == false) { 
			return;
		}
		var url = "/comp/comp0601";
		var s_part_name = $M.getValue("s_part_no");
		var stock_mon = "${inputParam.s_current_mon}";
		var param = {
			"s_part_no" : s_part_name
			, "s_sort_key" : "tp.part_no"
			, "s_sort_method" : "desc"
			, "stock_mon" : stock_mon
			, "s_cust_name" : "${partCustName}"
			, "s_part_group_name" : "${partGroupName}"
			, "s_part_mng_cd" : "${partMngCd}"
			, "s_only_warehouse_yn" : "${partOnlyWarehouseYn}"
			, "s_warehouse_cd" : "${partWarehouseCd}"
			, "partReadOnlyField" : "${partReadOnlyField}"
		};
		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : "get"},
			function(result) {
				if(result.success) {
					$("#s_part_no").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							__partSearchFormClear();
							break;
						case 1 : 
							var getItem = list[0];
							$M.setValue("s_part_no", getItem.part_no);
							$M.setValue("__part_name", getItem.part_name);
							_goPartExecFunc(getItem);
							break;
						default :
							var _param = {
								"s_part_no" : s_part_name
								, "s_cust_name" : "${partCustName}"
								, "s_part_group_name" : "${partGroupName}"
								, "s_part_mng_cd" : "${partMngCd}"
								, "s_only_warehouse_yn" : "${partOnlyWarehouseYn}"
								, "s_warehouse_cd" : "${partWarehouseCd}"
								, "partReadOnlyField" : "${partReadOnlyField}"
							};
							openSearchPartPanel("__fnSetPartInfo", "N", $M.toGetParam(_param));
						break;
					}
				}
			}
		);
	}
	
	// 부품조회 클릭
	function __goSearchPartClick() {
		var param = {
			"s_part_no" : $M.getValue("s_part_no")
			, "s_cust_name" : "${partCustName}"
			, "s_part_group_name" : "${partGroupName}"
			, "s_part_mng_cd" : "${partMngCd}"
			, "s_only_warehouse_yn" : "${partOnlyWarehouseYn}"
			, "s_warehouse_cd" : "${partWarehouseCd}"
			, "partReadOnlyField" : "${partReadOnlyField}" 
		};
		openSearchPartPanel("__fnSetPartInfo", "N", $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 부품정보 세팅
	function __fnSetPartInfo(data) {
		if( ($M.nvl(data.part_no, "")) != "" ) {
			$M.setValue("s_part_no", data.part_no);			
			$M.setValue("__part_name", data.part_name);	
			_goPartExecFunc(data);
		};
	}
	
	// 조회 후 실행함수
	function _goPartExecFunc(data) {
		if("${partExecFuncName}" != "") {
			try {
				${partExecFuncName}(data);
			} catch(e) {
				alert("호출 페이지에서 ${partExecFuncName}(data) 함수를 구현해주세요.");
			}
		}
	}

</script>
<div class="input-group">
	<input type="text" id="s_part_no" name="s_part_no" class="form-control border-right-0 width160px" value=""  placeholder="부품번호 " alt="부품번호 " minlength="2" ${fn:contains(partRequiredField, 's_part_no') ? 'required="required"' : '' }>
	<button name="__part_search_btn" type="button" class="btn btn-icon btn-primary-gra" onclick="__goSearchPartClick();"><i class="material-iconssearch"></i></button>
	<input type="text" id="__part_name" name="__part_name" class="form-control width120px ml5" value=""  placeholder="부품명" readonly="readonly" style="border-radius: 4px;">
</div>