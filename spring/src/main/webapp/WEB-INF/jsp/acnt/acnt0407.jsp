<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비재고현황 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-16 15:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		
		
		// 조회
		function goSearch() {
			var param = {
				s_start_dt 						: $M.getValue("s_start_dt"),
				s_end_dt 						: $M.getValue("s_end_dt"),
				s_machine_status_cd 		: $M.getValue("s_machine_status_cd"),
				s_machine_stock_yn 			: $M.getValue("s_machine_stock_yn"),
				// s_machine_out_pos_status_cd : $M.getValue("s_machine_out_pos_status_cd"),
				s_sort_key 					: "t.machine_name, t.seq_depth, t.pass_dt",
				s_sort_method 				: "asc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}		
			);
		}
		
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				treeColumnIndex : 0,
				displayTreeOpen : true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					headerText : "모델명", 
					dataField : "machine_name",
					width : "13%",
					style : "aui-left"
				},
				{
					headerText : "모델번호", 
					dataField : "machine_seq", 
					style : "aui-left",
					visible : false,
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "13%",
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "통관일자", 
					dataField : "pass_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "8%",
					style : "aui-center"
				},
				{ 
					headerText : "입고처리일자", 
					dataField : "in_proc_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "8%",
					style : "aui-center"
				},				
				{ 
					headerText : "화폐단위", 
					dataField : "money_unit_cd", 
					width : "6%",
					style : "aui-center"
				},
				{ 
					headerText : "외화단가", 
					dataField : "fe_unit_price", 
					width : "6%",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0.0####");
						return value == 0 ? "" : value;
					},
				},
				{ 
					headerText : "장비원가", 
					dataField : "mng_cost_amt", 
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						value = AUIGrid.formatNumber(value, "#,##0.0####");
						
						// 2021-07-16 (SR 11514) 장비원가 1뎁스는 미노출로 수정 - 황빛찬
						if (item.seq_depth == 1) {
							return "";
						} else {
							return value == 0 ? "" : value;
						}
					},
				},
				{ 
					headerText : "전월재고", 
					dataField : "bef_month_stock_cnt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : value;
					},
				},
				{ 
					headerText : "당월입고", 
					dataField : "curr_month_in_cnt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : value;
					},
				},
				{ 
					headerText : "당월판매", 
					dataField : "curr_month_sale_cnt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : value;
					},
				},
				{ 
					headerText : "당월재고", 
					dataField : "curr_month_stock_cnt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : value;
					},
				},
				{
					headerText : "재고금액",
					dataField : "curr_stock_price",
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var currValue = 0;
						if (item.seq_depth == 2) {
							currValue = AUIGrid.formatNumber(item.curr_stock_price, "#,##0.0####");
						} else {
							currValue = AUIGrid.formatNumber(value, "#,##0.0####");
						}

						return currValue == 0 ? "" : currValue;
					},
				},
				{
					headerText : "출하구분",
					dataField : "machine_status_name", 
					width : "6%",
					style : "aui-center"
				},
				{
					headerText : "관리점", 
					dataField : "in_org_name", 
					width : "6%",
					style : "aui-center"
				},
				{
					headerText : "정비상태", 
					dataField : "machine_out_pos_status_name", 
					width : "6%",
					style : "aui-center"
				},
				{ 
					headerText : "정비상태코드", 
					dataField : "machine_out_pos_status_cd", 
					style : "aui-center",
					visible : false,
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "fe_unit_price",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "mng_cost_amt",
					positionField : "mng_cost_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getTreeFlatData(auiGrid);
						var totalNum = 0;
						
						// 2021-07-16 (SR 11514) 장비원가 합계 당월재고 있는장비의 합으로 집계 - 황빛찬
						for (var i = 0; i < gridData.length; i++) {
							if (gridData[i].seq_depth == "2") {
								if (gridData[i].curr_month_stock_cnt != 0) {
									totalNum += gridData[i].mng_cost_amt;
								}
							}
						}
						
// 						for(var i=0, len=gridData.length; i<len; i++) {
// 							if(gridData[i]._$isBranch === true) {
// 								totalNum += gridData[i].mng_cost_amt;									
// 							};
// 						}
						return totalNum;
						
					}
				}, 
				{
					dataField : "bef_month_stock_cnt",
					positionField : "bef_month_stock_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}, 
				{
					dataField : "curr_month_in_cnt",
					positionField : "curr_month_in_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",

				}, 
				{
					dataField : "curr_month_sale_cnt",
					positionField : "curr_month_sale_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}, 
				{
					dataField : "curr_month_stock_cnt",
					positionField : "curr_month_stock_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "curr_stock_price",
					positionField : "curr_stock_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getTreeFlatData(auiGrid);
						var totalNum = 0;

						for (var i = 0; i < gridData.length; i++) {
							if (gridData[i].seq_depth == "1") {
								if (gridData[i].curr_stock_price != 0) {
									totalNum += gridData[i].curr_stock_price;
								}
							}
						}
						return totalNum;

					}
				},
			];


			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			$("#auiGrid").resize();
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
			
				if(event.item._$isBranch === true) {
					return;
				};
				
				if(event.dataField == "body_no" ) {
					var params = {
						"s_machine_seq" : event.item["machine_seq"],
					};
					var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
					$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
				};
			});	
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "장비재고현황", "");
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">			
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="270px">
								<col width="50px">
								<col width="130px">
								<col width="80px">
								<col width="130px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회일자</th>
									<td>
										<div class="row mg0">
											<div class="col-5">
												<div class="input-group width120px">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="종료일" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
												<jsp:param name="st_field_name" value="s_start_dt"/>
												<jsp:param name="ed_field_name" value="s_end_dt"/>
												<jsp:param name="exec_func_name" value="goSearch();"/>
											</jsp:include>
										</div>
<%--										<div class="input-group width120px">--%>
<%--											<input type="text" class="form-control border-right-0 calDate" id="s_date" name="s_date" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}" required="required">--%>
<%--										</div>--%>
									</td>
									<th>출하구분</th>
									<td>
										<select id="s_machine_status_cd" name="s_machine_status_cd" class="form-control">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MACHINE_STATUS']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
<%-- 									<th>정비상태</th>
									<td>
										<select id="s_machine_out_pos_status_cd" name="s_machine_out_pos_status_cd" class="form-control">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MACHINE_OUT_POS_STATUS']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td> --%>
									<th>장비재고여부</th>
									<td>
										<select id="s_machine_stock_yn" name="s_machine_stock_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">재고유</option>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
					</div>				
				</div>
			</div>	
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>