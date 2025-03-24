<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > MBO집계표 > 센터 별 작성분 확인 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-03-27 16:57:11
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">

	var auiGrid;
	var mngYn = "${page.fnc.F04564_001}" // 관리자 권한 여부

	$(document).ready(function() {
		createAUIGrid();
		goSearchSaleMboSeqNo();
	});
	
	function init() {
		$M.setValue("s_maker_cd", "${inputParam.s_maker_cd}");
		$M.setValue("s_seq_no", "${inputParam.s_seq_no}");
	}
	
	// 조회년도의 MBO 차수 조회
	function goSearchSaleMboSeqNo() {
		var year = $M.getValue("s_search_year");
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
							init();
						}
					}
				}
		);
	}
	
	// 조회
	function goSearch() {
		if($M.getValue("s_center_org_code") == ""){
			alert("조회할 센터를 선택해주세요.");
			return false;
		}
		if($M.getValue("s_seq_no") == ""){
			alert("조회할 차수를 선택해주세요.");
			return false;
		}
		var param = {
			"s_search_year" : $M.getValue("s_search_year"),
			"s_maker_cd" : $M.getValue("s_maker_cd"),
			"s_center_org_code" : $M.getValue("s_center_org_code"),
			"s_seq_no" : $M.getValue("s_seq_no"),
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						AUIGrid.destroy("#auiGrid");// 년도별로 컬럼명이 변경되기 때문에 그리드 초기화
						auiGrid = null;
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
						fnGridDataSet(); // 조회 후 메이커 별 합계 세팅
					}
				}
		);
	}


	// 조회 후 메이커 별 합계 세팅
	function fnGridDataSet() {
		var gridData = AUIGrid.getGridData(auiGrid);
		var makerArr = [];
		// 계산 할 컬럼
		var columnArr = ["forecast_max", "forecast_avr", "forecast_min", "sale_expect_max", "sale_expect_avr", "sale_expect_min", "sale_qty"];
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



	// 닫기
	function fnClose() {
		window.close();
	}

	// 그리드 생성
	function createAUIGrid() {

		const gridPros = {
			showRowNumColumn : false,
			editable : false,
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
				if (item.machine_name.includes("합계")) {
					return "aui-grid-row-depth3-style";
				}
			}
		};

		let columnLayout = [
			{
				headerText : "모델명",
				dataField : "machine_name",
				style : "aui-center",
				// width : "150",
			},
			{
				headerText : "규격",
				dataField : "machine_sub_type_name",
				width : "80",
				style : "aui-center",
				cellMerge : true,
			},
			{
				dataField : "machine_plant_seq",
				visible: false,
			},
			{
				dataField : "machine_sub_type_cd",
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

		var centerColumn = {
			headerText : $M.getValue("s_search_year") + "년",
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
							width : "7%",
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
							width : "7%",
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
							width : "7%",
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
							width : "7%",
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
							width : "7%",
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
							width : "7%",
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
							width : "7%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.sale_expect_max > 0 && item.forecast_max > 0){
									var rate = Math.round(item.sale_expect_max / item.forecast_max * 100);
									if(isFinite(rate)){
										return rate;
									}
								}
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
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
							width : "7%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								if(item.sale_expect_avr > 0 && item.forecast_avr > 0){
									var rate = Math.round(item.sale_expect_avr / item.forecast_avr * 100);
									if(isFinite(rate)){
										return rate;
									}
								}
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
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
							width : "7%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.sale_expect_min > 0 && item.forecast_min > 0){
									var rate = Math.round(item.sale_expect_min / item.forecast_min * 100);
									if(isFinite(rate)){
										return rate;
									}
								}
							},
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value + "%";
							},
						},
					]
				},
				{
					headerText : "달성률",
					dataField : "mbo_achieve",
					children : [
						{
							headerText : "AVR",
							dataField : "mbo_achieve_avr",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center",
							width : "7%",
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
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value + "%";
							},
						},
					]
				},
			]
		};
		AUIGrid.addColumn(auiGrid, centerColumn, 'last');
		$("#auiGrid").resize();
	}



</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="sale_mbo_type_cd" id="sale_mbo_type_cd">
	<!-- 팝업 -->
    <div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
        <div class="main-title">
        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<!-- 컨텐츠 영역 -->
        <div class="content-wrap">
			<div class="contents">
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="80px">
							<col width="80px">
							<col width="50px">
							<col width="90px">
							<col width="40px">
							<col width="80px">
							<col width="30px">
							<col width="60px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="pr5">조회년월</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-12">
										<select class="form-control" id="s_search_year" name="s_search_year"  onchange="javascript:goSearchSaleMboSeqNo();">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+1}" step="1">
												<option value="${i}" <c:if test="${i == inputParam.s_current_year}">selected</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</td>
							<th class="pr5">메이커</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-12">
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y'}"> <!-- 영업대상여부 Y -->
													<option value="${item.code_value}" >${item.code_name}</option>
												</c:if>
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
											<option value="">- 선택 -</option>
											<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
												<c:if test="${list.code_value ne '6000'}">
													<option value="${list.code_value}" >${list.code_name}</option>
												</c:if>
											</c:forEach>
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
						</tr>
						</tbody>
					</table>
				</div>
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
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
        </div>
    </div>
	<!-- /팝업 -->
</form>
</body>
</html>