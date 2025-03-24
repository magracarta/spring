<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 영업 > 장비어테치먼트관리 > null > 계약품의서 동기화
-- 작성자 : 황빛찬
-- 최초 작성일 : 2022-12-08 17:39:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
	
		$(document).ready(function(){
			createAUIGrid();
			goSearch();
		});
		
		// 마스킹 체크시 조회
		function goSearch() {
			var param = {
				"machine_plant_seq" : "${inputParam.machine_plant_seq}",
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// 체크박스 출력 여부
				showRowCheckColumn: true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox: true,
				height : 565,
				// rowStyleFunction : function(rowIndex, item) {
				// 	var style = "";
				// 	if (item.aui_status_cd !== "") {
				// 		if(item.aui_status_cd == "D") { // 기본
				// 			style = "aui-status-default";
				// 		} else if(item.aui_status_cd == "R") {
				// 			style = "aui-status-reject-or-urgent";
				// 		}
				// 	}
				// 	return style;
				// }
			};
			var columnLayout = [
				{
					dataField: "machine_plant_seq",
					visible : false
				},
				{
					headerText : "등록일자",
					dataField : "doc_dt",
					dataType : "date",
					width : "80",
					minWidth : "70",
					style : "aui-center",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					width : "80",
					minWidth : "80",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value.substring(4, 11);
					},
					style : "aui-center aui-popup"
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					width : "110",
					minWidth : "110",
					style : "aui-center"
				},
				{
					headerText : "상태",
					dataField : "machine_doc_status_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{
					headerText : "담당자",
					dataField : "doc_mem_name",
					width : "80",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "100",
					minWidth : "90",
					style : "aui-center"
				},
				{
					headerText : "변경될 부품정보",
					dataField : "part_info",
					width : "700",
					minWidth : "100",
					style : "aui-left"
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event){

				// 계약 품의서 팝업 호출
				if(event.dataField == "machine_doc_no") {
					var param = {
						machine_doc_no : event.item.machine_doc_no,
					}
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});

			$("#auiGrid").resize();
		}
		
		// 팝업 닫기
		function fnClose() {
			window.close();
		}

		// 적용
		function goApply() {
			if (confirm("변경된 부품목록 기준으로 선택한 품의서 어테치먼트에 추가/삭제가 진행됩니다.\n어테치먼트계 및 품의서 금액은 동기화 대상이 아닙니다.\n정말 어테치먼트 동기화를 진행 하시겠습니까 ?") == false) {
				return false;
			}

			var gridData = AUIGrid.getCheckedRowItems(auiGrid);

			var machineDocNoArr = [];
			for (var i = 0; i < gridData.length; i++) {
				machineDocNoArr.push(gridData[i].item.machine_doc_no);
			}

			var param = {
				machine_doc_no_str : $M.getArrStr(machineDocNoArr, {isEmpty : true}),
				machine_plant_seq : $M.getValue("machine_plant_seq")
			}

			$M.goNextPageAjax("/sale/syncDocProcess", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
			);
		}
	
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="${inputParam.machine_plant_seq}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            <button type="button" class="btn btn-icon"></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>계약품의서목록</h4>
					<div class="right">
						<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
						<div class="form-check form-check-inline">
							<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" onchange="javascript:goSearch()">
							<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
						</div>
						</c:if>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>				
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>