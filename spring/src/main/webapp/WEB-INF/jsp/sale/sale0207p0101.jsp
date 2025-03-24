<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비원가대장 > 장비원가상세 > 장비원가 변경내역
-- 작성자 : 김경빈
-- 최초 작성일 : 2022-12-16 16:22:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		let auiGrid;

		$(document).ready(function() {
			createAUIGrid();
            goSearch();
		});

        function goSearch() {
            let param = {
                machine_plant_seq : ${inputParam.machine_plant_seq},
            }
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
                function(result) {
					AUIGrid.setGridData(auiGrid, result);
                });
        }

		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			let gridPros = {
				rowIdField: "_$uid",
				height: 400,
				editable: false,
			}

			let columnLayout = [
				{
					headerText : "변경일시",
					dataField : "change_dt",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "변경전",
					children: [
						{
							headerText: "구분",
							dataField : "before_gubun",
							width : "9%",
							style : "aui-left",
						},
						{
							headerText: "항목명",
							dataField : "before_name",
							width : "14%",
							style : "aui-left",
						},
						{
							headerText: "금액",
							dataField : "before_price",
							width : "8%",
							dataType : "numeric",
							style : "aui-right",
						}
					]
				},
				{
					headerText : "변경후",
					children: [
						{
							headerText: "구분",
							dataField : "after_gubun",
							width : "9%",
							style : "aui-left",
						},
						{
							headerText: "항목명",
							dataField : "after_name",
							width : "14%",
							styleFunction : function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (AUIGrid.getCellValue(auiGrid, rowIndex, "before_name") === value) {
									// 변경전과 변경후가 모두 같으면 삭제된 건
									if (AUIGrid.getCellValue(auiGrid, rowIndex, "before_price") === AUIGrid.getCellValue(auiGrid, rowIndex, "after_price")) {
										return "aui-color-red-left-line";
									}
									return "aui-left";
								} else {
									return "aui-color-red-left";
								}
							}
						},
						{
							headerText: "금액",
							dataField : "after_price",
							width : "8%",
							dataType : "numeric",
							styleFunction : function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (AUIGrid.getCellValue(auiGrid, rowIndex, "before_price") === value) {
									// 변경전과 변경후가 모두 같으면 삭제된 건
									if (AUIGrid.getCellValue(auiGrid, rowIndex, "before_name") === AUIGrid.getCellValue(auiGrid, rowIndex, "after_name")) {
										return "aui-color-red-right-line";
									}
									return "aui-right";
								} else {
									return "aui-color-red-right";
								}
							}
						},
					]
				},
				{
					headerText: "변경사유",
					dataField : "remark",
					width : "21%",
					style : "aui-left",
				},
				{
					headerText: "처리자",
					dataField : "reg_name",
					width : "7%",
					style : "aui-center",
				}
			]

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀 영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<div class="content-wrap">
			<!-- 그리드 영역 -->
			<div id="auiGrid" style="margin-top: 5px;"></div>
			<div class="btn-group" style="margin-top: 10px;">
				<div class="left"></div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
    	</div>
		<!-- 버튼 그룹 -->
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>