<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 세금계산서-기간내 일괄발행 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
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
		});
		
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addDates($M.toDate(now), -14));
// 		}
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "breg_no",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "200",
					minWidth : "200",
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "상호", 
					dataField : "breg_name", 
					width : "200",
					minWidth : "200",
					style : "aui-center",
				},
				{ 
					headerText : "사업자번호", 
					dataField : "breg_no", 
					width : "140",
					minWidth : "140",
					style : "aui-center",
				},
				{ 
					headerText : "건수", 
					dataField : "issu_cnt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{ 
					headerText : "물품대", 
					dataField : "sum_doc_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "100",
					style : "aui-right"
				},
				{ 
					headerText : "부가세", 
					dataField : "sum_vat_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "100",
					minWidth : "100",
					style : "aui-right"
				},
				{ 
					headerText : "연락처", 
					dataField : "cust_hp_no",
					width : "140",
					minWidth : "140",
					style : "aui-center"
				},
				{ 
					dataField : "cust_no",
					visible : false
				},
				{ 
					dataField : "breg_seq",
					visible : false
				},
				{ 
					dataField : "inout_doc_no_str",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "cust_name",
					colSpan : 4,
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "sum_doc_amt",
					positionField : "sum_doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sum_vat_amt",
					positionField : "sum_vat_amt",
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
				if(event.dataField == "cust_name" ) {
					var params = {
							"inout_doc_no_str" : event.item["inout_doc_no_str"],
							"s_end_dt" : $M.getValue("s_end_dt")
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=650, left=0, top=0";
					$M.goNextPage('/acnt/acnt0302p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
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
		
		//조회
		function goSearch() { 
			var param = {
					"s_sort_key" : "doc.breg_no", 
					"s_sort_method" : "asc",
					"s_add_ut" : $M.getValue("s_add_ut"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		} 
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "세금계산서-기간내 일괄발행", exportProps);
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
								<col width="260px">								
								<col width="55px">
								<col width="120px">
								<col width="190px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>전표일자</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" required="required" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}" required="required">
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
									<th>고객명</th>
									<td>
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
									</td>
									<td class="pl10">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_add_ut" name="s_add_ut" value="T" checked="checked">
											<label class="form-check-label" for="s_add_ut">발행구분 월합계 고객 자료만</label>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
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