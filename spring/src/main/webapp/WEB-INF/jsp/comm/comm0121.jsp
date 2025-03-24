<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > null > null > 공휴일관리
-- 작성자 : 임예린
-- 최초 작성일 : 2021-09-17 03:40:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGrid;
	var ynList = [ {"code_value":"Y", "code_name" : "Y"}, {"code_value" :"N", "code_name" :"N"}];	
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		goSearch();
	});
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				headerText: "업무일자",
				dataField: "work_dt",
				dataType: "date",
				formatString: "yyyy-mm-dd",
				width: "130",
				minWidth: "50",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "주시작일",
				dataField: "week_st_dt",
				dataType: "date",
				formatString: "yyyy-mm-dd",
				width: "130",
				minWidth: "50",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "주종료일",
				dataField: "week_ed_dt",
				dataType: "date",
				formatString: "yyyy-mm-dd",
				width: "130",
				minWidth: "30",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "요일",
				dataField: "week",
				width: "110",
				minWidth: "50",
				style : "aui-center",
				editable : false,
			},
			{
				headerText: "근무여부",
				dataField: "work_yn",
				width: "90",
				minWidth: "30",
				style : "aui-center aui-editable",
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : ynList,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<ynList.length; i++){
						if(value == ynList[i].code_value){
							return ynList[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "공휴일여부",
				dataField: "holi_yn",
				width: "90",
				minWidth: "30",
				style : "aui-center aui-editable",
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : ynList,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<ynList.length; i++){
						if(value == ynList[i].code_value){
							return ynList[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "공휴일명",
				dataField: "holi_name",
				width: "150",
				minWidth: "50",
				style : "aui-center aui-editable",
				editable : true,
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", initColumnLayout(columnLayout), gridPros);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
	}
	
	// 조회
	function goSearch() {
		var param = {
				"s_start_mon" : $M.getValue("s_start_year")+$M.getValue("s_start_mon").padStart(2,'0'),
				"s_end_mon" : $M.getValue("s_end_year")+$M.getValue("s_end_mon").padStart(2,'0'),
				"s_work_yn" : $M.getValue("s_work_yn"),
				"s_holi_yn" : $M.getValue("s_holi_yn"),
				"s_holi_name" : $M.getValue("s_holi_name")
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
	
	function goSave() {
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역

		if (changeGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}
		
		var param = {
		}
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			goSearch();
				}
			}
		);	
	}
	
	function goSave() {
		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0) {
			alert("변경내역이 없습니다.");
			return;
		}

		var isSave = true;
		var workDtArr = [];
		var workYnArr = [];
		var holiYnArr = [];
		var holiNameArr = [];
		
		for (var i = 0; i < changeGridData.length; i++) {
			let holiYn = changeGridData[i].holi_yn;
			let workYn = changeGridData[i].work_yn;

			// [재호] [3차-Q&A 14310] 근무와 공휴일 여부가 Y로 같을 수 없게 수정
			if(holiYn == 'Y' && workYn == 'Y') {
				isSave = false;
				break;
			}

			workDtArr.push(changeGridData[i].work_dt);
			workYnArr.push(workYn);
			holiYnArr.push(holiYn);
			holiNameArr.push(changeGridData[i].holi_name);
		}

		if(!isSave) {
			alert("근무일과 공휴일이 [Y]로 같을 수 없습니다.");
			return;
		}
		
		var option = {
				isEmpty : true
		};
		
		var param = {
				work_dt_str : $M.getArrStr(workDtArr),
				work_yn_str : $M.getArrStr(workYnArr),
				holi_yn_str : $M.getArrStr(holiYnArr),
				holi_name_str : $M.getArrStr(holiNameArr, option),
		}

		console.log(param);
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			goSearch();
				}
			}
		);	
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
						<table class="table">
							<colgroup>
<%-- 								<col width="60px"> --%>
<%-- 								<col width="100px"> --%>
								<col width="60px">
								<col width="140px">		
								<col width="20px">
								<col width="140px">	
								<col width="60px">
								<col width="80px">
								<col width="70px">
								<col width="80px">
								<col width="60px">
								<col width="130px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>조회년월</th>
									<td>		
										<div class="form-row inline-pd" onChange="javascript:fnChangeMon();">							
											<div class="col-7">
												<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
													<jsp:param name="year_name" value="s_start_year"/>
													<jsp:param name="sort_type" value="u"/>
													<jsp:param name="select_year" value="${inputParam.s_start_year}"/>
													<jsp:param name="plus_minus" value="5"/>
													<jsp:param name="end_plus_minus" value="5"/>
												</jsp:include>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_start_mon" name="s_start_mon" >
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<td class="text-center">~</td>
									<td>
										<div class="form-row inline-pd">							
											<div class="col-7">
												<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
													<jsp:param name="year_name" value="s_end_year"/>
													<jsp:param name="sort_type" value="u"/>
													<jsp:param name="select_year" value="${inputParam.s_end_year}"/>
													<jsp:param name="plus_minus" value="5"/>
													<jsp:param name="end_plus_minus" value="5"/>
												</jsp:include>
											</div>
											<div class="col-5">
												<select class="form-control" id="s_end_mon" name="s_end_mon">
													<c:forEach var="i" begin="01" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.s_end_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
												</select>
											</div>
										</div>
									</td>
									<th>근무여부</th>
									<td>
										<select id="s_work_yn" name="s_work_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th>공휴일여부</th>
									<td>
										<select id="s_holi_yn" name="s_holi_yn" class="form-control">
											<option value="">- 전체 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th>공휴일명</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_holi_name" name="s_holi_name">
										</div>
									</td>																	
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
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