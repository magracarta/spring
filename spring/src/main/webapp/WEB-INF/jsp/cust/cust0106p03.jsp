<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 거래원장 > null > 입금예정
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-09 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
		});

		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "변경전",
					dataField: "deposit_old_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "80",
				},
				{
					headerText: "변경후",
					dataField: "deposit_plan_dt",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "80",
					minWidth : "80",
				},
				{
					headerText: "사유구분",
					dataField: "cust_deposit_chg_name",
					width : "80",
					minWidth : "80",
				},
				{
					headerText: "비고",
					dataField: "reason_text",
					style : "aui-left",
					width : "320",
					minWidth : "320",
				},
				{
					headerText: "등록자",
					dataField: "reg_mem_name",
					width : "80",
					minWidth : "80",
				},
				{
					headerText: "등록일시",
					dataField: "reg_date",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					width : "150",
					minWidth : "150",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
<form id="main_form" name="main_form">
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<h4>입금예정변경이력</h4>
			</div>
			<!-- 폼테이블 -->
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			<div class="btn-group mt10">
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