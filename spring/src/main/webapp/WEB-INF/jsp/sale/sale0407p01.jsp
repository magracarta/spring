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

		var auiGrid;
		var centerYn = "${page.fnc.F04464_001}";
		var saveYn = false;
		
		$(document).ready(function() {
			createAUIGrid();
			if(centerYn == "Y"){
				$("#s_sale_mem_no").prop("disabled", true); // 영업담당자 disabled
				$("#s_center_org_code").prop("disabled", true); // 센터 disabled
				$("#s_maker_cd").prop("disabled", true); // 메이커 disabled
			} else { // 센터인원이 아닌 경우 본인으로 영업담당자 고정
				goSearchCenter();
				$("#s_sale_mem_no").prop("disabled", true); // 영업담당자 disabled
			}
			goSearchSaleMboSeqNo(); // 조회년도의 차수 조회
		});
		
		
		// MBO 신규 세팅 및 조회
		function goSearch() {
			
			var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
			if (changeGridData.length != 0 && saveYn == false) {
				if(confirm("조회 시 작성한 내용이 사라집니다. 계속하시겠습니까?") == false){
					return false;
				}
			}
			
			if($M.getValue("s_center_org_code") == ""){
				alert("센터를 선택해 주세요")
				return false;
			}
			if($M.getValue("s_sale_mbo_type_cd") == ""){
				alert("작성구분을 선택해 주세요")
				return false;
			}
			if($M.getValue("s_seq_no") == ""){
				alert("차수를 선택해 주세요")
				return false;
			}

			

			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_sale_mem_no" : $M.getValue("s_sale_mem_no"),
				"s_center_org_code" : $M.getValue("s_center_org_code"),
				"s_search_year" : $M.getValue("s_search_year"),
				"s_sale_mbo_type_cd" : $M.getValue("s_sale_mbo_type_cd"),
				"s_seq_no" : $M.getValue("s_seq_no"), // 조회 차수
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "get"},
				function (result) {
					if (result.success) {
						var gridDataField = ["forecast_max", "forecast_avr", "forecast_min", "sale_expect_max", "sale_expect_min"
							, "mon_12", "mon_11", "mon_10", "mon_09", "mon_08", "mon_07", "mon_06", "mon_05", "mon_04", "mon_03", "mon_02", "mon_01"]
						
						AUIGrid.setGridData(auiGrid, result.list);
						saveYn = false;
						
						// 조회한 MBO가 현재 수정가능하면 저장버튼 노출 수정 불가능하면 저장버튼 미노출
						if($M.getValue("s_search_year") != "${inputParam.sale_mbo_year}"
						|| $M.getValue("s_sale_mbo_type_cd") != "${inputParam.sale_mbo_type_cd}"
						|| $M.getValue("s_seq_no") != ${inputParam.sale_mbo_seq_no}){
							$("#_goSave").addClass("dpn");
							AUIGrid.setProp(auiGrid, "editable", false);
							for(var i=0; i < gridDataField.length; i++){
								AUIGrid.setColumnPropByDataField(auiGrid, gridDataField[i], {style : "aui-center" });
							}
						} else {
							$M.setValue("center_org_code", $M.getValue("s_center_org_code"));
							$("#_goSave").removeClass("dpn");
							AUIGrid.setProp(auiGrid, "editable", true);
							for(var i=0; i < gridDataField.length; i++){
								AUIGrid.setColumnPropByDataField(auiGrid, gridDataField[i], {style : "aui-center aui-editable" });
							}
						}
							fnGridDataSet(); // 조회 후 메이커 별 합계 세팅
					} else {
						AUIGrid.clearGridData(auiGrid);
					}
				}
			);
		}

		// 조회 후 합계 계산
		function fnGridDataSet() {
			var gridData = AUIGrid.getGridData(auiGrid);
			var makerArr = [];
			var columnArr = ["forecast_max", "forecast_avr", "forecast_min", "sale_expect_max", "sale_expect_avr", "sale_expect_min",
				"ms_max", "ms_avr", "ms_min", "total", "quarter_1_4", "quarter_2_4", "quarter_3_4", "quarter_4_4", "mon_12",
				"mon_01", "mon_02", "mon_03", "mon_04", "mon_05", "mon_06", "mon_07", "mon_08", "mon_09", "mon_10", "mon_11"];
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
		// 비교자료 팝업
		function goMboPopup(){
			var params = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_sale_mem_no" : $M.getValue("s_sale_mem_no") == "" ? "" : $M.getValue("s_sale_mem_no"),
				"s_center_org_code" : $M.getValue("s_center_org_code"),
				"s_search_year" : $M.getValue("s_search_year"),
				"s_sale_mbo_type_cd" : $M.getValue("s_sale_mbo_type_cd"),
				"center_yn" : centerYn == "Y" ? "Y" : "N",
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=900, left=0, top=0";
			$M.goNextPage('/sale/sale0407p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// MBO 저장
		function goSave() {
			var frm = $M.toValueForm(document.main_form);
			// var concatCols = [];
			// var concatList = [];
			// var gridIds = [auiGrid];
			// for (var i = 0; i < gridIds.length; ++i) {
			// 	concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			// 	concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			// }
			// var gridForm = fnGridDataToForm(concatCols, concatList);

			var gridForm = fnChangeGridDataToForm(auiGrid, false);

			var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
			if (changeGridData.length == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			$M.copyForm(gridForm, frm);;

			$M.goNextPageAjaxSave(this_page + "/save", gridForm , {method : 'POST'},
					function(result) {
						if(result.success) {
							saveYn = true;
							goSearch();
						}
					}
			);
		}
		// 닫기
		function fnClose() {
			window.close();
		}

		function goSearchCenter() {
			var saleMemNo = $M.getValue("s_sale_mem_no");
			$("select#s_center_org_code option").remove();
			$('#s_center_org_code').append('<option value="" >'+ "- 선택 -" +'</option>');

			// 전체센터 세팅
			if(saleMemNo == ""){
				var warehouseJson = JSON.parse('${codeMapJsonObj['WAREHOUSE']}');
				for(var i = 0; i < warehouseJson.length; i++){
					if(warehouseJson[i].code_value != "6000") {
						var optVal = warehouseJson[i].code_value;
						var optText = warehouseJson[i].code_name;
						$('#s_center_org_code').append('<option value="' + optVal + '">' + optText + '</option>');
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
							}
						}
					}
				);
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
							}
						}
					}
			);
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

		// 그리드 생성
		function createAUIGrid() {

			var gridPros = {
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
					visible : false,
				},
				{
					dataField : "machine_sub_type_cd",
					visible : false,
				},
				{
					dataField : "maker_cd",
					visible : false,
				},
				{
					dataField : "maker_name",
					visible : false,
				},
				{
					dataField : "machine_plant_seq",
					visible : false,
				},
				{
					headerText : "수요예상",
					children : [
						{
							headerText : "MAX",
							dataField : "forecast_max",
							width : "50",
							style : "aui-center aui-editable",
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
							width : "50",
							style : "aui-center aui-editable",
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
							width : "50",
							style : "aui-center aui-editable",
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
					headerText : "판매예상",
					dataField : "sale_forecast",
					children : [
						{
							headerText : "MAX",
							dataField : "sale_expect_max",
							width : "50",
							style : "aui-center aui-editable",
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
							width : "50",
							editable : false,
							style : "aui-center aui-background-gray",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							dataType : "numeric",
							formatString: "#,###",
							expFunction : function(rowIndex, columnIndex, item, dataField) {
								var sum = 0;
								for (var data in item ){
									if (data.startsWith('mon_')) sum += Number(item[data]);
								}
								return sum;
							},
						},
						{
							headerText : "MIN",
							dataField : "sale_expect_min",
							width : "50",
							style : "aui-center aui-editable",
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
					headerText : "MS",
					dataField : "ms",
					children : [
						{
							headerText : "MAX",
							dataField : "ms_max",
							width : "50",
							editable : false,
							style : "aui-center aui-background-gray",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
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
							width : "50",
							editable : false,
							style : "aui-center aui-background-gray",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
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
							width : "50",
							editable : false,
							style : "aui-center aui-background-gray",
							cellMerge: true,
							mergeRef: "machine_sub_type_name",
							mergePolicy: "restrict",
							expFunction : function(rowIndex, columnIndex, item, dataField ) {
								// 판매예상 / 수요예상 %
								if(item.sale_expect_min > 0 && item.forecast_min > 0){
									var rate = Math.round(item.sale_expect_min / item.forecast_min * 100);
									return rate;
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
					headerText : "TOTAL",
					dataField : "total",
					width : "50",
					editable : false,
					style : "aui-center aui-background-gray",
					cellMerge: true,
					mergeRef: "machine_sub_type_name",
					mergePolicy: "restrict",
					dataType : "numeric",
					formatString: "#,###",
					expFunction : function(rowIndex, columnIndex, item, dataField) {
						return Object.keys(item).filter(s => s.startsWith("mon_")).reduce((acc, cur) => acc + parseInt(item[cur] || '0'), 0);
					},
				},
				{
					headerText : "1/4<br\>분기",
					dataField : "quarter_1_4",
					width : "50",
					editable : false,
					style : "aui-center aui-background-gray",
					cellMerge: true,
					mergeRef: "machine_sub_type_name",
					mergePolicy: "restrict",
					dataType : "numeric",
					formatString: "#,###",
					expFunction : function(rowIndex, columnIndex, item, dataField ) {
						return [item.mon_12, item.mon_01, item.mon_02].reduce((acc, cur) => acc + parseInt(cur || '0'), 0);
					},
				},
				{
					headerText : "12월",
					dataField : "mon_12",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "1월",
					dataField : "mon_01",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "2월",
					dataField : "mon_02",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "2/4<br\>분기",
					dataField : "quarter_2_4",
					width : "50",
					editable : false,
					style : "aui-center aui-background-gray",
					editable : false,
					cellMerge: true,
					mergeRef: "machine_sub_type_name",
					mergePolicy: "restrict",
					dataType : "numeric",
					formatString: "#,###",
					expFunction : function(rowIndex, columnIndex, item, dataField ) {
						return [item.mon_03, item.mon_04, item.mon_05].reduce((acc, cur) => acc + parseInt(cur || '0'), 0);
					},
				},
				{
					headerText : "3월",
					dataField : "mon_03",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "4월",
					dataField : "mon_04",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "5월",
					dataField : "mon_05",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "3/4<br\>분기",
					dataField : "quarter_3_4",
					width : "50",
					editable : false,
					style : "aui-center aui-background-gray",
					editable : false,
					cellMerge: true,
					mergeRef: "machine_sub_type_name",
					mergePolicy: "restrict",
					dataType : "numeric",
					formatString: "#,###",
					expFunction : function(rowIndex, columnIndex, item, dataField ) {
						return [item.mon_06, item.mon_07, item.mon_08].reduce((acc, cur) => acc + parseInt(cur || '0'), 0);
					},
				},
				{
					headerText : "6월",
					dataField : "mon_06",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "7월",
					dataField : "mon_07",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "8월",
					dataField : "mon_08",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "4/4<br\>분기",
					dataField : "quarter_4_4",
					width : "50",
					editable : false,
					style : "aui-center aui-background-gray",
					editable : false,
					cellMerge: true,
					mergeRef: "machine_sub_type_name",
					mergePolicy: "restrict",
					dataType : "numeric",
					formatString: "#,###",
					expFunction : function(rowIndex, columnIndex, item, dataField ) {
						return [item.mon_09, item.mon_10, item.mon_11].reduce((acc, cur) => acc + parseInt(cur || '0'), 0);
					},
				},
				{
					headerText : "9월",
					dataField : "mon_09",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "10월",
					dataField : "mon_10",
					width : "50",
					style : "aui-center aui-editable",
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
					headerText : "11월",
					dataField : "mon_11",
					width : "50",
					style : "aui-center aui-editable",
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

			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
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
									typeS += gridData[i][event.dataField] === undefined ? 0 : Number(gridData[i][event.dataField]);
								} else {
									typeL += gridData[i][event.dataField] === undefined ? 0 : Number(gridData[i][event.dataField]);
								}
								sum += gridData[i][event.dataField] === undefined ? 0 : Number(gridData[i][event.dataField]);
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
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="sale_mbo_type_cd" id="sale_mbo_type_cd" value="${inputParam.sale_mbo_type_cd}">
	<input type="hidden" name="sale_mbo_seq_no" id="sale_mbo_seq_no" value="${inputParam.sale_mbo_seq_no}">
	<input type="hidden" name="sale_mbo_year" id="sale_mbo_year" value="${inputParam.sale_mbo_year}">
	<input type="hidden" name="center_org_code" id="center_org_code" value="">
	<!-- 팝업 -->
    <div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
        <div class="main-title">
        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<!-- 컨텐츠 영역 -->
        <div class="content-wrap">
			<div class="search-wrap mt10">
				<table class="table">
					<colgroup>
						<col width="75px">
						<col width="70px">
						<col width="50px">
						<col width="90px">
						<col width="70px">
						<col width="90px">
						<col width="40px">
						<col width="90px">
						<col width="60px">
						<col width="80px">
						<col width="40px">
						<col width="70px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>조회년월</th>
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
						<th>메이커</th>	
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<select class="form-control" id="s_maker_cd" name="s_maker_cd">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['MAKER']}" var="item">
											<c:if test="${item.code_v1 eq 'Y' }">
												<option value="${item.code_value}" >${item.code_name}</option>
												<c:if test="${page.fnc.F04464_001 eq 'Y'}"><option value="${item.code_value}" ${item.code_value == "27" ? 'selected' : 'item.code_value' }>${item.code_name}</c:if></option>
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
											<option value="${item.sale_mem_no}" ${item.sale_mem_no == SecureUser.mem_no ? 'selected' : '' }>${item.sale_mem_name}</option>
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
												<c:if test="${page.fnc.F04464_001 eq 'Y' && list.code_value ne '5010'}"><option value="${list.code_value}" ${list.code_value == (SecureUser.warehouse_cd ne '' ? SecureUser.warehouse_cd : SecureUser.org_code) ? 'selected' : 'item.code_value' }>${list.code_name}</c:if></option>
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
										<option value="">- 선택 - </option>
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
			<div class="title-wrap">
				<h4>조회결과</h4>
				<div class="btn-group" style="margin-top: 10px;">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
			<!-- 그리드 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 650px;"></div>
			<!-- 우측 하단 버튼 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
	<!-- /팝업 -->
</form>
</body>
</html>