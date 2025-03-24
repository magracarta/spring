<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > GPS관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				enableFilter :true,
				rowIdField : "row",
				showRowNumColumn: true
			};
			var columnLayout = [
				{ 
					headerText : "개통일", 
					dataField : "open_dt", 
					dataType : "date",
					formatString : "yy-mm-dd",
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "고객구분", 
					dataField : "own_name", 
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "종류", 
					dataField : "gps_type_name",  
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "개통번호", 
					dataField : "gps_no", 
					width : "110", 
					minWidth : "75",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "계약번호", 
					dataField : "contract_no", 
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "GPS모델", 
					dataField : "gps_model_name", 					
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "사용시간",
					dataField : "use_time",
					style : "aui-center",
					dataType : "numeric",
					width : "75", 
					minWidth : "75",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "관리센터",
					dataField : "center_org_name",
					style : "aui-center",
					width : "75", 
					minWidth : "65",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "장착구분",
					dataField : "inst_yn_name",
					style : "aui-center",
					width : "75", 
					minWidth : "65",
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "inst_yn",
					visible : false
				},
				{
					headerText : "장착일자",
					dataField : "inst_dt",
// 					dataType : "date",
// 					formatString : "yyyy-mm-dd",
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = "";
						if(item.inst_yn == "Y"){
							template = $M.dateFormat(value, "yy-MM-dd");
						}											
						return template;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "장비모델",
					dataField : "machine_name",
					style : "aui-left",
					width : "75", 
					minWidth : "75",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = "";
						if(item.inst_yn == "Y"){
							template = value;
						}											
						return template;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					style : "aui-center",
					width : "140", 
					minWidth : "75",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = "";
						if(item.inst_yn == "Y"){
							template = value;
						}											
						return template;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "엔진번호",
					dataField : "engine_no_1",
// 					width : "8%",
					style : "aui-center",
					width : "120", 
					minWidth : "75",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = "";
						if(item.inst_yn == "Y"){
							template = value;
						}											
						return template;
					},
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "gps_seq",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//개통번호를 선택할 경우 
				if(event.dataField == "gps_no" ) {
					var params = {
						"gps_seq" : event.item.gps_seq
					};
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=620, left=0, top=0";
					$M.goNextPage('/rent/rent0203p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_open_start_dt","s_open_end_dt","s_gps_no","s_contract_no","s_body_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
	
		function goSearch() {
			var param = {
				"s_open_start_dt" : $M.getValue("s_open_start_dt")
				, "s_open_end_dt" : $M.getValue("s_open_end_dt")
				, "s_gps_no" : $M.getValue("s_gps_no")
				, "s_contract_no" : $M.getValue("s_contract_no")
				, "s_body_no" : $M.getValue("s_body_no")
				, "s_gps_type_cd" : $M.getValue("s_gps_type_cd")
				, "s_inst_yn" : $M.getValue("s_inst_yn")
				, "s_center_org_code" : $M.getValue("s_center_org_code")
			};
			_fnAddSearchDt(param, 's_open_start_dt', 's_open_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
	
		// 액셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "GPS관리");
		}
			
		// 페이지 이동
		function goNew() {
			$M.goNextPage("/rent/rent020301");
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
	<!-- 기본 -->									
				<div class="search-wrap">				
					<table class="table table-fixed">
						<colgroup>
							<col width="70px">
							<col width="260px">							
							<col width="50px">
							<col width="120px">	
							<col width="55px">
							<col width="120px">	
							<col width="55px">
							<col width="120px">	
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>개통일자</th>
								<td colspan="1">
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_open_start_dt" name="s_open_start_dt" dateformat="yyyy-MM-dd" alt="개통일자시작일" >
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_open_end_dt" name="s_open_end_dt" dateformat="yyyy-MM-dd" alt="개통일자종료일" >
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_open_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_open_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     	</jsp:include>
									</div>
								</td>
								<th>GPS번호</th>
								<td>
									<input type="text" class="form-control" id="s_gps_no" name="s_gps_no" alt="GPS번호">
								</td>
								<th>계약번호</th>
								<td>
									<input type="text" class="form-control width140px" id="s_contract_no" name="s_contract_no" alt="계약번호">
								</td>	
								<th>차대번호</th>
								<td>
									<input type="text" class="form-control width140px" id="s_body_no" name="s_body_no" alt="차대번호">
								</td>
							</tr>		
							<tr>
								<th>종류</th>
								<td colspan="1">
									<select class="form-control" id="s_gps_type_cd" name="s_gps_type_cd" alt="종류">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['GPS_TYPE']}" var="item">
											<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>	
								<th>장착구분</th>
								<td>
									<select class="form-control" id="s_inst_yn" name="s_inst_yn" alt="장착구분">
										<option value="">- 전체 -</option>
										<option value="Y">장착</option>
										<option value="N">미장착</option>
									</select>
								</td>
								<th>관리센터</th>
								<td>
									<select class="form-control" id="s_center_org_code" name="s_center_org_code" alt="관리센터">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>	
								<td >
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()" >조회</button>
								</td>									
							</tr>			
						</tbody>
					</table>					
				</div>				
				
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
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