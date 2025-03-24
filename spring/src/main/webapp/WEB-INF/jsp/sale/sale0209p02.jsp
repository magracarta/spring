<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 생산발주산출수량 > 실제판매비율 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-07 17:06:50
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			createAUIGrid();
		});

		// 닫기
		function fnClose() {
			window.close();
		}

		// 그리드 생성
		function createAUIGrid() {

			const gridPros = {
				rowIdField : "_$uid",
				rowStyleFunction : function(rowIndex, item) {
					// 단종된 모델인 경우 컬럼색 변경
					if (item.sale_yn === "N" || item.use_yn === "N") {
						return "aui-as-tot-row-style";
					}
				}
			};

			const columnLayout = [
				{
					headerText : "모델명",
					dataField : "machine_name",
					style : "aui-center"
				},
				{
					headerText : "비율",
					dataField : "rate",
					width : "120",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value + "%";
					},
				},
				{
					headerText : "규격",
					dataField : "machine_sub_type_name",
					width : "120",
					style : "aui-center",
				},
				{
					dataField : "machine_sub_type_cd",
					visible : false
				},
				{
					dataField : "machine_plant_seq",
					visible : false
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
        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<!-- 컨텐츠 영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<h4>실제판매비율(${inputParam.s_start_year}~${inputParam.s_end_year})</h4>
			</div>
			<!-- 그리드 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: auto;"></div>
			<!-- 우측 하단 버튼 영역 -->
			<div class="btn-group mt5">
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