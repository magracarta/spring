<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 출하명세서-보유장비대비 > null > 선적일정표
-- 작성자 : 황빛찬
-- 최초 작성일 : 2024-06-19 19:40:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;

	$(document).ready(function() {
		createAUIGrid(); // 메인 그리드
		goSearch();
	});
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: true,
			editable : false,
		};
		var columnLayout = [
			{
				headerText : "메이커", 
				dataField : "client_cust_name",
				width : "130",
				style : "aui-center",
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				width : "210",
				style : "aui-left",
			},
			{
				headerText : "수량",
				dataField : "qty",
				width : "60",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
			},
			{
				headerText : "출발예정일(ETD)",
				dataField : "etd", 
				width : "110",
				style : "aui-center",
				dataType : "date",   
				formatString : "yy-mm-dd",
			},
			{ 
				headerText : "도착예정일(ETA)",
				dataField : "eta", 
				width : "110",
				style : "aui-center",
				dataType : "date",   
				formatString : "yy-mm-dd",
			},
			{ 
				headerText : "입고예정일",
				dataField : "in_plan_dt",
				width : "100", 
				style : "aui-center",
				dataType : "date",   
				formatString : "yy-mm-dd",
			},
			{
				headerText : "비고",
				dataField : "ship_remark",
				width : "250",
				style : "aui-left",
			},
		];
		
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
	}

	// 액셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "선적일정표");
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
	// 조회
	function goSearch() {
		var param = {
				s_date_type : $M.getValue("s_date_type"),
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_machine_name : $M.getValue("s_machine_name"),
				s_cust_no : $M.getValue("s_cust_no"),
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

	// 모델조회
	function fnSettingMachine(data) {
		$M.setValue("s_machine_name", data.machine_name);
	}

	// 매입처조회 팝업
	function fnSearchClientComm() {
		var param = {
			's_cust_name' : $M.getValue('s_cust_name'),
		};
		openSearchClientPanel('fnSetClientInfo', 'comm', $M.toGetParam(param));
	}

	// 매입처 정보 세팅
	function fnSetClientInfo(row) {
		console.log(row);
		$M.setValue("s_cust_name", row.cust_name);
		$M.setValue("s_cust_no", row.cust_no);
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>					
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
								<col width="0px">
								<col width="120px">
								<col width="270px">
								<col width="60px">
								<col width="130px">
								<col width="50px">
								<col width="130px">
						</colgroup>
						<tbody>
							<tr>
								<th></th>
								<td>
									<select name="s_date_type" id="s_date_type" class="form-control width200px">
										<option value="etd">출발예정일(ETD)</option>
										<option value="eta">도착예정일(ETA)</option>
										<option value="in_plan_dt">입고예정일</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
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
								<th>발주처</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="s_cust_name" name="s_cust_name">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th>모델명</th>
								<td>
									<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
										<jsp:param name="required_field" value="s_machine_name"/>
										<jsp:param name="s_maker_cd" value=""/>
										<jsp:param name="s_machine_type_cd" value=""/>
										<jsp:param name="s_sale_yn" value=""/>
										<jsp:param name="readonly_field" value=""/>
										<jsp:param name="execFuncName" value="fnSettingMachine"/>
									</jsp:include>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 55px;" onclick="javascript:goSearch();">조회</button></td>
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
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>