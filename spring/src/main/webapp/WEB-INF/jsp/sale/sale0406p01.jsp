<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 수주잔고 > 수주잔고 리스트 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-02 10:15:49
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

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "수주잔고 리스트");
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 그리드 생성
		function createAUIGrid() {

			const gridPros = {
				rowIdField : "row_id",
			};

			const columnLayout = [
				{
					headerText : "년월",
					dataField : "year_mon",
					dataType : "date",
					formatString : "yyyy-mm",
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					width : "10%",
					style : "aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						let ret = "";
						if (value != null && value !== "") {
							ret = value.split("-");
							ret = ret[0]+"-"+ret[1];
							ret = ret.slice(4, ret.length);
						}
						return ret;
					},
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "15%",
					style : "aui-center",
				},
				{
					headerText : "모델",
					dataField : "machine_name",
					width : "20%",
					style : "aui-center"
				},
				{
					headerText : "담당자",
					dataField : "doc_mem_name",
					width : "15%",
					style : "aui-center"
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "15%",
					style : "aui-center"
				},
				{
					headerText : "지역명",
					dataField : "area_si",
					width : "15%",
					style : "aui-center",
				},
				{
					dataField : "maker_cd",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();

			// '관리번호' 클릭 시 [계약품의서상세] 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {

				// check
				if (this.self.columnData.style !== "aui-popup") {
                    return false;
                }

				let param = {
					machine_doc_no : event.item.machine_doc_no
				};

				$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : ""});
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
		<!-- 컨텐츠 영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<h4>수주잔고 리스트</h4>
				<div class="btn-group">
					<div class="right">
						<span class="text-warning">※ 날짜는 품의서 결재일 입니다.</span>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- 그리드 영역 -->
			<div id="auiGrid" style="margin-top: 5px;"></div>
			<!-- 우측 하단 버튼 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${size}</strong>건
				</div>
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