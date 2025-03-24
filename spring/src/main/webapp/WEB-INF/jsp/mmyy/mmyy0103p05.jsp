<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지(관리계정) 보이기/숨기기 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-06-26 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">

	$(document).ready(function() {
		createAUIGrid();
	});
	
	function goLarge() {
		var param = {
			s_mem_no : "${inputParam.s_mem_no}",
			s_work_dt : "${inputParam.s_work_dt}",
			s_work_text : "${bean.work_text}"
		}
		var poppupOption = "";
		var url = '/mmyy/mmyy010301p01';
		$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
	}
		
	function createAUIGrid() {
		var gridPros = {
			// singleRow 선택모드
			editBeginMode : "click", // doubleClick
			/* selectionMode : "singleRow", */
			enableFilter :true,
			rowStyleFunction : function(rowIndex, item) {
				if(item.view_yn == "N") {
					return "aui-status-reject-or-urgent";
				}
			},
		};
		
		var columnLayout = [
			{
				headerText : "부서명", 
				dataField : "org_name", 
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "직급",
				dataField : "job_name", 
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "성명", 
				dataField : "view_mem_name", 
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{ 
				headerText : "핸드폰", 
				dataField : "hp_no", 
				style : "aui-center",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
		            return fnGetHPNum(value);
				},
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				dataField : "view_mem_no",
				visible : false
			},
			{
				dataField : "view_yn",
				visible : false
			},
			{
				dataField : "mem_no",
				visible : false
			}
		]
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var param = {
					"mem_no" : event.item.mem_no,
					"view_mem_no" : event.item.view_mem_no
				};
				param["view_yn"] = event.item.view_yn == "Y" ? "N" : "Y";
				$M.goNextPageAjax(this_page, $M.toGetParam(param), {method : "POST"},
						function(result) {
							if(result.success) {
								var viewYn = event.item.view_yn == "Y" ? "N" : "Y";
								AUIGrid.updateRow(auiGrid, { "view_yn" : viewYn }, event.rowIndex);
								AUIGrid.resetUpdatedItems(auiGrid);
							};
						}
					);
				
		});
		$("#auiGrid").resize();
	}
	
	//팝업 끄기
	function fnClose() {
		window.close(); 
	}
	
</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
			<h4>보기/숨기기 설정 - 클릭시 자동 설정됩니다. <c:if test="${page.fnc.F01588_001 eq 'Y'}">- 센터 매니저/직장은 하위직급이 기본세팅됩니다.</c:if></h4>
				<div id="auiGrid" style="margin-top: 5px; height: 455px;"></div>
				
				<div class="btn-group mt5">					
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
				</div>
			
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>