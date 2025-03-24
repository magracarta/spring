<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > MBO집계표 > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-24 16:22:30
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">

	let auiGrid;
	let hideList = ["sale_amt", "sale_price"]; // 매출액, 기준판매가
	const mngYn = "${page.fnc.F04563_001}" // 관리자 여부

	$(document).ready(function() {
		createAUIGrid();
		if(mngYn != "Y"){
			$("#toggle_label").addClass("dpn"); // 관리자급 아니면 펼침 숨김
		}
		// Default : 매출액컬럼 Hide
		AUIGrid.hideColumnByDataField(auiGrid, hideList);
	});

	// [MBO집계표등록] 화면 호출
	function goAdd() {
		// TODO
		const params = {
			"s_maker_cd" : $M.getValue("s_maker_cd")
		};
		$M.goNextPage('/sale/sale0408p01', $M.toGetParam(params), {popupStatus : ""});
	}

	// 조회
	function goSearch() {
		const param = {
			"s_search_year" : $M.getValue("s_search_year"),
			"s_maker_cd" : $M.getValue("s_maker_cd"),
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success && result.treeList) {
						AUIGrid.destroy("#auiGrid"); // 년도별로 컬럼명이 변경되기 때문에 그리드 초기화
						auiGrid = null;
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.treeList);
						fnChangeColumn();
						fnGridDataSet(); // 조회 후 메이커 별 합계 계산
					}
				}
		);
	}

	// 합계 계산
	function fnGridDataSet() {
		var gridData = AUIGrid.getGridData(auiGrid);
		var makerArr = [];
		// 계산 할 컬럼
		var columnArr = ["forecast_max", "forecast_avr", "forecast_min", "sale_expect_max", "sale_expect_avr", "sale_expect_min", "sale_qty", "sale_amt"];
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
	function fnChangeColumn() {
		var checked = $("input:checkbox[id='s_toggle_column']").is(":checked");
		if (checked) {
			AUIGrid.showColumnByDataField(auiGrid, hideList);
		} else {
			AUIGrid.hideColumnByDataField(auiGrid, hideList);
		}
	}

	// 엑셀다운로드
	function fnDownloadExcel() {
		var exportProps = {
			// 제외항목
			exceptColumnFields : ["sale_amt", "sale_price"]
		};
		if(mngYn == "Y"){
			fnExportExcel(auiGrid, "마케팅 MBO 집계표");
		} else {
			fnExportExcel(auiGrid, "마케팅 MBO 집계표", exportProps);
		}
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
				width : "150",
			},
			{
				headerText : "기준판매가",
				dataField : "sale_price",
				dataType : "numeric",
				formatString: "#,###",
				headerStyle : "aui-fold",
				style : "aui-right",
				width : "8%",
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

		var mngColumn = {
			headerText : $M.getValue("s_search_year") + "년" ,
			headerStyle : "my-column-style",
			children : [
				{
					headerText : "수요예상",
					children : [
						{
							headerText : "MAX",
							dataField : "forecast_max",
							style : "aui-center",
							width : "5%",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
						},
						{
							headerText : "AVR",
							dataField : "forecast_avr",
							style : "aui-center",
							width : "5%",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
						},
						{
							headerText : "MIN",
							dataField : "forecast_min",
							style : "aui-center",
							width : "5%",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
						},
					]
				},
				{
					headerText : "판매예상(목표)",
					children : [
						{
							headerText : "MAX",
							dataField : "sale_expect_max",
							style : "aui-center",
							width : "5%",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
						},
						{
							headerText : "AVR",
							dataField : "sale_expect_avr",
							style : "aui-center",
							width : "5%",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
						},
						{
							headerText : "MIN",
							dataField : "sale_expect_min",
							style : "aui-center",
							width : "5%",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							},
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
							headerText : "판매액",
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
							width : "5%",
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
							width : "5%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								if(item.sale_expect_avr > 0 && item.forecast_avr > 0){
									var rate = Math.round(item.sale_expect_avr / item.forecast_avr * 100);
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
							width : "5%",
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
								value = AUIGrid.formatNumber(value, "#,###");
								return value == 0 ? "" : value + "%";
							},
						},
					]
				},
				{
					headerText : "달성률",
					headerStyle : "my-column-style",
					dataField : "mbo_achieve",
					children : [
						{
							headerText : "AVR",
							headerStyle : "my-column-style",
							dataField : "mbo_achieve_avr",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center",
							width : "5%",
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
		AUIGrid.addColumn(auiGrid, mngColumn, 'last');
		$("#auiGrid").resize();
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
								<col width="80px">
								<col width="80px">
								<col width="60px">
								<col width="120px">
								<col width="70px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="pr5">조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<select class="form-control" id="s_search_year" name="s_search_year">
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