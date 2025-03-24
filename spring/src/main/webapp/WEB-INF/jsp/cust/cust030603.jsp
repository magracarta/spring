<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 마일리지관리 > 마일리지현황 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-10-31 15:03:57
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
			fnExportExcel(auiGrid, '고객별 총 마일리지 현황');
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
				s_org_code 	: $M.getValue("s_org_code"),
				s_sort_key 		: "cust_name",
				s_sort_method 	: "asc",
				"s_masking_yn" 	: $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
				
			
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
					headerText : "적립", 
					dataField : "accumulated_amt", 
					width : "100",
					minWidth : "100",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "";
						}
						return "aui-popup"
						// return ""
					},
				},
				{ 
					headerText : "사용", 
					dataField : "used_amt", 
					width : "100",
					minWidth : "100",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "";
						}
						return "aui-popup"
						// return ""
					},
				},
				{ 
					headerText : "소멸", 
					dataField : "expired_amt",
					width : "100",
					minWidth : "100",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "";
						}
						return "aui-popup"
						// return ""
					},
				},
				{ 
					headerText : "잔여", 
					dataField : "balance_amt",
					width : "100",
					minWidth : "100",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "org_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "accumulated_amt",
					positionField : "accumulated_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "used_amt",
					positionField : "used_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "expired_amt",
					positionField : "expired_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "balance_amt",
					positionField : "balance_amt",
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
				if(event.value == 0) {
					return;
				};
				
				if(event.dataField == "accumulated_amt" || event.dataField == "used_amt" || event.dataField == "balance_amt") {
					// 고객거래원장 팝업
					var params = {
						s_cust_no : event.item.cust_no,
					}

					openDealLedgerPanel($M.toGetParam(params));
				}
			});	
		}
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '고객 마일리지 현황');
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">			
<!-- 검색영역 -->					
					<div class="search-wrap mt10">				
						<table class="table">
							<colgroup>
								<col width="45px">
								<col width="120px">								
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
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>