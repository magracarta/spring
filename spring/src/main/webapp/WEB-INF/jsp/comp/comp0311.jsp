<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 렌탈상담이력(방문일지) > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-05-03 14:08:47
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">

	let auiGrid;

	$(document).ready(function() {
		var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
		$M.setValue("s_end_dt", $M.toDate(now));

		createAUIGrid();
		goSearch();
	});

	// 조회
	function goSearch() {
		const param = {
			"s_start_dt" : $M.getValue("s_start_dt")	// 조회기간 From
			, "s_end_dt" : $M.getValue("s_end_dt")		// 조회기간 To
			, "s_cust_no" : '${inputParam.s_cust_no}'   // 고객번호
		}

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
			function(result) {
				if (result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					$("#total_cnt").html(result.total_cnt);
				}
			}
		);
	}

	// 팝업 닫기
	function fnClose() {
		window.close();
	}

	// 엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, '렌탈상담이력(방문일지)');
	}

	// 그리드 생성
	function createAUIGrid() {
		const gridPros = {
			showRowNumColumn: true,
			rowIdField : "_$uid",
			enableSorting : true,
			headerHeight : 30,
		};

		const columnLayout = [
			{
				headerText : "처리일자",
				dataField : "consult_dt",
				width : "100",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{
				headerText : "처리자",
				dataField : "mng_mem_name",
				width : "80",
			},
			{
				dataField: "mng_mem_no",
				visible: false
			},
			{
				headerText : "처리구분",
				dataField : "type_gubun",
				width : "70",
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				width : "110",
			},
			{
				dataField: "machine_plant_seq",
				visible: false
			},
			{
				headerText : "면담자",
				dataField : "interview_mem_name",
				width : "80",
			},
			{
				dataField : "interview_mem_no",
				visible : false
			},
			{
				headerText : "처리내역",
				dataField : "consult_text",
				style : "aui-left",
			},
			{
				headerText : "상담구분",
				dataField : "consult_type_name",
				width : "60",
			},
			{
				dataField : "consult_type_cd",
				visible : false
			},
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.resize(auiGrid);
	}

</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
    <div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<!-- /타이틀영역 -->
		<!-- 컨텐츠 영역 -->
        <div class="content-wrap">
			<div>
				<div>
					<a class="font-16" style="font-weight: bold; font-family: 'NG';">${cust_name}</a>
					<a class="font-16">님</a>
					<a class="font-16" style="margin-right: 10px; margin-left: 10px;">|</a>
					<a class="font-16" style="font-weight: bold; font-family: 'NG;">${hp_no}</a>
					<a class="font-16" style="margin-right: 10px; margin-left: 10px;">|</a>
					<a class="font-16" style="font-weight: bold; font-family: 'NG;">${breg_name}</a>
				</div>
				<!-- 검색영역 -->
				<div class="search-wrap mt10">
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="240px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>조회기간</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col width110px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="조회 시작일">
											</div>
										</div>
										<div class="col width16px text-center">~</div>
										<div class="col width110px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="조회 완료일">
											</div>
										</div>
									</div>
								</td>
								<td>
									<button type="button" onclick="goSearch()" class="btn btn-important" style="width: 50px;">조회</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div class="title-wrap mt5">
					<h4>렌탈상담이력(방문일지) 결과</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
                <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
			</div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
		<!-- /컨텐츠 영역 -->
    </div>
	<!-- /팝업 -->
</form>
</body>
</html>