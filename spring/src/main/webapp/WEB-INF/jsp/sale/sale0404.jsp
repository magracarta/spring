<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 영업직원개인별실적 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-23 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			fnInitDate();
			createAUIGrid();
		});
		
		// 시작일자 세팅 현재날짜의 1달 전
		function fnInitDate() {
			$M.setValue('s_start_dt', $M.getCurrentDate('yyyyMM') + "01");
		}
		
		// 부품이동처리 목록 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}; 
			
			var param = {
				s_start_dt 		: $M.getValue("s_start_dt"),
				s_end_dt 		: $M.getValue("s_end_dt"),
				s_machine_name	: $M.getValue("s_machine_name"),
				s_cust_name 	: $M.getValue("s_cust_name"),
				s_doc_mem_name 	: $M.getValue("s_doc_mem_name"),
				s_org_all_yn 	: $M.getValue("s_org_all_yn"),
			};
			
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_doc_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false,
				groupingFields : ["doc_mem_name"],
				groupingSummary :{
					dataFields : ["sale_amt", "discount_amt", "machine_used_loss_amt", "part_free_amt", "used_loss_amt", "sale_money"
								, "income_ref_amt", "income_amt", "base_support_amt", "etc_adjust_amt", "income_amt", "income_per"],
			    },
			    displayTreeOpen : true,
				enableCellMerge : true,
				showBranchOnGrouping : false,
				
	         	// 그리드 ROW 스타일 함수 정의
	            rowStyleFunction : function(rowIndex, item) {
	            	if(item._$isGroupSumField) { // 그룹핑으로 만들어진 합계 필드인지 여부
	                	return "aui-grid-row-depth3-style";
	                }
	                return null;
				}
			};
			var columnLayout = [
				{
					headerText : "담당자", 
					dataField : "doc_mem_no", 
 					width : "5%", 
 					visible : false,
					style : "aui-center"
				},
				{
					headerText : "담당자", 
					dataField : "doc_mem_name", 
 					width : "5%", 
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item._$isGroupSumField) {
							return "";
						}
						return "aui-popup"
					},
				},
				{
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "8%",
					style : "aui-center"
				},
				{
					headerText : "출하일", 
					dataField : "out_dt", 
					formatString : "yyyy-mm-dd",
				    dataType : "date",   
 					width : "5%",
					style : "aui-center"
				},
				{
					headerText : "고객명", 
					dataField : "cust_name", 
 					width : "7%",
					style : "aui-center"
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
 					width : "6%",
					style : "aui-center"
				},
				{
					headerText : "판매가격", 
					dataField : "sale_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "가격할인", 
					dataField : "discount_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "중고손실", 
					dataField : "machine_used_loss_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "지급품", 
					dataField : "part_free_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "기회비용", 
					dataField : "used_loss_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "실판매가", 
					dataField : "sale_money", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				}
				,{
					headerText : "손익기준가", 
					dataField : "income_ref_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "손익", 
					dataField : "income_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "본사지원", 
					dataField : "base_support_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "기타조정", 
					dataField : "etc_adjust_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "손익계", 
					dataField : "income_amt", 
					dataType : "numeric",
					formatString : "#,##0",
 					width : "6%",
					style : "aui-right"
				},
				{
					headerText : "%", 
					dataField : "income_per",
					width : "3%",
					style : "aui-center"
					
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.item._$isGroupSumField) {
					return;
				}
				
				if(event.dataField == "doc_mem_name") {
					var params = 
						{
							"machine_doc_no" : event.item.machine_doc_no
						}
						
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=650, left=0, top=0";
					$M.goNextPage('/sale/sale0404p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
			
			$("#auiGrid").resize();
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '마케팅직원개인별실적');
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
								<col width="40px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="150px">
								<col width="140px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>출하일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}">
												</div>
											</div>
										</div>
									</td>
									<th>담당자</th>
									<td>	
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_doc_mem_name" name="s_doc_mem_name">
										</div>
									</td>
									<th>고객명</th>
									<td>	
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
										</div>
									</td>
									<th>모델명</th>
									<td>		
										<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp"/>
									</td>
									<td class="pl15">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" name="s_org_all_yn" id="s_org_all_yn" value="Y" checked="checked">
											<label class="form-check-label" for="s_org_all_yn">마케팅부서 외 포함</label>
										</div>
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
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div style="margin-top: 5px; height: 555px;" id="auiGrid"></div>

				</div>
						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>