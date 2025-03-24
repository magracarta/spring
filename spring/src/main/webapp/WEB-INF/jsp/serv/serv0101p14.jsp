<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > CAP이력
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-09 19:54:29
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

		// 닫기
		function fnClose() {
			window.close();
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false
			};
			var columnLayout = [
				{
					headerText: "차수",
					dataField: "cap_cnt",
					width: "10%"
				},
				{
					headerText: "예정일",
					dataField: "plan_dt",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd"
				},
				{
					headerText: "정비일",
					dataField: "job_ed_dt",
					style: "aui-center aui-popup",
					dataType: "date",
					formatString: "yyyy-mm-dd"
				},
				{
					headerText: "담당자",
					dataField: "complete_mem_name",
					style: "aui-center"
				},
				{
					headerText: "상태",
					dataField: "job_status_name",
					style: "aui-center aui-popup"
				},
				{
					headerText: "장비일련번호",
					dataField: "machine_seq",
					visible: false
				},
				{
					headerText: "정비지시서번호",
					dataField: "job_report_no",
					visible: false
				},
				{
					headerText: "상태코드",
					dataField: "job_status_cd",
					visible: false
				},
				{
					headerText: "담당자번호",
					dataField: "complete_mem_no",
					visible: false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${capList});
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "job_ed_dt" && event.item.job_ed_dt != "") {
					var params = {
						"s_job_report_no": event.item.job_report_no
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
					$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
				}

				if (event.dataField == "job_status_name") {
					var params = {
						"s_machine_seq": event.item.machine_seq,
						"s_cap_cnt": event.item.cap_cnt
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=500, left=0, top=0";
					$M.goNextPage('/serv/serv0101p15', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
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
				<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
			</div>
			<!-- /폼테이블 -->
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