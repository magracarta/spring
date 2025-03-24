<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > CAP콜 관리이력
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-22 19:54:29
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

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
			};

			var columnLayout = [
				{
					headerText: "예정일",
					dataField: "plan_dt",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd"
				},
				{
					headerText: "변경일",
					dataField: "change_plan_dt",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd"
				},
				{
					headerText: "통화구분",
					dataField: "as_call_result_name",
					style: "aui-center"
				},
				{
					headerText: "내용",
					dataField: "remark",
					style: "aui-left"
				},
				{
					headerText: "처리자",
					dataField: "reg_mem_name",
					style: "aui-center"
				},
				{
					headerText: "처리일자",
					dataField: "reg_dt",
					style: "aui-center",
					dataType: "date",
					formatString: "yyyy-mm-dd"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${capCallList});
			$("#auiGrid").resize();

			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);

			// 구해진 칼럼 사이즈를 적용 시킴.
			AUIGrid.setColumnSizeList(auiGrid, colSizeList);
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
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">고객명</th>
						<td>${capCallInfo.cust_name}</td>
						<th class="text-right">차대번호</th>
						<td>${capCallInfo.body_no}</td>
						<th class="text-right">출하일</th>
						<td>${capCallInfo.out_dt}</td>
						<th class="text-right">휴대전화</th>
						<td>${capCallInfo.hp_no}</td>
						<th class="text-right">상태</th>
						<td>${capCallInfo.cap_status_name}</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
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