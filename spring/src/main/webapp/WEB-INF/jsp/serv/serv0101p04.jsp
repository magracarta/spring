<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 방문일지
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-22 19:54:29
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

		fnInit();
	});

	// 초기 Setting
	function fnInit() {
		var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
		$M.setValue("s_end_dt", $M.toDate(now));
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "처리일자", 
				dataField : "as_dt",
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				width : "10%"
			},
			{
				headerText : "처리자", 
				dataField : "reg_mem_name",
				style : "aui-center",
				width : "10%"
			},
			{ 
				headerText : "처리구분", 
				dataField : "type_name",
				style : "aui-center",
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					if(item.type_name != "매출") {
						return "aui-popup";
					}
				},
				width : "10%"
			},
			{ 
				headerText : "모델명", 
				dataField : "machine_name",
				style : "aui-center",
				width : "10%"
			},
			{ 
				headerText : "면담자", 
				dataField : "interview_mem_name",
				style : "aui-center",
				width : "10%"
			},
			{ 
				headerText : "처리내역1", 
				dataField : "remark1",
				style : "aui-left"
			},
			{ 
				headerText : "처리내역2", 
				dataField : "remark2",
				style : "aui-left"
			},
			{
				headerText : "AS번호",
				dataField : "as_no",
				visible : false
			},
			{
				headerText : "상담번호",
				dataField : "cust_counsel_seq",
				visible : false
			},
			{
				headerText : "장비번호",
				dataField : "machine_plant_seq",
				visible : false
			},
			{
				headerText : "전표번호",
				dataField : "inout_doc_no",
				visible : false
			},
			{
				headerText : "고객번호",
				dataField : "cust_no",
				visible : false
			}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "type_name" ) {
				var typeName = event.item.type_name;
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				var params = {
					"s_as_no" : event.item.as_no
				};

				switch (typeName) {
					case "출하일지" :
						$M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus : popupOption});
						break;
					case "정비일지" :
						$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus : popupOption});
						break;
					case "전화상담" :
						$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus : popupOption});
						break;
					case "상담일지" :
						// cust_consult_seq=0&cust_no=20130603145119670&own_machine_seq=100272
						var param = {
							"cust_no" : event.item.cust_no,
							"s_machine_plant_seq" : event.item.machine_plant_seq,
							"s_dt_yn": "N",
							// "s_start_dt" : event.item.as_dt,
							// "s_end_dt" : event.item.as_dt,
						};
						if (event.item.machine_plant_seq === "") {
							param.s_machine_plant_seq = "blank";
						}
						$M.goNextPage('/cust/cust0101p05', $M.toGetParam(param), {popupStatus : popupOption});
						break;
				}
			}
		});	
	}
	
	// 엑셀다운로드
	function fnExportExcel() {
		fnExportExcel(auiGrid, "방문일지");
    }

    // 조회
	function goSearch() {
		var param = {
			"s_start_dt": $M.getValue("s_start_dt"),
			"s_end_dt": $M.getValue("s_end_dt"),
			"s_cust_no" : $M.getValue("s_cust_no"),
			"s_type_cd" : $M.getValue("s_type_cd")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
				function (result) {
					if (result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
		);
    }

	// 닫기
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="s_cust_no" name="s_cust_no" value="${inputParam.cust_no}">
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
							<col width="50px">
							<col width="270px">
							<col width="50px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>조회기간</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="조회 시작일">
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="조회 종료일">
										</div>
									</div>
								</div>
							</td>
							<th>처리구분</th>
							<td>
								<select class="form-control" id="s_type_cd" name="s_type_cd">
									<option value="">- 전체 -</option>
									<option value="0">상담</option>
									<option value="1">서비스</option>
								</select>
							</td>
							<td class="">
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
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
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