<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 월별 총 재고현황 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-08-18 17:13:06
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createLeftAUIGrid();		
			createRightAUIGrid();		
		});
		
		function goSearchDetail(param) {
			AUIGrid.setGridData(auiGridRight, []);	// 요청예정목록 초기화
			if (param.s_type_1 == "part") {
				var columnLayout = [
						{
							headerText : "부품번호",
							dataField : "part_no",
							width : "100",
							minWidth: "30",
							style: "aui-center"
						},
						{
							headerText : "신번호",
							dataField : "part_new_no",
							width : "100",
							minWidth: "30",
							style: "aui-center"
						},
						{
							headerText : "수량",
							dataField : "cnt",
							width : "100",
							minWidth: "30",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style: "aui-right"
						},
						{
							headerText : "금액",
							dataField : "amt",
							width : "100",
							minWidth: "30",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style: "aui-right"
						}
				];
				AUIGrid.changeColumnLayout(auiGridRight, columnLayout);
				
				var footerColumnLayout = [ 
					{
						labelText : "합계",
						positionField : "part_new_no",
						style : "aui-center aui-footer",
					}, 
					{
						dataField : "cnt",
						positionField : "cnt",
						operation : "SUM",
						formatString : "#,##0",
						style : "aui-right aui-footer"
					},
					{
						dataField : "amt",
						positionField : "amt",
						operation : "SUM",
						formatString : "#,##0",
						style : "aui-right aui-footer"
					}
				];
				AUIGrid.changeFooterLayout(auiGridRight, footerColumnLayout);
			} else {
				var columnLayout = [
						{
							headerText : "메이커",
							dataField : "maker_name",
							width : "100",
							minWidth: "30",
							style: "aui-center"
						},
						{
							headerText : "모델명",
							dataField : "machine_name",
							width : "100",
							minWidth: "30",
							style: "aui-right"
						},
						{
							headerText : "수량",
							dataField : "cnt",
							width : "100",
							minWidth: "30",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style: "aui-right"
						},
						{
							headerText : "금액",
							dataField : "amt",
							width : "100",
							minWidth: "30",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style: "aui-right"
						}
				];
				AUIGrid.changeColumnLayout(auiGridRight, columnLayout);
				
				var footerColumnLayout = [ 
					{
						labelText : "합계",
						positionField : "machine_name",
						style : "aui-center aui-footer",
					}, 
					{
						dataField : "cnt",
						positionField : "cnt",
						operation : "SUM",
						formatString : "#,##0",
						style : "aui-right aui-footer"
					},
					{
						dataField : "amt",
						positionField : "amt",
						operation : "SUM",
						formatString : "#,##0",
						style : "aui-right aui-footer"
					}
				];
				AUIGrid.changeFooterLayout(auiGridRight, footerColumnLayout);
			}
			
			
			$M.goNextPageAjax(this_page + "/detailSearch", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							console.log(result.list);
							AUIGrid.setGridData(auiGridRight, result.list);	// 요청예정목록 초기화
						};
					}
				);
		}
		

		// 그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showFooter : true,
				footerPosition : "top",
				showRowNumColumn: false,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "구분",
					dataField : "gubun",
					width : "80",
					minWidth : "80",
				},
				{
					headerText : "전월재고",
					children : [
						{
							dataField : "bef_month_stock_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						}, 
						{
							dataField : "bef_month_stock_amt",
							headerText : "금액",
							width : "100",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "당월입고",
					children : [
						{
							dataField : "curr_month_in_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						}, 
						{
							dataField : "curr_month_in_amt",
							headerText : "금액",
							width : "100",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "당월판매",
					children : [
						{
							dataField : "curr_month_sale_cnt",
							headerText : "수량",
							width : "50",
							minWidth : "50",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						}, 
						{
							dataField : "curr_month_sale_amt",
							headerText : "금액",
							width : "100",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "송금완료",
					children : [
						{
							dataField : "remit_proc_cnt",
							headerText : "수량",
							width : "50",
							minWidth : "50",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						}, 
						{
							dataField : "remit_proc_amt",
							headerText : "금액",
							width : "100",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "당월재고",
					children : [
						{
							dataField : "curr_month_stock_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						}, 
						{
							dataField : "curr_month_stock_amt",
							headerText : "금액",
							width : "100",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "gubun",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "bef_month_stock_cnt",
					positionField : "bef_month_stock_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "bef_month_stock_amt",
					positionField : "bef_month_stock_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "curr_month_in_cnt",
					positionField : "curr_month_in_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_in_amt",
					positionField : "curr_month_in_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "curr_month_sale_cnt",
					positionField : "curr_month_sale_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_sale_amt",
					positionField : "curr_month_sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},				
				{
					dataField : "remit_proc_cnt",
					positionField : "remit_proc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "remit_proc_amt",
					positionField : "remit_proc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_stock_cnt",
					positionField : "curr_month_stock_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_stock_amt",
					positionField : "curr_month_stock_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}
			];
			
			
			// 그리드 출력
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGridLeft, 4);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);
			AUIGrid.setFooter(auiGridLeft, footerColumnLayout);
			$("#auiGridLeft").resize();
			// 클릭 시 이벤트
 			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
 				
 				if (event.value == "" || !event.dataField.endsWith("amt")) {
 					return;
 				}
 				
 				var param = {
					s_year  : $M.getValue("s_year"),
					s_mon 	: $M.getValue("s_mon"),
				};
 				
 				// 로우인덱스에 따라 구분
 				if (event.rowIndex == 0) {
 					param["s_type_1"] = "machine"; // 장비재고
 					$("#detail_name").html("장비재고 상세내역");
 				} else if (event.rowIndex == 1) {
 					param["s_type_1"] = "part"; // 부품재고
 					$("#detail_name").html("부품재고 상세내역");
 				} else {
 					param["s_type_1"] = "used"; // 중고장비재고
 					$("#detail_name").html("중고장비재고 상세내역");
 				}
 				
 				// 전월재고금액
 				if(event.dataField == "bef_month_stock_amt") { 
 					param["s_type"] = "bef_month_stock_amt";
	 				goSearchDetail(param);  
 				}
 				
 				// 당월입고금액
 				if(event.dataField == "curr_month_in_amt") { 
 					param["s_type"] = "curr_month_in_amt";
	 				goSearchDetail(param);  
 				}
 				
 				// 당월판매금액
 				if(event.dataField == "curr_month_sale_amt") { 
 					param["s_type"] = "curr_month_sale_amt";
	 				goSearchDetail(param);  
 				}
 				
 				// 송금완료
 				if(event.dataField == "remit_proc_amt") { 
 					param["s_type"] = "remit_proc_amt";
	 				goSearchDetail(param);  
 				}
 				
 				// 당월 재고금액
 				if(event.dataField == "curr_month_stock_amt") { 
 					param["s_type"] = "curr_month_stock_amt";
	 				goSearchDetail(param);  
 				}
 				
			});
		}
		
		// 그리드생성
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showFooter : true,
				footerPosition : "top",
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
					{
						headerText : "메이커",
						dataField : "default1"
					},
					{
						headerText : "부품",
						dataField : "default2"
					},
					{
						headerText : "수량",
						dataField : "default3"
					},
					{
						headerText : "금액",
						dataField : "default4"
					}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
							
			];
			
			// 그리드 출력
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridRight, []);
	
			AUIGrid.setFooter(auiGridRight, footerColumnLayout);
			$("#auiGridRight").resize();
		}

        function fnDownloadExcel() {
			fnExportExcel(auiGridRight, "재고현황");
        }
		
      	//조회시
	   	function goSearch() {
      		
			var param = {
				s_year : $M.getValue("s_year"),
				s_mon  : $M.getValue("s_mon"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result.list);
						AUIGrid.setGridData(auiGridLeft, result.list);
						AUIGrid.setGridData(auiGridRight, []);	// 요청예정목록 초기화
					};
				}
			);
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
					
					<div class="search-wrap">				
						<table class="table table-fixed">
							<colgroup>
								<col width="70px">
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
												</jsp:include>
											</div>
											<div class="col-auto">
												<select class="form-control" id="s_mon" name="s_mon">
													<c:forEach var="i" begin="1" end="12" step="1">
														<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button>
									</td>	
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
					<div class="row">
						<div class="col-7">
<!-- 조회결과 -->
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
							</div>		
							<div style="margin-top: 5px; height: 555px;" id="auiGridLeft"></div>
<!-- /조회결과 -->							
						</div>
						<div class="col-5">
<!-- 부품목록 -->
							<div class="title-wrap mt10">
								<h4 id="detail_name">상세내역</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div style="margin-top: 5px; height: 555px;" id="auiGridRight"></div>
<!-- /부품목록 -->	
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