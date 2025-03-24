<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동요청 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-02-25 11:15:30
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
// 			fnInitDate();
			createAUIGrid();
			goSearch();
		});
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품이동요청내역", "");
		}
		
		
		// 부품이동요청 목록 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}; 
			
			var param = {
				s_start_dt 			: $M.getValue("s_start_dt"),
				s_end_dt 			: $M.getValue("s_end_dt"),
				s_to_warehouse_cd 	: $M.getValue("s_to_warehouse_cd"),
				s_complete_yn 		: $M.getValue("s_complete_yn"),
				s_sort_key : "part_trans_req_no",
				s_sort_method : "desc"
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
		
		// 시작일자 세팅 현재날짜의 1달 전
// 		function fnInitDate() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		}
		
		function goNew() {
			$M.goNextPage("/part/part020101");
		}
		
		function fnList() {
			history.back();
		}
		
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "part_trans_req_no",
				showRowNumColumn : true,
				headerHeight : 40,
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 4,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "부품이동<br\>요청번호",
				    dataField: "part_trans_req_no",
					width : "95",
					minWidth : "90",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{
					headerText: "요청일",
				    dataField: "reg_date",
				    dataType : "date",   
					width : "75",
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{
				    headerText: "요청방법",
				    dataField: "part_trans_req_type_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "310",
					minWidth : "200",
					style : "aui-left"
				},
				{
				    headerText: "FROM<br\>가용재고",
				    dataField: "current_able_stock",
				    dataType : "numeric",
					formatString : "#,##0",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
				    headerText: "요청수량",
				    dataField: "req_qty",
				    dataType : "numeric",
					formatString : "#,##0",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
				    headerText: "미처리량",
				    dataField: "mi_qty",
				    dataType : "numeric",
					formatString : "#,##0",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
				    headerText: "요청자",
				    dataField: "reg_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
				    headerText: "TO<br\>창고",
				    dataField: "to_warehouse_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{
				    dataField: "to_warehouse_cd",
				    visible : false,
				},
				{
				    dataField: "from_warehouse_cd",
				    visible : false,
				},
				{
				    headerText: "FROM<br\>창고",
				    dataField: "from_warehouse_name",
					width : "80",
					minWidth : "80",
					style : "aui-center"
				},
				{
				    headerText: "발송구분",
				    dataField: "invoice_send_name",
					width : "70",
					minWidth : "70",
					style : "aui-center aui-popup"
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "195",
					minWidth : "100",
					style : "aui-left"
				},
				{
				    headerText: "상태",
				    dataField: "complete_yn",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return item["complete_yn"] == "Y"? "완료" : "대기"
					},
					width : "45",
					minWidth : "45",
					style : "aui-center",
				},
				{
				    dataField: "send_invoice_seq",
				    visible : false,
				},
				{
				    dataField: "invoice_send_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_type_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_warehouse",
				    visible : false,
				},
				{
				    dataField: "invoice_no",
				    visible : false,
				},
				{
				    dataField: "invoice_qty",
				    visible : false,
				},
				{
				    dataField: "receive_tel_no",
				    visible : false,
				},
				{
				    dataField: "receive_hp_no",
				    visible : false,
				},
				{
				    dataField: "invoice_remark",
				    visible : false,
				},
				{
				    dataField: "invoice_money_cd",
				    visible : false,
				},
				{
				    dataField: "invoice_post_no",
				    visible : false,
				},
				{
				    dataField: "invoice_addr1",
				    visible : false,
				},
				{
				    dataField: "invoice_addr2",
				    visible : false,
				},
				{
				    dataField: "receive_name",
				    visible : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "part_trans_req_no") {
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=660, left=0, top=0";
 					var param = {
 						"part_trans_req_no" : event.item.part_trans_req_no	
 					}
 					
					$M.goNextPage("/part/part0201p01", $M.toGetParam(param), {popupStatus : popupOption});
 				}
 				
 				
 				if(event.dataField == "invoice_send_name") {
 					if($M.nvl(event.value, 0) == 0) {
 						return;
 					};
 					
 					var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=660, left=0, top=0";
 					var param = {
		    			invoice_type_cd 	: event.item.invoice_type_cd,
		    			invoice_money_cd	: event.item.invoice_money_cd,
		    			invoice_send_cd 	: event.item.invoice_send_cd,
		    			receive_name 		: event.item.receive_name,
		    			invoice_no 			: event.item.invoice_no,
		    			receive_hp_no 		: event.item.receive_hp_no,
		    			receive_tel_no 		: event.item.receive_tel_no,
		    			qty 				: event.item.invoice_qty,
		    			remark 				: event.item.invoice_remark,
		    			post_no 			: event.item.invoice_post_no,
		    			addr1				: event.item.invoice_addr1,
		    			addr2				: event.item.invoice_addr2,
		    			show_yn				: 'Y',
 					}

					$M.goNextPage("/cust/cust0201p02", $M.toGetParam(param), {popupStatus : popupOption});
 				}
 				
			});
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
									<col width="65px">
									<col width="260px">
									<col width="40px">
									<col width="100px">
									<col width="80px">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>요청일자</th>
										<td>
											<div class="form-row inline-pd">
				                                <div class="col-5">
				                                   <div class="input-group">
				                                      <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청 시작일" value="${searchDtMap.s_start_dt}">
				                                   </div>
				                                </div>
				                                <div class="col-auto">~</div>
				                                <div class="col-5">
				                                   <div class="input-group">
				                                      <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청 종료일" value="${searchDtMap.s_end_dt}">
				                                   </div>
				                                </div>
				                                <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
					                     		<jsp:param name="st_field_name" value="s_start_dt"/>
					                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
					                     		<jsp:param name="click_exec_yn" value="Y"/>
					                     		<jsp:param name="exec_func_name" value="goSearch();"/>
					                     		</jsp:include>	
                              				</div>
										</td>
										<th>요청처</th>
										<td>			
											<!-- 로그인 계정이 본사인 경우, 창고목록 콤보그리드 선택가능 -->
											<!-- 로그인 계정이 본사가 아닌 경우 해당부서코드 Set -->
											<c:choose>
												<c:when test="${page.fnc.F00423_001 eq 'Y'}">
													<input type="text" style="width : 200px";
														value="${SecureUser.part_org_yn eq 'Y' ? SecureUser.org_code : ''}"
														id="s_to_warehouse_cd" 
														name="s_to_warehouse_cd" 
														idfield="code_value"
														easyui="combogrid"
														header="Y"
														easyuiname="warehouseList" 
														panelwidth="200"
														maxheight="155"
														enter="goSearch()"
														textfield="code_name"
														multi="N"/>
												</c:when>
												<c:when test="${page.fnc.F00423_001 ne 'Y'}">
													<div class="col width100px" style="padding-right: 0;">
														<input type="text" class="form-control" value="${SecureUser.warehouse_name}" readonly="readonly">
														<input type="hidden" value="${SecureUser.warehouse_cd}" id="s_to_warehouse_cd" name="s_to_warehouse_cd" readonly="readonly">
													</div> 
												</c:when>
											</c:choose>
										</td>
										<th>상태</th>
										<td>
											<select class="form-control" id="s_complete_yn" name="s_complete_yn">
												<option value="">- 전체 -</option>
												<option value="Y">완료</option>
												<option value="N">대기</option>
											</select>
										</td>
										<td>
											<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
										</td>			
									</tr>										
								</tbody>
							</table>					
						</div>
						<!-- /검색영역 -->	
						<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt10">
							<h4>이동요청내역</h4>
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
						<!-- /그리드 타이틀, 컨트롤 영역 -->					
						<div style="margin-top: 5px; height: 555px;" id="auiGrid"></div>
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">				
								총 <strong class="text-primary" id="total_cnt">0</strong>건 
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
				</div>
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
			</div>
			<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>