<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 영업 Q&A
-- 작성자 : 류성진
-- 최초 작성일 : 2021-04-13 14:50:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_title", "s_content", "s_reg_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function goSearch() {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
				"s_title" : $M.getValue("s_title"),
				"s_content" : $M.getValue("s_content"),
				"s_reg_mem_name" : $M.getValue("s_reg_mem_name"),
				"s_sort_key" : "bbs_seq",
				"s_sort_method" : "desc"
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
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "bbs_seq",
				height : 555,
				showRowNumColumn: true,
				rowStyleFunction : function(rowIndex, item) {
					var style = "";
					if(item.top_yn == 'Y'){
						style = "aui-status-reject-or-urgent"
					}
					return style;
				},
			};
			var columnLayout = [
				{
					headerText : "제목", 
					dataField : "title", 
					width : "400",
					minWidth : "400",
					style : "aui-left aui-popup",
					editable : false,
				},
				{
					headerText : "내용", 
					dataField : "content", 
					width : "400",
					minWidth : "400",
					style : "aui-left",
					editable : false,
				},
				{
					headerText : "작성자", 
					dataField : "reg_mem_name", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "답변지정인원", 
					dataField : "people_cnt", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "답변", 
					dataField : "reply_cnt", 
					width : "100",
					minWidth : "100",
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "작성일", 
					dataField : "reg_date", 
					width : "90",
					minWidth : "90",
					dataType : "date",
					formatString : "yy-mm-dd", 
					style : "aui-center",
					editable : false,
				},
				{
					headerText : "조회수", 
					dataField : "read_cnt", 
					width : "55",
					minWidth : "55",
					style : "aui-center",
					editable : false,
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				if(event.dataField == "title") {
					console.log(event.item);
					var param = {
						"bbs_seq" : event.item["bbs_seq"]
					};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=1100, left=0, top=0";
					$M.goNextPage('/sale/sale0105p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
		
		// 문의하기 페이지 이동
		function goNew() {
			$M.goNextPage("/sale/sale010501");
		} 
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "마케팅Q&A", exportProps);
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
								<col width="260px">
								<col width="40px">
								<col width="120px">
								<col width="45px">
								<col width="120px">
								<col width="55px">
								<col width="120px">
								<col width="*">								
							</colgroup>
							<tbody>
								<tr>
									<th>작성일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="작성시작일" value="${searchDtMap.s_start_dt}">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="작성종료일">
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
									<th>제목</th>
									<td>
										<input type="text" class="form-control width140px" id="s_title" name="s_title">
									</td>									
									<th>내용</th>
									<td>
										<input type="text" class="form-control width140px" id="s_content" name="s_content">
									</td>
									<th>작성자</th>
									<td>
										<input type="text" class="form-control width120px" id="s_reg_mem_name" name="s_reg_mem_name">			
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