<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인사관리 > null > 비용집계
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-10-07 17:48:32
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
			createAUIGridBottom();
			goSearch();
		});
		
		function goSearch() { 
			var param = {
				s_year_mon : $M.getValue("s_year")+$M.lpad($M.getValue("s_mon"), 2, '0'),
				s_sort_key : "org_code",
				s_sort_method : "desc",
			};
			$M.goNextPageAjax("/acnt/acnt0601p0109/svcResultSearch", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						AUIGrid.setGridData(auiGridBottom, result.listComm);
// 						$("#total_cnt").html(result.list.length);
						
						
					};
				}
			);
		} 
		

		//엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "비용집계");
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
				showFooter: true,
				footerPosition : "top"
			};

			var columnLayout = [
				{
					headerText: "센터명",
					dataField: "org_name",
					width : "70",
					minWidth : "50",
					style: "aui-center",
				},
				{
					headerText: "센터 지출비용",
					dataField: "out_sum_amt",
					width : "100",
					minWidth : "90",
					style: "aui-center",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "공통비",
					dataField: "comm_amt",
					width : "90",
					minWidth : "90",
					style: "aui-center",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인건비",
					dataField: "person_amt",
					style: "aui-center",
					width : "100",
					minWidth : "90",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "센터 총경비",
					dataField: "total_out_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인원수",
					dataField: "person_cnt",
					width : "60",
					minWidth : "30",
					dataType : "numeric", 
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인원",
					dataField: "mem_list",
					width : "620",
					minWidth : "90",
					style: "aui-left",
				},
				{
					headerText: "센터인당지출비용",
					dataField: "person_out_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric", 
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인당공통비평균",
					dataField: "person_comm_avg_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric", 
					formatString: "#,##0",
					style: "aui-right",
				},
			];

			var footerColumnLayout = [];
			
			footerColumnLayout = [
				{
					labelText: "합계",
					positionField: "org_name",
					style: "aui-right aui-footer",
				},
				{
					dataField: "out_cost_amt",
					positionField: "out_cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "out_sum_amt",
					positionField: "out_sum_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "comm_amt",
					positionField: "comm_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "person_amt",
					positionField: "person_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "total_out_amt",
					positionField: "total_out_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "person_cnt",
					positionField: "person_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "person_out_amt",
					positionField: "person_out_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "person_comm_avg_amt",
					positionField: "person_comm_avg_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${list});

			$("#auiGrid").resize();
		}

		// (Q&A 16287) 유정은 팀장님과 협의하여 공통 비용 따로 빼기로함. 20220906 김상덕
		// 공통용 그리드생성
		function createAUIGridBottom() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
// 				showFooter: true,
// 				footerPosition : "top"
			};

			var columnLayout = [
				{
					headerText: "센터명",
					dataField: "org_name",
					width : "70",
					minWidth : "50",
					style: "aui-center",
				},
				{
					headerText: "센터 지출비용",
					dataField: "out_sum_amt",
					width : "100",
					minWidth : "90",
					style: "aui-center",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "공통비",
					dataField: "comm_amt",
					width : "90",
					minWidth : "90",
					style: "aui-center",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인건비",
					dataField: "person_amt",
					style: "aui-center",
					width : "100",
					minWidth : "90",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "센터 총경비",
					dataField: "total_out_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인원수",
					dataField: "person_cnt",
					width : "60",
					minWidth : "30",
					dataType : "numeric", 
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인원",
					dataField: "mem_list",
					width : "620",
					minWidth : "90",
					style: "aui-left",
				},
				{
					headerText: "센터인당지출비용",
					dataField: "person_out_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric", 
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "인당공통비평균",
					dataField: "person_comm_avg_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric", 
					formatString: "#,##0",
					style: "aui-right",
				},
			];


			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBottom, []);

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
            	<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="130px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>조회년월</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="sort_type" value="d"/>
										<jsp:param name="year_name" value="s_year"/>
										<jsp:param name="select_year" value="${s_year}"/>	
									</jsp:include>
								</div>
								<div class="col-auto">
									<select class="form-control" id="s_mon" name="s_mon">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
						<td class="">
                            <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
                        </td>
					</tr>
					</tbody>
				</table>
			</div>
                <div class="title-wrap mt5">
                    <h4>비용집계</h4>
                    <div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
                <div class="title-wrap mt5">
                    <h4>공통비용</h4>
                </div>
                <div id="auiGridBottom" style="margin-top: 5px; height: 60px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
<!--                 <div class="left"> -->
<!--                     총 <strong class="text-primary" id="total_cnt">0</strong>건 -->
<!--                 </div> -->
<!--                 <div class="right"> -->
<%-- 					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
<!--                 </div> -->
            </div>
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