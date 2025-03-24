<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 워렌티 오픈관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-21 13:20:29
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

	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_cust_name", "s_body_no"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	function fnSetOrgMapPanel(data) {
		$M.setValue("s_org_code", data.org_code);
		$M.setValue("s_org_name", data.org_name);
	}

	// 조회
	function goSearch() {
		var frm = document.main_form;
		//validationcheck
		if ($M.validation(frm,
				{field: ["s_start_dt", "s_end_dt"]}) == false) {
			return;
		}

		var params = {
			"s_date_type" : $M.getValue("s_date_type"),
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt"),
			"s_maker_cd" : $M.getValue("s_maker_cd"),
			"s_cust_name" : $M.getValue("s_cust_name"),
			"s_body_no" : $M.getValue("s_body_no"),
			"s_org_code" : $M.getValue("s_org_code"),
			"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
		};
		_fnAddSearchDt(params, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
				function (result) {
					if (result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
		);
	}

	// 엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "워런티 오픈관리");
	}	

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			// fixedColumnCount : 7,
		};
		var columnLayout = [
			{
				headerText : "장비대장번호",
				dataField : "machine_seq",
				visible : false
			},
			{ 
				headerText : "관리번호", 
				dataField : "paper_mng_no",
				style : "aui-center",
			},
			{
				headerText : "차주명", 
				dataField : "cust_name",
				width : "120",
				minWidth : "120",
				style : "aui-center",
			},
			{ 
				headerText : "연락처", 
				dataField : "hp_no",
				style : "aui-center",
				width : "110",
				minWidth : "110",
			},
			{ 
				headerText : "차대번호", 
				dataField : "body_no",
				style : "aui-center aui-popup",
				width : "150",
				minWidth : "150",
			},
			{ 
				headerText : "엔진번호", 
				dataField : "engine_no_1",
				width : "90",
				minWidth : "90",
				style : "aui-center",
			},
			{ 
				headerText : "모델명", 
				dataField : "machine_name",
				width : "120",
				minWidth : "120",
				style : "aui-left",
			},
			{ 
				headerText : "입고일자", 
				dataField : "in_dt",
				dataType : "date",
				formatString : "yy-mm-dd",
				width : "65",
				minWidth : "65",
				style : "aui-center",
			},
			{ 
				headerText : "출하일자", 
				dataField : "out_dt",
				dataType : "date",
				formatString : "yy-mm-dd",
				width : "65",
				minWidth : "65",
				style : "aui-center",
			},
			{
				headerText : "DI레포트", 
				dataField : "di",
				style : "aui-center",
				children : [
					{
						headerText : "예정일자",
						dataField : "di_plan_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검일자",
						dataField : "di_check_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검자",
						dataField : "di_check_mem_name",
						width : "60",
						minWidth : "60",
						style : "aui-center",
					},
					{
						headerText : "비고",
						dataField : "di_remark",
						style : "aui-left",
						width : "150",
						minWidth : "150"
					},
				]
			},
			{ 
				headerText : "납입점검", 
				dataField : "pay",
				style : "aui-center",
				children : [
					{
						headerText : "예정일자",
						dataField : "pay_plan_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검일자",
						dataField : "pay_check_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검자",
						dataField : "pay_check_mem_name",
						width : "60",
						minWidth : "60",
						style : "aui-center",
					},
					{
						headerText : "비고",
						dataField : "pay_remark",
						style : "aui-left",
						width : "150",
						minWidth : "150"
					},
				]
			},
			{ 
				headerText : "초기점검", 
				dataField : "early",
				style : "aui-center",
				children : [
					{
						headerText : "예정일자",
						dataField : "early_plan_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검일자",
						dataField : "early_check_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검자",
						dataField : "early_check_mem_name",
						width : "60",
						minWidth : "60",
						style : "aui-center",
					},
					{
						headerText : "비고",
						dataField : "early_remark",
						style : "aui-left",
						width : "150",
						minWidth : "150"
					},
				]
			},
			{ 
				headerText : "종료점검", 
				dataField : "end",
				style : "aui-center",
				children : [
					{
						headerText : "예정일자",
						dataField : "end_plan_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검일자",
						dataField : "end_check_dt",
						dataType : "date",
						formatString : "yy-mm-dd",
						width : "65",
						minWidth : "65",
						style : "aui-center",
					},
					{
						headerText : "점검자",
						dataField : "end_check_mem_name",
						width : "60",
						minWidth : "60",
						style : "aui-center",
					},
					{
						headerText : "비고",
						dataField : "end_reamrk",
						style : "aui-left",
						width : "150",
						minWidth : "150"
					},
				]
			},
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "body_no" ) {
 				var params = {
 					"s_machine_seq" : event.item.machine_seq
				};
 				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=800, left=0, top=0";
 				$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});	
		
		$("#auiGrid").resize();
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="s_org_code" name="s_org_code">
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
								<col width="100px">
								<col width="260px">
								<col width="40px">
								<col width="100px">
								<col width="55px">
								<col width="100px">
								<col width="65px">
								<col width="100px">
								<col width="65px">
								<col width="110px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<select class="form-control" id="s_date_type" name="s_date_type">
										<option value="in_dt">입고일자</option>
										<option value="out_dt">출하일자</option>
										<option value="sale_dt" selected="selected">예정일자</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청 시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청 종료일" value="${searchDtMap.s_end_dt}">
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
								<th>메이커</th>
								<td>
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>차주명</th>
								<td>
									<input type="text" class="form-control" id="s_cust_nmae" name="s_cust_name">
								</td>
								<th>차대번호</th>
								<td>
									<input type="text" class="form-control" id="s_body_no" name="s_body_no">
								</td>
								<th>판매부서</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="s_org_name" name="s_org_name" readonly="readonly">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('fnSetOrgMapPanel');" ><i class="material-iconssearch"></i></button>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
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