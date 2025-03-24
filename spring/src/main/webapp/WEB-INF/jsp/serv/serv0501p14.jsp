<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 안건상담 리스트
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
		});

		//엑셀다운로드
		function fnExcelDownSec() {
			fnExportExcel(auiGrid, "안건상담 리스트");
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "상담일자",
					dataField: "consult_dt",
					dataType: "date",
					style: "aui-center",
					formatString: "yyyy-mm-dd",
				},
				{
					headerText: "상담시간",
					dataField: "consult_time",
					style: "aui-center",
				},
				{
					headerText: "상담모델",
					dataField: "machine_name",
					style: "aui-center",
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					style: "aui-center",
				},
				{
					headerText: "상담자",
					dataField: "mem_name",
					style: "aui-center",
				},
				{
					headerText: "상담방법",
					dataField: "consult_case_name",
					style: "aui-center",
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});

			$("#auiGrid").resize();
		}

	</script>
</head>
<body class="bg-white class">
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
					<h4>안건상담 리스트</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>

				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>

			</div>
			<!-- /폼테이블-->
			<div class="btn-group mt10">
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