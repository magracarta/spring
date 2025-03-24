<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 담당지역관리현황 > 장비모델 별 분포
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-04-21 11:29:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	let auiGridTop;
	let auiGridBottom;
	
	$(document).ready(function() {
		createAUIGridTop();
		createAUIGridBottom();
	});
	
	// 엑셀다운로드
	function fnExcelDownload() {
		fnExportExcel(auiGridTop, "장비모델 별 분포");
	}

	// 닫기
    function fnClose() {
    	window.close();
    }
	
	// 장비모델 별 분포 그리드 생성
	function createAUIGridTop() {
		const gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : false,
			headerHeight : 40,
		};

		const columnLayout = [
			{ 
				headerText : "메이커", 
				dataField : "maker_name",
				style : "aui-center",
				width : "70",
			},
			{
				dataField: "maker_cd",
				visible: false
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				style : "aui-center",
			},
			{
				dataField : "machine_plant_seq",
				visible : false
			},
			{
				headerText : "총대수", 
				dataField : "total_cnt",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-popup",
				width : "60",
			},
			{
				headerText : "당년<br>매출비율",
				dataField : "amt_rate",
				style : "aui-center",
				width : "70",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value ? Math.round(value) + "%" : "";
				},
			},
			{
				headerText : "당년<br>매출금액",
				dataField : "this_amt",
				style : "aui-right",
				width : "100",
				dataType : "numeric",
				formatString : "#,###",
			},
			{ 
				headerText : "당년<br>월 가동시간",
				dataField : "this_mon_run_time",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-center",
				width : "70",
			},
			{ 
				headerText : "전년<br>매출금액",
				dataField : "last_amt",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-right",
				width : "100",
			},
			{ 
				headerText : "전년<br>월 가동시간",
				dataField : "last_mon_run_time",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-center",
				width : "70",
			},
			{ 
				headerText : "전전년<br>매출금액",
				dataField : "prev_amt",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-right",
				width : "100",
			},
			{ 
				headerText : "전전년<br>월 가동시간",
				dataField : "prev_mon_run_time",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-center",
				width : "70",
			},
		];

		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTop, ${list});
		$("#auiGridTop").resize();

		AUIGrid.bind(auiGridTop, "cellClick", function(event) {

			// 총대수 클릭 시, 장비목록 팝업 호출
			if (event.dataField == "total_cnt") {

				const param = {
					"s_center_org_code": '${inputParam.s_center_org_code}' ? '${inputParam.s_center_org_code}' : '${inputParam.s_org_code}',
					"s_start_dt" : '${inputParam.s_from_dt}',
					"s_end_dt" : '${inputParam.s_to_dt}',
					"s_sale_area_code" : '${inputParam.s_area_code}',
					"s_machine_plant_seq" : event.item.machine_plant_seq,
					// 23.07.11 채상무님 요청으로 미관리장비 제외
					"s_except_yk_yn" : "Y",
					"s_except_used_yn" : "Y",
					"s_except_rental_yn" : "Y",
					"s_except_agency_yn" : "Y", 
					"s_except_status_yn" : "Y", 
				};

				$M.goNextPage('/serv/serv0511p03', $M.toGetParam(param), {popupStatus : ''});
			}
		});
	}

	// 최대매출고객 그리드 생성
	function createAUIGridBottom() {
		const gridPros = {
			rowIdField : "_$uid",
		};

		const columnLayout = [
			{
				headerText : "고객명",
				dataField : "cust_name",
				style : "aui-popup",
				width : "130",
			},
			{
				dataField : "cust_no",
				visible : false
			},
			{
				headerText : "보유장비", 
				dataField : "machine_name",
				style : "aui-popup",
			},
			{ 
				headerText : "매출계", 
				dataField : "total_amt",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				width : "110",
			},
			{ 
				headerText : "정비매출", 
				dataField : "job_total_amt",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-right",
				width : "110",
			},
			{ 
				headerText : "부품매출", 
				dataField : "part_total_amt",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-right",
				width : "110",
			},
			{
				headerText : "렌탈매출", 
				dataField : "rental_total_amt",
				dataType : "numeric",
				formatString : "#,###",
				style : "aui-right",
				width : "110",
			},
		];
		
		auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridBottom, ${custList});
		$("#auiGridBottom").resize();

		AUIGrid.bind(auiGridBottom, "cellClick", function(event) {
			const param = {
				"cust_no" : event.item.cust_no,
			};

			if (event.dataField == "machine_name") {
				// 보유장비 클릭 시 [보유기종] 팝업 호출
				openHaveMachineCustPanel($M.toGetParam(param));

			} else if (event.dataField == "cust_name") {
				// 고객명 클릭 시 [고객정보상세] 팝업 호출
				$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : ""});
			}
		});
	}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="contents">
				<!-- 상단 - 장비모델 별 분포 -->
				<div class="title-wrap mt5">
					<div class="form-check form-check-inline">
						<h4>장비모델 별 분포 (${inputParam.target_name})</h4>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGridTop" style="margin-top: 5px; height: 350px;"></div>
				<!-- /상단 - 장비모델 별 분포 -->
				<!-- 하단 - 최대매출고객 -->
				<div class="title-wrap mt10">
					<h4>최대매출고객</h4>
				</div>
				<div id="auiGridBottom" style="margin-top: 5px; height: 288px;"></div>
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
				<!-- /하단 - 최대매출고객 -->
			</div>
		</div>
	</div>
	<!-- /contents 전체 영역 -->
</form>
</body>
</html>