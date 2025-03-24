<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 재고조정요청현황 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-08-14 09:56:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();	
// 			fnInit();
		});
		
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		}
		
		
		function goSearch() {
			
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			
			
			
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),					
				s_warehouse_cd : $M.getValue("s_warehouse_cd"),
				s_part_adjust_status_cd : $M.getValue("s_part_adjust_status_cd"),
				s_sort_key     : "part_adjust_no",
				s_sort_method  : "desc"
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
		
		function goNew() {			
			$M.goNextPage("/part/part050501");					
		}

		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품재고조정현황");
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false

			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "요청번호",
				    dataField: "part_adjust_no",
					style : "aui-center aui-popup"
				},
				{
					headerText : "등록일",
					dataField : "reg_dt",
					style : "aui-center"
				},
				{
				    headerText: "요청센터",
				    dataField: "warehouse_name",
					style : "aui-center"
				},
				{
				    dataField: "warehouse_cd",
					visible : false
				},
				{
				    headerText: "작성자",
				    dataField: "reg_mem_name",
					style : "aui-center"
				},
				{
				    headerText: "품목수",
				    dataField: "adjust_qty",
					style : "aui-center"
				},
				{
					dataField : "appr_proc_status_cd",
					visible : false
				},
				{
				    headerText: "상태",
				    dataField: "appr_proc_status_name",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return (item.appr_proc_status_cd == '05') ? '반영완료' : value; 
					}
				},
				{
				    headerText: "결재요청일",
				    dataField: "appr_req_dt",
					dataType : "date",   
					formatString : "yyyy-mm-dd",			    
					style : "aui-center"
				},
				{
				    headerText: "반영일",
				    dataField: "adjust_dt",
					dataType : "date",   
					formatString : "yyyy-mm-dd",	
					style : "aui-center"
				},
				{
				    headerText: "내용",
				    dataField: "count_remark",
				    width: "20%",
					style : "aui-left"
				},
				{
				    headerText: "비고",
				    dataField: "remark",
				    width: "25%",
					style : "aui-left"
				},
			];
			

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "part_adjust_no") {
 					
 					var param = {
 							"part_adjust_no" : event.item.part_adjust_no
 					};	
 				
 					var popupOption = "";
 					$M.goNextPage('/part/part0505p01', $M.toGetParam(param), {popupStatus : popupOption});

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
								<col width="60px">
								<col width="260px">
								<col width="30px">
								<col width="100px">
								<col width="75px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>등록일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="조회 시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일" value="${searchDtMap.s_end_dt}">
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
										<!-- 로그인 계정이 센터가 아닌경우, 창고목록 콤보그리드 선택가능 -->
										<!-- 로그인 계정이 센터인경우 해당부서코드 Set -->
										<c:choose>
											<c:when test="${page.fnc.F00680_001 eq 'Y'}">
												<select class="form-control" id="s_warehouse_cd" name="s_warehouse_cd">
													<option value="">- 전체 - </option>
													<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
														<option value="${item.code_value}">${item.code_name}</option>										
													</c:forEach>
												</select>
											</c:when>
											<c:when test="${page.fnc.F00680_002 eq 'Y'}">
												<select class="form-control" id="s_warehouse_cd" name="s_warehouse_cd">																				
													<option value="${SecureUser.org_code}">${SecureUser.org_name}</option>																					
												</select>
											</c:when>
										</c:choose>		
									</td>
									<th>결재구분</th>
									<td>
										<select class="form-control" id="s_part_adjust_status_cd" name="s_part_adjust_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="list" items="${codeMap['APPR_PROC_STATUS']}">
											<option value="${list.code_value}" ${(SecureUser.appr_auth_yn == "Y" && list.code_value == "03") ? 'selected' : list.code_value == "0" ? 'selected' : ''}>${list.code_name}</option>
											</c:forEach>
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
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt" >0</strong>건
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