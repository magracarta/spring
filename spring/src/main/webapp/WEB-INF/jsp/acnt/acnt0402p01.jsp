<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 위탁판매점월정산 > null > 장비미수명세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-12-22 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
			};
			var columnLayout = [
				{
					dataField : "machine_doc_no",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					headerText : "차주",
					dataField : "cust_name",
					width : "12%",
					style : "aui-center"
				},
				{
					headerText : "품명",
					dataField : "machine_name",
					width : "12%",
					style : "aui-center aui-popup"
				},
				{
					headerText : "출하일",
					dataField : "out_dt",
					width : "10%",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
				},
// 				{
// 					headerText : "차수",
// 					dataField : "",
// 					width : "3%",
// 					style : "aui-center",
// 				},
				{
					headerText : "구분",
					dataField : "cash_case_name",
					width : "6%",
					style : "aui-center",
				},
// 				{
// 					headerText : "구분",
// 					dataField : "machine_pay_type_name",
// 					width : "6%",
// 					style : "aui-center",
// 				},
				{
					headerText : "예정일",
					dataField : "plan_dt",
					width : "10%",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
				},
				{
					headerText : "예정금액",
					dataField : "plan_amt",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "미결재금",
					dataField : "miamount",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "확보미수",
					dataField : "deposit_amt",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					headerText : "미확보미수",
					dataField : "misu_amt",
// 					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText : "대리점주",
					headerText : "위탁판매점주",
					dataField : "org_mem_name",
					width : "7%",
					style : "aui-center",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
			// 발주내역 클릭시 -> 발주서상세 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_name" ) {
					if (event.item.machine_doc_no != "") {
						var params = {
							"machine_doc_no" : event.item.machine_doc_no
						};
						var popupOption = "";
						$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
					}
				}
			});
		}

		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->
			<div>
				<div class="title-wrap">
					<h4>${orgName}<span>&nbsp;장비미수명세</span></h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
<!-- /폼테이블-->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
