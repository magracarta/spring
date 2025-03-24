<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 장비 입/출고 > 장비입고관리 > null > 장비입고처리
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	var auiGridTop;
	var auiGridBom;
	var machineOutPosArray = JSON.parse('${codeMapJsonObj['MACHINE_OUT_POS_STATUS']}');
	var hideColumnYn = '${page.fnc.F00724_002}';

	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGridTop();
		createAUIGridBom();
	});
	
	// 그리드생성
	function createAUIGridTop() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: false,
		};
		var columnLayout = [
			{ 
				headerText : "발주번호", 
				dataField : "machine_order_no", 
				style : "aui-center",
			},
			{
				headerText : "모델명", 
				dataField : "machine_name", 
				style : "aui-center"
			},
			{ 
				headerText : "Description", 
				dataField : "remark", 
				style : "aui-left"
			},
			{ 
				headerText : "Quantity", 
				dataField : "qty", 
				dataType : "numeric",
				width : "8%",
				style : "aui-center",
			},
			{ 
				headerText : "Option", 
				dataField : "opt_kor_name", 
				style : "aui-left",
			},
		];
	
		
		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTop, ${machineLcOrderList});
		//AUIGrid.setGridData(auiGridTop, testData);
		
		$("#auiGridTop").resize();
	}	

	// 미결사항 그리드
	function createAUIGridBom() {
		var gridPros = {
			rowIdField : "_$uid",
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : false,
			showRowNumColumn: true,
			editable : true,
		};

		var columnLayout = [
			{ 
				headerText : "처리구분", 
				dataField : "in_yn_name", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "모델명", 
				dataField : "machine_name", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "외화단가",
				dataField : "unit_price",
				dataType : "numeric",
				formatString : "#,##0.00",
				width : "100",
				style : "aui-right"
			},
			{ 
				headerText : "차대번호", 
				dataField : "body_no", 
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "엔진번호", 
				dataField : "engine_no_1", 
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "입고일자", 
				dataField : "in_dt",
				dataType : "date",
				style : "aui-center",
				dataInputString : "yyyymmdd",
				formatString : "yyyy-mm-dd",
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
				editable : true,
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.in_yn == "Y") {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{ 
				headerText : "상태구분", 
				dataField : "machine_out_pos_status_cd",
				style : "aui-center aui-editable",
				width : "6%",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					list : machineOutPosArray,
					keyField : "code_value",
					valueField  : "code_name"
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<machineOutPosArray.length; i++){
						if(value == machineOutPosArray[i].code_value){
							return machineOutPosArray[i].code_name;
						}
					}
					return value;
				},
// 				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 					if (item.in_yn == "Y") {
// 						return null;
// 					} else {
// 						return "aui-editable";
// 					}
// 					return "aui-editable";
// 				},
			},
			{ 
				headerText : "정비완료예정일", 
				dataField : "repair_finish_dt",
				dataType : "date",
				style : "aui-center aui-editable",
				dataInputString : "yyyymmdd",
				formatString : "yyyy-mm-dd",
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
				editable : true,
			},
			{ 
				headerText : "메모", 
				dataField : "remark", 
				style : "aui-left",
				styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.in_yn == "Y") {
						return null;
					} else {
						return "aui-editable";
					}
				},
			},
			{ 
				headerText : "컨테이너", 
				dataField : "container_name", 
				style : "aui-center",
				width : "10%",
				editable : false,
			},
			{
				headerText : "컨테이너상태", 
				dataField : "container_status_name", 
				style : "aui-center",
				width : "6%",
				editable : false,
			},
			{
				headerText : "센터확정여부", 
				dataField : "center_confirm_yn_nm",
				style : "aui-center",
				width : "6%",
				editable : false,
			},
			{
				headerText : "입고확정센터", 
				dataField : "in_org_name",
				style : "aui-center",
				width : "6%",
				editable : false,
			},
			{
				headerText : "입고예정일", 
				dataField : "center_in_plan_dt",
				style : "aui-center",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				width : "6%",
				editable : false,
			},
// 			{ 
// 				headerText : "창고명", 
// 				dataField : "center_org_name", 
// 				style : "aui-center",
// 				width : "7%",
// 				editable : false,
// 			},
// 			{ 
// 				headerText : "창고명", 
// 				dataField : "in_org_name", 
// 				style : "aui-center",
// 				width : "7%",
// 				editable : false,
// 			},
			{ 
				headerText : "옵션", 
				dataField : "opt_code", 
				style : "aui-center",
				width : "3%",
				editable : false,
			},
			{ 
				headerText : "옵션명", 
				dataField : "opt_kor_name", 
				style : "aui-center aui-popup",
				editable : false,
			},
			{
				headerText : "주문번호",
				dataField : "machine_order_no",
				visible : false
			},
			{
				dataField : "machine_seq",
				visible : false
			},
			{
				dataField : "container_seq",
				visible : false
			},
			{
				dataField : "center_confirm_yn",
				visible : false
			},
			{
				dataField : "center_confirm_req_yn",
				visible : false
			},
			{
				dataField : "in_yn",
				visible : false
			},
			{
				dataField : "cust_no",
				visible : false
			},
			{
				dataField : "breg_no",
				visible : false
			},
			{
				dataField : "in_org_code",
				visible : false
			},
			{
				dataField : "center_org_code",
				visible : false
			},
			{
				dataField : "machine_plant_seq",
				visible : false
			},
			{
				headerText : "발주옵션",
				dataField : "order_text",
				style : "aui-center",
				editable : false,
			},
		];
		
		auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridBom, ${bodyNoRegistList});

		AUIGrid.bind(auiGridBom, "rowCheckClick", function( event ) {
// 			if(event.item.in_yn == "Y"){
// 				alert("입고처리가 된 내역입니다.");
// 				AUIGrid.addUncheckedRowsByValue(auiGridBom, "container_seq", event.item.container_seq);
// 				return;
// 			}
			
			if(event.item.center_confirm_yn == "N"){
				alert("센터확정 처리를 먼저 진행 해 주세요.");
				AUIGrid.addUncheckedRowsByValue(auiGridBom, "container_seq", event.item.container_seq);
				return;
			}
			
			// 최승희대리님 입고처리 가능하도록. 전화로 요청. 211026 김상덕
			<%--if ("${SecureUser.mem_no}" != "MB00000133") {--%>
			if (${page.fnc.F00724_001 ne 'Y'}) {
				if(event.item.in_org_code != $M.getValue("login_org_code")) {
					alert("해당 입고센터만 처리 가능합니다.");
					AUIGrid.addUncheckedRowsByValue(auiGridBom, "container_seq", event.item.container_seq);
					return;
				}
			}
			
			if(event.item.container_seq != ""){
				if(event.checked){
					AUIGrid.addCheckedRowsByValue(auiGridBom, "container_seq", event.item.container_seq);
				}else{
					AUIGrid.addUncheckedRowsByValue(auiGridBom, "container_seq", event.item.container_seq);
				} 
			}
		});
		
		AUIGrid.bind(auiGridBom, "cellClick", function(event) {
			if(event.dataField == "opt_kor_name" && event.item.opt_kor_name != "") {
				
				var params = {
						opt_code : event.item.opt_code
						, opt_kor_name : event.item.opt_kor_name
						, machine_order_no : event.item.machine_order_no
						, machine_plant_seq : event.item.machine_plant_seq
				};
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=440, left=0, top=0";
				$M.goNextPage('/serv/serv0201p03', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});	
		
		AUIGrid.bind(auiGridBom, "cellEditBegin", function(event) {
			if (event.item.in_yn == "Y") {
				if(event.dataField == "in_dt" || event.dataField == "remark") {
					return false;
				}
			}
			
			if (event.dataField == "repair_finish_dt") {
				if (event.item.machine_out_pos_status_cd != "2") {
					setTimeout(function() {
						   AUIGrid.showToastMessage(auiGridBom, event.rowIndex, event.columnIndex, "상태가 정비후 일 경우에만 입력가능합니다.");
					}, 1);
					return false;
				}
			}
		});	
		
		AUIGrid.bind(auiGridBom, "cellEditEnd", function(event) {
			if (event.dataField == "in_dt") {
				var containerSeq = event.item.container_seq;
				var eventVal = event.value;
				
				var gridAllList = AUIGrid.getGridData(auiGridBom);	
				
				for (var i = 0; i < gridAllList.length; i++) {
					if (gridAllList[i].container_seq == containerSeq) {
						AUIGrid.updateRow(auiGridBom, { "in_dt" : eventVal }, i, false);
					}
				}
			}
			
			if (event.dataField == "repair_finish_dt") {
				var containerSeq = event.item.container_seq;
				var eventVal = event.value;
				
				var gridAllList = AUIGrid.getGridData(auiGridBom);	
				
				for (var i = 0; i < gridAllList.length; i++) {
					if (gridAllList[i].container_seq == containerSeq) {
						if (gridAllList[i].machine_out_pos_status_cd == "2") {
							AUIGrid.updateRow(auiGridBom, { "repair_finish_dt" : eventVal }, i, false);
						}
					}
				}
			}
			
			if (event.dataField == "machine_out_pos_status_cd") {
				if (event.value != "2") {
					AUIGrid.updateRow(auiGridBom, { "repair_finish_dt" : "" }, event.rowIndex);
				}
			}
		});

		// (Q&A 17756) 서비스 소속은 단가 보이면 안됨. 2023-02-08 정윤수, 이강원
		var hideList = ["unit_price"];
		// 서비스 소속은 입고단가 노출안함
		AUIGrid.hideColumnByDataField(auiGridBom, hideList);
		if("Y" != hideColumnYn) {
			AUIGrid.showColumnByDataField(auiGridBom, hideList);
		}

		$("#auiGridBom").resize();
		    // 구해진 칼럼 사이즈를 적용 시킴.
		var colSizeList = AUIGrid.getFitColumnSizeList(auiGridBom, true);
	    AUIGrid.setColumnSizeList(auiGridBom, colSizeList);
	}	
	
	// 닫기
    function fnClose() {
    	window.close();
    }
	
	function goInY() {
		var allRows = AUIGrid.getCheckedRowItemsAll(auiGridBom);
		var rowsLength = AUIGrid.getGridData(auiGridBom).length;
		if(allRows.length == 0){
			alert("선택된 값이 없습니다.");
			return;
		}

		var rows = [];

		// 체크된 행 중 미입고 행만 선별
		for (var k = 0; k < allRows.length; k++) {
			if (allRows[k].in_yn == "N") {
				rows.push(allRows[k]);
			}
		}

		if(rows.length == 0){
			alert("체크된 행중 미입고 처리된 행이 없습니다.");
			return;
		}

		var inOrgCodeArr = [];
		
		for(var i = 0; i < rows.length ; i++) {
			if(rows[i].in_yn == "Y") {
				alert("이미 입고처리된 컨테이너가 있습니다.");
				return;
			}
			
			inOrgCodeArr.push(rows[i].in_org_code);
			
			if(rows[i].center_confirm_yn == "N"){
				alert("센터확정이 되지 않았습니다.");
				return;
			}
			if(rows[i].client_cust_no == "") {
				alert("전표 발행 불가 고객코드 입니다. : 고객코드 없음");
				return;
			}
			if(rows[i].in_dt == "") {
				alert("입고일자는 필수 입력값입니다.");
				return;
			}
			if(rows[i].machine_out_pos_status_cd == "") {
				alert("상태구분은 필수 입력값입니다.");
				return;
			}
			if(rows[i].container_seq == "" || rows[i].container_seq == "0"){
				alert("컨테이너가 등록되지 않았습니다.");
				return;
			}
			
			if(rows[i].machine_out_pos_status_cd == "2" && rows[i].repair_finish_dt == "") {
				alert("상태가 정비후 일 경우 정비완료예정일은 필수 입력입니다.");
				return;
			}
		}
		
		const chkInOrgCode = Array.from(new Set(inOrgCodeArr));
		
		if (chkInOrgCode.length > 1) {
			alert("동일한 센터끼리만 입고처리가 가능합니다.");
			return;
		} else {
			$M.setValue("in_org_code", chkInOrgCode[0]);
		}
		
		var getData = AUIGrid.getGridData(auiGridBom);
		console.log("getData : ", getData);
		
		// var cnt = 0;
		// for (var i = 0; i < getData.length; i++) {
		// 	if (getData[i].in_yn == "N") {
		// 		cnt++;
		// 	}
		// }
		//
		// for (var i = 0; i < rows.length; i++) {
		// 	if (rows[i].in_yn == "N") {
		// 		cnt--;
		// 	}
		// }
		//
		// console.log("cnt : ", cnt);
		//
		// var in_ypn = "";
		// var machine_lc_status_cd = "";
		// if (cnt == 0) {
		// 	console.log("전체입고");
		// 	in_ypn = "Y";
		// 	machine_lc_status_cd = "11"
		// } else {
		// 	console.log("부분입고");
		// 	in_ypn = "P";
		// 	machine_lc_status_cd = "10"
		// }
		
		var machineSeqArr = [];
		var containerSeqArr = [];
		var machineOutPosStatusCd = [];
		var remarkArr = [];
		var inDtArr = [];
// 		var inOrgCodeArr = [];
		var containerStatusCdArr = [];
		var repairFinishDtArr = [];
		
		// 옵션관련
		var machinePlantSeqArr = [];
		var originMachinePlantSeqArr = [];
		var optCodeArr = [];
		
		for (var i = 0; i < rows.length; i++) {
			machineSeqArr.push(rows[i].machine_seq);
			containerSeqArr.push(rows[i].container_seq);
			machineOutPosStatusCd.push(rows[i].machine_out_pos_status_cd);
			remarkArr.push(rows[i].remark);
			inDtArr.push(rows[i].in_dt);
// 			inOrgCodeArr.push(rows[i].center_org_code);
			originMachinePlantSeqArr.push(rows[i].machine_plant_seq);
			containerStatusCdArr.push("03");
			repairFinishDtArr.push(rows[i].repair_finish_dt);
			
			if (rows[i].opt_code != "") {
				optCodeArr.push(rows[i].opt_code);
				machinePlantSeqArr.push(rows[i].machine_plant_seq);
			}
		}
		
		frm = $M.toValueForm(document.main_form);
		
		var option = {
				isEmpty : true
		};
		console.log($M.getArrStr(machinePlantSeqArr, option));
		
		$M.setValue(frm, "machine_lc_no", $M.getValue("machine_lc_no"));
		$M.setValue(frm, "machine_seq_str", $M.getArrStr(machineSeqArr, option));
		$M.setValue(frm, "container_seq_str", $M.getArrStr(containerSeqArr, option));
		$M.setValue(frm, "machine_out_pos_status_cd_str", $M.getArrStr(machineOutPosStatusCd, option));
		$M.setValue(frm, "in_remark_str", $M.getArrStr(remarkArr, option));
		$M.setValue(frm, "in_dt_str", $M.getArrStr(inDtArr, option));
// 		$M.setValue(frm, "in_org_code_arr_str", $M.getArrStr(inOrgCodeArr, option));
		$M.setValue(frm, "container_status_cd_str", $M.getArrStr(containerStatusCdArr, option));
		// $M.setValue(frm, "in_ypn", in_ypn);
		// $M.setValue(frm, "machine_lc_status_cd", machine_lc_status_cd);
		$M.setValue(frm, "client_cust_no", $M.getValue("client_cust_no"));
		$M.setValue(frm, "in_org_code", $M.getValue("in_org_code"));
		$M.setValue(frm, "machine_plant_seq_str", $M.getArrStr(machinePlantSeqArr, option));
		$M.setValue(frm, "opt_code_str", $M.getArrStr(optCodeArr, option));
		$M.setValue(frm, "origin_machine_plant_seq_str", $M.getArrStr(originMachinePlantSeqArr, option));
		$M.setValue(frm, "repair_finish_dt_str", $M.getArrStr(repairFinishDtArr, option));
		console.log(frm);
		
		var msg = "입고처리 후 수정 및 삭제가 불가능 합니다. 처리 하시겠습니까? \n(미입고 행만 입고처리 됩니다.)";

		console.log("frm : ", frm);

		$M.goNextPageAjaxMsg(msg, this_page + "/inSave", frm, {method : 'POST'},
			function(result) {
				if(result.success) {
					location.reload();
					if(opener != null && opener.goSearch) {
						opener.goSearch();
					}
				}
			}
		);
	}
	
	function goSave() {
		var rows = AUIGrid.getCheckedRowItemsAll(auiGridBom);
// 		var rows = AUIGrid.getEditedRowItems(auiGridBom); // 변경내역
		
		var frm = document.main_form;
		frm = $M.toValueForm(frm);
		
		console.log(rows);
		
		if(rows.length == 0){
			alert("선택된 값이 없습니다.");
			return;
		}
		
		var machineSeqArr = [];
		var machineOutPosStatusCdArr = [];
		var inDtArr = [];
		var remarkArr = [];
		var repairFinishDtArr = [];
		var inOrgCodeArr = [];
		
		for (var i = 0; i < rows.length; i++) {
			machineSeqArr.push(rows[i].machine_seq);
			machineOutPosStatusCdArr.push(rows[i].machine_out_pos_status_cd);
			inDtArr.push(rows[i].in_dt);
			remarkArr.push(rows[i].remark);
			repairFinishDtArr.push(rows[i].repair_finish_dt);
			inOrgCodeArr.push(rows[i].in_org_code);
		}
		
		var option = {
				isEmpty : true
		};
		
		$M.setValue(frm, "machine_seq_str", $M.getArrStr(machineSeqArr, option));
		$M.setValue(frm, "machine_out_pos_status_cd_str", $M.getArrStr(machineOutPosStatusCdArr, option));
		$M.setValue(frm, "in_dt_str", $M.getArrStr(inDtArr, option));
		$M.setValue(frm, "remark_str", $M.getArrStr(remarkArr, option));
		$M.setValue(frm, "repair_finish_dt_str", $M.getArrStr(repairFinishDtArr, option));
		$M.setValue(frm, "real_in_org_code_str", $M.getArrStr(inOrgCodeArr, option));

		console.log("frm : ", frm);

		$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'},
			function(result) {
				if(result.success) {
					location.reload();
				}
			}
		);
	}
	
	function goBodyNoPrint() {
		var rows = AUIGrid.getCheckedRowItemsAll(auiGridBom);
		var rowsLength = AUIGrid.getGridData(auiGridBom).length;
		if(rows.length == 0){
			alert("선택된 값이 없습니다.");
			return;
		}
		
		// 엔진번호 공백 제거
		for (var i in rows) {
			rows[i].engine_no_1 = rows[i].engine_no_1.trim(); 
		}
		
		var param = {"data" : rows};
			
		openReportPanel('serv/serv0201p02_01_.crf', param);
	}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="client_cust_no" id="client_cust_no" value="${machineInMap.client_cust_no}"> <!-- 품명 외 몇 건 -->
<input type="hidden" name="in_org_code" id="in_org_code"> 
<input type="hidden" name="login_org_code" id="login_org_code" value="${login_org_code}"> 
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap half-print">
				<h4 class="primary">장비입고처리</h4>		
			</div>
<!-- 폼테이블 -->
			<table class="table-border mt5">
				<colgroup>
					<col width="75px">
					<col width="">
					<col width="75px">
					<col width="">
					<col width="75px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">관리번호</th>
						<td>
							<input type="text" id="machine_lc_no" name="machine_lc_no" class="form-control width200px" value="${machineInMap.machine_lc_no}"readonly>
							<!-- <div class="form-row inline-pd">
								<div class="col-5">
									<input type="text" class="form-control" readonly>
								</div>
								<div class="col-auto">~</div>
								<div class="col-5">
									<input type="text" class="form-control" readonly>
								</div>
							</div> -->
						</td>
						<th class="text-right">담당자</th>
						<td>
<%-- 							<input type="text" id="client_charge_name" name="client_charge_name" class="form-control width120px" value="${machineInMap.client_charge_name }" readonly> --%>
							<input type="text" class="form-control width80px" id="reg_mem_name" name="reg_mem_name" value="${machineInMap.reg_mem_name}" readonly alt="담당자"  required="required">
							<input type="hidden" name="reg_id" id="reg_id" value="${machineInMap.reg_mem_no}" >
						</td>
						<th class="text-right">상태</th>
						<td>${machineInMap.machine_lc_status_name }</td>
					</tr>
					<tr>
						<th class="text-right">발주일자</th>
						<td>
							<input type="text" id="lc_dt" name="lc_dt" class="form-control width120px" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${machineInMap.lc_dt}" alt="조회 시작일" readonly>
						</td>
						<th class="text-right">To</th>
						<td>
							<input type="text" id="cust_name" name="cust_name" class="form-control" value="${machineInMap.cust_name }" readonly>
						</td>
						<th rowspan="2" class="text-right">From</th>
						<td rowspan="2">
							<div class="form-row inline-pd mb7">
								<div class="col-12">
									<input type="text" id="mem_eng_name" name="mem_eng_name" class="form-control" value="${machineInMap.mem_eng_name }"readonly>
								</div>
							</div>
							<div class="form-row inline-pd">
								<div class="col-12">
									<input type="text" id="job_eng_name" name="job_eng_name" class="form-control" value="${machineInMap.job_eng_name }" readonly>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">입고예정</th>
						<td>
							<input type="text" id="in_plan_dt" name="in_plan_dt" class="form-control width120px" dateFormat="yyyy-MM-dd"  value="${machineInMap.in_plan_dt}" alt="조회 완료일" readonly>
						</td>
						<th class="text-right">Re</th>
						<td>
							<input type="text" id="order_remark" name="order_remark" class="form-control" value="${machineInMap.order_remark }" readonly>
						</td>
					</tr>
				</tbody>
			</table>
<!-- /폼테이블 -->			
<!-- 발주내역 -->
			<div class="title-wrap mt10">
				<h4>발주내역</h4>
			</div>
			<div id="auiGridTop" style="margin-top: 5px; height: 200px;"></div>
<!-- /발주내역 -->
<!-- 차대번호등록내역 -->
			<div class="title-wrap mt10">
				<h4>차대번호등록내역</h4>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					<button type="button" class="btn btn-default" onclick="javascript:goInY();"><i class="material-iconsdone text-default"></i>입고처리</button>
				</div>
			</div>
			<div id="auiGridBom" style="margin-top: 5px; height: 200px;"></div>	
<!-- /차대번호등록내역 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
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