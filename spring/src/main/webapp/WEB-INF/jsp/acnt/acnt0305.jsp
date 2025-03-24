<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 고객별 총 미수 현황 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-16 14:03:57
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
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '고객별 총 미수 현황');
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 조회
		function goSearch() {		
			var param = {
				s_date 			: $M.getValue("s_date"),
				s_cust_name 	: $M.getValue("s_cust_name"),
				s_misu_type 	: $M.getValue("s_misu_type"),
				s_org_code 	: $M.getValue("s_org_code"),
				s_sort_key 		: "cust_name",
				s_sort_method 	: "asc",
				"s_masking_yn" 	: $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
				
			
			console.log(param.s_misu_type);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}		
			);
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row",
				// No. 제거
				showRowNumColumn: true,
				// 고정칼럼 카운트 지정
				editable : false,
				showFooter : true,
				footerPosition : "top",
				selectionMode : "singleRow",
				showSelectionBorder : true
			};
			var columnLayout = [
				{
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "150",
					minWidth : "150",
					style : "aui-center"
				},
				{
					dataField : "cust_no",
					visible : false,
				},
				{ 
					headerText : "전화번호", 
					dataField : "hp_no", 
					width : "130",
					minWidth : "130",
					style : "aui-center"
				},
				{ 
					headerText : "더존거래처번호", 
					dataField : "account_link_cd", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
				},
				{ 
					headerText : "사업자명", 
					dataField : "breg_name", 
					width : "170",
					minWidth : "170",
					style : "aui-center",
				},
				{ 
					headerText : "센터", 
					dataField : "org_name", 
					width : "100",
					minWidth : "100",
					style : "aui-center",
				},
				{ 
					headerText : "담당자(미수)", 
					dataField : "misu_mem_name", 
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{ 
					headerText : "장비 미수금", 
					dataField : "machine_misu_amt", 
					width : "110",
					minWidth : "110",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "";
						}
						return "aui-popup"
					},
				},
				{ 
					headerText : "정비/부품 미수금", 
					dataField : "repair_misu_amt", 
					width : "110",
					minWidth : "110",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "";
						}
						return "aui-popup"
					},
				},
// 				{ 
// 					headerText : "렌탈 미수금", 
// 					dataField : "rental_misu_amt",
// 					width : "12%",
// 					dataType : "numeric",
// 					formatString : "#,##0",
// 					style : "aui-right",
// 					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 						if(value == 0) {
// 							return "";
// 						}
// 						return "aui-popup"
// 					},
// 				},
				{ 
					headerText : "미수금 합계", 
					dataField : "tot_misu_amt",
					width : "110",
					minWidth : "110",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "misu_mem_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "machine_misu_amt",
					positionField : "machine_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "repair_misu_amt",
					positionField : "repair_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "rental_misu_amt",
					positionField : "rental_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "tot_misu_amt",
					positionField : "tot_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 고객장비거래원장 팝업
				if(event.value == 0) {
					return;
				};
				
				if(event.dataField == "machine_misu_amt" ) {
					console.log(event.item.cust_no);
					var params = {
						s_cust_no : event.item.cust_no,
					}
					
					openCustMachineDealLedgerPanel($M.toGetParam(params));
					
				} else if(event.dataField == "repair_misu_amt" ) {
					// 고객거래원장 팝업(정비)
					var params = {
						s_cust_no : event.item.cust_no,
// 						s_inout_doc_type_cd : '07',
					}
					
					openDealLedgerPanel($M.toGetParam(params));
				} else if(event.dataField == "rental_misu_amt" ) {
					// 고객거래원장 팝업(렌탈)
					var params = {
						s_cust_no : event.item.cust_no,
						s_inout_doc_type_cd : '11',
					}
					
					openDealLedgerPanel($M.toGetParam(params));
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
								<col width="45px">
								<col width="120px">								
								<col width="45px">
								<col width="100px">
								<col width="45px">
								<col width="100px">
								<col width="55px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>기간</th>
									<td>
										<div class="input-group width120px">
											<input type="text" class="form-control border-right-0 calDate" id="s_date" name="s_date" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}">
										</div>
									</td>
									<th>구분</th>
									<td>
										<select class="form-control" id="s_misu_type" name="s_misu_type">
											<option value="" >- 전체 -</option>
											<option value="M" >장비</option>
											<option value="P" >정비/부품미수 </option>
										</select>
									</td>
									<th>센터</th>
									<td>
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgCenterList}">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>고객명</th>
									<td>
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
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
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
								</c:if>									
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