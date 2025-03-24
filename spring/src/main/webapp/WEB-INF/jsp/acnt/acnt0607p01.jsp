<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 발령관리 > null > 발령 상세
-- 작성자 : 이강원
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
	var auiGrid;
	var orgList = ${orgList};
	var gradeList = JSON.parse('${codeMapJsonObj['GRADE']}');
	var memMoveList = JSON.parse('${codeMapJsonObj['MEM_MOVE']}');
	// 수습이 아닌 인원은 발령구분에 수습해지가 없는 리스트
	var memMoveList2 = memMoveList.filter(function(value,index,arr){
		return arr[index].code_value != '04';
	});
	// 부서권한
	var menuOrgList = ${menuOrgList};
	// 인사정보 반영여부 N, 셀 편집 N 일 때 true
	var showMemApplyYn = false;
	
	// 부서별 권한
	// function getOrgList(orgCode) {
	// 	return menuOrgList.filter(function(value,index,arr){
	// 		return arr[index].up_org_code == orgCode;
	// 	});
	// }
	
	// getOrgList로 수정 220613 김상덕
	/* 
	// 부품부권한
	var partOrgList = menuOrgList.filter(function(value,index,arr){
		return arr[index].up_org_code == '6000';
	});
	// 서비스권한
	var servOrgList = menuOrgList.filter(function(value,index,arr){
		return arr[index].up_org_code == '5000';
	});
	// 영업권한
	var saleOrgList = menuOrgList.filter(function(value,index,arr){
		return arr[index].up_org_code == '4000';
	});
	// 경영지원권한
	var suppOrgList = menuOrgList.filter(function(value,index,arr){
		return arr[index].up_org_code == '3000';
	});
	// 관리권한
	var manageOrgList = menuOrgList.filter(function(value,index,arr){
		return arr[index].up_org_code == '2000';
	});
	 */
	
	// 현재 부서별 권한 임시저장
	var nowOrgList = [];
	
	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
	});
	
	function createAUIGrid(){
		var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
				rowHeight : 30,
		};
		var myDateEditRenderer = {
				type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
				defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
				onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
				maxlength : 8,
				editable : true,
				onlyNumeric : true, // 숫자만
				validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
					return fnCheckDate(oldValue, newValue, rowItem);
				},
				showEditorBtnOver : true	
		};
		var myDropOrgEditRenderer = {
				type : "DropDownListRenderer",
				showEditorBtn : false,
				showEditorBtnOver : true,
				editable : true,
				list : orgList,
				keyField : "org_code", 
				valueField : "path_org_name",	
		};
		var myDropGradeEditRenderer = {
				type : "DropDownListRenderer",
				showEditorBtn : false,
				showEditorBtnOver : true,
				editable : true,
				list : gradeList,
				keyField : "code_value", 
				valueField : "code_name",	
		};
		var columnLayout = [
			{
				headerText : "직원번호", 
				dataField : "mem_no", 
				style : "aui-center",
				editable : false,
				visible : false,
			},
			{
				headerText : "순번", 
				dataField : "seq_no", 
				style : "aui-center",
				editable : false,
				visible : false,
			},
			{
				headerText : "사용여부", 
				dataField : "use_yn", 
				style : "aui-center",
				editable : false,
				visible : false,
			},
			{
				headerText : "지급품회수 체크", 
				dataField : "payment_check", 
				style : "aui-center",
				editable : false,
				visible : false,
			},
			{
				headerText : "전도금관리체크", 
				dataField : "imprest_mem_check", 
				style : "aui-center",
				editable : false,
				visible : false,
			},
			{
				headerText : "직원명", 
				dataField : "mem_name", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "계정아이디", 
				dataField : "web_id", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "사번", 
				dataField : "emp_id", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "발령일자", 
				dataField : "move_dt", 
				width : "70",
				minWidth : "70",
				style : "aui-center aui-editable",
				dataType : "date",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
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
			},
			{
				headerText : "발령구분", 
				dataField : "mem_move_cd", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : true,
					listFunction : function(rowIndex,columnIndex,item){
						if(item.regular_st_dt == ""){
							return memMoveList;
						}
						return memMoveList2;
					},
					keyField : "code_value", 
					valueField : "code_name",
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					for(var i=0; i<memMoveList.length; i++) {
						if(value == memMoveList[i].code_value){
							return memMoveList[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText : "현 정보", 
				children:[
					{
						headerText : "부서", 
						dataField : "old_org_code", 
						width : "70",
						minWidth : "70",
						styleFunction : myCellStyleFunction,
						editable : false,
						labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
							if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06' ){
								return item.old_org_name;
							}
							return "";
						}
					},
					{
						headerText : "직책",
						dataField : "old_grade_cd", 
						width : "70",
						minWidth : "70",
						styleFunction : myCellStyleFunction,
						editable : false,
						labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
							if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
								return item.old_grade_name;
							}
							return "";
						}
					},
					{
						headerText : "직급",
						dataField : "old_job_cd", 
						visible : false,
						editable : false,
					},
					{
						headerText : "부서권한", 
						dataField : "old_menu_org_code", 
						visible : false,
						editable : false,
					},
				]
			},
			{
				headerText : "발령 후 정보", 
				children:[
					{
						headerText : "부서", 
						dataField : "new_org_code", 
						width : "70",
						minWidth : "70",
						styleFunction : myCellStyleFunction,
						editable : true,
						editRenderer : {
							type : "ConditionRenderer", 
							conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
								if(item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
									return myDropOrgEditRenderer;
								}
							}
						},
						labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
							if(item.mem_move_cd == '01' ){
								return item.old_org_name;
							}else if(item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
								for(var i=0; i<orgList.length; i++) {
									if(value == orgList[i].org_code){
										return orgList[i].org_name;
									}
								}
							}else{
								return "";
							}
						}
					},
					{
						headerText : "직책",
						dataField : "new_grade_cd", 
						width : "70",
						minWidth : "70",
						styleFunction : myCellStyleFunction,
						editable : true,
						editRenderer : {
							type : "ConditionRenderer", 
							conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
								if(item.mem_move_cd == '01' || item.mem_move_cd == '04' || item.mem_move_cd == '06'){
									return myDropGradeEditRenderer;
								}
							}
						},
						labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
							if(item.mem_move_cd == '02' || item.mem_move_cd == '05'){
								return item.old_grade_name;
							}else if(item.mem_move_cd == '01' || item.mem_move_cd == '04' || item.mem_move_cd == '06'){
								for(var i=0; i<gradeList.length; i++) {
									if(value == gradeList[i].code_value){
										return gradeList[i].code_name;
									}
								}
							}else {
								return "";
							}
						}
					},
					{
						headerText: "부서권한",
						dataField: "new_menu_org_code",
						width: "250",
						minWidth: "180",
						editable: false,
						style: "aui-background-darkgray",
						editRenderer : {
							type: "DropDownListRenderer",
							showEditorBtn : false,
							showEditorBtnOver : false,
							list: menuOrgList,
							listAlign: "left",
							keyField: "org_code",
							valueField: "path_org_name",
							editable: false
						},
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
							var retStr = "";
							if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06') {
								for (var i = 0; i < menuOrgList.length; i++) {
									if (value == menuOrgList[i].org_code) {
										retStr = menuOrgList[i].path_org_name;
									}
								}
							}
							return retStr;
						}
					},
// 					{
// 						headerText : "부서권한",
// 						dataField : "new_menu_org_code",
// 						width : "70",
// 						minWidth : "70",
// 						styleFunction : myCellStyleFunction,
// 						editable : true,
// 						editRenderer : {
// 							type : "DropDownListRenderer",
// 							showEditorBtn : false,
// 							showEditorBtnOver : true,
// 							editable : true,
// 							listFunction : function(rowIndex, columnIndex, value, item, dataField){
// 								var new_org_code = AUIGrid.getCellValue(auiGrid,rowIndex,"new_org_code");
//
// 								for(var i=0; i<orgList.length; i++){
// 									if(new_org_code == orgList[i].org_code){
// 										new_org_code = orgList[i].root_org_code;
// 										break;
// 									}
// 								}
//
// // 								if(new_org_code == '6000'){
// // 									nowOrgList = partOrgList;
// // 								}else if(new_org_code == '5000'){
// // 									nowOrgList = servOrgList;
// // 								}else if(new_org_code == '4000'){
// // 									nowOrgList = saleOrgList;
// // 								}else if(new_org_code == '3000'){
// // 									nowOrgList = suppOrgList;
// // 								}else if(new_org_code == '2000'){
// // 									nowOrgList = manageOrgList;
// // 								}else{
// // 									nowOrgList = [];
// // 								}
// 								nowOrgList = getOrgList(new_org_code);
// 								return nowOrgList;
// 							},
// 							keyField : "org_code",
// 							valueField : "org_name",
// 						},
// 						labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
// 							if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
// 								for(var i=0; i<menuOrgList.length; i++) {
// 									if(value == menuOrgList[i].org_code){
// 										return menuOrgList[i].org_name;
// 									}
// 								}
// 								for(var i=0; i<menuOrgList.length; i++) {
// 									if(item.new_org_code == menuOrgList[i].up_org_code && item.new_grade_cd == menuOrgList[i].menu_grade_cd && menuOrgList[i].menu_grade_cd != ""){
// 										value = menuOrgList[i].org_code;
// 										return menuOrgList[i].org_name;
// 									}
// 								}
// 								return "";
// 							}else {
// 								return "";
// 							}
// 						}
// 					},
					{
						headerText : "직급",
						dataField : "new_job_cd", 
						visible : false,
						editable : false,
					},
				]
			},
			{
				headerText : "시작일", 
				dataField : "start_dt", 
				width : "80",
				minWidth : "80",
				dataType : "date",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				styleFunction : myCellStyleFunction,
				editable : true,
				editRenderer : {
					type : "ConditionRenderer",
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '03' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
							return myDateEditRenderer;
						}
					}
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '03' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
						return AUIGrid.formatDate(value,"yy-mm-dd");
					}else{
						return "";
					}
				}
			},
			{
				headerText : "종료일", 
				dataField : "end_dt", 
				width : "80",
				minWidth : "80",
				dataType : "date",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				styleFunction : myCellStyleFunction,
				editable : true,
				editRenderer : {
					type : "ConditionRenderer",
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						if(item.mem_move_cd == '03' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '90'){
							return myDateEditRenderer;
						}
					}
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(item.mem_move_cd == '03' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '90'){
						if(value == null || value == ""){
							return "";
						}
						return AUIGrid.formatDate(value,"yy-mm-dd");
					}else{
						return "";
					}
				}
			},
			{
				headerText : "지급품회수", 
				dataField : "collectBtn", 
				width : "70",
				styleFunction : myCellStyleFunction,
				editable : false,
				renderer : {
					type : "TemplateRenderer"
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(item.mem_move_cd == '90'){
						var template = '<div class="aui-grid-renderer-base" style="white-space: nowrap; display: inline-block; width: 100%; max-height: 24px;">';
						template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goCheckPayment(\'' + item.mem_no + '\','+rowIndex+',0)">지급품회수</span></div>'
						
						return template;
					}else{
						return null;
					}
				}	
			},
			{
				headerText : "비고", 
				dataField : "remark", 
				width : "150",
				minWidth : "150",
				editable : true,
				style : "aui-left",
			},
			{
				headerText : "공지<br>여부", 
				dataField : "notice_seq", 
				width : "40",
				minWidth : "40",
				style : "aui-center",
				editable : false,
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(value > 0){
						return "Y";
					}else{
						return "N";
					}
				}
			},
			{ 
				headerText : "삭제", 
				dataField : "removeBtn", 
				width : "50",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						if(event.item.modify_yn == 'N'){
							alert("공지가 등록된 발령은 삭제할 수 없습니다.");
							return;
						}
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if(isRemoved == false){
							AUIGrid.updateRow(auiGrid,{"cmd":"D"},event.rowIndex);
							AUIGrid.removeRow(event.pid,event.rowIndex);
						}else{
							AUIGrid.restoreSoftRows(auiGrid,"selectedIndex");
							AUIGrid.updateRow(auiGrid,{"cmd":""},event.rowIndex);
						}
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,headerText, item) {
					return "삭제";
				},
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "인사정보<br>반영여부", 
				dataField : "mem_apply_yn", 
				width : "60",
				style : "aui-center aui-editable",
				editable : false,
			},
			{
				headerText : "인사정보<br>반영", 
				dataField : "mem_apply_yn", 
				width : "60",
				styleFunction : myCellStyleFunction,
				editable : false,
				renderer : {
					type : "TemplateRenderer"
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(value == 'N' && item.apply_check == 'Y'){
						showMemApplyYn = true;
						var template = '<div class="aui-grid-renderer-base" style="white-space: nowrap; display: inline-block; width: 100%; max-height: 24px;">';
						template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goHRApply(\'' + item.mem_move_no + '\',' + item.seq_no + ',' + item.mem_move_cd + ')">반영</span></div>';
						return template;
					}else{
						return null;
					}
				}	
			},
			{
				dataField : "cmd",
				visible : false,
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${memMoveList});
		AUIGrid.bind(auiGrid,"cellClick",function(event){
			$M.setValue("clickedRowIndex", event.rowIndex);
			if(event.item.modify_yn == 'N' && event.dataField != "mem_apply_yn"){
				alert("공지가 등록된 발령사항은 수정이 불가능합니다. 공지 삭제후 수정해주세요.");
			}
		});
		AUIGrid.bind(auiGrid,"cellEditBegin",function(event){
			if(event.dataField == "mem_move_cd"){
				if(event.item.modify_yn == 'N'){
					return false;
				}
			}else if(event.dataField == "move_dt"){
				if(event.item.modify_yn == 'N'){
					return false;
				}
			}else if(event.dataField == "new_org_code"){
				if(event.item.mem_move_cd == '02' || event.item.mem_move_cd == '04' || event.item.mem_move_cd == '05' || event.item.mem_move_cd == '06'){
					if(event.item.modify_yn == 'N'){
						return false;
					}
					return true;
				}else{
					return false;
				}
			}else if(event.dataField == "new_grade_cd"){
				if(event.item.mem_move_cd == '01' || event.item.mem_move_cd == '04' || event.item.mem_move_cd == '06'){
					if(event.item.modify_yn == 'N'){
						return false;
					}
					return true;
				}else{
					return false;
				}
			}else if(event.dataField == "start_dt"){
				if(event.item.mem_move_cd == '01' || event.item.mem_move_cd == '02' || event.item.mem_move_cd == '03' || event.item.mem_move_cd == '05' || event.item.mem_move_cd == '06'){
					if(event.item.modify_yn == 'N'){
						return false;
					}
					return true;
				}else{
					return false;
				}
			}else if(event.dataField == "end_dt"){
				if(event.item.mem_move_cd == '03' || event.item.mem_move_cd == '04' || event.item.mem_move_cd == '05' || event.item.mem_move_cd == '90'){
					if(event.item.modify_yn == 'N'){
						return false;
					}
					return true;
				}else{
					return false;
				}
			}else if(event.dataField == "new_menu_org_code"){
				// if(event.item.mem_move_cd == '01' || event.item.mem_move_cd == '02' || event.item.mem_move_cd == '04' || event.item.mem_move_cd == '05' || event.item.mem_move_cd == '06'){
				// 	if(event.item.modify_yn == 'N'){
				// 		return false;
				// 	}
				// 	return true;
				// }else{
				// 	return false;
				// }
			}else if(event.dataField == "remark"){
				if(event.item.modify_yn == 'N'){
					return false;
				}
			}
		});
		AUIGrid.bind(auiGrid,"cellEditEnd",function(event){
			var rowIndex = event.rowIndex;
			AUIGrid.setCellValue(auiGrid,rowIndex,"apply_check","N");
			if(event.dataField == "mem_move_cd"){
				var tempNewOrgCode;
				var tempNewGradeCd;
				var tempStartDt;
				var tempEndDt;
				var menuOrgCheck = false;
				AUIGrid.setCellValue(auiGrid,rowIndex,"payment_check","Y");
				switch(event.item.mem_move_cd){
					case '01':
						tempNewGradeCd = "";
						tempNewOrgCode = event.item.old_org_code;
						tempStartDt = event.item.move_dt;
						tempEndDt = "";
						menuOrgCheck = true;
						break;
					case '02':
						tempNewGradeCd = event.item.old_grade_cd ;
						tempNewOrgCode = "";
						tempStartDt = event.item.move_dt;
						tempEndDt = "";
						menuOrgCheck = true;
						break;
					case '03':
						tempNewGradeCd = "";
						tempNewOrgCode = "";
						tempStartDt = event.item.move_dt;
						tempEndDt = "";
						break;
					case '04':
						tempNewGradeCd = "";
						tempNewOrgCode = "";
						tempStartDt = event.item.ipsa_dt;
						tempEndDt = event.item.move_dt;
						break;
					case '05':
						tempNewGradeCd = event.item.old_grade_cd ;
						tempNewOrgCode = "";
						tempStartDt = event.item.move_dt;
						tempEndDt = "";
						menuOrgCheck = true;
						break;
					case '06':
						tempNewGradeCd = "";
						tempNewOrgCode = "";
						tempStartDt = event.item.move_dt;
						tempEndDt = "";
						menuOrgCheck = true;
						break;
					case '90':
						tempNewGradeCd = "";
						tempNewOrgCode = "";
						tempStartDt = "";
						tempEndDt = "";
						AUIGrid.setCellValue(auiGrid,rowIndex,"payment_check","N");
						break;
				}
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_grade_cd",tempNewGradeCd);
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_org_code",tempNewOrgCode);
				AUIGrid.setCellValue(auiGrid,rowIndex,"start_dt",tempStartDt);
				AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",tempEndDt);
				if (tempNewGradeCd == "" || tempNewOrgCode == "") {
					AUIGrid.setCellValue(auiGrid,rowIndex,"new_menu_org_code","");
				} else {
					var param = {
						row_idx: rowIndex,
						org_code: tempNewOrgCode,
						grade_cd: tempNewGradeCd
					}
					fnSetOrgAuth(param);
				}
			}else if(event.dataField == "move_dt"){
				if(event.item.mem_move_cd == '04'){
					if(event.item.start_dt < event.item.move_dt){
						AUIGrid.setCellValue(auiGrid,rowIndex,"move_dt",event.item.start_dt);
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "발령일자를 입사일(시작일) 이후로 선택해주세요.");
					}else{
						AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",event.item.move_dt);
					}
				}else if(event.item.mem_move_cd == '90'){
					AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",event.item.move_dt);
				}else{
					AUIGrid.setCellValue(auiGrid,rowIndex,"start_dt",event.item.move_dt);
					if(event.item.move_dt > event.item.end_dt){
						AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",event.item.move_dt);
					}
				}
			}else if(event.dataField == "start_dt"){
				if(event.item.start_dt < event.item.move_dt){
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "시작일을 발령일자 이후로 선택해주세요.");
					}, 1);
					AUIGrid.setCellValue(auiGrid,rowIndex,"start_dt",event.item.move_dt);
				}else if(event.item.start_dt > event.item.end_dt && event.item.end_dt != ""){
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "시작일을 종료일 이전으로 선택해주세요.");
					}, 1);
					AUIGrid.setCellValue(auiGrid,rowIndex,"start_dt",event.item.move_dt);
				}
			}else if(event.dataField == "end_dt"){
				if(event.item.mem_move_cd != '90' && (event.item.start_dt > event.item.end_dt)){
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료일을 시작일 이후로 선택해주세요.");
					}, 1);
					AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",event.item.start_dt);
				}else if(event.item.mem_move_cd == '04' && ((event.item.start_dt > event.item.end_dt)||(event.item.move_dt > event.item.end_dt))){
					if(event.item.start_dt < event.item.move_dt){
						setTimeout(function() {
							 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료일을 발령일자 이후로 선택해주세요.");
						}, 1);
						AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",event.item.move_dt);
					}else{
						setTimeout(function() {
							 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료일을 시작일 이후로 선택해주세요.");
						}, 1);
						AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",event.item.start_dt);
					}
				}else if(event.item.end_dt < event.item.move_dt && event.item.mem_move_cd != '90'){
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "종료일을 발령일자 이후로 선택해주세요.");
					}, 1);
					AUIGrid.setCellValue(auiGrid,rowIndex,"end_dt",event.item.move_dt);
				}
			}else if(event.dataField == "new_org_code" || event.dataField == "new_grade_cd") {
				var param = {
					row_idx: rowIndex,
					org_code: event.item.new_org_code,
					grade_cd: event.item.new_grade_cd
				}
				fnSetOrgAuth(param);
			}
		});
	}

	// 부서 or 직책 변경시 부서권한 세팅
	function fnSetOrgAuth(obj) {
		var param = {
			org_code: obj.org_code,
			grade_cd: obj.grade_cd
		};
		$M.goNextPageAjax("/orgAuth",  $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						AUIGrid.setCellValue(auiGrid, obj.row_idx, "new_menu_org_code", result.auth_org_code);
					}
				}
		);
	}

	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField){
		if(headerText == "부서" || headerText == "직책"){
			if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
				return "aui-center";
			}else{
				return "aui-background-darkgray";
			}
		}else if(headerText == "부서권한"){
			// if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
			// 	return "aui-center aui-editable";
			// }else{
			// 	return "aui-background-darkgray";
			// }
		}else if(headerText == "시작일"){
			if(item.mem_move_cd == '01' || item.mem_move_cd == '02' || item.mem_move_cd == '03' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '06'){
				return "aui-center aui-editable";
			}else{
				return "aui-background-darkgray";
			}
		}else if(headerText == "종료일"){
			if(item.mem_move_cd == '03' || item.mem_move_cd == '04' || item.mem_move_cd == '05' || item.mem_move_cd == '90'){
				return "aui-center aui-editable";
			}else{
				return "aui-background-darkgray";
			}
		} else if (headerText == "지급품회수"){
			if(item.mem_move_cd == '90'){
				return "aui-center";
			}else{
				return "aui-background-darkgray";
			}
		}
	}
	
	// 지급품회수 확인 reCheck는 지급품회수 페이지에서 돌아와서 체크할때 사용 (0 : 기존 페이지, 1 : 지급품함수 페이지)
	function goCheckPayment(memNo, row, reCheck){
		param = {
				"mem_no" : memNo
		}
		
		if(AUIGrid.getCellValue(auiGrid,row,"modify_yn") == 'N'){
			return;
		}
		
		var check = AUIGrid.getCellValue(auiGrid,row,"payment_check");
		
		if(check == 'Y'){
			alert("모든 지급품을 회수하였습니다.");
			return;
		}else{
			$M.goNextPageAjax("/acnt/acnt060701/check", $M.toGetParam(param) , {method : 'GET'},
					function(result) {
			    		if(result.success) {
							// [14626] 이관할 업무 존재 여부 체크 - 김경빈
							// 미수담당 이관 확인 추가
			    			if(result.paymentListSize === 0 && result.carListSize === 0 && result.cardListSize === 0 && result.toDoListSize === 0 && result.changeJobSize === 0
									// && result.saleAreaList.length == 0 && result.misuList.length === 0
							){
			    				alert("모든 지급품을 회수하였습니다.");
								AUIGrid.setCellValue(auiGrid,row,"payment_check","Y");
			    				return;
			    			}else if(reCheck == 1){
			    				alert("모든 지급품을 회수하지 않았습니다. 저장하기 위해서는 모든 지급품을 회수하여야 합니다.");
			    			}else{
								let endDt = AUIGrid.getCellValue(auiGrid, row, "end_dt");
								if (endDt == "" || endDt == undefined) {
									alert("종료일을 먼저 설정 후, 지급품회수를 설정해 주세요.")
									return;
								}
			    				param = {
			    						"s_mem_no" : memNo,
			    						"s_row" : row,
										"end_dt" : endDt,
			    				}
			    				$M.goNextPage('/acnt/acnt0607p02', $M.toGetParam(param), {popupStatus : ""});
			    			}
						}
					}
			);
		}
	}
	
	// 저장
	function goModify(){
		var frm = document.main_form;
		if($M.validation(frm) == false){
			return;
		}
	
        var addGridData = AUIGrid.getAddedRowItems(auiGrid);  // 추가내역
        var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
        var removeGridData = AUIGrid.getRemovedItems(auiGrid); // 변경내역
		
		if (changeGridData.length == 0 && addGridData.length == 0 && removeGridData == 0) {
			alert("변경된 내역이 없습니다.");
			return;
		}
		
		frm = $M.toValueForm(frm);
		var data = AUIGrid.getGridData(auiGrid);
		if(data.length - removeGridData.length == 0){
			alert("직원을 추가해주세요.");
			return;
		}
		
		var existData = [];
		for(var i=0;i<data.length;i++){
			if(data[i].cmd != 'D'){
				existData.push(data[i]);
			}
		}
		console.log(existData[0]);
		
		$M.setValue("firstMemName",existData[0].mem_name);
		$M.setValue("rowCount",existData.length);
		
		// 그리드 벨리데이션
		if(fnCheckGridEmpty(data)==false){
			return;
		}
		$.each(data,function(rowIndex){
			// 발령 후 부서가 없을 시 현재 부서로 저장
			if(data[rowIndex].new_org_code==""){
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_org_code",data[rowIndex].old_org_code);
			}
			// 발령 후 직급이 없을 시 현재 직급으로 저장
			if(data[rowIndex].new_grade_cd=="" || data[rowIndex].new_job_cd==undefined){
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_job_cd",data[rowIndex].old_job_cd);
			}else{
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_job_cd",data[rowIndex].new_job_cd);
			}
			// 발령 후 직책이 없을 시 현재 직책으로 저장
			if(data[rowIndex].new_grade_cd=="" || data[rowIndex].new_grade_cd==undefined) {
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_grade_cd",data[rowIndex].old_grade_cd);
			}else{
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_grade_cd",data[rowIndex].new_grade_cd);
			}
			// 발령 후 권한이 없을 시 현재 권한으로 저장
			if(data[rowIndex].new_menu_org_code==""){
				AUIGrid.setCellValue(auiGrid,rowIndex,"new_menu_org_code",data[rowIndex].old_menu_org_code);
			}
		}); 

		var gridForm = fnChangeGridDataToForm(auiGrid,'N');
		$M.copyForm(gridForm, frm);

		$M.goNextPageAjaxSave(this_page + "/modify", gridForm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("수정이 완료되었습니다.");
	    			if (opener != null && opener.goSearch) {
						opener.goSearch();
					}
					location.reload();
				}
			}
		);
	}
	
	// 삭제
	function goRemove(){
		var data = AUIGrid.getGridData(auiGrid);
		
		if($M.getValue("mem_move_modify_yn") == 'N'){
			alert("공지가 등록된 발령이 존재합니다. 공지삭제 후 삭제해주세요.");
			return;
		}
		
		var param = {
			"mem_move_no" : $M.getValue("mem_move_no")
		};
		
		$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
		    			window.close();
					}
				}
		);
	}
	
	// 그리드 벨리데이션
	function fnCheckGridEmpty(rows) {
		var check = 0;
		for(var i = 0; i < rows.length; i++){
			var data = rows[i];
			switch(data.mem_move_cd){
				case undefined:
					alert("발령구분을 선택해주세요.");
					check = 1;
					break;
				case '01':
					if(data.new_grade_cd == ""){
						alert("직책을 선택해주세요.");
						check = 1;
						break;
					}
					if(data.new_menu_org_code == ""){
						alert("부서권한이 없습니다. 직책관리 메뉴에서 부서권한 설정 후 처리해주세요.");
						check = 1;
						break;
					}
					break;
				case '02':
					if(data.imprest_mem_check > 0){
						alert(data.mem_name+" 직원은 전도금 관리직원입니다. 변경 후 발령처리 해주세요.");
						check = 1;
						break;
					}
					if(data.new_org_code == ""){
						alert("부서를 선택해주세요.");
						check = 1;
						break;
					}
					if(data.new_menu_org_code == ""){
						alert("부서권한이 없습니다. 직책관리 메뉴에서 부서권한 설정 후 처리해주세요.");
						check = 1;
						break;
					}
					break;
				case '03':
					if(data.start_dt == "" || data.end_dt == ""){
						alert("시작일과 종료일을 선택해주세요.");
						check = 1;
						break;
					}
					break;
				case '04':
					if(data.new_grade_cd == "" || data.new_org_code == ""){
						alert("부서와 직책을 선택해주세요.");
						check = 1;
						break;
					}
					if(data.new_menu_org_code == ""){
						alert("부서권한이 없습니다. 직책관리 메뉴에서 부서권한 설정 후 처리해주세요.");
						check = 1;
						break;
					}
					if(data.end_dt == ""){
						alert("종료일을 선택해주세요.");
						check = 1;
						break;
					}
					break;
				case '05':
					if(data.imprest_mem_check > 0){
						alert(data.mem_name+" 직원은 전도금 관리직원입니다. 변경 후 발령처리 해주세요.");
						check = 1;
						break;
					}
					if(data.new_org_code == "" ){
						alert("부서를 선택해주세요.");
						check = 1;
						break;
					}
					if(data.new_menu_org_code == ""){
						alert("부서권한이 없습니다. 직책관리 메뉴에서 부서권한 설정 후 처리해주세요.");
						check = 1;
						break;
					}
					if(data.start_dt == "" || data.end_dt == ""){
						alert("시작일, 종료일을 선택해주세요.");
						check = 1;
						break;
					}
					break;
				case '06':
					if(data.imprest_mem_check > 0){
						alert(data.mem_name+" 직원은 전도금 관리직원입니다. 변경 후 발령처리 해주세요.");
						check = 1;
						break;
					}
					if(data.new_grade_cd == "" || data.new_org_code == ""){
						alert("부서와 직책을 선택해주세요.");
						check = 1;
						break;
					}
					if(data.new_menu_org_code == ""){
						alert("부서권한이 없습니다. 직책관리 메뉴에서 부서권한 설정 후 처리해주세요.");
						check = 1;
						break;
					}
					break;
				case '90':
					if(data.imprest_mem_check > 0){
						alert(data.mem_name+" 직원은 전도금 관리직원입니다. 변경 후 발령처리 해주세요.");
						check = 1;
						break;
					}
					if(data.end_dt == ""){
						alert("종료일을 선택해주세요.");
						check = 1;
						break;
					}
					if(data.payment_check == 'N'){
						alert(data.mem_name+" 직원의 지급품회수를 확인해주세요.");
						check = 1;
						break;
					}
					break;
			}
			if(check == 1){
				break;
			}
		}
		return check == 1? false:true;
	}
	
	// 직원추가
	function goNew(){
		openMemberOrgPanel('setMemberOrgMapPanel','Y');
	}
	
	// 직원추가 리턴함수
	function setMemberOrgMapPanel(result){
		var data = []
		for(var i = 0 ; i < result.length ; i++){
			if(result[i].mem_no != "" && AUIGrid.isUniqueValue(auiGrid, "mem_no", result[i].mem_no)){
				data.push(result[i].mem_no);
			}
		}
		
		if(data.length == 0){
			alert("이미 등록한 인원입니다.");
			return;
		}
		
		var param = {
				"data":data
		};
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						var list = result.list;
						for (var i = 0; i < list.length; ++i) {
							list[i]["move_dt"] = "${inputParam.s_current_dt}";
						}
						AUIGrid.addRow(auiGrid, list);
				}
			}
		);
	}

	function goHRApply(memMoveNo, seqNo, memMoveCd) {
		var param = {
			"mem_move_no":memMoveNo,
			"seq_no":seqNo,
			"mem_move_cd" : memMoveCd,
		};
		console.log(memMoveNo);
		console.log(seqNo);
		$M.goNextPageAjax(this_page + "/hrApply", $M.toGetParam(param), {method: "POST"},
				function (result) {
					if(result.success){
						location.reload();
					}
				}
		);
	}
	
	// 목록 및 뒤로가기
	function fnCancel(){
 		window.close();
	}

</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="mem_move_no" name="mem_move_no" value="${memMoveNo }"/>
<input type="hidden" id="rowCount" name="rowCount" value="0"/>
<input type="hidden" id="firstMemName" name="firstMemName" value=""/>
<input type="hidden" id="mem_move_modify_yn" name="mem_move_modify_yn" value="${mem_move_modify_yn}"/>
<input type="hidden" name="clickedRowIndex">
<!-- 팝업 -->
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
<!-- /타이틀영역 -->
	<div class="content-wrap">
<!-- 발령상세 -->	
		<div class="title-wrap">
			<h4 class="primary">
				발령상세
			</h4>
		</div>
		<div>
		<!-- 기본 -->					
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">발령번호</th>
							<td><input class="form-control" style="width:140px;" type="text" id="mem_move_no" name="mem_move_no" value="${memMoveNo}"  readonly="readonly"/></td>
						</tr>								
					</tbody>
				</table>
			</div>
				<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4>대상자</h4>
				<div class="btn-group">
					<div class="right">
						<div class="right text-warning" style="display:inline-block;">
						※ 공지한 발령은 시작일 기준으로 인사정보에 자동 반영됩니다.(삭제시 인사정보 반영된건 유지)
						</div>
						<button type="button"style="display:inline-block;" class="btn btn-default" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'Y');"><i class="material-iconsadd text-default"></i> 직원추가</button>
					</div>
				</div>
			</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">					
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="mem_no" value="${reg_mem_no}"/>
					</jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /기본 -->
		</div>
	</div>					
</div>		
</form>	
</body>
</html>