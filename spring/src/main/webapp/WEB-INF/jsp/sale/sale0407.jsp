<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > MBO > MBO등록 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-03-15 10:15:49
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var centerYn = "${page.fnc.F04463_003}"
		var auiGrid;
		var searchOrgCode = []; // 영업담당자 담당센터 전체 조회하기 위함
		var searchOrgName = ""; // 조회하는 센터
		var nextYearMboYn = "N";
		var hideList = ["sale_amt"]; // 매출액
		$(document).ready(function() {
			createAUIGrid();
			if("${page.fnc.F04463_003}" == "Y"){
				$("#s_sale_mem_no").prop("disabled", true); // 영업담당자 disabled
				$("#s_center_org_code").prop("disabled", true); // 센터 disabled
			} else if("${page.fnc.F04463_004}" != "Y"){ // 관리자가 아닌 경우
				$("#toggle_label").addClass("dpn"); // 관리자급 아니면 펼침 숨김
				goSearchCenter();
				$("#s_sale_mem_no").prop("disabled", true); // 영업담당자 disabled
			} else {
				goSearchCenter();
			}
			goSearchSaleMboSeqNo();
		});

		// 영업담당자 선택 시 담당센터 조회 및 세팅
		function goSearchCenter() {
			searchOrgCode = []; // 조회센터 초기화
			searchOrgName = ""; // 조회센터이름 초기화
			var saleMemNo = $M.getValue("s_sale_mem_no");
			$("select#s_center_org_code option").remove();
			$('#s_center_org_code').append('<option value="" >'+ "- 전체 -" +'</option>');
			// 전체센터 세팅
			if(saleMemNo == ""){
				var warehouseJson = JSON.parse('${codeMapJsonObj['WAREHOUSE']}');
				for(var i = 0; i < warehouseJson.length; i++){
					if(warehouseJson[i].code_value != "6000") {
						var optVal = warehouseJson[i].code_value;
						var optText = warehouseJson[i].code_name;
						$('#s_center_org_code').append('<option value="' + optVal + '">' + optText + '</option>');
						searchOrgCode.push(optVal);
						if(searchOrgName == ""){
							searchOrgName = optText;
						} else {
							searchOrgName += ", " + optText;
						}
					}
				}
			} else {
				// 선택한 영업담당자의 담당센터 조회
				$M.goNextPageAjax(this_page + "/searchCenter" + "/" + saleMemNo, "", {method: "get"},
						function (result) {
							if (result.success) {
								for (i = 0; i < result.list.length; i++) {
									var optVal = result.list[i].center_org_code;
									var optText = result.list[i].center_org_name;
									$('#s_center_org_code').append('<option value="' + optVal + '">' + optText + '</option>');
									searchOrgCode.push(optVal);
									if(searchOrgName == ""){
										searchOrgName = optText;
									} else {
										searchOrgName += ", " + optText;
									}
								}
							}
						}
				);
			}
		}
		
		// 조회년도의 MBO 차수 조회
		function goSearchSaleMboSeqNo() {
			var year = $M.getValue("s_year");
			$("select#s_seq_no option").remove();
			$('#s_seq_no').append('<option value="" >'+ "- 선택 -" +'</option>');

			// 선택한 년도의 차수 조회
			$M.goNextPageAjax("/sale/sale0407p01/searchMboSeqNo" + "/" + year, "", {method: "get"},
					function (result) {
						if (result.success) {
							for (i = 0; i < result.list.length; i++) {
								var optVal = result.list[i].seq_no;
								var optText = result.list[i].seq_no + "차";
								$('#s_seq_no').append('<option value="' + optVal + '">' + optText + '</option>');
							}
						}
					}
			);
		}
		function goSearch() {
			if($M.getValue("s_sale_mbo_type_cd") == ""){
				alert("조회할 작성분을 선택해주세요.");
				return false;
			}
			if($M.getValue("s_seq_no") == ""){
				alert("조회할 차수를 선택해주세요.");
				return false;
			}
			var param = {
				"s_year" : $M.getValue("s_year"),
				"s_mon" : $M.getValue("s_mon").length == 1 ? "0" + $M.getValue("s_mon") : $M.getValue("s_mon"),
				"s_center_org_code" : $M.getValue("s_center_org_code") == "" ? searchOrgCode : $M.getValue("s_center_org_code"),
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_sale_mbo_type_cd" : $M.getValue("s_sale_mbo_type_cd"),
				"s_seq_no" : $M.getValue("s_seq_no"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "get"},
					function (result) {
						if (result.success) {
							nextYearMboYn = result.nextYearMboYn;
							if($M.getValue("s_center_org_code") == ""){
								$("#s_center_org_name").text("(" + searchOrgName + ")"); // 영업담당자 담당센터 전체 조회 시 센터 이름 세팅
							} else {
								$("#s_center_org_name").text("(" + $("#s_center_org_code option:checked").text() + ")"); // 조회한 센터 이름 세팅
							}
							AUIGrid.destroy("#auiGrid"); // 년도별로 컬럼명이 변경되기 때문에 그리드 초기화
							auiGrid = null;
							createAUIGrid();
							AUIGrid.setGridData(auiGrid, result.treeList);
							fnGridDataSet(); // 조회 후 메이커 별 합계 계산
							// 조회년월의 MS자료가 없으면 MS 컬럼 색상변경
							if(result.msYn == "N"){
								AUIGrid.setColumnPropByDataField(auiGrid,"ms", {headerStyle : "aui-bg-warning"})
								alert("조회하신 월의 MS자료가 아직 적용되지 않았습니다.");
							} else {
								AUIGrid.setColumnPropByDataField(auiGrid,"ms", {headerStyle : ""})
							}
						}
					}
			);
		}

		// 합계 계산
		function fnGridDataSet() {
			var gridData = AUIGrid.getGridData(auiGrid);
			var makerArr = [];
			// 계산 할 컬럼
			var columnArr = ["bef_ms_qty", "bef_sale_qty", "forecast_max", "forecast_avr", "forecast_min", "bef_sale_expect_avr",
							"bef_forecast_avr", "sale_expect_max", "sale_expect_avr", "sale_expect_min", "sale_qty", "sale_amt", "ms_qty"];
			var sumObj = {}; // 컬럼 별 합계 저장
			var sumSObj = {}; // 얀마 미니 컬럼 별 합계 저장
			var sumLObj = {}; // 얀마 대형 컬럼 별 합계 저장

			// 메이커 목록
			for(var i = 0; i < gridData.length; i++){
				if(makerArr.includes(gridData[i].maker_name) == false && gridData[i].maker_name != ""){
					makerArr.push(gridData[i].maker_name);
				}
			}
			// 합계 산출
			for(var i=0; i<columnArr.length; i++){
				sumObj[columnArr[i]] = 0;
				sumSObj[columnArr[i]] = 0;
				sumLObj[columnArr[i]] = 0;
				for(var l=0; l < makerArr.length; l++){ // 메이커 별
					var subTyperArr = [];
					for(var j=0; j < gridData.length; j++){
						if(gridData[j].maker_name == makerArr[l] && gridData[j][columnArr[i]] != ""){
							if(subTyperArr.includes(gridData[j].machine_sub_type_cd) == false){ // 셀 병합되어있으면 한번만 더하기 위함
								subTyperArr.push(gridData[j].machine_sub_type_cd);
								sumObj[columnArr[i]] += $M.toNum(gridData[j][columnArr[i]]);
								if(gridData[j].maker_cd == "27" && gridData[j].machine_sub_type_cd <= "0104" || gridData[j].machine_sub_type_cd == "0111" || gridData[j].machine_sub_type_cd == "0109"){
									sumSObj[columnArr[i]] += $M.toNum(gridData[j][columnArr[i]]);
								} else{
									sumLObj[columnArr[i]] += $M.toNum(gridData[j][columnArr[i]]);
								}
							}
						}
					}
					for(var k=0; k < gridData.length; k++){
						if(gridData[k].machine_name == makerArr[l] + " 합계"){
							var item = {};
							item[columnArr[i]] = sumObj[columnArr[i]];
							AUIGrid.updateRow(auiGrid, item, k, false)
							sumObj[columnArr[i]] = 0;
						} else if(makerArr[l] == "얀마" && gridData[k].machine_name == "미니 합계"){
							var item = {};
							item[columnArr[i]] = sumSObj[columnArr[i]];
							AUIGrid.updateRow(auiGrid, item, k, false)
							sumSObj[columnArr[i]] = 0;
						} else if(makerArr[l] == "얀마" && gridData[k].machine_name == "대형 합계"){
							var item = {};
							item[columnArr[i]] = sumLObj[columnArr[i]];
							AUIGrid.updateRow(auiGrid, item, k, false)
							sumLObj[columnArr[i]] = 0;
						}
					}
				}
			}


		}

		// 펼침
		function fnChangeColumn(event) {
			var checked = $("input:checkbox[id='s_toggle_column']").is(":checked");
			if (checked) {
				AUIGrid.showColumnByDataField(auiGrid, hideList);
			} else {
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
			}
		}

		// MBO 등록기간 내 등록
		function goAdd() {
            // 현재 등록기간인 MBO 차수 조회
            $M.goNextPageAjax("/sale/sale0407/searchMboSeq", "", {method: "get"},
                function (result) {
                    if (result.success) {
						var params = {
							"sale_mbo_type_cd" : centerYn == "Y" ? "C" : "S", // C:센터, S:영업, M:관리자(관리자는 집계표만 작성가능)
							"sale_mbo_seq_no" : result.seq_no, // 현재 시점 기준 MBO 차수
							"sale_mbo_year" : result.sale_mbo_year, // 현재 시점 기준 MBO 년도
						};
						var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=800, left=0, top=0";
						$M.goNextPage('/sale/sale0407p01', $M.toGetParam(params), {popupStatus : popupOption});
                    }
                }
            );
		}


		// MBO 차수 별 등록기간 관리 팝업 호출
		function goMboPeriod() {
			var param = {

			};

			var poppupOption = "";
			$M.goNextPage('/sale/sale0407p03', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			// 엑셀 내보내기 속성
			var exportProps = {
				// 제외항목
				exceptColumnFields : ["sale_amt"]
			};
			if("${page.fnc.F04463_004}" == "Y"){
				fnExportExcel(auiGrid, "마케팅 MBO");
			} else {
				fnExportExcel(auiGrid, "마케팅 MBO", exportProps);
			}
		}
		// 그리드 생성
		function createAUIGrid() {

			var gridPros = {
				showRowNumColumn : false,
				editable : false,
				// showEditedCellMarker : false,
				// rowBackgroundStyles : [], // 세로 셀 병합 후 그리드 깨질때 해결방법
				// 트리 펼치기
				displayTreeOpen : true,
				treeColumnIndex : 0,
				rowCheckDependingTree : true,
				// 셀 병합 실행
				enableCellMerge : true,
				cellMergeRowSpan:  true,
				cellMergePolicy: "withNull", // null 도 하나의 값으로 간주하여 다수의 null 을 병합된 하나의 공백으로 출력
				enableMovingColumn : false,
				rowStyleFunction : function(rowIndex, item) {
					if(item.machine_name.indexOf("합계") != -1) {
						return "aui-grid-row-depth3-style";
					}
					return "";
				},
			};

			var columnLayout = [
				{
					headerText : "모델명",
					dataField : "machine_name",
					style : "aui-center",
					width : "150",
					editable : false,
				},
				{
					headerText : "규격",
					dataField : "machine_sub_type_name",
					width : "80",
					style : "aui-center",
					editable : false,
					cellMerge : true,
				},
				{
					dataField : "sale_mbo_seq",
					visible: false,
				},
				{
					dataField : "machine_plant_seq",
					visible: false,
				},
				{
					dataField : "maker_cd",
					visible : false,
				},
				{
					dataField : "maker_name",
					visible : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			var before_year = $M.getValue("s_year") - 1;
			var current_year = $M.getValue("s_year");
			var beforeColumn = {
				headerText : before_year + "년",
				children : [
					{
						headerText : "수요",
						children : [
							{
								headerText : "AVR",
								dataField : "bef_ms_qty",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
							{
								dataField : "bef_forecast_avr", // MS 계산하기 위함
								visible : false,
							},
						]
					},
					{
						headerText : "판매(실제판매)",
						children : [
							{
								headerText : "MAX",
								dataField : "bef_sale_qty",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "6.5%",
							},
							{
								dataField : "bef_sale_expect_avr",
								visible : false,
							}
						]
					},
					{
						headerText : "MS",
						children : [
							{
								headerText : "AVR",
								dataField : "bef_ms_avr",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
								expFunction : function(rowIndex, columnIndex, item, dataField ) {
									// MS수요 / 수요예상 %
									if(item.bef_ms_qty > 0 && item.bef_forecast_avr > 0){
										var rate = Math.round(item.bef_ms_qty / item.bef_forecast_avr * 100);
										if(isFinite(rate)){
											return rate;
										}
									}
								},
								labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
									value = AUIGrid.formatNumber(value, "#,###");
									return value == 0 ? "" : value + "%";
								},
							}
						]
					},
					{
						headerText : "달성률",
						children : [
							{
								headerText : "AVR",
								dataField : "before_year_mbo_rate_avr",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
								expFunction : function(rowIndex, columnIndex, item, dataField ) {
									// 판매수량 / 판매예상 %
									if(item.bef_sale_qty > 0 && item.bef_sale_expect_avr > 0){
										var rate = Math.round(item.bef_sale_qty / item.bef_sale_expect_avr * 100);
										if(isFinite(rate)){
											return rate;
										}
									}
								},
								labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
									value = AUIGrid.formatNumber(value, "#,###");
									return value == 0 ? "" : value + "%";
								},
							}
						]
					},
				]
			};
			AUIGrid.addColumn(auiGrid, beforeColumn, 'last');

			var currentColumn = {
				headerText : current_year + "년",
				children : [
					{
						headerText : "수요예상",
						children : [
							{
								headerText : "MAX",
								dataField : "forecast_max",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
							{
								headerText : "AVR",
								dataField : "forecast_avr",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
							{
								headerText : "MIN",
								dataField : "forecast_min",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
						]
					},
					{
						headerText : "수요",
						children : [
							{
								headerText : "실수요",
								dataField : "ms_qty",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
						]
					},
					{
						headerText : "판매예상(목표)",
						children : [
							{
								headerText : "MAX",
								dataField : "sale_expect_max",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
							{
								headerText : "AVR",
								dataField : "sale_expect_avr",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
							{
								headerText : "MIN",
								dataField : "sale_expect_min",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
							},
						]
					},
					{
						headerText : "판매(실제판매)",
						children : [
							{
								headerText : "수량",
								dataField : "sale_qty",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "6.5%",
							},
							{
								headerText : "매출액",
								dataField : "sale_amt",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								headerStyle : "aui-fold",
								style : "aui-right",
								width : "10%",
							},
						]
					},
					{
						headerText : "MS",
						dataField : "ms",
						children : [
							{
								headerText : "MAX",
								dataField : "ms_max",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
								expFunction : function(rowIndex, columnIndex, item, dataField ) {
									// 판매예상 / 수요예상 %
									if(nextYearMboYn == "Y" && item.sale_expect_max > 0 && item.forecast_max > 0){
										var rate = Math.round(item.sale_expect_max / item.forecast_max * 100);
										if(isFinite(rate)){
											return rate;
										}
									}
								},
								labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
									value = AUIGrid.formatNumber(value, "#,###");
									return value == 0 ? "" : value + "%";
								},
							},
							{
								headerText : "AVR",
								dataField : "ms_avr",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
								expFunction : function(rowIndex, columnIndex, item, dataField ) {
									if(nextYearMboYn == "Y" && item.sale_expect_avr > 0 && item.forecast_avr > 0){
										var rate = Math.round(item.sale_expect_avr / item.forecast_avr * 100);
										if(isFinite(rate)){
											return rate;
										}
									} else if(item.ms_qty > 0 && item.forecast_avr > 0){
										// MS수량 / 수요예상 %
										var rate = Math.round(item.ms_qty / item.forecast_avr * 100);
										if(isFinite(rate)){
											return rate;
										}
									}
								},
								labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
									value = AUIGrid.formatNumber(value, "#,###");
									return value == 0 ? "" : value + "%";
								},
							},
							{
								headerText : "MIN",
								dataField : "ms_min",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
								expFunction : function(rowIndex, columnIndex, item, dataField ) {
									// 판매예상 / 수요예상 %
									if(nextYearMboYn == "Y" && item.sale_expect_min > 0 && item.forecast_min > 0){
										var rate = Math.round(item.sale_expect_min / item.forecast_min * 100);
										if(isFinite(rate)){
											return rate;
										}
									}
								},
								labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
									value = AUIGrid.formatNumber(value, "#,###");
									return value == 0 ? "" : value + "%";
								},
							},
						]
					},
					{
						headerText : "달성률",
						children : [
							{
								headerText : "AVR",
								dataField : "mbo_rate_avr",
								cellMerge: true,
								mergeRef: "machine_sub_type_name",
								mergePolicy: "restrict",
								dataType : "numeric",
								formatString: "#,###",
								style : "aui-center",
								width : "4%",
								expFunction : function(rowIndex, columnIndex, item, dataField ) {
									// 판매수량 / 판매예상 %
									if(item.sale_qty > 0 && item.sale_expect_avr > 0){
										var rate = Math.round(item.sale_qty / item.sale_expect_avr * 100);
										if(isFinite(rate)){
											return rate;
										}
									}
								},
								labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
									value = AUIGrid.formatNumber(value, "#,###");
									return value == 0 ? "" : value + "%";
								},
							},
						]
					},
				]
			};
			AUIGrid.addColumn(auiGrid, currentColumn, 'last');
			$("#auiGrid").resize();
			// Default : 매출액컬럼 Hide
			AUIGrid.hideColumnByDataField(auiGrid, hideList);
		}

	</script>
</head>
<body class="bg-white">
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
								<col width="75px">
								<col width="120px">
								<col width="50px">
								<col width="90px">
								<col width="70px">
								<col width="90px">
								<col width="30px">
								<col width="90px">
								<col width="50px">
								<col width="90px">
								<col width="40px">
								<col width="70px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<select class="form-control" id="s_year" name="s_year" onchange="javascript:goSearchSaleMboSeqNo()">
												<c:forEach var="i" begin="2000" end="${inputParam.current_year + 1}" step="1">
													<option value="${i}" <c:if test="${i == inputParam.current_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-5">
											<select class="form-control" id="s_mon" name="s_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i == inputParam.current_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>메이커</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<select class="form-control" id="s_maker_cd" name="s_maker_cd">
												<option value="">- 전체 -</option>
												<c:forEach items="${codeMap['MAKER']}" var="item">
													<c:if test="${item.code_v1 eq 'Y' }">
														<option value="${item.code_value}" >${item.code_name}</option>
													</c:if>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>마케팅담당자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<select class="form-control" id="s_sale_mem_no" name="s_sale_mem_no" onchange="javascript:goSearchCenter();" >
												<option value="">- 전체 -</option>
												<c:forEach items="${saleMemList}" var="item">
													<option value="${item.sale_mem_no}" ${page.fnc.F04463_004 ne 'Y' and item.sale_mem_no == SecureUser.mem_no ? 'selected' : '' }>${item.sale_mem_name}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>센터</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<select class="form-control" id="s_center_org_code" name="s_center_org_code">
												<option value="">- 전체 -</option>
												<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
													<c:if test="${list.code_value ne '6000'}">
														<c:if test="${page.fnc.F04463_003 eq 'Y' && list.code_value ne '5010'}"><option value="${list.code_value}" ${list.code_value == (SecureUser.warehouse_cd ne '' ? SecureUser.warehouse_cd : SecureUser.org_code) ? 'selected' : 'item.code_value' }>${list.code_name}</c:if></option>
													</c:if>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>작성구분</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<select class="form-control" id="s_sale_mbo_type_cd" name="s_sale_mbo_type_cd">
												<option value="">- 선택 -</option>
												<option value="C">센터인원</option>
												<option value="S">마케팅담당자</option>
											</select>
										</div>
									</div>
								</td>
								<th>차수</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<select class="form-control" id="s_seq_no" name="s_seq_no">
												<option value="">- 선택 -</option>
											</select>
										</div>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch()">조회</button>
								</td>
								<td style="text-align : right;">
									<span class="text-warning">※ 차년도 전체목표조회는 11월 기준입니다.</span>
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
							<div class="form-row inline-pd" id="s_center_org_name" name="s_center_org_name" style="margin-left: 5px;"></div>
							<div class="right">
								<span class="text-warning">※ 당사 렌탈출고수량은 판매(실제판매)수량에서 제외</span>
								<label id="toggle_label" for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn()">펼침
								</label>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
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