<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 new
-- 작성자 : jsk
-- 최초 작성일 : 2024-05-22 15:10:31
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
	
		$(document).ready(function() {
			createAUIGrid();
		});

		// 엔터키 이벤트
		function enter(fieldObj) {
			// 제목, 내용검색
			const field = ["s_check_mem_name"];
			field.forEach(name => {
				if (fieldObj.name == name) {
					goSearch();
				}
			});
		}
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: true,
				fillColumnSizeMode: false
			};
			var columnLayout = [
				{
					dataField : "nsvc_tool_check_seq",
					visible : false
				},
				{
					headerText : "센터명",
					dataField : "org_name",
					style : "aui-center",
					width : "140"
				},
				{
					headerText : "조사일자",
					dataField : "check_dt",
					style : "aui-center aui-popup",
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "120"
				},
				{
					headerText : "조사자",
					dataField : "check_mem_name",
					style : "aui-center",
					width : "180"
				},
				{
					headerText : "상태",
					dataField : "appr_proc_status_name",
					style : "aui-center",
					width : "140",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						console.log(value);
						if (value == undefined || value == "") {
							return "작성중";
						}
						return value;
					}
				},
				{
					headerText : "차이수량 합계",
					dataField : "sum_gap_qty",
					style : "aui-center",
					width : "120"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "check_dt" ) {
					var params = {
						"s_nsvc_tool_check_seq" : event.item.nsvc_tool_check_seq,
						"s_center_org_code" : event.item.org_code
					};
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=950, left=0, top=0";
					$M.goNextPage('/serv/serv0104p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
			$("#auiGrid").resize();
		}
	
		// 조회
		function goSearch() {
			var param = {
				"s_year" 				: $M.getValue("s_year"),
				"s_center_org_code" 	: $M.getValue("s_center_org_code"),
				"s_check_mem_name" 		: $M.getValue("s_check_mem_name"),
				"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}

		function fnExcelDownload() {
			fnExportExcel("정비Tool관리 목록", {});
		}

		// 신규등록
		function goNew() {
			var params = {
				"center_org_code"	: $M.getValue("s_center_org_code"),
				"check_dt"			: ""
			};
			var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=950, left=0, top=0";
			$M.goNextPage('/serv/serv0104p01', $M.toGetParam(params), {popupStatus : popupOption});
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
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="80px">
								<col width="50px">
								<col width="120px">
								<col width="60px">
								<col width="140px">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>조회년도</th>
									<td>
										<select class="form-control" id="s_year" name="s_year" required="required" alt="조회년도">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
												<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
											</c:forEach>
										</select>
									</td>
									<th>센터</th>
									<td>
										<c:if test="${page.fnc.F05763_001 ne 'Y'}">
											<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
											<input type="hidden" value="${SecureUser.org_code}" id="s_center_org_code" name="s_center_org_code" readonly="readonly">
										</c:if>
										<c:if test="${page.fnc.F05763_001 eq 'Y'}">
											<select class="form-control" id="s_center_org_code" name="s_center_org_code">
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${orgCenterList}">
													<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected="selected"</c:if>>${item.org_name}</option>
												</c:forEach>
											</select>
										</c:if>
									</td>
									<th>조사자</th>
									<td>
										<input type="text" id="s_check_mem_name" name="s_check_mem_name" class="form-control">
									</td>
									<th>상태</th>
									<td>
										<select class="form-control" name="s_appr_proc_status_cd" id="s_appr_proc_status_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['APPR_PROC_STATUS']}">
												<c:if test="${item.code_value ne '06'}">
													<option value="${item.code_value}" ${(SecureUser.appr_auth_yn == "Y" && item.code_value == "03") ? 'selected' : item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
												</c:if>
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
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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