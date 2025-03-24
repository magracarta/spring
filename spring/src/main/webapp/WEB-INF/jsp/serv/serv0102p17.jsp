<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 부품내역 상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-16 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
	});

	// 닫기
	function fnClose() {
		window.close();
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			// 체크박스 출력 여부
			showRowCheckColumn : false,
			// 전체선택 체크박스 표시 여부
			editable : false
		};
		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				width : "20%",
				style : "aui-left",
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				width : "20%",
				style : "aui-left",
			},
			{
				headerText : "수량",
				dataField : "use_qty",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "단가",
				dataField : "unit_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "금액",
				dataField : "bill_amount",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
		
		$("#auiGrid").resize();
	}	

	</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<!-- 의견추가내역 -->
				<div class="title-wrap">
					<h4>부품내역 상세</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
				<!-- /의견추가내역 -->
				<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>