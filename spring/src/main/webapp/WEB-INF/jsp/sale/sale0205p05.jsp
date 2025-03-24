<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비대장관리 > null > 정비지시서
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
	});
	
	//엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "정비지시서", "");
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			showFooter : true,
			footerPosition : "top",
		};
		var columnLayout = [
			{
				headerText : "관리번호",
				dataField : "job_report_no",
				style : "aui-center aui-popup",
				width : "120",
				minWidth : "120",
			},
			{
				headerText : "상태",
				dataField : "job_status_name",
				dataType : "date",
				formatString : "yy-mm-dd",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "상담일자",
				dataField : "consult_dt",
				dataType : "date",
				formatString : "yy-mm-dd",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "방문일자",
				dataField : "visit_dt",
				dataType : "date",
				formatString : "yy-mm-dd",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "입고일자",
				dataField : "in_dt",
				dataType : "date",
				formatString : "yy-mm-dd",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "완료일자",
				dataField : "job_ed_dt",
				dataType : "date",
				formatString : "yy-mm-dd",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "무상금액",
				dataField : "free_cost_amt",
				dataType : "numeric",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "센터",
				dataField : "org_name",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "접수자",
				dataField : "reg_mem_name",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "정비자",
				dataField : "eng_mem_name",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
		];
		
		var footerColumnLayoutOppCost = [ 
			{
				labelText : "합계",
				positionField : "job_ed_dt"
			},
			{
				dataField : "free_cost_amt",
				positionField : "free_cost_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
		AUIGrid.setFooter(auiGrid, footerColumnLayoutOppCost);
		
		// 상세팝업
        AUIGrid.bind(auiGrid, "cellClick", function (event) {
            if (event.dataField == "job_report_no") {
                var params = {
                    "s_job_report_no": event.item["job_report_no"]
                };
                var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
                $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
            }
        });
		
		$("#auiGrid").resize();
	}

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
			<div class="title-wrap">		
				<h4>${item.machine_name } ${item.body_no }</h4>
				<div class="btn-group mt5">
					<div class="right">
						<div class="right text-warning">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    	</div>
						
					</div>
               	</div>
			</div>	
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
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