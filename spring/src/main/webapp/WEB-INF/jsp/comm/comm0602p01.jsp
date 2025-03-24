<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 근무관리 > 부서근로시간정산표(관리) > null > 연장근로신청내역
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-27 09:24:19
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

		// 닫기
		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				showRowNumColum: true
			};

			var columnLayout = [
				{
					headerText: "신청일시",
					dataField: "appr_req_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "10%"
				},
				{
					headerText: "승인일시",
					dataField: "last_proc_dt",
					dataType: "date",
					formatString: "yyyy-mm-dd",
					width: "10%"
				},
				{
					headerText: "신청시간",
					dataField: "req_time",
					width: "10%"
				},
				{
					headerText: "승인시간",
					dataField: "approval_time",
					width: "10%"
				},
				{
					headerText: "인정근로시간",
					dataField: "allow_time",
					width: "10%"
				},
				{
					headerText: "연장근로사유",
					dataField: "remark",
					width: "50%"
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
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
					<h4><span class="text-primary">[${inputParam.s_org_name}]</span> <span class="text-primary">${inputParam.s_mem_name}</span>님 연장근로승인내역</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
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