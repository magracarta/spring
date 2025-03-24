<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 출장여비정산서 > 출장여비정산서 등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	
	<style type="text/css">
		/* 해외그리드 푸터 스타일 적용 */
		.my-row-style1 {
			background: #eeeeee;
			border: 1px solid #cccccc;
			border-right:none;
			border-left: none;
			font-weight: bold;
			font-size: 1em;
			color: #000000;
			text-align: center;
			cursor: default;
		}
		
		body {
			 height: 1100px;
		}
		
		.layout-box {
			 height: 1100px;
		}
					
	</style>	
	
	<script type="text/javascript">
	
	var tripInItemjson = JSON.parse('${codeMapJsonObj['TRIP_IN_ITEM']}');    // 국내출장항목
	var tripOutItemjson = JSON.parse('${codeMapJsonObj['TRIP_OUT_ITEM']}');  // 해외출장항목
	var tripInOiljson = JSON.parse('${codeMapJsonObj['TRIP_IN_OIL']}');  // 국내출장유류대 구간
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileCount = 5;
	
	var visitRowNum = 0;
	var rowNum = 0;
	
	$(document).ready(function() {
        if ( parent.fnStyleChange )
		parent.fnStyleChange('add');
		
		// 그리드 생성
		createAUIGrid();
		createAUIGridTripI();
		createAUIGridTripO();
		createAUIGridTripOFooter();
		
		$("#auiGridTripO").addClass("dpn");
		$("#auiGridTripOFooter").addClass("dpn");
		
		console.log("tripInItemjson : ", tripInItemjson);
	});
	
	function fnAddFile() {
		if($("input[name='file_seq']").size() >= fileCount) {
			alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
		var param = {
			upload_type	: "DOC",
			file_type : "both",
		};
		
		openFileUploadPanel('setFileInfo', $M.toGetParam(param));
		
	}
	
	function setFileInfo(result) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
		str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
		} else {
			return false;
		}
		
	}
	
	// 방문정보 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField: "visit_row_num",
				visible : false
			},
			{
				dataField: "visit_seq_no",
				visible : false
			},
			{
				headerText: "방문일자",
				dataField: "visit_dt",
				width : "100",
				style : "aui-center aui-editable",
				dataInputString : "yyyymmdd",
				formatString : "yyyy-mm-dd",
				dataType : "date",   
				editable : true,
				editRenderer : {
					type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					maxlength : 8,
					onlyNumeric : true, // 숫자만
					validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
						return fnCheckDate(oldValue, newValue, rowItem);
					},
					showEditorBtnOver : true
				}
			},
			{
				headerText: "방문처",
				dataField: "visit_place",
				width : "130",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText: "내용",
				dataField: "visit_content",
				width : "250",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText: "비고",
				dataField: "visit_remark",
				width : "150",
				style : "aui-left aui-editable",
				editable : true,
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		$("#auiGrid").resize();
	}
	
	// 방문정보 행추가
	function fnAdd() {
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
    		item.visit_row_num = visitRowNum,
    		item.visit_seq_no = "",
    		item.visit_dt = "",
    		item.visit_place = "",
    		item.visit_content = "",
    		item.visit_remark = "",

    		visitRowNum++;
    		AUIGrid.addRow(auiGrid, item, 'last');
		}	
	}
	
	// 그리드 벨리데이션
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["visit_dt", "visit_place"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 상세내역 - 국내 그리드생성
	function createAUIGridTripI() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true,
			showFooter : true,
			footerPosition : "top"
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField: "row_num",
				visible : false
			},
			{
				dataField: "seq_no",
				visible : false
			},
			{
				headerText: "구분",
				dataField: "trip_in_item_cd",
				width : "120",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : tripInItemjson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<tripInItemjson.length; i++){
						if(value == tripInItemjson[i].code_value){
							return tripInItemjson[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "내역",
				dataField: "trip_content",
				width : "150",
				style : "aui-left aui-editable",
				editable : true,
// 				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 					if (item.trip_in_item_cd == "02") {
// 						return "aui-background-darkgray";
// 					} else {
// 						return "aui-editable";
// 					};
// 				},
			},
			{
				headerText: "출장거리(km)",
				dataField: "trip_km",
				width : "80",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0.0",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      // 소수점 허용여부
				      allowPoint : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.trip_in_item_cd == "02" || item.trip_in_item_cd == "") {
						return "aui-editable";
					} else {
						return "aui-background-darkgray";
					};
				},
			},
			{
				headerText: "구간선택",
				dataField: "trip_in_oil_cd",
				width : "100",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : tripInOiljson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<tripInOiljson.length; i++){
						if(value == tripInOiljson[i].code_value){
							return tripInOiljson[i].code_name;
						}
					}
					return value;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.trip_in_item_cd == "02" || item.trip_in_item_cd == "") {
						return "aui-editable";
					} else {
						return "aui-background-darkgray";
					};
				},
			},
			{
				headerText: "금액",
				dataField: "trip_amt",
				width : "120",
				style : "aui-right aui-editable",
				dataType : "numeric",
				formatString : "#,##0",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGridTripI, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreSoftRows(auiGridTripI, "selectedIndex");
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : true
			}
		];
		
		// 푸터레이아웃
		var footerColumnLayout = [
			{
				dataField : "trip_amt",
				positionField : "trip_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			}
		];
		
		auiGridTripI = AUIGrid.create("#auiGridTripI", columnLayout, gridPros);
		// 푸터 세팅
		AUIGrid.setFooter(auiGridTripI, footerColumnLayout);
		AUIGrid.setGridData(auiGridTripI, []);
		$("#auiGridTripI").resize();
		
		AUIGrid.bind(auiGridTripI, "cellEditBegin", function(event) {
			// 구분 선택 후 다른 컬럼 수정가능.
			if(event.dataField == "trip_content" || event.dataField == "trip_km" || event.dataField == "trip_in_oil_cd" || event.dataField == "trip_amt") {
				if (event.item.trip_in_item_cd == "") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridTripI, event.rowIndex, event.columnIndex, "구분을 먼저 선택해주세요.");
					}, 1);
					if (event.oldValue == null) {
						return "";
					} else {
						return event.oldValue;
					}
				}
			}
			
			// 구분 : 유류대가 아닌경우 출장거리, 구간선택 컬럼 수정 비활성화
			if(event.dataField == "trip_km" || event.dataField == "trip_in_oil_cd") {
				if (event.item.trip_in_item_cd != "02") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridTripI, event.rowIndex, event.columnIndex, "유류대일 경우에만 출장거리(km), 구간선택이 가능합니다.");
					}, 1);
					return false;
				}
			}
			
			// 구분 : 유류대일 경우 내역, 금액 비활성화
			if(event.dataField == "trip_amt") {
				if (event.item.trip_in_item_cd == "02") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridTripI, event.rowIndex, event.columnIndex, "유류대일 경우 금액은 자동계산 됩니다.");
					}, 1);
					return false;
				}
			}
		});
		
		AUIGrid.bind(auiGridTripI, "cellEditEnd", function( event ) {		
			if (event.dataField == "trip_in_item_cd") {
				if (event.item.trip_in_item_cd != "02") {
					// 구분 : 유류대가 아닌경우 출장거리, 구간선택 컬럼 초기화
					AUIGrid.updateRow(auiGridTripI, { "trip_km" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_in_oil_cd" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_amt" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_content" : ""}, event.rowIndex);
				} else {
					// 구분 : 유류대일 경우 내역 컬럼 초기화
					AUIGrid.updateRow(auiGridTripI, { "trip_content" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_amt" : ""}, event.rowIndex);
				}
			}

			if (event.dataField == "trip_km" || event.dataField == "trip_in_oil_cd") {
				// 구분 : 유류대 일  금액 = 출장거리 * 구간
				var executiveYn = $M.getValue("grade_cd_v4");  // 임원여부
				var oilCodeVal = event.item.trip_in_oil_cd;  // 구간 code값
				
				// 임원이면 code_v1 아니면 code_v2 데이터 가져와야함.
				var oilAmt = 0;
				
				for (var i = 0; i < tripInOiljson.length; i++) {
					if (oilCodeVal == tripInOiljson[i].code_value) {
						// 임원일 경우
						if (executiveYn == "Y") {
							oilAmt = tripInOiljson[i].code_v1;
						} else {
							oilAmt = tripInOiljson[i].code_v2;
						}
						break;
					}					
				}
				
				AUIGrid.updateRow(auiGridTripI, { "trip_amt" : Math.round(event.item.trip_km * oilAmt)}, event.rowIndex);
			}
		});
	}
	
	// 상세내역 - 해외 그리드생성
	function createAUIGridTripO() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : true,
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField: "row_num",
				visible : false
			},
			{
				dataField: "seq_no",
				visible : false
			},
			{
				headerText: "구분",
				dataField: "trip_out_item_cd",
				width : "80",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : tripOutItemjson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<tripOutItemjson.length; i++){
						if(value == tripOutItemjson[i].code_value){
							return tripOutItemjson[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText: "내역",
				dataField: "trip_content",
				width : "230",
				style : "",
				editable : true,
	            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
	            	console.log(value);
	            	if (value == "가불금" || value == "합계" || value == "반환금" || value == "과부족") {
	            		return "aui-right";
	            	}
	            	return "aui-left aui-editable";
				}
			},
			{
				headerText: "금액",
				dataField: "",
				children : [
					{
						headerText : "유로(U)",
						dataField: "out_eur_amt",
						width : "80",
						style : "aui-right aui-editable",
						dataType : "numeric",
						formatString : "#,##0",
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true,
						      // 에디팅 유효성 검사
						      validator : AUIGrid.commonValidator
						}
					}, 
					{
						headerText : "달러($)",
						dataField: "out_usd_amt",
						width : "80",
						style : "aui-right aui-editable",
						dataType : "numeric",
						formatString : "#,##0",
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true,
						      // 에디팅 유효성 검사
						      validator : AUIGrid.commonValidator
						}
					}, 
					{
						headerText : "엔화(Y)",
						dataField: "out_jpy_amt",
						width : "80",
						style : "aui-right aui-editable",
						dataType : "numeric",
						formatString : "#,##0",
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true,
						      // 에디팅 유효성 검사
						      validator : AUIGrid.commonValidator
						}
					}, 
					{
						headerText : "원화(W)",
						dataField: "out_krw_amt",
						width : "80",
						style : "aui-right aui-editable",
						dataType : "numeric",
						formatString : "#,##0",
						editRenderer : {
						      type : "InputEditRenderer",
						      onlyNumeric : true,
						      // 에디팅 유효성 검사
						      validator : AUIGrid.commonValidator
						}
					}, 
				]
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGridTripO, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							
							// 푸터 그리드 갱신
							fnCalcAmt("EUR");
							fnCalcAmt("USD");
							fnCalcAmt("JPY");
							fnCalcAmt("KRW");
						} else {
							AUIGrid.restoreSoftRows(auiGridTripO, "selectedIndex");
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제';
				},
				style : "aui-center",
				editable : false
			}
		];
		
		auiGridTripO = AUIGrid.create("#auiGridTripO", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTripO, []);
		$("#auiGridTripO").resize();
		
		AUIGrid.bind(auiGridTripO, "cellEditEnd", function( event ) {		
			// 1. 가불금 = 직접입력
			// 2. 합계 = 각 화폐금액 SUM
			// 3. 반환금 = 가불금 - 합계
			// 4. 과부족 = 가불금 - 합계 - 반환금
			
			// 합계 구하기
			switch (event.dataField) {
				case "out_eur_amt" :
					fnCalcAmt("EUR");
				break;
				case "out_usd_amt" :
					fnCalcAmt("USD");
				break;
				case "out_jpy_amt" :
					fnCalcAmt("JPY");
				break;
				case "out_krw_amt" :
					fnCalcAmt("KRW");
				break;
			}
		});
	}
	
	// 푸터 합계 구하기.
	function fnCalcAmt(code, rowIndex) {
		var gridData = AUIGrid.getGridData(auiGridTripO);
		var gridDataFooter = AUIGrid.getGridData(auiGridTripOFooter);
		
		var sumValEUR = 0; // 유로합
		var sumValUSD = 0; // 달러합
		var sumValJPY = 0; // 엔화합
		var sumValKRW = 0; // 원화합
		
		for (var i = 0; i < gridData.length; i++) {
			sumValEUR += gridData[i].out_eur_amt;
			sumValUSD += gridData[i].out_usd_amt;
			sumValJPY += gridData[i].out_jpy_amt;
			sumValKRW += gridData[i].out_krw_amt;
		}
        console.log(sumValEUR, sumValUSD, sumValJPY, sumValKRW);
        console.log(gridData);

		
		switch (code) {
			case "EUR" :
				var returnAmt = 0;
				if (rowIndex == 2) {
					returnAmt = gridDataFooter[2].pre_out_eur_amt; // 반환금
				} else {
					returnAmt = gridDataFooter[0].pre_out_eur_amt - sumValEUR; // 반환금
				}
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_eur_amt" : sumValEUR}, 1); // 합계
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_eur_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_eur_amt" : gridDataFooter[0].pre_out_eur_amt - sumValEUR - returnAmt}, 3); // 과부족
			break;
			case "USD" :
				var returnAmt = 0;
				if (rowIndex == 2) {
					returnAmt = gridDataFooter[2].pre_out_usd_amt; // 반환금
				} else {
					returnAmt = gridDataFooter[0].pre_out_usd_amt - sumValUSD; // 반환금
				}
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_usd_amt" : sumValUSD}, 1);
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_usd_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_usd_amt" : gridDataFooter[0].pre_out_usd_amt - sumValUSD - returnAmt}, 3); // 과부족
			break;
			case "JPY" :
				var returnAmt = 0;
				if (rowIndex == 2) {
					returnAmt = gridDataFooter[2].pre_out_jpy_amt; // 반환금
				} else {
					returnAmt = gridDataFooter[0].pre_out_jpy_amt - sumValJPY; // 반환금
				}
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_jpy_amt" : sumValJPY}, 1);
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_jpy_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_jpy_amt" : gridDataFooter[0].pre_out_jpy_amt - sumValJPY - returnAmt}, 3); // 과부족
			break;
			case "KRW" :
				var returnAmt = 0;
				if (rowIndex == 2) {
					returnAmt = gridDataFooter[2].pre_out_krw_amt; // 반환금
				} else {
					returnAmt = gridDataFooter[0].pre_out_krw_amt - sumValKRW;  // 반환금
				}
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_krw_amt" : sumValKRW}, 1);
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_krw_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_krw_amt" : gridDataFooter[0].pre_out_krw_amt - sumValKRW - returnAmt}, 3); // 과부족
			break;
		}
	}
	
	// 상세내역 - 해외 그리드 푸터 생성
	function createAUIGridTripOFooter() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : false,
			enableFilter :true,
			editable : true,
			showHeader : false,
			rowStyleFunction : function(rowIndex, item) {
				if(rowIndex != 0 && rowIndex != 2) {
					return "my-row-style1";
				}
			},
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				headerText : "헤더",
				dataField: "header",
				width : "350",
				style : "aui-right",
				editable : false,
			},
			{
				headerText : "유로(U)",
				dataField: "pre_out_eur_amt",
				width : "80",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (rowIndex != 0 && rowIndex != 2) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			}, 
			{
				headerText : "달러($)",
				dataField: "pre_out_usd_amt",
				width : "80",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (rowIndex != 0 && rowIndex != 2) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			}, 
			{
				headerText : "엔화(Y)",
				dataField: "pre_out_jpy_amt",
				width : "80",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (rowIndex != 0 && rowIndex != 2) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			}, 
			{
				headerText : "원화(W)",
				dataField: "pre_out_krw_amt",
				width : "80",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (rowIndex != 0 && rowIndex != 2) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			}, 
		];
		
		var dummyData = [
			{
				"header" : "가불금",
				"pre_out_eur_amt" : 0,
				"pre_out_usd_amt" : 0,
				"pre_out_jpy_amt" : 0,
				"pre_out_krw_amt" : 0
			},
			{
				"header" : "합계",
				"pre_out_eur_amt" : 0,
				"pre_out_usd_amt" : 0,
				"pre_out_jpy_amt" : 0,
				"pre_out_krw_amt" : 0
			},
			{
				"header" : "반환금",
				"pre_out_eur_amt" : 0,
				"pre_out_usd_amt" : 0,
				"pre_out_jpy_amt" : 0,
				"pre_out_krw_amt" : 0
			},
			{
				"header" : "과부족",
				"pre_out_eur_amt" : 0,
				"pre_out_usd_amt" : 0,
				"pre_out_jpy_amt" : 0,
				"pre_out_krw_amt" : 0
			}
		]
		
		auiGridTripOFooter = AUIGrid.create("#auiGridTripOFooter", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTripOFooter, dummyData);
		$("#auiGridTripOFooter").resize();
		
		// 가불금 제외하고 에디팅 제어
		AUIGrid.bind(auiGridTripOFooter, "cellEditBegin", function (event) {
			if (event.rowIndex != 0 && event.rowIndex != 2) {
				if (event.dataField) {
					return false;
				}
			}
		});
		
		AUIGrid.bind(auiGridTripOFooter, "cellEditEnd", function( event ) {		
			// 1. 가불금 = 직접입력
			// 2. 합계 = 각 화폐금액 SUM
			// 3. 반환금 = 가불금 - 합계
			// 4. 과부족 = 가불금 - 합계 - 반환금
			
			var rowIndex = event.rowIndex;
			if (rowIndex == 0 || rowIndex == 2) {
				// 반환금, 과부족 갱신
				switch (event.dataField) {
					case "pre_out_eur_amt" :
						fnCalcAmt("EUR", rowIndex);
					break;
					case "pre_out_usd_amt" :
						fnCalcAmt("USD", rowIndex);
					break;
					case "pre_out_jpy_amt" :
						fnCalcAmt("JPY", rowIndex);
					break;
					case "pre_out_krw_amt" :
						fnCalcAmt("KRW", rowIndex);
					break;
				}			
			} 
		});
	}
	
	// 방문정보 행추가
	function fnAddSec() {
		var item = new Object();
		
		if ($M.getValue("trip_io") == "I") {
			// 국내일경우
			if(fnCheckGridEmptyTripI(auiGridTripI)) {
	    		item.row_num = rowNum,
	    		item.seq_no = "",
	    		item.trip_in_item_cd = "",
	    		item.trip_content = "",
	    		item.trip_km = "",
	    		item.trip_in_oil_cd = "",
	    		item.trip_amt = "",
	    		
	    		rowNum++;
	    		AUIGrid.addRow(auiGridTripI, item, 'last');
			}	
		} else {
			// 해외일경우
			if(fnCheckGridEmptyTripO(auiGridTripO)) {
				item.row_num = rowNum,
	    		item.seq_no = "",
	    		item.trip_out_item_cd = "",
	    		item.trip_content = "",
	    		item.out_eur_amt = 0,
	    		item.out_usd_amt = 0,
	    		item.out_jpy_amt = 0,
	    		item.out_krw_amt = 0,
	    		
	    		rowNum++;
	    		AUIGrid.addRow(auiGridTripO, item, 'last');
			}	
		}
	}
	
	// 그리드 벨리데이션
	function fnCheckGridEmptyTripI() {
		var gridData = AUIGrid.getGridData(auiGridTripI);
		for (var i = 0; i < gridData.length; i++) {
			// 구분
			if (gridData[i].trip_in_item_cd == "") {
				var rowIndex = gridData[i].row_num; 
			    AUIGrid.showToastMessage(auiGridTripI, rowIndex, 2, "구분은 필수 입력입니다.");
			    return false;
			}
			
			// 유류대일경우 출장거리, 구간선택 필수
			if (gridData[i].trip_in_item_cd == "02") {
				if (gridData[i].trip_km == "") {
					var rowIndex = gridData[i].row_num; 
				    AUIGrid.showToastMessage(auiGridTripI, rowIndex, 4, "유류대일경우 출장거리는 필수 입력입니다.");
				    return false;					
				}

				if (gridData[i].trip_in_oil_cd == "") {
					var rowIndex = gridData[i].row_num; 
				    AUIGrid.showToastMessage(auiGridTripI, rowIndex, 5, "유류대일경우 구간선택은 필수 입력입니다.");
				    return false;					
				}
			} 
			
			// 금액
			if (gridData[i].trip_amt == "" || gridData[i].trip_amt == 0) {
				var rowIndex = gridData[i].row_num; 
			    AUIGrid.showToastMessage(auiGridTripI, rowIndex, 6, "금액은 필수 입력입니다.");
			    return false;	
			}
		}
		
		return true;
	}

	// 그리드 벨리데이션
	function fnCheckGridEmptyTripO() {
		return AUIGrid.validateGridData(auiGridTripO, ["trip_out_item_cd"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 목록
	function fnList() {
// 		history.back();

		var param = {
				"init_yn" : "Y"
			}
		$M.goNextPage("/mmyy/mmyy011103", $M.toGetParam(param));	
	}
	
	function fnChangeGridDtl(val) {
		var tripIoVal = val;  // I : 국내 / O : 해외
		
		if(confirm("출장구분 변경시 입력한 상세내역 데이터가 초기화됩니다.\n변경하시겠습니까?") == false) {
			// 취소 클릭시 체크 원래대로 돌리기.
			if (tripIoVal == "I") {
				$("#trip_io_i").prop("checked", false);
				$("#trip_io_o").prop("checked", true);
			} else {
				$("#trip_io_i").prop("checked", true);
				$("#trip_io_o").prop("checked", false);
			}
			return false;
		}

		if (tripIoVal == "I") {
			// 국내일경우 국내 그리드로 변경
			// TODO : 그리드에 입력했던 정보들은 초기화
			AUIGrid.clearGridData(auiGridTripO);
			$("#auiGridTripO").addClass("dpn");
			$("#auiGridTripOFooter").addClass("dpn");
			$("#auiGridTripI").removeClass("dpn");
		} else {
			// 해외일경우 해외 그리드로 변경
			AUIGrid.clearGridData(auiGridTripI);
			$("#auiGridTripI").addClass("dpn");
			$("#auiGridTripO").removeClass("dpn");
			$("#auiGridTripOFooter").removeClass("dpn");
		}
	}
	
	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}
	
	// 저장
	function goSave(isRequestAppr) {
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if (fnCheckGridEmpty() == false) {
			return;
		};
		
		// 구분 : 국내, 해외에 따라 그리드 벨리데이션 체크 
		if ($M.getValue("trip_io") == "I") {
			if (fnCheckGridEmptyTripI() == false) {
				return;
			};
		} else {
			if (fnCheckGridEmptyTripO() == false) {
				return;
			};
		}

		var msg = "";
		if (isRequestAppr != undefined) {
			$M.setValue("save_mode", "appr"); // 결재요청
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "save"); // 저장
			msg = "저장 하시겠습니까?";
		}

        if (confirm(msg) == false) {
            return false;
        }

		var idx = 1;
		$("input[name='file_seq']").each(function() {
			var str = 'doc_file_seq_' + idx;
            if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
                $M.setValue(str, $(this).val());
            }
			idx++;
		});

		for(; idx <= fileCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, '');
		}

		var frm = $M.toValueForm(document.main_form);
		var gridData = AUIGrid.getGridData(auiGrid); // 방문정보 그리드
		var inGridData = AUIGrid.getGridData(auiGridTripI); // 국내 그리드 데이터
		var outGridData = AUIGrid.getGridData(auiGridTripO); // 해외 그리드 데이터
		var outFooterGridData = AUIGrid.getGridData(auiGridTripOFooter); // 해외 그리드 푸터 데이터
		
		// 방문정보
		var visitRowNumArr = [];
		var visitDtArr = [];
		var visitPlaceArr = [];
		var visitContentArr = [];
		var visitRemark = [];
		
		// 상세내역
		var rowNumArr = [];
		var tripInItemCdArr = [];
		var tripOutItemCdArr = [];
		var tripInOilCdArr = [];
		var tripContentArr = [];
		var tripKmArr = [];
		var tripAmtArr = [];
		var outEurAmtArr = [];
		var outUsdAmtArr = [];
		var outJpyAmtArr = [];
		var outKrwAmtArr = [];
		
		for (var i = 0; i < gridData.length; i++) {
			visitRowNumArr.push(gridData[i].visit_row_num);
			visitDtArr.push(gridData[i].visit_dt);
			visitPlaceArr.push(gridData[i].visit_place);
			visitContentArr.push(gridData[i].visit_content);
			visitRemark.push(gridData[i].visit_remark);
		}
		
		for (var i = 0; i < inGridData.length; i++) {
			rowNumArr.push(inGridData[i].row_num);
			tripInItemCdArr.push(inGridData[i].trip_in_item_cd);
			tripContentArr.push(inGridData[i].trip_content);
			tripKmArr.push(inGridData[i].trip_km);
			tripInOilCdArr.push(inGridData[i].trip_in_oil_cd);
			tripAmtArr.push(inGridData[i].trip_amt);
		}
		
		for (var i = 0; i < outGridData.length; i++) {
			rowNumArr.push(outGridData[i].row_num);
			tripOutItemCdArr.push(outGridData[i].trip_out_item_cd);
			tripContentArr.push(outGridData[i].trip_content);
			outEurAmtArr.push(outGridData[i].out_eur_amt);
			outUsdAmtArr.push(outGridData[i].out_usd_amt);
			outJpyAmtArr.push(outGridData[i].out_jpy_amt);
			outKrwAmtArr.push(outGridData[i].out_krw_amt);
		}
		
		// 가불금 세팅
		var preOutAmtData = outFooterGridData[0];
		$M.setValue(frm, "pre_out_eur_amt", preOutAmtData.pre_out_eur_amt);
		$M.setValue(frm, "pre_out_usd_amt", preOutAmtData.pre_out_usd_amt);
		$M.setValue(frm, "pre_out_jpy_amt", preOutAmtData.pre_out_jpy_amt);
		$M.setValue(frm, "pre_out_krw_amt", preOutAmtData.pre_out_krw_amt);
		
		// 반환금 세팅
		var returnAmtData = outFooterGridData[2];
		$M.setValue(frm, "return_eur_amt", returnAmtData.pre_out_eur_amt);
		$M.setValue(frm, "return_usd_amt", returnAmtData.pre_out_usd_amt);
		$M.setValue(frm, "return_jpy_amt", returnAmtData.pre_out_jpy_amt);
		$M.setValue(frm, "return_krw_amt", returnAmtData.pre_out_krw_amt);
		
		var option = {
				isEmpty : true
		};
		
		$M.setValue(frm, "visit_row_num_str", $M.getArrStr(visitRowNumArr, option));
		$M.setValue(frm, "visit_dt_str", $M.getArrStr(visitDtArr, option));
		$M.setValue(frm, "visit_place_str", $M.getArrStr(visitPlaceArr, option));
		$M.setValue(frm, "visit_content_str", $M.getArrStr(visitContentArr, option));
		$M.setValue(frm, "visit_remark_str", $M.getArrStr(visitRemark, option));
		
		$M.setValue(frm, "row_num_str", $M.getArrStr(rowNumArr, option));
		$M.setValue(frm, "trip_in_item_cd_str", $M.getArrStr(tripInItemCdArr, option));
		$M.setValue(frm, "trip_content_str", $M.getArrStr(tripContentArr, option));
		$M.setValue(frm, "trip_km_str", $M.getArrStr(tripKmArr, option));
		$M.setValue(frm, "trip_in_oil_cd_str", $M.getArrStr(tripInOilCdArr, option));
		$M.setValue(frm, "trip_amt_str", $M.getArrStr(tripAmtArr, option));

		$M.setValue(frm, "trip_out_item_cd_str", $M.getArrStr(tripOutItemCdArr, option));
		$M.setValue(frm, "out_eur_amt_str", $M.getArrStr(outEurAmtArr, option));
		$M.setValue(frm, "out_usd_amt_str", $M.getArrStr(outUsdAmtArr, option));
		$M.setValue(frm, "out_jpy_amt_str", $M.getArrStr(outJpyAmtArr, option));
		$M.setValue(frm, "out_krw_amt_str", $M.getArrStr(outKrwAmtArr, option));

		console.log("frm : ", frm);
		
		$M.goNextPageAjax(this_page + "/save", frm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			fnList();
				}
			}
		);
	}

    function goModify(){
        var param = {
            group_code : "TRIP_IN_OIL",
            all_yn : 'Y',
            show_extra_cols : "v1,v2"
        }
        openGroupCodeDetailPanel($M.toGetParam(param));
    }
    </script>
</head>
<body>
<body style="background : #fff;">
<form id="main_form" name="main_form">
<input type="hidden" id="grade_cd_v4" name="grade_cd_v4" value="${info.grade_cd_v4}">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail width780px">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
<%-- 						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
						<h2>출장여비정산서 등록</h2>
                    </div>
<!-- 결재영역 -->
                    <div class="pl10">
                    	<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
                    </div>
<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->					
                    <table class="table-border width750px">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right">작성자</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="mem_name" name="mem_name" value="${info.kor_name}">
                                    <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                                </td>		
                                <th class="text-right">작성일</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${inputParam.s_current_dt}" dateformat="yyyy-MM-dd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">부서</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="org_name" name="org_name" value="${info.org_name}">
                                    <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                                </td>		
                                <th class="text-right">직위</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name" value="${info.grade_name}">
                                    <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                                    <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">출장구분</th>
                                <td colspan="3">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="trip_io_i" name="trip_io" value="I" checked="checked" onchange="javascipt:fnChangeGridDtl(this.value);">
                                        <label class="form-check-label" for="trip_io_i">국내</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="trip_io_o" name="trip_io" value="O" onchange="javascipt:fnChangeGridDtl(this.value);">
                                        <label class="form-check-label" for="trip_io_o">해외</label>
                                    </div>
                                </td>						
                            </tr>
                            <tr>
                                <th class="text-right essential-item">출장지(국)</th>
                                <td colspan="3">
                                    <input type="text" class="form-control rb" id="trip_place" name="trip_place" required="required">
                                </td>						
                            </tr>					
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 방문정보 -->		
                    <div class="title-wrap mt10 width750px">
                        <h4>방문정보</h4>
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                    <div id="auiGrid" class="width750px" style="margin-top: 5px; height: 150px;"></div>	
<!-- /방문정보 -->
<!-- 상세내역 -->		
                    <div class="title-wrap mt10 width750px">
                        <h4>상세내역</h4>
                        <div class="right">
                            <button type="button" class="btn btn-default" onclick="javascript:window.open('http://www.opinet.co.kr/user/dopospdrg/dopOsPdrgSelect.do')">유류대 추이</button>
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                        </div>
                    </div>	
                    <div id="auiGridTripI" class="width750px" style="margin-top: 5px; height: 200px;"></div>						
                    <div id="auiGridTripO" class="width750px" style="margin-top: 5px; height: 200px;"></div>						
                    <div id="auiGridTripOFooter" class="width750px" style="margin-top: 5px; height: 120px;"></div>						
<!-- /상세내역 -->		
<!-- 폼테이블 -->			
                    <table class="table-border mt10 width750px">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right">의견</th>
                                <td>
                                    <textarea class="form-control" style="height: 70px;" placeholder="내용을 입력하세요." id="remark" name="remark"></textarea>
                                </td>							
                            </tr>	
                            <tr>
                                <th class="text-right">첨부파일</th>
                                <td>
									<div class="table-attfile doc_file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
										&nbsp;&nbsp;
										</div>
									</div>
                                </td>							
                            </tr>			
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
                    <div class="doc-com width750px">
                        <div class="text">
                            위와 같이 정산서를 신청 하오니 재가하여 주시기 바랍니다<br>
                            ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                            부서 : ${info.org_name}<br>
                            성명 : ${info.kor_name}
                        </div> 
                    </div>			
<!-- /하단 내용 -->
					<div class="btn-group mt10 width750px">
						<div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->
</div>
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value=""/>
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value=""/>
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value=""/>
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value=""/>
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value=""/>
</form>	
</body>
</html>