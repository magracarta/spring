<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 신차계약납기조회 > null > null
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
			createAUIGrid();
			goSearch();
		});

		function enter(fieldObj) {
			var field = ["s_cust_name", "s_doc_mem_name", "s_machine_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function goSearch() {
			var param = {
				s_machine_name : $M.getValue("s_machine_name"),
				s_cust_name : $M.getValue("s_cust_name"),
				s_doc_mem_name : $M.getValue("s_doc_mem_name"),
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
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
				height : 500
			};
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					width : "80",
					minWidth : "70",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
		                  var ret = "";
		                  if (value != null && value != "") {
		                     ret = value.split("-");
		                     ret = ret[0]+"-"+ret[1];
		                     ret = ret.substr(4, ret.length);
		                  }
		                   return ret; 
		               }, 
				},
				{
					headerText : "출하가능일", 
					dataField : "out_poss_dt",
					dataType : "date",   
					width : "80",
					minWidth : "80",
					style : "aui-center",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "모델", 
					dataField : "machine_name", 
					width : "100",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "담당자",
					dataField : "doc_mem_name",
					width : "100",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "100",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "휴대폰", 
					dataField : "hp_no", 
					width : "100",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "미결제액합계", // 고객미수금에서 장비품의서의 미결제액 합계로 변경(21.1.25 신정애요청)
					dataField : "receivable_amt",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "80", 
					style : "aui-right"
				},
				{ 
					headerText : "메모", 
					dataField : "order_text",
					style : "aui-left",
					width : "500",
					minWidth : "80", 
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_doc_no") {
					var param = {
						machine_doc_no : event.item.machine_doc_no,
					}
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=950, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
			$("#auiGrid").resize();
		}
		
		function fnMyExecFuncName(row) {
			$M.setValue("s_machine_plant_seq", row.machine_plant_seq);
		}
		
		function fnMyInFuncName() {
			$M.clearValue("s_machine_plant_seq");
		}
		
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "신차계약납기", {})
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="sale_mem_yn" name="sale_mem_yn" value="${sale_mem_yn}">
<input type="hidden" id="doc_mem_yn" name="doc_mem_yn" value="${doc_mem_yn}">
<input type="hidden" id="agency_mem_yn" name="agency_mem_yn" value="${agency_mem_yn}">
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
								<%-- <col width="80px">
								<col width="80px"> --%>
								<col width="40px">
								<col width="100px">
								<col width="40px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>모델명</th>
									<td>		
				                     	<input class="form-control" type="text" id="s_machine_name" name="s_machine_name">
									</td>
										<th>고객명</th>
										<td>
					                     	<input class="form-control" type="text" id="s_cust_name" name="s_cust_name">
										</td>
									<c:if test="${sale_mem_yn eq 'Y'}">
										<th>담당자</th>
										<td>		
					                     	<input class="form-control" type="text" name="s_doc_mem_name">
										</td>
									</c:if>
									<c:if test="${agency_mem_yn eq 'Y'}">
										<th>담당자</th>
										<td>
<%--											<input class="form-control" type="text" name="s_doc_mem_name">--%>
											<select id="s_doc_mem_name" name="s_doc_mem_name"  class="form-control width80px">
												<c:forEach items="${agencyMemList}" var="item">
													<option value="${item.kor_name}">${item.kor_name}</option>
												</c:forEach>
											</select>
										</td>
									</c:if>
									<c:if test="${doc_mem_yn eq 'Y'}">
										<th>담당자</th>
										<td>
											<input class="form-control" type="text" name="s_doc_mem_name" value="${SecureUser.kor_name}" readonly>
										</td>
									</c:if>
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
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
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