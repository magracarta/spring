<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > MBO집계표 > MBO집계표등록 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-03-27 16:57:11
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<style>
	/* 커스텀 행 스타일 (세로선) */
	.my-column-style {
		border-right: 1px solid #000000 !important;
	}
</style>
<script type="text/javascript">

	var auiGrid;
	var mngYn = "${page.fnc.F04564_001}" // 관리자 권한 여부

	$(document).ready(function() {
		createAUIGrid();
		goSearchSaleMboSeqNo();
	});
	
	function init() {
		$M.setValue("s_maker_cd", "${inputParam.s_maker_cd}");
		$M.setValue("s_seq_no", "${seq_no}");
		
		setTimeout(function(){
			goSearch();
		}, 100);
	}
	// 조회
	function goSearch() {

		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		if (changeGridData.length != 0) {
			if(confirm("조회 시 작성한 내용이 사라집니다. 계속하시겠습니까?") == false){
				return false;
			}
		}
		
		if($M.getValue("s_seq_no") == ""){
			alert("차수를 선택해주세요.");
			return false;
		}
		const param = {
			"s_search_year" : $M.getValue("s_search_year"),
			"s_maker_cd" : $M.getValue("s_maker_cd"),
			"s_seq_no" : $M.getValue("s_seq_no"),
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						$M.setValue("sale_mbo_year", $M.getValue("s_search_year"));
						AUIGrid.destroy("#auiGrid");// 년도별로 컬럼명이 변경되기 때문에 그리드 초기화
						auiGrid = null;
						createAUIGrid();
						AUIGrid.setGridData(auiGrid, result.list);
						fnGridDataSet(); // 조회 후 메이커 별 합계 세팅
						fnChangeColumn(); // 조회년도에 따라 달성률 컬럼 숨김
					}
				}
		);
	}

	// 조회년도에 따라 달성률 컬럼 숨김
	function fnChangeColumn() {
		var hideList = ["center_mbo_achieve", "mng_mbo_achieve", "center_mbo_achieve_avr", "mng_mbo_achieve_avr"]; // 달성률 컬럼
		if ($M.getValue("s_search_year") > "${inputParam.s_current_year}") { // 차년도 작성분 조회 시 달성률 컬럼 숨김
			AUIGrid.hideColumnByDataField(auiGrid, hideList);
		} else { // 지난년도 작성분 조회 시 달성률 컬럼 노출
			AUIGrid.showColumnByDataField(auiGrid, hideList);
		}
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
	
	// 합계 계산
	function fnGridDataSet() {
		var gridData = AUIGrid.getGridData(auiGrid);
		var makerArr = [];
		// 계산 할 컬럼
		var columnArr = ["forecast_max", "forecast_avr", "forecast_min", "sale_expect_max", "sale_expect_avr", "sale_expect_min", "sale_qty"
						, "center_forecast_max", "center_forecast_avr", "center_forecast_min", "center_sale_expect_max", "center_sale_expect_avr", "center_sale_expect_min"];
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

	//  병합된 모든 행의 값를 동기화 시킴.
	function syncData(rowIndex, dataField, oldValue, value, rowStateFlag) {
		var gridData = AUIGrid.getGridData(auiGrid);
		var mergedIndex = AUIGrid.getMergeEndRowIndex(auiGrid, rowIndex, 1); // 세로 병합된 셀에 대하여 해당 병합의 마지막 행 인덱스를 반환
		var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
		var items = [];
		var row;
		var obj;
		if(rowStateFlag){ // 수정취소 시 인덱스 수정
			rowIndex --;
		}
		for(var i=rowIndex+1; i<mergedIndex+1; i++) {
			row = gridData[i];
			if(row[dataField] == oldValue) {
				obj = {};
				obj[rowIdField] = row[rowIdField];
				obj[dataField] = value;
				items.push(obj);
			} else {
				break;
			}
		}
		// 동일하게 변경
		AUIGrid.updateRowsById(auiGrid, items);
	};

	function goSave(){
		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGrid, false);

		var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
		if (changeGridData.length == 0) {
			alert("변경된 데이터가 없습니다.");
			return false;
		}
		if (confirm("저장 하시겠습니까?") == false) {
			return false;
		}
		$M.copyForm(gridFrm, frm);

		$M.goNextPageAjax("/sale/sale0408p01/save", gridFrm , {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					}
				}
		);

	}

	// 닫기
	function fnClose() {
		window.close();
	}

	// 그리드 생성
	function createAUIGrid() {

		const gridPros = {
			rowIdField : "machine_plant_seq",
			showStateColumn : true,
			showRowNumColumn : false,
			editable : true,
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
				editable : false,
			},
			{
				headerText : "규격",
				dataField : "machine_sub_type_name",
				width : "80",
				style : "aui-center",
				cellMerge : true,
				editable : false,
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
			headerText : $M.getValue("s_search_year") + "년(관리자 조정)" ,
			headerStyle : "my-column-style",
			children : [
				{
					headerText : "수요예상",
					children : [
						{
							headerText : "MAX",
							dataField : "forecast_max",
							style : "aui-center aui-editable",
							width : "4%",
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
							style : "aui-center aui-editable",
							width : "4%",
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
							style : "aui-center aui-editable",
							width : "4%",
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
					headerText : "판매예상(목표)_작성분",
					children : [
						{
							headerText : "MAX",
							dataField : "sale_expect_max",
							style : "aui-center aui-editable",
							width : "4%",
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
							style : "aui-center aui-editable",
							width : "4%",
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
							style : "aui-center aui-editable",
							width : "4%",
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
					dataField : "sale_qty",
					visible : false,
				},
				{
					headerText : "MS",
					dataField : "ms",
					children : [
						{
							headerText : "MAX",
							dataField : "mng_ms_max",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center aui-background-gray",
							width : "4%",
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
							dataField : "mng_ms_avr",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center aui-background-gray",
							width : "4%",
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
							dataField : "mng_ms_min",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center aui-background-gray",
							width : "4%",
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
					headerStyle : "my-column-style",
					dataField : "mng_mbo_achieve",
					children : [
						{
							headerText : "AVR",
							headerStyle : "my-column-style",
							dataField : "mng_mbo_achieve_avr",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center aui-background-gray",
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
								value = AUIGrid.formatNumber(value, "#,##0");
								return value == 0 ? "" : value + "%";
							},
						},
					]
				},
			]
		};
		AUIGrid.addColumn(auiGrid, mngColumn, 'last');
		var centerColumn = {
			headerText : $M.getValue("s_search_year") + "년(전체센터 작성분)",
			children : [
				{
					headerText : "수요예상",
					children : [
						{
							headerText : "MAX",
							dataField : "center_forecast_max",
							editable : false,
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
							dataField : "center_forecast_avr",
							editable : false,
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
							dataField : "center_forecast_min",
							editable : false,
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
							dataField : "center_sale_expect_max",
							editable : false,
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
							dataField : "center_sale_expect_avr",
							editable : false,
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
							dataField : "center_sale_expect_min",
							editable : false,
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
					headerText : "MS",
					dataField : "ms",
					children : [
						{
							headerText : "MAX",
							dataField : "center_ms_max",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center",
							width : "4%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.center_sale_expect_max > 0 && item.center_forecast_max > 0){
									var rate = Math.round(item.center_sale_expect_max / item.center_forecast_max * 100);
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
							dataField : "center_ms_avr",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center",
							width : "4%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								if(item.center_sale_expect_avr > 0 && item.center_forecast_avr > 0){
									var rate = Math.round(item.center_sale_expect_avr / item.center_forecast_avr * 100);
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
							dataField : "center_ms_min",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center",
							width : "4%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.center_sale_expect_min > 0 && item.center_forecast_min > 0){
									var rate = Math.round(item.center_sale_expect_min / item.center_forecast_min * 100);
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
					dataField : "center_mbo_achieve",
					children : [
						{
							headerText : "AVR",
							dataField : "center_mbo_achieve_avr",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							style : "aui-center",
							width : "4%",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매수량 / 판매예상 %
								if(item.sale_qty > 0 && item.center_sale_expect_avr > 0){
									var rate = Math.round(item.sale_qty / item.center_sale_expect_avr * 100);
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

		AUIGrid.bind(auiGrid, "cellEditBegin", auiCellEditHandler);
		// 셀 수정 완료 이벤트 바인딩
		AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
		// 셀 수정 되돌리기 이벤트 바인딩
		AUIGrid.bind(auiGrid, "rowStateCellClick", auiCellEditHandler);
	}

	function auiCellEditHandler(event) {

		switch(event.type) {
			case "cellEditBegin" :
				if(event.item.machine_name.indexOf("합계") != -1) {
					return false;
				}
				break;
			case "cellEditEnd" :
				// 병합된 모든 행의 값를 동기화 시킴.
				syncData(event.rowIndex, event.dataField,  event.oldValue, event.value, false);
				var gridData = AUIGrid.getGridData(auiGrid);
				var dataField = event.dataField;
				var sum = 0; // 합계
				var typeS = 0; // 미니 합계
				var typeL = 0; // 대형 합계
				// 메이커 별 합계 산출
				for (var i = 0; i < gridData.length; i++) {
					if(gridData[i].maker_cd == event.item.maker_cd && gridData[i].machine_name.indexOf("합계") == -1){
						var endRowIndex = AUIGrid.getMergeEndRowIndex(auiGrid, i, event.columnIndex);
						if(gridData[i].maker_cd == '27' && (gridData[i].machine_sub_type_cd  <= '0104' || gridData[i].machine_sub_type_cd == '0109' || gridData[i].machine_sub_type_cd == '0111')){
							typeS += Number(gridData[i][event.dataField]);
						} else {
							typeL += Number(gridData[i][event.dataField]);
						}
						sum += Number(gridData[i][event.dataField]);
						i = endRowIndex;
					}
				}
				for (var i = 0; i < gridData.length; i++) {
					if(gridData[i].machine_name == event.item.maker_name+" 합계"){
						var item = { };
						item[dataField] = sum;
						AUIGrid.updateRow(auiGrid, item, i, false);
					} else if(gridData[i].machine_name == "미니 합계"){
						var item = { };
						item[dataField] = typeS;
						AUIGrid.updateRow(auiGrid, item, i, false);
					} else if(gridData[i].machine_name == "대형 합계"){
						var item = { };
						item[dataField] = typeL;
						AUIGrid.updateRow(auiGrid, item, i, false);
					}
				}
				break;
			case "rowStateCellClick" :
				if (event.marker == "edited") { // 현재 수정된 상태를 클릭 한 경우  
					var orgItems = AUIGrid.getOrgValueItem(auiGrid, event.item.machine_plant_seq);
					var orgDataField = Object.keys(orgItems); // 수정된 컬럼
					var orgDataValue = Object.values(orgItems); // 수정 전 값
					var mergedIndex = AUIGrid.getMergeStartRowIndex(auiGrid, event.rowIndex, 1); // 병함된 첫번째 행 index

					for (var i = 0; i < orgDataField.length; i++){
						syncData(mergedIndex, orgDataField[i],  event.item[orgDataField[i]], orgDataValue[i], true);
						var gridData = AUIGrid.getGridData(auiGrid);
						var dataField = orgDataField[i];
						var sum = 0; // 합계
						var typeS = 0; // 미니 합계
						var typeL = 0; // 대형 합계
						// 메이커 별 합계 산출
						for (var j = 0; j < gridData.length; j++) {
							if(gridData[j].maker_cd == event.item.maker_cd && gridData[j].machine_name.indexOf("합계") == -1){
								var endRowIndex = AUIGrid.getMergeEndRowIndex(auiGrid, j, 1);
								if(gridData[j].maker_cd == '27' && (gridData[j].machine_sub_type_cd  <= '0104' || gridData[j].machine_sub_type_cd == '0109' || gridData[j].machine_sub_type_cd == '0111')){
									typeS += gridData[j][dataField] === undefined ? 0 : Number(gridData[j][dataField]);
								} else {
									typeL += gridData[j][dataField] === undefined ? 0 : Number(gridData[j][dataField]);
								}
								sum += gridData[j][dataField] === undefined ? 0 : Number(gridData[j][dataField]);
								j = endRowIndex;
							}
						}
						for (var j = 0; j < gridData.length; j++) {
							if(gridData[j].machine_name == event.item.maker_name+" 합계"){
								var item = { };
								item[dataField] = sum;
								AUIGrid.updateRow(auiGrid, item, j, false);
							} else if(gridData[j].machine_name == "미니 합계"){
								var item = { };
								item[dataField] = typeS;
								AUIGrid.updateRow(auiGrid, item, j, false);
							} else if(gridData[j].machine_name == "대형 합계"){
								var item = { };
								item[dataField] = typeL;
								AUIGrid.updateRow(auiGrid, item, j, false);
							}
						}
					}
				}
				break;
		}
	}

	// 센터 별 작성분 확인
	function goHistory() {
		// TODO
		const params = {
			"s_maker_cd" : $M.getValue("s_maker_cd"),
			"s_seq_no" : $M.getValue("s_seq_no"),
		};
		$M.goNextPage('/sale/sale0408p02', $M.toGetParam(params), {popupStatus : ""});
	}

</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="sale_mbo_year" id="sale_mbo_year">
	<input type="hidden" name="s_center_org_code" id="s_center_org_code">
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
							<col width="80px">
							<col width="40px">
							<col width="70px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="pr5">조회년월</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-12">
										<select class="form-control" id="s_search_year" name="s_search_year" onchange="javascript:goSearchSaleMboSeqNo();">
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
							<th>차수</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-12">
										<select class="form-control" id="s_seq_no" name="s_seq_no">
											<option value="">- 선택 - </option>
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