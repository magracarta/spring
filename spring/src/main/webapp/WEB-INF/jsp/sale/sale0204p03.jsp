<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비통합조회 > null > 장비별집계조회
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
		});

		// 엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "집계현황");
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				// No. 제거
				showRowNumColumn: true,
				// 고정칼럼 카운트 지정
				editable: false,
				enableMovingColumn: false,
				showFooter: true,
				footerPosition : "top",
			};

			var columnLayout = [
				{
					headerText: "모델명",
					dataField: "machine_name",
// 					width : "18%",
					style: "aui-center"
				},
				{
					headerText: "본사",
					dataField: "base_cnt",
					width: "14%",
					style: "aui-center"
				},
				{
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// headerText: "대리점",
					headerText: "위탁판매점",
					dataField: "agency_cnt",
					width: "14%",
					style: "aui-center",
				},
				{
					headerText: "전체",
					dataField: "total_cnt",
					width: "14%",
					style: "aui-center",
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText: "합계",
					positionField: "machine_name"
				},
				{
					dataField: "base_cnt",
					positionField: "base_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "agency_cnt",
					positionField: "agency_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "total_cnt",
					positionField: "total_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-center aui-footer"
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
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
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<h4>집계현황</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<div style="margin-top: 5px; height: 320px;" id="auiGrid"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary">${total_cnt}</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
			<!-- /상단 폼테이블 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>
