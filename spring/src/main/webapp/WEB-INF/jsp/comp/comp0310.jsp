<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > 고객렌탈이력 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-05-03 09:35:45
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
		fnExportExcel(auiGrid, '고객렌탈이력');
	}

	// 그리드 생성
	function createAUIGrid() {
		const gridPros = {
			showRowNumColumn: true,
			rowIdField : "_$uid",
			enableSorting : true,
			headerHeight : 40,
		};

		const columnLayout = [
			{
				headerText : "전표일자",
				dataField : "inout_dt",
				width : "100",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{
				headerText : "전표번호",
				dataField : "inout_doc_no",
				width : "120",
			},
			{
				headerText : "고객업종",
				dataField : "breg_cor_part",
				width : "100",
			},
			{
				headerText : "업체유형",
				dataField : "breg_type_name",
				width : "90",
			},
			{
				dataField: "breg_type_cd",
				visible: false
			},
			{
				headerText : "지사장비<br>보유",
				dataField : "own_yk_mch_yn",
				width : "60",
			},
			{
				headerText : "렌탈기종",
				dataField : "machine_name",
				width : "100",
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				width : "120",
			},
			{
				headerText : "접수자",
				dataField : "receipt_mem_name",
				width : "70",
			},
			{
				dataField : "receipt_mem_no",
				visible : false
			},
			{
				headerText: "렌탈시작",
				dataField : "rental_st_dt",
				width: "80",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{
				headerText: "렌탈종료",
				dataField : "rental_ed_dt",
				width: "80",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{
				headerText: "렌탈기간<br>(일)",
				dataField : "day_cnt",
				width: "60"
			},
			{
				headerText: "렌탈금액",
				dataField : "rental_amt",
				width: "100",
				dataType : "numeric",
				formatString: "#,###",
			},
			{
				headerText: "출고 시<br>가동시간",
				dataField : "out_op_hour",
				width: "60",
				dataType : "numeric",
				formatString: "#,###",
			},
			{
				headerText: "회수 시<br>가동시간",
				dataField : "return_op_hour",
				width: "60",
				dataType : "numeric",
				formatString: "#,###",
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
					<h4>렌탈이력결과</h4>
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