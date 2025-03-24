<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 출장여비정산서 > null > 출장여비정산서 상세
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
					
	</style>	
	
	<script type="text/javascript">
	
	var tripInItemjson = JSON.parse('${codeMapJsonObj['TRIP_IN_ITEM']}');    // 국내출장항목
	var tripOutItemjson = JSON.parse('${codeMapJsonObj['TRIP_OUT_ITEM']}');  // 해외출장항목
	var tripInOiljson = JSON.parse('${codeMapJsonObj['TRIP_IN_OIL']}');  // 국내출장유류대 구간
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileMaxCount = 5;
	
	var visitRowNum = '${visitRowNum}' + 1;
	var rowNum = '${rowNum}' + 1;
	
	var regMemNo = '${info.mem_no}';
	var memNo = '${SecureUser.mem_no}';
	
	$(document).ready(function() {
		// 그리드 생성
		createAUIGrid();
		createAUIGridTripI();
		createAUIGridTripO();
		createAUIGridTripOFooter();
		
		<c:forEach var="list" items="${doc_file}">setFileInfo('${list.file_seq}', '${list.file_name}');</c:forEach>
		
		if ($M.getValue("trip_io") == "I") {
			$("#auiGridTripO").addClass("dpn");
			$("#auiGridTripOFooter").addClass("dpn");
			$("#auiGridTripI").removeClass("dpn");
		} else {
			$("#auiGridTripI").addClass("dpn");
			$("#auiGridTripO").removeClass("dpn");
			$("#auiGridTripOFooter").removeClass("dpn");
		}
		
		// 푸터 그리드 갱신
		fnCalcAmt("EUR", "", "Y");
		fnCalcAmt("USD", "", "Y");
		fnCalcAmt("JPY", "", "Y");
		fnCalcAmt("KRW", "", "Y");
		
	    // 결재상태에 따라 수정가능 제어
	    if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
	          || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))
	    ) {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :button[onclick='javascript:fnPrint();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
		}
	    
	    if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y') {
			$("#_fnPrint").show();
		} else {
			$("#_fnPrint").hide();
		}
		
	});
	
	// 첨부파일
	function goSearchFile(){
		if($("input[class='doc_file_list']").size() >= fileMaxCount) {
			alert("파일은 " + fileMaxCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
        var param = {
            upload_type: 'DOC',
            file_type: 'both',
        };
        
		openFileUploadPanel('fnPrintFileInfo', $M.toGetParam(param));
	}
	
	function fnPrintFileInfo(result) {
		setFileInfo(result.file_seq, result.file_name)
	}
	
	//첨부파일 세팅
	function setFileInfo(fileSeq, fileName) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" class="doc_file_list" name="doc_file_seq_'+ fileIndex + '" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) { 
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
			$("#doc_file_seq_" + fileIndex).remove();
		} else {
			return false;
		}
	}
	
	function fnClose() {
		window.close();
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
				dataField: "visit_use_yn",
				visible : false
			},
			{
				dataField: "visit_cmd",
				visible : false
			},
			{
				headerText: "방문일자",
				dataField: "visit_dt",
				width : "100",
				style : "aui-center",
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
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "방문처",
				dataField: "visit_place",
				width : "130",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "내용",
				dataField: "visit_content",
				width : "250",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "비고",
				dataField: "visit_remark",
				width : "150",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						if ((($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
							       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGrid, {visit_use_yn : "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								AUIGrid.updateRow(auiGrid, {visit_use_yn : "Y"}, event.rowIndex);
							}
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
		AUIGrid.setGridData(auiGrid, ${visitList});
		$("#auiGrid").resize();
		
		// 가불금 제외하고 에디팅 제어
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			// 결재상태에 따라 에디팅 제어
// 			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo) && '${page.fnc.F02014_001}' != 'Y') {
// 				if (event.dataField) {
// 					return false;
// 				}
// 			}
			
			if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y') {
				if (event.dataField) {
					return true;
				}
			}
			
			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo)) {
				if (event.dataField) {
					return false;
				}
			}			
		});
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
    		item.visit_use_yn = "Y"
    		item.visit_cmd = "C"

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
				dataField: "dtl_use_yn",
				visible : false
			},
			{
				dataField: "dtl_cmd",
				visible : false
			},
			{
				dataField: "trip_in_item_cd",
				visible : false
			},
			{
				headerText: "구분",
				dataField: "trip_in_item_name",
				width : "120",
				style : "aui-center",
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
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "내역",
				dataField: "trip_content",
				width : "150",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
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
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else if (item.trip_in_item_cd == "02" || item.trip_in_item_cd == "") {
						return "aui-editable";
					} else {
						return "aui-background-darkgray";
					}
				},
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == 0.0) {
						return "";
					} else {
						return value;
					}
				},
			},
			{
				dataField: "trip_in_oil_cd",
				visible : false
			},
			{
				headerText: "구간선택",
				dataField: "trip_in_oil_name",
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
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else if (item.trip_in_item_cd == "02" || item.trip_in_item_cd == "") {
						return "aui-editable";
					} else {
						return "aui-background-darkgray";
					}
				},
			},
			{
				headerText: "금액",
				dataField: "trip_amt",
				width : "120",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						if ((($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
							       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
							var isRemoved = AUIGrid.isRemovedById(auiGridTripI, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridTripI, {dtl_use_yn : "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGridTripI);
							} else {
								AUIGrid.restoreSoftRows(auiGridTripI, "selectedIndex");
								AUIGrid.updateRow(auiGridTripI, {dtl_use_yn : "Y"}, event.rowIndex);
								AUIGrid.update(auiGridTripI);
							}
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
				style : "aui-right aui-footer",
				expFunction : function(columnValues) {
					var gridData = AUIGrid.getGridData(auiGridTripI);
					var rowIdField = AUIGrid.getProp(auiGridTripI, "rowIdField");
					var item;
					var sum = 0;
					for(var i=0, len=gridData.length; i<len; i++) {
						item = gridData[i];
						if(!AUIGrid.isRemovedById(auiGridTripI, item[rowIdField])) {
							sum += item.trip_amt;
						}
					}
					return sum;
				}
			}
		];
		
		auiGridTripI = AUIGrid.create("#auiGridTripI", columnLayout, gridPros);
		// 푸터 세팅
		AUIGrid.setFooter(auiGridTripI, footerColumnLayout);
		AUIGrid.setGridData(auiGridTripI, ${dtlList});
		$("#auiGridTripI").resize();
		
		AUIGrid.bind(auiGridTripI, "cellEditBegin", function(event) {
			// 결재상태에 따라 에디팅 제어
// 			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo) && '${page.fnc.F02014_001}' != 'Y') {
// 				if (event.dataField) {
// 					return false;
// 				}
// 			}

			// 결재완료, 관리부일경우 수정가능
			if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y') {
				if (event.dataField) {
					
				}
				
			// 자신이 쓴 작성중은 수정가능
			} else if (($M.getValue("appr_proc_status_cd") == 01 && regMemNo == memNo)) {
				if (event.dataField) {
					
				} 
				
			// 위 두가지경우 아니면 수정불가능
			} else {
				return false;
			}
			
				
			// 구분 선택 후 다른 컬럼 수정가능.
			if(event.dataField == "trip_content" || event.dataField == "trip_km" || event.dataField == "trip_in_oil_name" || event.dataField == "trip_amt") {
				if (event.item.trip_in_item_name == "") {
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
			if(event.dataField == "trip_km" || event.dataField == "trip_in_oil_name") {
				if (event.item.trip_in_item_cd != "02") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridTripI, event.rowIndex, event.columnIndex, "유류대일 경우에만 출장거리(km), 구간선택이 가능합니다.");
					}, 1);
					return false;
				}
			}
			
			// 구분 : 유류대일 경우 내역, 금액 비활성화
			if(event.dataField == "trip_amt") {
				if (event.item.trip_in_item_name == "유류대" || event.item.trip_in_item_cd == "02") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridTripI, event.rowIndex, event.columnIndex, "유류대일 경우 금액은 자동계산 됩니다.");
					}, 1);
					return false;
				}
			}
				
		});
		
		AUIGrid.bind(auiGridTripI, "cellEditEnd", function( event ) {		
			if (event.dataField == "trip_in_item_name") {
				console.log("event : ", event);
				AUIGrid.updateRow(auiGridTripI, { "trip_in_item_cd" : event.value}, event.rowIndex);
				
				if (event.item.trip_in_item_name != "02") {
					// 구분 : 유류대가 아닌경우 출장거리, 구간선택 컬럼 초기화
					AUIGrid.updateRow(auiGridTripI, { "trip_km" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_in_oil_name" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_amt" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_content" : ""}, event.rowIndex);
				} else {
					// 구분 : 유류대일 경우 내역 컬럼 초기화
					AUIGrid.updateRow(auiGridTripI, { "trip_content" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridTripI, { "trip_amt" : ""}, event.rowIndex);
				}
			}

			if (event.dataField == "trip_in_oil_name") {
				AUIGrid.updateRow(auiGridTripI, { "trip_in_oil_cd" : event.value}, event.rowIndex);
			}
			
			if (event.dataField == "trip_km") {
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

			if (event.dataField == "trip_in_oil_name") {
				// 구분 : 유류대 일  금액 = 출장거리 * 구간
				var executiveYn = $M.getValue("grade_cd_v4");  // 임원여부
				var oilCodeVal = event.item.trip_in_oil_name;  // 구간 code값
				
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
				
				AUIGrid.updateRow(auiGridTripI, { "trip_amt" : event.item.trip_km * oilAmt}, event.rowIndex);
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
				dataField: "dtl_use_yn",
				visible : false
			},
			{
				dataField: "dtl_cmd",
				visible : false
			},
			{
				dataField: "trip_out_item_cd",
				visible : false
			},
			{
				headerText: "구분",
				dataField: "trip_out_item_name",
				width : "80",
				style : "aui-center",
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
				},
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "내역",
				dataField: "trip_content",
				width : "230",
				style : "aui-left",
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{
				headerText: "금액",
				dataField: "",
				children : [
					{
						headerText : "유로(U)",
						dataField: "out_eur_amt",
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
							if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
								       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
								return null;
							} else {
								return "aui-editable";
							}
						},
					}, 
					{
						headerText : "달러($)",
						dataField: "out_usd_amt",
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
							if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
								       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
								return null;
							} else {
								return "aui-editable";
							}
						},
					}, 
					{
						headerText : "엔화(Y)",
						dataField: "out_jpy_amt",
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
							if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
								       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
								return null;
							} else {
								return "aui-editable";
							}
						},
					}, 
					{
						headerText : "원화(W)",
						dataField: "out_krw_amt",
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
							if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
								       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
								return null;
							} else {
								return "aui-editable";
							}
						},
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
						if ((($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
							       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
							var isRemoved = AUIGrid.isRemovedById(auiGridTripO, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridTripO, {dtl_use_yn : "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridTripO, "selectedIndex");
								AUIGrid.updateRow(auiGridTripO, {dtl_use_yn : "N"}, event.rowIndex);
							}
							
							// 푸터 그리드 갱신
							fnCalcAmt("EUR");
							fnCalcAmt("USD");
							fnCalcAmt("JPY");
							fnCalcAmt("KRW");
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
		AUIGrid.setGridData(auiGridTripO, ${dtlList});
		$("#auiGridTripO").resize();
		
		// 가불금 제외하고 에디팅 제어
		AUIGrid.bind(auiGridTripO, "cellEditBegin", function (event) {
			// 결재상태에 따라 에디팅 제어
// 			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo) && '${page.fnc.F02014_001}' != 'Y') {
// 				if (event.dataField) {
// 					return false;
// 				}
// 			}
			
			if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y') {
				if (event.dataField) {
					return true;
				}
			}
			
			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo)) {
				if (event.dataField) {
					return false;
				}
			}			
		});
		
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
			
			if (event.dataField == "trip_out_item_name") {
				AUIGrid.updateRow(auiGridTripO, { "trip_out_item_cd" : event.value}, event.rowIndex);
			}
		});
	}		
	
	// 푸터 합계 구하기.
	function fnCalcAmt(code, rowIndex, inItYn) {
		var gridData = AUIGrid.getGridData(auiGridTripO);
		var gridDataFooter = AUIGrid.getGridData(auiGridTripOFooter);
		
		var sumValEUR = 0; // 유로합
		var sumValUSD = 0; // 달러합
		var sumValJPY = 0; // 엔화합
		var sumValKRW = 0; // 원화합
		
		for (var i = 0; i < gridData.length; i++) {
			var isRemoved = AUIGrid.isRemovedById(auiGridTripO, gridData[i]._$uid);
			if (isRemoved == false) {
				sumValEUR += gridData[i].out_eur_amt;
				sumValUSD += gridData[i].out_usd_amt;
				sumValJPY += gridData[i].out_jpy_amt;
				sumValKRW += gridData[i].out_krw_amt;
			}
		}
		
		switch (code) {
			case "EUR" :
				var returnAmt = 0;
				
				if (inItYn == "Y") {
					returnAmt = '${info.return_eur_amt}';
				} else {
					if (rowIndex == 2) {
						returnAmt = gridDataFooter[2].pre_out_eur_amt; // 반환금
					} else {
						returnAmt = gridDataFooter[0].pre_out_eur_amt - sumValEUR; // 반환금
					}
				}
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_eur_amt" : sumValEUR}, 1); // 합계
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_eur_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_eur_amt" : gridDataFooter[0].pre_out_eur_amt - sumValEUR - returnAmt}, 3); // 과부족
			break;
			case "USD" :
				var returnAmt = 0;
				
				if (inItYn == "Y") {
					returnAmt = '${info.return_usd_amt}';
				} else {
					if (rowIndex == 2) {
						returnAmt = gridDataFooter[2].pre_out_usd_amt; // 반환금
					} else {
						returnAmt = gridDataFooter[0].pre_out_usd_amt - sumValUSD; // 반환금
					}
				}
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_usd_amt" : sumValUSD}, 1);
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_usd_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_usd_amt" : gridDataFooter[0].pre_out_usd_amt - sumValUSD - returnAmt}, 3); // 과부족
			break;
			case "JPY" :
				var returnAmt = 0;
				
				if (inItYn == "Y") {
					returnAmt = '${info.return_jpy_amt}';
				} else {
					if (rowIndex == 2) {
						returnAmt = gridDataFooter[2].pre_out_jpy_amt; // 반환금
					} else {
						returnAmt = gridDataFooter[0].pre_out_jpy_amt - sumValJPY; // 반환금
					}
				}
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_jpy_amt" : sumValJPY}, 1);
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_jpy_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_jpy_amt" : gridDataFooter[0].pre_out_jpy_amt - sumValJPY - returnAmt}, 3); // 과부족
			break;
			case "KRW" :
				var returnAmt = 0;
				
				if (inItYn == "Y") {
					returnAmt = '${info.return_krw_amt}';
				} else {
					if (rowIndex == 2) {
						returnAmt = gridDataFooter[2].pre_out_krw_amt; // 반환금
					} else {
						returnAmt = gridDataFooter[0].pre_out_krw_amt - sumValKRW;  // 반환금
					}
				} 
				
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_krw_amt" : sumValKRW}, 1);
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_krw_amt" : returnAmt}, 2); // 반환금
				AUIGrid.updateRow(auiGridTripOFooter, { "pre_out_krw_amt" : gridDataFooter[0].pre_out_krw_amt - sumValKRW - returnAmt}, 3); // 과부족
			break;
		}
	}
	
	// 상세내역 - 해외 그리드생성
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
			showStateColumn : false,
			// 수정 표시 제거
			showEditedCellMarker : false
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
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						if (rowIndex == 0 || rowIndex == 2) {
							return "aui-editable";
						}
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
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						if (rowIndex == 0 || rowIndex == 2) {
							return "aui-editable";
						}
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
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						if (rowIndex == 0 || rowIndex == 2) {
							return "aui-editable";
						}
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
					if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
						       || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y'))) {
						return null;
					} else {
						if (rowIndex == 0 || rowIndex == 2) {
							return "aui-editable";
						}
					}
				},
			}, 
		];
		
		var dummyData = [
			{
				"header" : "가불금",
				"pre_out_eur_amt" : $M.getValue("pre_out_eur_amt_val"),
				"pre_out_usd_amt" : $M.getValue("pre_out_usd_amt_val"),
				"pre_out_jpy_amt" : $M.getValue("pre_out_jpy_amt_val"),
				"pre_out_krw_amt" : $M.getValue("pre_out_krw_amt_val")
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
				"pre_out_eur_amt" : $M.getValue("return_eur_amt_val"),
				"pre_out_usd_amt" : $M.getValue("return_usd_amt_val"),
				"pre_out_jpy_amt" : $M.getValue("return_jpy_amt_val"),
				"pre_out_krw_amt" : $M.getValue("return_krw_amt_val")
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
			if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02014_001}' == 'Y') {
				if (event.dataField) {
					return true;
				}
			}
			
			if (($M.getValue("appr_proc_status_cd") != 01 || regMemNo != memNo)) {
				if (event.dataField) {
					return false;
				}
			}			
			
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
	    		item.trip_in_item_name = "",
	    		item.trip_content = "",
	    		item.trip_km = "",
	    		item.trip_in_oil_cd = "",
	    		item.trip_in_oil_name = "",
	    		item.trip_amt = "",
	    		item.dtl_use_yn = "Y"
	    		item.dtl_cmd = "C"
	    		
	    		rowNum++;
	    		AUIGrid.addRow(auiGridTripI, item, 'last');
			}	
		} else {
			// 해외일경우
			if(fnCheckGridEmptyTripO(auiGridTripO)) {
				item.row_num = rowNum,
	    		item.seq_no = "",
	    		item.trip_out_item_cd = "",
	    		item.trip_out_item_name = "",
	    		item.trip_content = "",
	    		item.out_eur_amt = 0,
	    		item.out_usd_amt = 0,
	    		item.out_jpy_amt = 0,
	    		item.out_krw_amt = 0,
	    		item.dtl_use_yn = "Y"
	    		item.dtl_cmd = "C"
	    		
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
			    AUIGrid.showToastMessage(auiGridTripI, i, 5, "구분은 필수 입력입니다.");
			    return false;
			}
			
			// 유류대일경우 출장거리, 구간선택 필수
			if (gridData[i].trip_in_item_cd == "02") {
				if (gridData[i].trip_km == "") {
				    AUIGrid.showToastMessage(auiGridTripI, i, 7, "유류대일경우 출장거리는 필수 입력입니다.");
				    return false;					
				}

				if (gridData[i].trip_in_oil_cd == "") {
				    AUIGrid.showToastMessage(auiGridTripI, i, 8, "유류대일경우 구간선택은 필수 입력입니다.");
				    return false;					
				}
			} 
			
			// 금액
			if (gridData[i].trip_amt == "" || gridData[i].trip_amt == 0) {
			    AUIGrid.showToastMessage(auiGridTripI, i, 10, "금액은 필수 입력입니다.");
			    return false;	
			}
		}
		
		return true;
	}

	// 그리드 벨리데이션
	function fnCheckGridEmptyTripO() {
		return AUIGrid.validateGridData(auiGridTripO, ["trip_out_item_name"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 결재취소
	function goApprCancel() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}",
			appr_cancel_yn: "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}
	
	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method: 'GET'},
			function (result) {
				if (result.success) {
					alert("결재취소가 완료됐습니다.");
					location.reload();
				}
			}
		);
	}
	
	// 결재처리
	function goApproval() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}"
		};
		$M.setValue("save_mode", "approval"); // 승인
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}
	
	// 결재처리 결과
	function goApprovalResult(result) {
		// 반려이면 페이지 리로딩
		if (result.appr_status_cd == '03') {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("반려가 완료되었습니다.");
						location.reload();
					}
				}
			);
		} else if (result.appr_status_cd == '05') {
            $M.goNextPageAjax('/session/check', '', {method: 'GET'},
                function (result) {
                    if (result.success) {
                        alert("종결처리가 완료되었습니다.");
                        location.reload();
                    }
                }
            );
        } else {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("처리가 완료되었습니다.");
						location.reload();
					}
				}
			);
		}
	}
	
	// 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
	}

    // 종결처리
    function goApprovalEnd() {
        var param = {
            appr_job_seq : "${apprBean.appr_job_seq}",
            seq_no : "${apprBean.seq_no}",
            appr_end_only : 'Y',
        };
        openApprPanel("goApprovalResult", $M.toGetParam(param));
    }
	
	// 수정
	function goModify(isRequestAppr) {
		// validationcheck
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
		
		var idx = 1;
		$("input[class='doc_file_list']").each(function() {
			var str = 'doc_file_seq_' + idx;
			$M.setValue(str, $(this).val());
			idx++;
		});
		
		for(; idx <= fileMaxCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, 0);
		}

		var msg = "";
		if (isRequestAppr != undefined) {
			// 결재요청 Setting
			$M.setValue("save_mode", "appr");
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "modify");
			msg = "수정 하시겠습니까?";
		}
		
		var frm = $M.toValueForm(document.main_form);
		
		var concatCols = [];
		var concatList = [];
		var gridIds = [];
		if ($M.getValue("trip_io") == "I") {
			gridIds = [auiGrid, auiGridTripI];
		} else {
			gridIds = [auiGrid, auiGridTripO];
			
			var outFooterGridData = AUIGrid.getGridData(auiGridTripOFooter); // 해외 그리드 푸터 데이터
			// 가불금 세팅
			var preOutAmtData = outFooterGridData[0];
			console.log("preOutAmtData : ", preOutAmtData);
			$M.setValue(frm, "pre_out_eur_amt", preOutAmtData.pre_out_eur_amt);
			$M.setValue(frm, "pre_out_usd_amt", preOutAmtData.pre_out_usd_amt);
			$M.setValue(frm, "pre_out_jpy_amt", preOutAmtData.pre_out_jpy_amt);
			$M.setValue(frm, "pre_out_krw_amt", preOutAmtData.pre_out_krw_amt);
			
			// 반환금 세팅
			var returnAmtData = outFooterGridData[2];
			console.log("returnAmtData : ", returnAmtData);
			$M.setValue(frm, "return_eur_amt", returnAmtData.pre_out_eur_amt);
			$M.setValue(frm, "return_usd_amt", returnAmtData.pre_out_usd_amt);
			$M.setValue(frm, "return_jpy_amt", returnAmtData.pre_out_jpy_amt);
			$M.setValue(frm, "return_krw_amt", returnAmtData.pre_out_krw_amt);
		}
		
		for (var i = 0; i < gridIds.length; ++i) {
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}

		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);
		
		console.log("gridFrm : ", gridFrm);
		
		$M.goNextPageAjaxMsg(msg, this_page + "/modify", gridFrm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
					window.location.reload();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
	}
	
	// 삭제
	function goRemove() {
		var frm = $M.toValueForm(document.main_form);

		var concatCols = [];
		var concatList = [];
		var gridIds = [];
		if ($M.getValue("trip_io") == "I") {
			gridIds = [auiGrid, auiGridTripI];
		} else {
			gridIds = [auiGrid, auiGridTripO];
		}
		
		for (var i = 0; i < gridIds.length; ++i) {
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		
		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);
		
		console.log("gridFrm : ", gridFrm);

		$M.goNextPageAjaxRemove(this_page + "/remove", gridFrm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
	    			fnClose();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
	}	
	
	// 인쇄
	function fnPrint() {
		
		var tripIo = $M.getValue("trip_io");
		var titlePrefix = "I" == tripIo ? "국내" : "해외";  
		var title = titlePrefix + " 출장여비 정산서";

		var apprListJson = JSON.parse('${apprMemoListJson}');
		var apprMemoListJson = [];
		for(var i=0; i<apprListJson.length; i++){
			apprMemoListJson.push(apprListJson[i]);
			if(apprListJson[i].appr_status_cd == '03'){
				apprMemoListJson = [];
			}
		}
		
		apprMemoListJson[0].grade_name = "작성자";
		
		
		
		// 방문정보
		var visitGridData = AUIGrid.getGridData(auiGrid);
		//상세내역 (국내)
		var tripIGridData = AUIGrid.getGridData(auiGridTripI);
		if (tripIGridData.length > 0) {
			//상세내역 합계 (국내)
			tripIGridData[0].total_amt = AUIGrid.getFooterData(auiGridTripI)[0].value;
		}
		
		//상세내역 (해외)
		var tripOGridData = AUIGrid.getGridData(auiGridTripO);
		// 상세내역 합계 (해외)
		var tripOFooterData = AUIGrid.getGridData(auiGridTripOFooter);
		
		
		var data = {
			"mem_name" : "${info.mem_name}"
			, "doc_dt" : "${info.doc_dt}"
			, "org_name" : "${info.org_name}"
			, "grade_name" : "${info.grade_name}"
			, "trip_place" : $M.getValue("trip_place")
			, "remark" : $M.getValue("remark")
			, "trip_io" : tripIo
			, "title" : title
		};
		
		var param = {
			"data" : data
			, "dtlVisit" : visitGridData
			, "dtlTripI" : tripIGridData
			, "dtlTripO" : tripOGridData
			, "dtlTripOFooter" : tripOFooterData
			, "apprData" : apprMemoListJson
		}
		
		openReportPanel("mmyy/mmyy011103p01_01.crf", param);
	}
	
	
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${info.appr_proc_status_cd}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${info.appr_job_seq}" />
<input type="hidden" id="doc_type_cd" name="doc_type_cd" value="${info.doc_type_cd}" />
<input type="hidden" id="pre_out_eur_amt_val" name="pre_out_eur_amt_val" value="${info.pre_out_eur_amt}" />
<input type="hidden" id="pre_out_usd_amt_val" name="pre_out_usd_amt_val" value="${info.pre_out_usd_amt}" />
<input type="hidden" id="pre_out_jpy_amt_val" name="pre_out_jpy_amt_val" value="${info.pre_out_jpy_amt}" />
<input type="hidden" id="pre_out_krw_amt_val" name="pre_out_krw_amt_val" value="${info.pre_out_krw_amt}" />
<input type="hidden" id="return_eur_amt_val" name="return_eur_amt_val" value="${info.return_eur_amt}" />
<input type="hidden" id="return_usd_amt_val" name="return_usd_amt_val" value="${info.return_usd_amt}" />
<input type="hidden" id="return_jpy_amt_val" name="return_jpy_amt_val" value="${info.return_jpy_amt}" />
<input type="hidden" id="return_krw_amt_val" name="return_krw_amt_val" value="${info.return_krw_amt}" />
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
        	<div class="text-right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>
            </div>
<!-- 폼테이블 -->						
            <div class="title-wrap mt10">
                <div class="left approval-left">
                    <h4 class="primary">출장여비정산서 상세</h4>		
                </div>
<!-- 결재영역 -->
				<div class="pl10">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->
            </div>								
            <table class="table-border mt10">
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
                            <input type="text" class="form-control width120px" readonly value="${info.mem_name}">
                            <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                        </td>		
                        <th class="text-right">작성일</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${info.doc_dt}" dateformat="yyyy-MM-dd">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">부서</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.org_name}">
                            <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                        </td>		
                        <th class="text-right">직위</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.grade_name}">
                            <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                            <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">출장구분</th>
                        <td colspan="3">
                           <div class="form-check form-check-inline">
                               <input class="form-check-input" type="radio" id="trip_io_i" name="trip_io" value="I" ${info.trip_io == 'I' ? 'checked="checked"' : ''} disabled>
                               <label class="form-check-label" for="trip_io_i">국내</label>
                           </div>
                           <div class="form-check form-check-inline">
                               <input class="form-check-input" type="radio" id="trip_io_o" name="trip_io" value="O" ${info.trip_io == 'O' ? 'checked="checked"' : ''} disabled>
                               <label class="form-check-label" for="trip_io_o">해외</label>
                           </div>
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right essential-item">출장지(국)</th>
                        <td colspan="3">
                            <input type="text" class="form-control rb" id="trip_place" name="trip_place" required="required" value="${info.trip_place}">
                        </td>						
                    </tr>					
                </tbody>
            </table>	
<!-- /폼테이블 -->
<!-- 방문정보 -->		
                    <div class="title-wrap mt10">
                        <h4>방문정보</h4>
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>			
                    <div id="auiGrid" class="width750px" style="margin-top: 5px; height: 150px;"></div>
<!-- /방문정보 -->	
<!-- 상세내역 -->		
                    <div class="title-wrap mt10">
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
                    <table class="table-border mt10">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right">의견</th>
                                <td>
                                    <textarea class="form-control" style="height: 70px;" id="remark" name="remark">${info.remark}</textarea>
                                </td>							
                            </tr>	
                            <tr>
                                <th class="text-right">첨부파일</th>
		                        <td>
									<div class="table-attfile doc_file_div" style="width: 100%;">
										<div class="table-attfile" style="float: left">
											<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:goSearchFile();">파일찾기</button>
											&nbsp;&nbsp;
										</div>
									</div>
		                        </td>							
                            </tr>			
                        </tbody>
                    </table>				
<!-- /폼테이블 -->
<!-- 하단 내용 -->                  
                    <div class="doc-com ">
                        <div class="text">
                            위와 같이 정산서를 신청 하오니 재가하여 주시기 바랍니다<br>
                            ${info.apply_date.substring(0,4)}년 ${info.apply_date.substring(4,6)}월 ${info.apply_date.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                    부서 : ${info.org_name}<br>
                    성명 : ${info.mem_name}
                        </div> 
                    </div>			
<!-- /하단 내용 -->
<!-- 결재자 의견 -->   
            <div class="title-wrap mt10">
                <div class="left">
                    <h4>결재자 의견</h4>
                </div>                    
            </div>
				<table class="table mt5">
					<colgroup>
						<col width="40px">
						<col width="">
						<col width="60px">
						<col width="">
					</colgroup>
					<thead>
					<tr>
						<td colspan="5">
							<div class="fixed-table-container" style="width: 100%; height: 110px;">
								<!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
								<div class="fixed-table-wrapper">
									<table class="table-border doc-table md-table">
										<colgroup>
											<col width="40px">
											<col width="140px">
											<col width="55px">
											<col width="">
										</colgroup>
										<thead>
										<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
										<tr>
											<th class="th" style="font-size: 12px !important">구분</th>
											<th class="th" style="font-size: 12px !important">결재일시</th>
											<th class="th" style="font-size: 12px !important">담당자</th>
											<th class="th" style="font-size: 12px !important">특이사항</th>
										</tr>
										</thead>
										<tbody>
										<c:forEach var="list" items="${apprMemoList}">
											<tr>
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
												<td class="td"
													style="font-size: 12px !important">${list.proc_date }</td>
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
												<td class="td" style="font-size: 12px !important">${list.memo }</td>
											</tr>
										</c:forEach>
										</tbody>
									</table>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
<!-- /결재자 의견 -->
			<div class="btn-group mt10">
				<div class="right">
					<!-- 관리부는 수정가능 -->
					<c:if test="${page.fnc.F02014_001 eq 'Y' and info.appr_proc_status_cd == '05'}">
						<button type="button" class="btn btn-info" id="_goModify" name="_goModify" onclick="javascript:goModify()">수정</button>
					</c:if>			
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value="${info.doc_file_seq_1 }" />
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value="${info.doc_file_seq_2 }" />
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value="${info.doc_file_seq_3 }" />
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value="${info.doc_file_seq_4 }" />
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value="${info.doc_file_seq_5 }" />
</form>
</body>
</html>