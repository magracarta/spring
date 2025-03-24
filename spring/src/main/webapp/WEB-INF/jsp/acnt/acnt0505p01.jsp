<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 자산지급품관리 > null > 사후관리변동이력 (15288 변동이력으로 이름 바뀜)
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-23 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	//변경구분
	//var assetChangeJson = JSON.parse('${codeMapJsonObj['ASSET_CHANGE']}');

	//221208 15288 전호형
	//자산지급품관리 구분과 통일
	var assetOwnerJson = JSON.parse('${codeMapJsonObj['ASSET_OWNER']}');		//자산소유구분
	var orgCenterListJson = ${centerList};								//센터리스트
	var orgCenterListScrapJson = Object.assign(${centerList}, orgListJson);	// 부서+센터리스트 (폐기 시 사용)
	var orgCenterListDocJson = ${orgList2}; // 품의서에서 사용하는 부서목록

	var columAddCnt = 0;
	var fastSeq = ${fast_seq};
		
	var gridRowIndex;
	var auiGrid;

	//221213 15288 전호형 입력 권한 관리를 위해 적용
	var servYn = "Y";

	if ("${page.fnc.F00597_001}" == "Y") {
		servYn = "N";
	}
	if(servYn == "Y") {
		gridPros.editable = false;
	}


	$(document).ready(function() {
		createAUIGrid();
	});
	
	function createAUIGrid() {
		var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true
		};
		var myDropEditRenderer = {
			type : "DropDownListRenderer",
			keyField : "org_code",
			valueField  : "org_name",
			showEditorBtnOver : true,
			listFunction : function(rowIndex, columnIndex, item, dataField) {

				//조건에 맞는 드랍다운리스트를 반환함
				//이 함수의 반환값이 곧 해당 항목의 출력 리스트가 됩니다.(반드시 Array를 반환하십시오.)

				//부서
				if(item.asset_owner_cd == '02'){
					return newObj(orgListJson);
				}
				//센터
				else if(item.asset_owner_cd == '03'){
					return newObj(orgCenterListJson);
				}
				//폐기
				else if(item.asset_owner_cd == '04'){
					return newObj(orgCenterListScrapJson);
				}
				else {
					return "";
				}

			}
		};

		var columnLayout = [
			{
				dataField : "asset_payment_no",
				visible : false
			},
			{
				headerText : "변동일자", 
				dataField : "change_dt", 
				dataType : "date",   
				width : "20%",
				style : "aui-center",
				required : true,
				editable : true,				
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
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					//221208 15288 전호형
					//행추가 시, 그리고 최근 항목만 editable 스타일로 변경
					if(AUIGrid.isAddedById(auiGrid,item._$uid) || item.seq_no == "${fast_seq}"){
						return "aui-editable";
					}
					return "aui-center";
				},
			},		
			{
				headerText : "구분",
				dataField : "asset_owner_cd",
				width : "90",
				minWidth : "90",
				style : "aui-center",
				required : true,
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : assetOwnerJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<assetOwnerJson.length; i++){
						if(value == assetOwnerJson[i].code_value){
							return assetOwnerJson[i].code_name;
						}
					}
					return value;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					//221208 15288 전호형
					//행추가 시, 그리고 최근 항목만 editable 스타일로 변경
					if(AUIGrid.isAddedById(auiGrid,item._$uid) || item.seq_no == "${fast_seq}"){
						return "aui-editable";
					}
					return "aui-center";
				}
			},
			{
				headerText : "보관처직원번호",
				dataField : "use_mem_no",
				visible : false
			},
			{
				headerText : "보관처",
				dataField : "use_kor_name",
				width : "65",
				minWidth : "65",
				style : "aui-center",
				editable : false,
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					//221208 15288 전호형
					//행추가 시, 그리고 최근 항목만 editable 스타일로 변경
					if(AUIGrid.isAddedById(auiGrid,item._$uid) || item.seq_no == "${fast_seq}"){
						return "aui-editable";
					}
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			},
			{
				headerText : "보관부서",
				dataField : "use_org_code",
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editRenderer : {
					type : "ConditionRenderer",
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						return myDropEditRenderer;
					}
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					if(item.asset_owner_cd == "02"){	//구분 - 부서
						for(var i = 0 ;  i < orgListJson.length; i++) {
							if(orgListJson[i]["org_code"] == value) {
								retStr = orgListJson[i]["org_name"];
								break;
							}
						}
						for(var i = 0 ;  i < orgCenterListDocJson.length; i++) {
							if (orgCenterListDocJson[i]["org_code"] == value) {
								retStr = orgCenterListDocJson[i]["org_name"];
								break;
							}
						}
					}
					if(item.asset_owner_cd == "03"){	//구분 - 센터
						for(var i = 0 ;  i < orgCenterListJson.length; i++) {
							if(orgCenterListJson[i]["org_code"] == value) {
								retStr = orgCenterListJson[i]["org_name"];
								break;
							}
						}
						for(var i = 0 ;  i < orgCenterListDocJson.length; i++) {
							if (orgCenterListDocJson[i]["org_code"] == value) {
								retStr = orgCenterListDocJson[i]["org_name"];
								break;
							}
						}
					}

					if(item.asset_owner_cd == "04"){	//구분 - 폐기
						for(var i = 0 ;  i < orgCenterListJson.length; i++) {
							if(orgCenterListJson[i]["org_code"] == value) {
								retStr = orgCenterListJson[i]["org_name"];
								break;
							}
						}
						for(var i = 0 ;  i < orgListJson.length; i++) {
							if(orgListJson[i]["org_code"] == value) {
								retStr = orgListJson[i]["org_name"];
								break;
							}
						}
						for(var i = 0 ;  i < orgCenterListDocJson.length; i++) {
							if (orgCenterListDocJson[i]["org_code"] == value) {
								retStr = orgCenterListDocJson[i]["org_name"];
								break;
							}
						}
					}
					return retStr;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					//221208 15288 전호형
					//행추가 시, 그리고 최근 항목만 editable 스타일로 변경
					if(AUIGrid.isAddedById(auiGrid,item._$uid) || item.seq_no == "${fast_seq}"){
						return "aui-editable";
					}
					return "aui-center";
				},
				filter : {
					showIcon : true,
					displayFormatValues : true
				},
			},
			{
				headerText : "세부내역",
				dataField : "change_text",
				width : "40%",
				style : "aui-left",
				required : true,
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 100,

				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					//221208 15288 전호형
					//행추가 시, 그리고 최근 항목만 editable 스타일로 변경
					if(AUIGrid.isAddedById(auiGrid,item._$uid) || item.seq_no == "${fast_seq}"){
						return "aui-editable";
					}
					return "aui-left";
				}
			},
			{
				dataField : "seq_no",
				visible : false
			},
			//221208 15288 전호형
			//삭제 버튼 없애고 작성자 추가
			{
				headerText : "작성자",
				dataField : "reg_kor_name",
				width : "65",
				style : "aui-center",
				//required : true,
				editable : false
			},
			{
				dataField : "reg_id",
				visible: false
			},
			/*
			{
				
				headerText : "삭제",
				dataField : "removeBtn",
				width : "20%",
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
				editable : true
			}
			*/
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, assetPaymentLogListJson);
		$("#auiGrid").resize();

		AUIGrid.bind(auiGrid, "cellClick", function(event) {

			if(event.dataField == "use_kor_name" && servYn != "Y") {
				if(AUIGrid.isAddedById(auiGrid, event.item._$uid) || event.item.seq_no == "${fast_seq}") {
					if (event.item.asset_owner_cd == "01" || event.item.asset_owner_cd == "04") {
						gridRowIndex = event.rowIndex;
						param = {
							"agency_yn": "N"
						}
						openMemberOrgPanel('fnsetOrgMapPanel2', 'N', $M.toGetParam(param));
						//openSearchMemberPanel('fnSetBuyMemberInfo', $M.toGetParam(param));
					}
				}
			}

			if(event.dataField == "asset_payment_log_cnt" && !AUIGrid.isAddedById(auiGrid,event.item._$uid) && servYn != "Y") {
				gridRowIndex = event.rowIndex;
				param = {"asset_payment_no" : event.item.asset_payment_no };
				openAssetPaymentLogPanel('fnSetAssetPaymentLogInfo', $M.toGetParam(param));
			}

			//보관처 - 구분이 개인/폐기인 경우에만 선택 가능

			//221208 15288 전호형
			//행 추가 시 또는 가장 최신날짜의 게시물의 경우 동작
			if(event.dataField == "use_kor_name" && servYn != "Y" && AUIGrid.isAddedById(auiGrid,event.item._$uid) ||
					event.dataField == "use_kor_name" && servYn != "Y" && event.seq_no == "${fast_seq}"){

				// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
				if(event.item.asset_owner_cd == "01" || event.item.asset_owner_cd == "04") {
					gridRowIndex = event.rowIndex;
					param = {
						"agency_yn" : "N"
					}
					openMemberOrgPanel('fnsetOrgMapPanel3','N', $M.toGetParam(param));
					//openOrgMapPanel('fnSetUseMemberInfo', $M.toGetParam(param));
				} else {
					setTimeout(function() {
						AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "입력할 수 없습니다. 구분을 확인해주세요.");
					}, 1);
				}
			}
			//보관부서 - 구분이 부서/센터인 경우에만 선택가능
			if(event.dataField == "use_org_code" && servYn != "Y") {

				if(event.item.asset_owner_cd != "02" && event.item.asset_owner_cd != "03" && event.item.asset_owner_cd != "04") {

					setTimeout(function() {
						AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "입력할 수 없습니다. 구분을 확인해주세요.");
					}, 1);
					return false;
				}
			}
		});


		//221206 15288 전호형
		//작성이후에도 수정이 가능하도록 변경 (주석 처리)

		AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
			// 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
			if(AUIGrid.isAddedById(auiGrid,event.item._$uid) || event.item.seq_no == "${fast_seq}") {
				return true;
			}
			else{
				return false;
			}
						
		});
				
		
		AUIGrid.bind(auiGrid, "addRow", function( event ) {
			fnUpdateCnt();
		});
		AUIGrid.bind(auiGrid, "removeRow", function( event ) {
			fnUpdateCnt();
			// 15288 전호형
			// 저장 후 행추가가 가능하도록 다시 행추가 제한 변수 초기화
			columAddCnt = 0;
		});

		AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {

			if(event.dataField == "asset_owner_cd") {
				// 15288 전호형
				// 부서 <-> 센터 변경 시 보관부서가 초기화 되도록 변경 (기타 버그)
				if(event.item.asset_owner_cd == "01") {
					AUIGrid.updateRow(auiGrid, { "use_org_code" : ""}, event.rowIndex);
				} else if (event.item.asset_owner_cd == "02" || event.item.asset_owner_cd == "03") {
					AUIGrid.updateRow(auiGrid, { "use_org_code" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGrid, { "use_mem_no" : "" }, event.rowIndex);
					AUIGrid.updateRow(auiGrid, { "use_kor_name" :"" }, event.rowIndex);
				}

				// 폐기를 선택할 경우 직전의 보관처 보관부서 정보 가져오기
				if (event.item.asset_owner_cd == "04") {

					// 신규 추가면
					if ( event.item.seq_no == "0") {
						AUIGrid.updateRow(auiGrid, {"use_org_code": AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", fastSeq), "use_org_code")}, event.rowIndex);
						AUIGrid.updateRow(auiGrid, {"use_mem_no": AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", fastSeq), "use_mem_no")}, event.rowIndex);
						AUIGrid.updateRow(auiGrid, {"use_kor_name": AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", fastSeq), "use_kor_name")}, event.rowIndex);

					// 기존 것 수정인 경우
					} else {

						// 작성된 줄이 1줄 이상인 경우
						if ( fastSeq > 1 ) {
							AUIGrid.updateRow(auiGrid, {"use_org_code": AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", fastSeq), "use_org_code")}, event.rowIndex);
							AUIGrid.updateRow(auiGrid, {"use_mem_no": AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", fastSeq), "use_mem_no")}, event.rowIndex);
							AUIGrid.updateRow(auiGrid, {"use_kor_name": AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", fastSeq), "use_kor_name")}, event.rowIndex);

						// 한줄인 경우
						} else {
							//AUIGrid.updateRow(auiGrid, {"use_org_code": ""}, event.rowIndex);
							//AUIGrid.updateRow(auiGrid, {"use_mem_no": ""}, event.rowIndex);
							//AUIGrid.updateRow(auiGrid, {"use_kor_name": ""}, event.rowIndex);
						}

					}
				}

			}

		});
	}


	function fnUpdateCnt() {
		var cnt = AUIGrid.getGridData(auiGrid).length;
		$("#total_cnt").html(cnt);
	}
	
	//행추가
	function fnAdd() {
		// 15288 전호형
		// 1회 저장에 1번의 행추가만 가능하게 수정
		if(columAddCnt == 0) {
			columAddCnt = 1;
    		var item = new Object();

   			item.asset_payment_no = "${asset_payment_no}";
    		item.change_dt = "${inputParam.s_current_dt}";
    		item.asset_owner_cd = ""
    		item.use_mem_no = "";
			item.use_kor_name = "";
			item.use_org_code = "";
			item.change_text ="";
			item.seq_no = 0;
			item.reg_kor_name= "${SecureUser.kor_name}";
			item.reg_id= "${SecureUser.user_id}";

  		
			AUIGrid.addRow(auiGrid, item, 'first');
		} else {
			alert("저장 당 하나의 행만 저장 가능합니다.\n저장 후 다시 시도해주세요.")
		}
	}
	
	
	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validation(auiGrid);
	}




	// 15288 전호형
	// 저장하려는 항목의 변동일자가 최근 작성된 것 보다 빨라야함
	function fnDateCheck() {
		var rowCount = parseInt(AUIGrid.getRowCount(auiGrid));
		var tmp1 = ""; tmp2 = ""; tmp3 = ""; // 줄 수에 맞춰 seq_no 임시 저장용

		if ( AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", "0") != "" ) {  // 행추가가 있다면
			tmp1 = "0";
			tmp2 = ""+rowCount-1;
			tmp3 = ""+rowCount-2;
		} else {
			tmp1 = ""+rowCount
			tmp2 = ""+rowCount-1
			tmp3 = ""+rowCount-2
		}
		var latestDate0 = parseInt(AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", tmp1), "change_dt"));
		var latestDate1 = parseInt(AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", tmp2), "change_dt"));
		var latestDate2 = parseInt(AUIGrid.getCellValue(auiGrid, AUIGrid.getRowIndexesByValue(auiGrid, "seq_no", tmp3), "change_dt"));


		if ( rowCount == 1 ) {
			return true;
		} else if ( rowCount == 2 && latestDate0 > latestDate1 ) {

			return true;
		} else if ( rowCount >= 3 && latestDate0 > latestDate1 && latestDate1 > latestDate2 ) {
			return true;
		} else {
			alert('변동일자는 이전에 작성된 항목의 날짜보다 이후의 날짜로만 저장 가능합니다.')
		}
	}

	//15288 새로 추가될 항목의 보관처/보관부서 모두 내용이 들어간 경우 체크
	function fnValueCheck() {
		// 화면에 보여지는 그리드 데이터 목록
		var gridAllList = AUIGrid.getGridData(auiGrid);
		for (var i = 0; i < gridAllList.length; i++) {

			if (gridAllList[i].use_mem_no != "" && gridAllList[i].use_org_code != "") {
				AUIGrid.showToastMessage(auiGrid, i, 3, "보관처와 보관부서는 동시에 저장할 수 없습니다. 내용을 확인해주세요.");
				return false;
			}
		}
		return true;
	}

	// 저장
 	function goSave() {
		if (!fnDateCheck()){
			return false;
		};

		if (!fnValueCheck()){
			return false;
		};

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

			// 지급구분코드 ( asset_owner_cd ) -  01: 개인  , 02 :부서 , 03: 센터 , 04: 폐기
			if (gridAllList[i].asset_owner_cd != "") {

				if (gridAllList[i].asset_owner_cd == "01") {
					if (gridAllList[i].use_mem_no == "") {
						AUIGrid.showToastMessage(auiGrid, i, 4, "보관처를 입력하세요.");
						return;
					}
				}
				if (gridAllList[i].asset_owner_cd == "02" || gridAllList[i].asset_owner_cd == "03") {
					if (gridAllList[i].use_org_code == "") {
						AUIGrid.showToastMessage(auiGrid, i, 5, "보관부서를 입력하세요.");
						return;
					}
				}

				if (gridAllList[i].asset_owner_cd == "04" ) {
					if (gridAllList[i].use_mem_no == "" && gridAllList[i].use_org_code == "") {
						AUIGrid.showToastMessage(auiGrid, i, 4, "보관처 또는 보관부서를 입력하세요.");
						return;
					}
				}

			}
		}

		var frm = fnChangeGridDataToForm(auiGrid,'N');
		console.log(frm);
		$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'},
			function(result) {
				if(result.success) {
					AUIGrid.removeSoftRows(auiGrid);
					AUIGrid.resetUpdatedItems(auiGrid);

					//저장 후 변경된 최신 소유자 정보 넘겨주기
					opener.${inputParam.parent_js_name}(result);

					// 15288 전호형
					// 저장 후 행추가가 가능하도록 다시 행추가 제한 변수 초기화
					columAddCnt = 0;

					$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);

					opener.goSearch();
					window.location.reload();
				};
			}
		);
	}
	
	function fnClose() {
		window.close(); 
	}

	function newObj(param){
		return $.extend(true, [], param);
	};

	// 직원조회 결과 ( 보관자 )
	function fnsetOrgMapPanel3(data) {
		AUIGrid.updateRow(auiGrid, { "use_kor_name" : data.mem_name }, gridRowIndex);
		AUIGrid.updateRow(auiGrid, { "use_mem_no" : data.mem_no }, gridRowIndex);
	}


	// 직원조회 결과 ( 구매자 )
	function fnsetOrgMapPanel2(data) {

		// 전호형 / 임직원 트리를 선택했을 때 공란되는 버그 수정 ( 기존 버그 )
		if ( data.mem_name != '') {
			AUIGrid.updateRow(auiGrid, { "use_kor_name" :  data.mem_name }, gridRowIndex);
			AUIGrid.updateRow(auiGrid, { "use_mem_no" : data.mem_no }, gridRowIndex);
		} else {
			alert('올바른 임직원을 선택해 주세요.')
		}


		$M.setValue("s_kor_name", data.mem_name)
		$M.setValue("s_use_place", data.mem_no);
	}


	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">

<!-- 팝업 -->
    <div class="popup-wrap width-100per" >
	<!-- 메인 타이틀 -->
      	<div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
	<!-- /메인 타이틀 -->
		<div class="content-wrap">

	<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4>변동이력</h4>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
			<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
<!-- 팝업 -->
	</div>
</form>
</body>
</html>