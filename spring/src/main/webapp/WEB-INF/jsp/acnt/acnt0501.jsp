<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include
	page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c"
	uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn"
	uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt"
	uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib
	uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib
	uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 법인차량관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-04-16 17:15:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	//보험회사코드 , 보험연령코드
	var carInsureJson = JSON.parse('${codeMapJsonObj['CAR_INSURE']}');
	var carInsureAgeJson = JSON.parse('${codeMapJsonObj['CAR_INSURE_AGE']}');
	
	
	//선택항목 추가 ( 드랍다운리스트)
	var defaultArr= { "code_name" : "- 선택 -","code_value":"" };	
	carInsureJson.unshift(defaultArr);
	carInsureAgeJson.unshift(defaultArr);
	
	//회사소유여부
	var compOwnYnList = [{"code_value":"Y", "code_name" : "회사"}, {"code_value" :"N", "code_name" :"자가"}];	
	
	// 하이패스 여부
	var hiPassYnList = [{"code_value":"Y", "code_name" : "지정"}, {"code_value" :"N", "code_name" :"미지정"}];	
	
	var gridRowIndex;
	var auiGrid;
	
	$(document).ready(function() {
		createAUIGrid();
		goSearch();
		
		// 관리부이거나, 최승희대리일경우를 제외하면 구분선택 못함. 해당부서와, 본인것만 조회가능.
		if (('${page.fnc.F00585_001}' == 'Y') == false) {
			$("#s_org_code").prop("disabled", true);
		}
	});
	
	function createAUIGrid() {
		var gridPros = {
			editable : true,
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowIdField가 unique 임을 보장
			rowIdTrustMode : true,
			// rowNumber 
			showRowNumColumn : true,
			enableSorting : true,
// 			showStateColumn : true,
			showRowCheckColumn : false,
			editableOnFixedCell : true
		};
		
		var servYn = "${page.fnc.F00585_002}" == "Y" ? "Y" : "N";
		
		if(servYn == "Y") {
			gridPros.editable = false;
		}
		
		var columnLayout = [
			{
				headerText : "차량<br\>코드",
				dataField : "car_code",
				width : "55",
				minWidth : "55",
				style : "aui-center aui-popup",
				required : false,
				editable : false
			}, {
				headerText : "차량번호",
				dataField : "car_no",
				width : "150",
				minWidth : "30",
				style : "aui-left",
				required : true,
				editable :true
			}, {
				headerText : "더존<br\>관리",
				dataField : "douzon_code",
				width : "55",
				minWidth : "55",
				style : "aui-center",
				required : true,
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 3,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				}
			}, {
				headerText : "업무차량<br\>코드",
				dataField : "biz_car_code",
				width : "75",
				minWidth : "75",
				style : "aui-center",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 20,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				}
			}, {
				headerText : "부서",
				dataField : "org_kor_name",
				width : "65",
				minWidth : "65",
				style : "aui-center",
				required : true,
				editable : false																
			}, 	{
				headerText : "사용자명",
				dataField : "kor_name",
				width : "60",
				minWidth : "60",
				style : "aui-center",
				required : true,
				editable : false
			}, 
			{ 
				dataField : "mem_no",
				visible : false
			},
			{
				headerText : "소유<br\>구분",
				dataField : "comp_own_yn",
				width : "55",
				minWidth : "55",
				style : "aui-center",
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : compOwnYnList,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<compOwnYnList.length; i++){
						if(value == compOwnYnList[i].code_value){
							return compOwnYnList[i].code_name;
						}
					}
					return value;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable"
					};
					return "aui-center";
				},
			},
			{
				headerText : "보험사",
				dataField : "car_insure_name",
				width : "85",
				minWidth : "30",
				style : "aui-center",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : carInsureJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					var retStr = value;
					for(var i=0; i<carInsureJson.length; i++){
						
						if(carInsureJson[i].code_value == value) {
							retStr = carInsureJson[i].code_name;
							break;
						} else if(value == null) {
							retStr = "- 선택 -";
							break;
						}

					}
					return retStr;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable"
					};
					return "aui-center";
				},			
			},	
			{ 
				headerText : "보험사코드", 
				dataField : "car_insure_cd", 
				visible : false
			},				
			
			{
				headerText : "보험기간",
				children : [	
					{
						headerText : "시작일", 
						dataField : "insure_st_dt", 
						dataType : "date",   
						width : "65",
						minWidth : "65",
						style : "aui-center",
						dataInputString : "yyyymmdd",
						formatString : "yy-mm-dd",
						editRenderer : {
							type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
							defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
							onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
							maxlength : 8,
							onlyNumeric : true, // 숫자만
							validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
								//삭제는 가능해야함
								if (newValue != ""){
									return fnCheckDate(oldValue, newValue, rowItem);
								}								
							},
							showEditorBtnOver : true
						},
						styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
							if (servYn != "Y") {
								return "aui-editable"
							};
							return "aui-center";
						},						
					},
					{
						headerText : "종료일", 
						dataField : "insure_ed_dt", 
						dataType : "date",   
						width : "65",
						minWidth : "65",
						style : "aui-center",
						dataInputString : "yyyymmdd",
						formatString : "yy-mm-dd",
						editRenderer : {
							type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
							defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
							onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
							maxlength : 8,
							onlyNumeric : true, // 숫자만
							validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
								//삭제는 가능해야함
								if (newValue != ""){
									return fnCheckDate(oldValue, newValue, rowItem);
								}	
							},
							showEditorBtnOver : true
						},
						styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
							if (servYn != "Y") {
								return "aui-editable"
							};
							return "aui-center";
						},	
					}
				]
			},	
			{ 
				headerText : "보험연령코드", 
				dataField : "car_insure_age_cd", 
				visible : false
			},			
			{
				headerText : "보험연령",
				dataField : "car_insure_age_name",
				width : "70",
				minWidth : "70",
				style : "aui-center",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : carInsureAgeJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					var retStr = value;
					for(var i=0; i<carInsureAgeJson.length; i++){
						if(carInsureAgeJson[i].code_value == value) {
							retStr = carInsureAgeJson[i].code_name;
							break;
						} else if(value == null) {
							retStr = "- 선택 -";
							break;
						}
					}

					return retStr;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable"
					};
					return "aui-center";
				},		
			},	
			{
				headerText : "검사기간",
				children : [	
					{
						headerText : "시작일", 
						dataField : "check_st_dt", 
						dataType : "date",   
						width : "65",
						minWidth : "65",
						style : "aui-center",
						dataInputString : "yyyymmdd",
						formatString : "yy-mm-dd",
						editRenderer : {
							type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
							defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
							onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
							maxlength : 8,
							onlyNumeric : true, // 숫자만
							validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
								//삭제는 가능해야함
								if (newValue != ""){
									return fnCheckDate(oldValue, newValue, rowItem);
								}	
							},
							showEditorBtnOver : true
						},
						styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
							if (servYn != "Y") {
								return "aui-editable"
							};
							return "aui-center";
						},						
					},
					{
						headerText : "종료일", 
						dataField : "check_ed_dt", 
						dataType : "date",   
						width : "65",
						minWidth : "65",
						style : "aui-center",
						dataInputString : "yyyymmdd",
						formatString : "yy-mm-dd",
						editRenderer : {
							type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
							defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
							onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
							maxlength : 8,
							onlyNumeric : true, // 숫자만
							validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
								//삭제는 가능해야함
								if (newValue != ""){
									return fnCheckDate(oldValue, newValue, rowItem);
								}	
							},
							showEditorBtnOver : true
						},
						styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
							if (servYn != "Y") {
								return "aui-editable"
							};
							return "aui-center";
						},	
					}
				]
			},		
			{
				headerText : "하이패스",
				dataField : "card_code",
				width : "75",
				minWidth : "75",
				style : "aui-left",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : hiPassYnList,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<hiPassYnList.length; i++){
						if(value == hiPassYnList[i].code_value){
							return hiPassYnList[i].code_name;
						}
					}
					return value;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable"
					};
					return "aui-popup";
				},
			},			
			{
				headerText : "비고",
				dataField : "remark",
				width : "275",
				minWidth : "30",
				style : "aui-left",
				editable :  true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 100,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				}
			},					
			{
				headerText : "등록일", 
				dataField : "reg_date", 
				width : "65",
				minWidth : "65",
				dataType : "date",
				formatString : "yy-mm-dd", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "사용<br\>여부", 
				dataField : "use_yn", 
				width : "40",
				minWidth : "40", 
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				}
			}			
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// AUIGrid.setFixedColumnCount(auiGrid, 7);
		
		
		//$("#auiGrid").resize();
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(AUIGrid.isAddedById(auiGrid,event.item._$uid)) {
				// 부서 cellclick 이벤트 삭제.
// 				if(event.dataField == "kor_name" || event.dataField == "org_kor_name" ) {
// 					gridRowIndex = event.rowIndex;
// 					param = {}							
					
// 					openOrgMapPanel('fnsetOrgMapPanel', $M.toGetParam(param));
// 					//openSearchMemberPanel('fnSetMemberInfo', $M.toGetParam(param));
// 				}
				
				if (event.dataField == "kor_name") {
					gridRowIndex = event.rowIndex;
					param = {}		
					
// 					openSearchMemberPanel('fnSetMemInfo', $M.toGetParam(param));
					openMemberOrgPanel('fnsetOrgMapPanel', "N" , $M.toGetParam(param));
				}				
			}
			else {
				if(event.dataField == "car_code") {
					gridRowIndex = event.rowIndex;
					param = {"car_code" : event.item.car_code };										
					openCarMemHistPanel('fnSetCarMemInfo', $M.toGetParam(param));
				}				
			}

		});
			
		AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {
			if(event.dataField == "douzon_code") {
				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
				if(AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "더존코드 값은 수정할수 없습니다.");
					}, 1);
					return false; 
				}
			}	

		});
		// 보험사 , 보험연령 선택 후
		AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
			if(event.dataField == 'car_insure_age_name') {
				var evantVal = event.value;
				gridRowIndex = event.rowIndex;
				AUIGrid.updateRow(auiGrid, { "car_insure_age_cd" : evantVal }, gridRowIndex);
			}
			if(event.dataField == 'car_insure_name') {
				var evantVal = event.value;
				gridRowIndex = event.rowIndex;
				AUIGrid.updateRow(auiGrid, { "car_insure_cd" : evantVal }, gridRowIndex);
			}
			
			
			if(event.dataField == "card_code" ) {
				if (event.value == "Y") {
					AUIGrid.updateRow(auiGrid, { "card_code" : event.oldValue }, event.rowIndex);
					
					gridRowIndex = event.rowIndex;
					param = {};										
					openHipassCardPanel('fnSetHipassCardInfo', $M.toGetParam(param));
				} else {
					AUIGrid.updateRow(auiGrid, { "card_code" : "" }, event.rowIndex);
				}
			}
		});		
		
	}
		
	// 직원조회 결과
	function fnsetOrgMapPanel(data) {		
		console.log("data : ", data);
		console.log(data);
		
	    AUIGrid.updateRow(auiGrid, { "org_kor_name" : data.org_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "kor_name" : data.mem_name }, gridRowIndex);
	    AUIGrid.updateRow(auiGrid, { "mem_no" : data.mem_no }, gridRowIndex);
	}
	
	// 차량변경이력 처리 결과
	function fnSetCarMemInfo(data) {		
	   AUIGrid.updateRow(auiGrid, { "org_kor_name" : data.org_kor_name }, gridRowIndex);
	   AUIGrid.updateRow(auiGrid, { "kor_name" : data.kor_name }, gridRowIndex);
	   AUIGrid.updateRow(auiGrid, { "mem_no" : data.mem_no }, gridRowIndex);
	}
	
	// 하이패스카드 조회 결과
	function fnSetHipassCardInfo(data) {		
		 AUIGrid.updateRow(auiGrid, { "card_code" : data.card_code }, gridRowIndex);
	}
	
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_org_code", "s_kor_name","s_car_code", "s_car_no","s_comp_own_yn", "s_use_yn"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	function goSearch() {

		var param = {
				
			s_org_code : $M.getValue("s_org_code"),
			s_kor_name : $M.getValue("s_kor_name"),
			s_car_code : $M.getValue("s_car_code"),
			s_car_no : $M.getValue("s_car_no"),			
			s_comp_own_yn : $M.getValue("s_comp_own_yn"),
			s_use_yn : $M.getValue("s_use_yn"),
			s_sort_key : "insure_ed_dt asc,car_code",
			s_sort_method : "desc"
		};
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}
		);
	}
	
	//더존코드 중복체크 후 저장
	function checkDouzonAndSave(){
				
		//추가된 로우데이터들
		var addRows = AUIGrid.getAddedRowItems(auiGrid);
		console.log(addRows);
		
		//DB 저장전 더존코드 중복체크하기		
		var douzon_codes=[];		
		for (var i = 0; i < addRows.length; ++i) {
			douzon_codes.push(addRows[i].douzon_code);			
		}
				
		var param = {
			"douzon_code_str" :	$M.getArrStr(douzon_codes)
		}
				
		if( addRows.length > 0  && douzon_codes.length>0 ) {
			$M.goNextPageAjax(this_page+"/douzonCodeDuplCheck", $M.toGetParam(param), {method : "post"},
				function(result) {
		    		if(result.success) {
		    			
		    			var frm = fnChangeGridDataToForm(auiGrid);	    			
		    			console.log(frm);
		    			
		    			$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'}, 
		    				function(result) {
		    					if(result.success) {
		    						AUIGrid.removeSoftRows(auiGrid);
		    						AUIGrid.resetUpdatedItems(auiGrid);		
		    						$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
		    						goSearch();
		    					};
		    				}
		    			);
		    			
					}
		    		else {
		    			return false;
		    		}
				}
			);
		}
		else {
						
			var frm = fnChangeGridDataToForm(auiGrid);	    			
			console.log(frm);
			
			$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);		
						$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);		
						goSearch();
					};
				}
			);
			
		}
	}
	
	
	// 저장
 	function goSave() {
		
 		if (fnChangeGridDataCnt(auiGrid) == 0){
			alert("변경된 데이터가 없습니다.");
			return false;
		};
		if (fnCheckGridEmpty(auiGrid) === false){
			alert("필수 항목은 반드시 값을 입력해야합니다.");
			return false;
		}
		
		// 화면에 보여지는 그리드 데이터 목록
		var gridAllList = AUIGrid.getGridData(auiGrid);
		
		for (var i = 0; i < gridAllList.length; i++) {
			
			if( gridAllList[i].insure_st_dt != ""   ||  gridAllList[i].insure_ed_dt != "" ||
				gridAllList[i].car_insure_cd != ""   ||  gridAllList[i].car_insure_age_cd != "") {

				// 보험회사코드
				if( gridAllList[i].car_insure_cd == "") {
					alert("보험사를 선택해주세요. \n차량번호 : " + gridAllList[i].car_no );							
					return;
				}
				
				
				// 시작일 종료일중 1개만 들어가는 경우 오류 (둘다 없는 건 상관없음)
				if( gridAllList[i].insure_st_dt != ""   && gridAllList[i].insure_ed_dt == "") {
					alert("보험종료일을 입력하세요. \n차량번호 : " + gridAllList[i].car_no );							
					return;
				}
				if( gridAllList[i].insure_st_dt == ""   && gridAllList[i].insure_ed_dt != "") {
					alert("보험시작일을 입력하세요. \n차량번호 : " + gridAllList[i].car_no );						
					return;
				}	
				
				if( gridAllList[i].insure_st_dt != ""   && gridAllList[i].insure_ed_dt != "") {
					
					if( gridAllList[i].insure_st_dt > gridAllList[i].insure_ed_dt ){
						alert("보험시작일은 종료일보다 클 수 없습니다. \n차량번호 : " + gridAllList[i].car_no );	
						return;
					}
								
				}
	
				// 보험연력코드
				if( gridAllList[i].car_insure_age_cd == "") {
					alert("보험연령을 선택해주세요. \n차량번호 : " + gridAllList[i].car_no );		
					return;
				}

			}

			// 시작일 종료일중 1개만 들어가는 경우 오류 (둘다 없는 건 상관없음)
			if( gridAllList[i].check_st_dt != ""   && gridAllList[i].check_ed_dt == "") {
				alert("검사종료일을 입력하세요. \n차량번호 : " + gridAllList[i].car_no );	
				return;
			}
			if( gridAllList[i].check_st_dt == ""   && gridAllList[i].check_ed_dt != "") {
				alert("검사시작일을 입력하세요. \n차량번호 : " + gridAllList[i].car_no );	
				return;
			}	
				
			if( gridAllList[i].check_st_dt != ""   && gridAllList[i].check_ed_dt != "") {
				
				if( gridAllList[i].check_st_dt > gridAllList[i].check_ed_dt ){
					alert("검사시작일은 종료일보다 클 수 없습니다. \n차량번호 : " + gridAllList[i].car_no );	
					return;
				}
							
			}			

			//신규추가건은 차량코드에 -1 입력 ( DB에서 일괄 발번 할것임)
			if(gridAllList[i].car_code == ""){					
				 AUIGrid.setCellValue(auiGrid, i, "car_code", "-1");
			}									
		}		
		
		checkDouzonAndSave();
	}
		
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validation(auiGrid);
	}
	
	// 행추가
	function fnAdd() {					
		if(fnCheckGridEmpty(auiGrid)) {

			var item = new Object();
    		item.car_code = "";	
    		item.car_no = "";
    		item.douzon_code = "";
    		item.biz_car_code = "";
    		item.org_kor_name = "";
    		item.kor_name = "";
    		item.mem_no="";
    		item.comp_own_yn = "N";
    		item.remark="";   		
    		item.reg_date="";
    		item.use_yn = "Y";
    		
    		item.car_insure_cd="";
    		item.car_insure_age_cd="";
    		item.insure_st_dt="";
    		item.insure_ed_dt=""; 		
    		item.check_st_dt="";
    		item.check_ed_dt="";
    		item.card_code="";

			AUIGrid.addRow(auiGrid, item, 'first');
			
		}
	}
	
	function fnDownloadExcel() {
		  // 엑셀 내보내기 속성
		  var exportProps = {
		         // 제외항목
		         //exceptColumnFields : ["removeBtn"]
		  };
		  fnExportExcel(auiGrid, "법인차량목록", exportProps);
	}
	
	
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<div class="layout-box">
			<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="content-box">
					<!-- 메인 타이틀 -->
					<div class="main-title">
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
					</div>
					<!-- /메인 타이틀 -->
					<div class="contents">
						<!-- 기본 -->
						<div class="search-wrap">
							<table class="table">
								<colgroup>
									<col width="45px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>부서</th>
										<td>
										<c:choose>
												<c:when test="${page.fnc.F00585_003 eq 'Y'}">
													<select id="s_org_code" name="s_org_code"
														class="form-control">
															<option value="">- 전체 -</option>
															<c:forEach items="${orgList}" var="item">
																<option value="${item.org_code}"
																	${item.org_code == inputParam.s_org_code ? 'selected="selected"' : ''}>${item.org_name}</option>
															</c:forEach>
													</select>
												</c:when>
												<c:when test="${page.fnc.F00585_003 ne 'Y'}">
													<div class="col width100px" style="padding-right: 0;">
														<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
														<input type="hidden" value="${SecureUser.org_code}" id="s_org_code" name="s_org_code" readonly="readonly">
													</div> 
												</c:when>
											</c:choose>
										</td>
										<th>사용자명</th>
										<td><input type="text" class="form-control width120px"
											id="s_kor_name" name="s_kor_name"></td>
										<th>차량코드</th>
										<td><input type="text" class="form-control width120px"
											id="s_car_code" name="s_car_code"></td>
										<th>차량번호</th>
										<td><input type="text" class="form-control width120px"
											id="s_car_no" name="s_car_no"></td>
										<th>소유구분</th>
										<td><select class="form-control" id="s_comp_own_yn"
											name="s_comp_own_yn">
												<option value="">- 전체 -</option>
												<option value="N">자가</option>
												<option value="Y">회사</option>
										</select></td>
										<th>사용여부</th>
										<td><select id="s_use_yn" name="s_use_yn"
											class="form-control">
												<option value="">- 전체 -</option>
												<option value="Y" selected="selected">사용</option>
												<option value="N">미사용</option>
										</select></td>
										<td>
											<button type="button" class="btn btn-important"
												style="width: 50px;" onclick="javascript:goSearch();">조회</button>
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
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
								</div>
							</div>
						</div>
						<!-- /그리드 타이틀, 컨트롤 영역 -->
						<div id="auiGrid" style="margin-top: 5px; height: 555px;""></div>
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>

				</div>
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
			</div>
			<!-- /contents 전체 영역 -->
		</div>
	</form>
</body>
</html>