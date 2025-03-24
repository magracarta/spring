<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터일괄변경 > 부품마스터 변경내역 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-04-03 17:45:54
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		let auiGrid;

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
				showRowNumColumn : true,
				wordWrap: true, // 줄바꿈 적용
				showTooltip : true,
			};

			const columnLayout = [
				{
					headerText : "변경일자",
					dataField : "change_dt",
					width : "100",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return String(value).substring(0, 4) + "-" + String(value).substring(4, 6) + "-" + String(value).substring(6, 8);
					}
				},
				{
					dataField : "reg_date",
					visible : false
				},
				{
					headerText : "변경 전 내용",
					dataField : "before_text",
					style : "aui-left",
					tooltip : {
						tooltipFunction : fnShowGridText
					},
				},
				{
					headerText : "변경 후 내용",
					dataField : "after_text",
					style : "aui-left",
					tooltip : {
						tooltipFunction : fnShowGridText
					},
				},
				{
					headerText: "처리자",
					dataField : "reg_name",
					width : "100",
					style : "aui-center",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.resize(auiGrid);
		}

		// '변경 전/후 내용' 툴팁으로 보기좋게 표기
		function fnShowGridText(rowIndex, columnIndex, value, headerText, item, dataField) {
			let retStr = "";
			let arr = value.split(" / ");
			arr.forEach(str => {
				retStr += str + '<br>';
			});
			return retStr;
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
		<!-- 컨텐츠 영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<h4>${inputParam.part_no} | ${part_name}</h4>
			</div>
			<!-- 그리드 영역 -->
			<div id="auiGrid" style="margin-top: 10px; height: 400px;"></div>
			<!-- 하단 버튼 그룹 -->
			<div class="btn-group" style="margin-top: 10px;">
				<div class="left">
					총 <strong class="text-primary">${total_cnt}</strong>건
				</div>
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