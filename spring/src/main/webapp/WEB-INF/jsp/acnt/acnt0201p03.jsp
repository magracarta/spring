<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > 계좌거래내역조회
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-08 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			fnInit();
			createAUIGrid();
		});

		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
		}
		
		function goSearch() {
			var param = {
					s_start_dt : $M.getValue("s_start_dt"),
					s_end_dt : $M.getValue("s_end_dt"),
					acct_no : $M.getValue("acct_no"),
				};
				
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						
					};
				}		
			);	
		}

		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn : true,
				showFooter : true,
				footerPosition : "top",
			};

			var columnLayout = [
				{
					headerText : "은행명",
					dataField : "bank_name",
					style: "aui-center",
					width : "8%"
				},
				{
					headerText : "계좌번호",
					dataField : "acct_no",
					style: "aui-center",
					width : "12%"
				},
				{
					headerText : "처리일자",
					dataField : "acct_txday",
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					style: "aui-center"
				},
				{
					headerText : "입금",
					dataField : "in_amt",
					dataType : "numeric",
					formatString : "#,##0",
					style: "aui-right"
				},
				{
					headerText : "출금",
					dataField : "out_amt",
					dataType : "numeric",
					formatString : "#,##0",
					style: "aui-right"
				},
				{
					headerText : "잔액",
					dataField : "tx_cur_bal",
					dataType : "numeric",
					formatString : "#,##0",
					style: "aui-right"
				},
				{
					headerText : "적요",
					dataField : "jeokyo",
					style: "aui-left"
				},
				{
					headerText : "메모",
					dataField : "erp_memo",
					style: "aui-left"
				},
				{
					headerText : "처리액",
					dataField : "",
					dataType : "numeric",
					formatString : "#,##0",
					style: "aui-right"
				},
				{
					headerText : "처리내역",
					dataField : "",
					style: "aui-left"
				},
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "acct_txday"
				},
				{
					dataField: "im_amt",
					positionField: "im_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "out_amt",
					positionField: "out_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "tx_cur_bal",
					positionField: "tx_cur_bal",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "",
					positionField: "",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}
	</script>
</head>
<body>
<!-- 팝업 -->
<input type="hidden" name="acct_no" value="${inputParam.acct_no}" >
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 검색영역 -->
		<div class="search-wrap mt5">
			<table class="table table-fixed">
				<colgroup>
					<col width="65px">
					<col width="250px">
					<col width="">
				</colgroup>
				<tbody>
				<tr>
					<th>처리일자</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width120px">
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="조회 시작일">
								</div>
							</div>
							<div class="col width16px text-center">~</div>
							<div class="col width120px">
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_end_dt}" alt="조회 완료일">
								</div>
							</div>
						</div>
					</td>
					<td>
						<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
					</td>
				</tr>
				</tbody>
			</table>
		</div>
		<!-- /검색영역 -->
		<!-- 폼테이블 -->
		<div>
			<div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
		</div>
		<!-- /폼테이블-->
		<div class="btn-group mt10">
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->

</body>
</html>