<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 입금현황 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
// 			fnInit();
			goSearch();
		});
		
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		}
		
		// 조회
		function goSearch() {
			var param = {
				"s_org_code" : $M.getValue("s_org_code"),
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
				"s_misu_yn" : $M.getValue("s_misu_yn"),
				"s_date_type" : $M.getValue("s_date_type"),
				"s_sort_key" : "machine_doc_no",
				"s_sort_method" : "asc",
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
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
					rowIdField : "machine_doc_no",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					showBranchOnGrouping : false,
					showFooter : true,
					footerPosition : "top",
					editable : false,
					enableFilter :true,
				};
			var columnLayout = [
				{
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "75",
					minWidth : "75",
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
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "120",
					minWidth : "110",
					style : "aui-center",
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",
					width : "110",
					minWidth : "110",
					style : "aui-center",
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "120",
					minWidth : "110",
					style : "aui-left aui-popup",
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "담당자", 
					dataField : "doc_mem_name", 
					width : "60",
					minWidth : "60",
					style : "aui-center",
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "출하일", 
					dataField : "out_dt", 
					width : "75",
					minWidth : "75",
					dataType : "date",   
					formatString : "yy-mm-dd",
					style : "aui-center aui-popup",
					filter : {
		                showIcon : true
		            }
				},
				{ 
					headerText : "물품대", 
					dataField : "sale_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "95",
					style : "aui-right",
				},
				{ 
					headerText : "부가세", 
					dataField : "vat_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "95",
					style : "aui-right",
				},
				{ 
					headerText : "최종입금일", 
					dataField : "deposit_dt",
					dataType : "date",   
					formatString : "yy-mm-dd", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
				},
				{ 
					headerText : "입금액", 
					dataField : "deposit_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "95",
					style : "aui-right",
				},
				{ 
					headerText : "미결재금", 
					dataField : "misu_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "95",
					style : "aui-right",
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					width : "255",
					minWidth : "200",
					style : "aui-left",
				},
				{ 
					dataField : "doc_org_code", 
					visible : false
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_doc_no",
					style : "aui-center aui-footer",
					colSpan : 6
				}, 
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "deposit_amt",
					positionField : "deposit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "misu_amt",
					positionField : "misu_amt",
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
				// 입금현황 팝업 오픈
				if(event.dataField == "machine_doc_no" ) {
					var params = {
							"machine_doc_no" : event.item["machine_doc_no"]
						};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=750, left=0, top=0";
					$M.goNextPage('/cust/cust0301p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
				// 계약품의서 상세 팝업 오픈
				if(event.dataField == "machine_name" ) {
					var params = {
							"machine_doc_no" : event.item["machine_doc_no"]
						};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=900, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
				// 출하의뢰서 상세 팝업 오픈
				if(event.dataField == "out_dt" ) {
					if(event.item["out_dt"] != "") {
						var params = {
							"machine_doc_no" : event.item["machine_doc_no"]
						};
						var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=900, left=0, top=0";
						$M.goNextPage('/sale/sale0101p03', $M.toGetParam(params), {popupStatus : poppupOption});
					}
				}
			});	
		}
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "장비입금관리-기간별", exportProps);
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->					
					<div class="search-wrap mt10">				
						<table class="table">
							<colgroup>
								<col width="85px">
								<col width="260px">								
								<col width="45px">
								<col width="150px">
								<col width="170px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<td>
										<select class="form-control" id="s_date_type" name="s_date_type">
											<option value="doc_dt">등록일자</option>
											<option value="out_dt">출하일자</option>
										</select>
									</td>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
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
									<th>부서</th>
									<td>
									
									<!-- 대리점일 경우, 본인 부서만 조회가능하므로 셀렉트박스로 안함. -->
<%--										<c:if test="${SecureUser.org_type eq 'AGENCY'}">--%>
										<c:if test="${page.fnc.F01021_001 eq 'Y'}">
											<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
											<input type="hidden" value="${SecureUser.org_code}" id="s_org_code" name="s_org_code" readonly="readonly"> 
										</c:if>
										<!-- 본사의 경우, 전체 부서목록 선택가능 -->
<%--										<c:if test="${SecureUser.org_type ne 'AGENCY'}">--%>
										<c:if test="${page.fnc.F01021_001 ne 'Y'}">
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 전체 -</option>
											<c:forEach items="${list}" var="item">
											  <option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
										</c:if>
									</td>
									<td class="pl10">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_misu_yn" name="s_misu_yn" value="Y">
											<label class="form-check-label" for="s_misu_yn">미 결재금(임대장비제외)</label>
										</div>
									</td>
									<td>
										<button type="button" onclick="javascript:goSearch();"class="btn btn-important" style="width: 50px;">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="right">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
							<div class="form-check form-check-inline">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</div>
							</c:if>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
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
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>