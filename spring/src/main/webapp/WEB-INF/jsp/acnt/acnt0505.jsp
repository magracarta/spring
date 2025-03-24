<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 자산지급품관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-04-21 13:15:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>

	var orgCenterListJson = ${centerList};								//센터리스트
	var assetOwnerJson = JSON.parse('${codeMapJsonObj['ASSET_OWNER']}');		//자산소유구분
	var assetTypeJson = JSON.parse('${codeMapJsonObj['ASSET_TYPE']}');			//자산물품구분
	var orgCenterListScrapJson = Object.assign(${centerList}, orgListJson);	// 부서+센터리스트 (폐기 시 사용)
	var orgCenterListDocJson = ${orgList2}; // 품의서에서 사용하는 부서목록
	
	//15288 최승희 대리 요청으로 보관처 소속정보 출력
	var orgAllList = ${orgAllList};
	var memOrgAllList = ${memOrgAllList};
	
	//선택항목 추가 ( 드랍다운리스트)
	var defaultArr= { "code_name" : "- 선택 -","code_value":"" };


	var gridRowIndex;
	var auiGrid;

	//15288 변동이력에 동시 저장할 때 asset_payment_no를 구분할 수 있도록 row별 고유 식별자 추가
	var asset_payment_no = 0;
	
	$(document).ready(function() {
// 		fnInitDate();
		createAUIGrid();
		fnSetting();
		goSearch();
	});
	
	function fnSetting() {

		// 15288 전호형 최승희 대리 요청에 따라 초기 조회시엔 폐기를 제외한 항목만 검색 토록 변경
		var selectCd = ['01','02','03'] // 선택된 항목 (개인, 부서, 센터)
		$M.setValue("s_asset_owner_cd", selectCd);

		// 관리부이거나, 최승희대리일경우를 제외하면 구분선택 못함. 본인것만 조회가능.
		if ("${page.fnc.F00593_001}" != "Y" && "${page.fnc.F00593_003}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             " != "Y") {
			if ("${page.fnc.F00593_002}" == "Y") {
				var selectCd = ['01','03'] // 선택된 항목 (개인, 부서, 센터)
				$M.setValue("s_asset_owner_cd", selectCd);
				$('#s_asset_owner_cd').combogrid("disable")
				$("#s_center_org_code").prop("disabled", true);
			} else {
				$('#s_asset_owner_cd').combogrid("disable")
				$("#s_center_org_code").prop("disabled", true);
			}
		}
		
	}
	
	// 자산지급품 매입일자 시작일자 세팅 현재날짜의 1달 전
// 	function fnInitDate() {
// 		var now = "${inputParam.s_current_dt}";
// 		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 	}
	
	function createAUIGrid() {
		var gridPros = {
			// 체크박스 표시 설정
			showRowCheckColumn : true,			
			// 전체 체크박스 표시 설정
			showRowAllCheckBox : true,

			// 전체 선택 체크박스가 독립적인 역할을 할지 여부
			independentAllCheckBox : true,
			
			editable : true,
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowIdField가 unique 임을 보장
			rowIdTrustMode : true,
			// rowNumber 
			showRowNumColumn : true,
			enableSorting : true,
			showStateColumn : true,
			
			
			// 엑스트라 체크박스 disabled 함수
			// 이 함수는 렌더링 시 빈번히 호출됩니다. 무리한 DOM 작업 하지 마십시오. (성능에 영향을 미침)
			// rowCheckDisabledFunction 이 아래와 같이 간단한 로직이라면, 실제로 rowCheckableFunction 정의가 필요 없습니다.
			// rowCheckDisabledFunction 으로 비활성화된 체크박스는 체크 반응이 일어나지 않습니다.(rowCheckableFunction 불필요)
			rowCheckDisabledFunction : function(rowIndex, isChecked, item) {
				
				if(AUIGrid.isAddedById(auiGrid,item._$uid)) {
					return false;
				}
				else {
					return true;
				}
			},
			enableFilter :true
			
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
		
// 		var servYn = "${SecureUser.org_code}".substring(0, 1) == "5" ? "Y" : "N";
		var servYn = "Y";
		
		if ("${page.fnc.F00593_001}" == "Y") {
			servYn = "N";
		}
		
		if(servYn == "Y") {
			gridPros.editable = false;
		}

		
		var columnLayout = [
			{
				headerText : "관리번호",
				dataField : "asset_payment_no",
				width : "70",
				minWidth : "70",
				style : "aui-center",
				required : false,
				editable : false,	
				filter : {
					showIcon : true
				},
				// 전호형 / 생성 시 임시 발번하는 음수로 된 관리번호 숨기기 (기존 버그)
				labelFunction : function(rowIndex, columnIndex, value, headerText, item ) {
					var str = value;
					if(item.asset_payment_no < 0){
						str = "";
					}
					return str;
				},

			},
			{ 
				headerText : "구매자직원번호", 
				dataField : "buy_mem_no", 
				required : true,
				visible : false
			},						
			{				
				headerText : "구매자",
				dataField : "buy_kor_name",
				width : "65",
				minWidth : "65",
				style : "aui-center",
				required : true,
				editable : false,
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},	
				filter : {
					showIcon : true
				},
			}, 			
			{
				headerText : "매입일", 
				dataField : "buy_dt", 
				dataType : "date",   
				width : "70",
				minWidth : "70",
				style : "aui-center",
				required : true,
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
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
				filter : {
					showIcon : true
				},
			},	
			{
				headerText : "구분",
				dataField : "asset_owner_cd",		
				width : "90",
				minWidth : "90",
				style : "aui-center",
				required : true,
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
					//작성시에만 에디팅 스타일
					if (AUIGrid.isAddedById(auiGrid,item._$uid) && servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true,
					displayFormatValues : true
// 					filterFunction : function (dataField, value, item) {
// 						console.log(item)
// // 						return item.asset_owner_name;
// 						return value;
// 				    }
				},
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
					//작성시에만 에디팅 스타일
					if (AUIGrid.isAddedById(auiGrid,item._$uid) && servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			},
			// 15288 전호형 최승희 대리 요청으로 보관처에 대한 소속 출력
			{
				headerText : "소속센터(부서)",
				dataField : "org_code",
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					//221208 15288 전호형
					//작성시에만 에디팅 스타일
					if (AUIGrid.isAddedById(auiGrid,item._$uid) && servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item ) {
					//var retStr = value;
					var tmpOrgCode = '';
					var tmpOrgKorName = '';
					if (item.use_mem_no != '') {	//구분 - 부서
						for (var i = 0; i < memOrgAllList.length; i++) {
							console.log("유즈"+item.use_mem_no);
							if (memOrgAllList[i]["mem_no"] == item.use_mem_no) {
								tmpOrgCode = memOrgAllList[i]["org_code"];
								console.log("같음"+tmpOrgCode);
								break;
							}
						}
						for (var i = 0; i < orgAllList.length; i++) {
							if (orgAllList[i]["org_code"] == tmpOrgCode) {
								tmpOrgKorName = orgAllList[i]["org_kor_name"];
								return tmpOrgKorName;
							}
						}
					} else {
						return  '';
					}
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
					//작성시에만 에디팅 스타일
					if (AUIGrid.isAddedById(auiGrid,item._$uid) && servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true,
					displayFormatValues : true
				},
			},
			{ 
				headerText : "상위자산관리번호", 
				dataField : "up_asset_payment_no", 
				visible : false
			},
			{
				dataField : "asset_type_cd",
				visible : false
			},
			{
				headerText : "물품구분",
				dataField : "asset_type_name",
				width : "80",
				minWidth : "80",
				style : "aui-center",
				required : true,
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : false,
					list : assetTypeJson,
					keyField : "code_value", 
					valueField : "code_name" 				
				},
				labelFunction : function(rowIndex, columnIndex, value){
					var retStr = value;
					for(var j = 0; j < assetTypeJson.length; j++) {
						if(assetTypeJson[j]["code_value"] == value) {
							retStr = assetTypeJson[j]["code_name"];
							break;
						}
					}
					return retStr;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true,
					displayFormatValues : true
				},
			}, 	
			{
				headerText : "구입처",
				dataField : "buy_office",
				width : "110",
				minWidth : "110",
				style : "aui-center",
				required : true,
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 30,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			}, 
			{
				headerText : "제품명",
				dataField : "maker_brand",
				width : "110",
				minWidth : "110",
				style : "aui-center",
				required : true,
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 50,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			}, 
			{ 
				headerText : "금액",
				dataField : "buy_amt",
				width : "85",
				minWidth : "85",
				dataType : "numeric",
// 				formatString : "#,##0",
				style : "aui-right",
				required : true,
				editable : true,
				editRenderer : {
			    	type : "InputEditRenderer",
				    onlyNumeric : true,
// 			      	auiGrid : "#auiGrid",
// 		     	 	maxlength : 20,
			      	// 에디팅 유효성 검사
			      	validator : AUIGrid.commonValidator
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			},			
			{
				headerText : "사용기한", 
				dataField : "use_limit_dt", 
				dataType : "date",   
				width : "70",
				minWidth : "70",
				style : "aui-center",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				required : true,
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
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			},				
			{
				headerText : "비고(모델명)",
				dataField : "remark",
				width : "100",
				minWidth : "50",
				style : "aui-left",
				editable :  true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 1000,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-editable";
					};
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			},
			/*	//221213 15288 전호형 변동이력에도 저장할 수 있도록 컬럼 제거 (사용되지 않음)
			{
				dataField : "use_yn",
				visible : false
			},
			*/
				//221213 15288 전호형 변동이력에도 저장할 수 있도록 컬럼 추가
			{
				dataField : "seq_no",
				visible : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return "1";
				}
			},
			{
				headerText : "변동이력", 
				style : "aui-center",			
				width : "70",
				minWidth : "55",	
				dataField : "asset_payment_log_cnt", 
				editable : false,
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-popup"
					};
					return "aui-center";
				},
				filter : {
					showIcon : true
				},
			},
			{
				headerText : "매수",
				dataField : "output_count",
				width : "50",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
				    type : "InputEditRenderer",
				    onlyNumeric : true,
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
		            return value == "" || value == null ? "1" : value;
				}
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "55",
				minWidth : "55",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);		
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
						}
					},
					visibleFunction :  function(rowIndex, columnIndex, value, 
							item, dataField ) {
						// 삭제버튼은 행 추가시에만 보이게 함
						if(AUIGrid.isAddedById(auiGrid,item._$uid)) {
						  	return true;
						}
						else {
						  	return false;
						}						 
				 	}
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
	
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				},
			}			
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		$("#auiGrid").resize();

		AUIGrid.bind(auiGrid, "cellClick", function(event) {

			if(event.dataField == "buy_kor_name" && servYn != "Y") {
				gridRowIndex = event.rowIndex;
				param = {
					  "agency_yn" : "N"
				}			
				openMemberOrgPanel('fnsetOrgMapPanel2','N', $M.toGetParam(param));
				//openSearchMemberPanel('fnSetBuyMemberInfo', $M.toGetParam(param));
			}
			
			if(event.dataField == "asset_payment_log_cnt" && !AUIGrid.isAddedById(auiGrid,event.item._$uid) && servYn != "Y") {
				gridRowIndex = event.rowIndex;
				param = {"asset_payment_no" : event.item.asset_payment_no };							
				openAssetPaymentLogPanel('fnSetAssetPaymentLogInfo', $M.toGetParam(param));
			}



			
			//보관처 - 구분이 개인/폐기인 경우에만 선택 가능

			//221212 15288 전호형
			//최초 작성시에만 입력 가능
			if(event.dataField == "use_kor_name" && servYn != "Y" && AUIGrid.isAddedById(auiGrid,event.item._$uid)){
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
			//최초 작성시에만 입력 가능
			if(event.dataField == "use_org_code" && servYn != "Y" && AUIGrid.isAddedById(auiGrid,event.item._$uid) ) {

				if(event.item.asset_owner_cd == "01") {

					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "입력할 수 없습니다. 구분을 확인해주세요.");
					}, 1);
					return false; 
				}
			}	
		});


		//221208 15288 전호형
		//최초 작성시에만 입력 가능
		AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
			if (event.dataField == "use_kor_name" || event.dataField == "asset_owner_cd" || event.dataField == "use_org_code") {
				if (!AUIGrid.isAddedById(auiGrid,event.item._$uid)) {
					return false;
				}
			}
		});


		AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {

			if(event.dataField == "asset_owner_cd") {
				// 15288 전호형
				// 부서 <-> 센터 변경 시 보관부서가 초기화 되도록 변경 (이전 버그 수정)
				if(event.item.asset_owner_cd == "01" || event.item.asset_owner_cd == "04") {
					AUIGrid.updateRow(auiGrid, { "use_org_code" : ""}, event.rowIndex);
				} else {
					AUIGrid.updateRow(auiGrid, { "use_org_code" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGrid, { "use_mem_no" : "" }, event.rowIndex);
					AUIGrid.updateRow(auiGrid, { "use_kor_name" :"" }, event.rowIndex);
				}
			}

			if(event.dataField == 'asset_type_name') {
				var evantVal = event.value;
				gridRowIndex = event.rowIndex;
				AUIGrid.updateRow(auiGrid, { "asset_type_cd" : evantVal }, gridRowIndex);
			}

		});	
		
		// 전체 체크박스 클릭 이벤트 바인딩
		AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
			
			if(event.checked) {
				// asset_payment_no 의 값들 얻기
				var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "asset_payment_no");
				
				//신규등록 , 행복사인 경우 체크하지 않음
				for (var i = 0; i < uniqueValues.length; ++i) {
					if (uniqueValues[i] == "") {
						uniqueValues.splice(i,1);
					}
				}
				
				AUIGrid.setCheckedRowsByValue(event.pid, "asset_payment_no", uniqueValues);
			} else {
				AUIGrid.setCheckedRowsByValue(event.pid, "asset_payment_no", []);
			}
		});
				
	}

 	function newObj(param){
	    return $.extend(true, [], param);
	};
	
	
	
	// 직원조회 결과 ( 검색용 )
	function fnsetOrgMapPanel(data) {		
		$M.setValue("s_kor_name", data.mem_name);
		$M.setValue("s_use_place", data.mem_no );

	}
	
	// 직원조회 결과 ( 구매자 )
	function fnsetOrgMapPanel2(data) {

		// 전호형 / 임직원 트리를 선택했을 때 공란되는 버그 수정 ( 기존 버그 )
		if ( data.mem_name != '') {
			AUIGrid.updateRow(auiGrid, {"buy_kor_name": data.mem_name}, gridRowIndex);
			AUIGrid.updateRow(auiGrid, {"buy_mem_no": data.mem_no}, gridRowIndex);
		} else {
			alert('올바른 임직원을 선택해 주세요.')
		}
	    
	    //$M.setValue("s_kor_name", data.mem_name)
	    //$M.setValue("s_use_place", data.mem_no);
	}
	
	
	// 직원조회 결과 ( 보관자 )
	function fnsetOrgMapPanel3(data) {

		// 전호형 / 임직원 트리를 선택했을 때 공란되는 버그 수정 ( 기존 버그 )
		if ( data.mem_name != '') {
	    	AUIGrid.updateRow(auiGrid, { "use_kor_name" : data.mem_name }, gridRowIndex);
	    	AUIGrid.updateRow(auiGrid, { "use_mem_no" : data.mem_no }, gridRowIndex);
		} else {
			alert('올바른 임직원을 선택해 주세요.')
		}
	}
	
	
	// 자산지급품 사후관리변동이력 결과
	function fnSetAssetPaymentLogInfo(data) {		
	   AUIGrid.updateRow(auiGrid, { "asset_payment_log_cnt" : data.asset_payment_log_count }, gridRowIndex);
	}
	

	// 셀렉트박스 변경시 처리 ( 소유구분)
	function fnChangeAssetOwner(obj){	
		console.log(obj);
		console.log(obj.value);
		switch(obj.value)
		{		
			case "01" : $("#asset_owner_01").show();$("#asset_owner_02").hide();$("#asset_owner_03").hide(); $("#asset_owner_all").hide(); $("#gubun_name").text("보관처"); 	break;
			case "02" : $("#asset_owner_01").hide();$("#asset_owner_02").hide();$("#asset_owner_03").show(); $("#asset_owner_all").hide(); $("#gubun_name").text("보관부서"); break;
			case "03" : $("#asset_owner_01").hide();$("#asset_owner_02").show();$("#asset_owner_03").hide(); $("#asset_owner_all").hide(); $("#gubun_name").text("보관부서"); break;
			case "04" : $("#asset_owner_01").show();$("#asset_owner_02").hide();$("#asset_owner_03").hide(); $("#asset_owner_all").hide(); $("#gubun_name").text("보관처"); break;
			default   : $("#asset_owner_01").hide();$("#asset_owner_02").hide();$("#asset_owner_03").hide(); $("#asset_owner_all").show(); $("#gubun_name").text("보관처"); break;
		}
		$M.setValue("s_use_place", "");
		$M.setValue("s_kor_name", "");
	}
	
	// 셀렉트박스 파라미터 처리 ( 부서 , 센터)
	function fnChangeUsePlase(obj){	
		$M.setValue("s_use_place", obj.value);
	}
	
	
	function goSearch() {

		if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
			return;
		}; 
		
		var usePlaceArr = "";
		if($M.getValue("s_asset_owner_cd") == "02"){
			usePlaceArr = $M.getValue("s_org_code");
		}else if($M.getValue("s_asset_owner_cd") == "03"){
			usePlaceArr = $M.getValue("s_center_org_code");
		}else{
			usePlaceArr = $M.getValue("s_use_place");
		}
		
		var param = {
			s_date_type : $M.getValue("s_date_type"),
			s_start_dt : $M.getValue("s_start_dt"),
			s_end_dt : $M.getValue("s_end_dt"),
			s_asset_owner_cd_str : $M.getValue("s_asset_owner_cd"),
			s_use_place_str : usePlaceArr,			
			s_asset_type_cd_str : $M.getValue("s_asset_type_cd"),
			s_asset_payment_no : $M.getValue("s_asset_payment_no"),
			s_sort_key : "buy_dt desc, asset_payment_no ",
			s_sort_method : "desc"
		};
		//_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		console.log(param);
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#total_cnt").html(result.total_cnt);
					AUIGrid.setGridData(auiGrid, result.list);
				};
			}
		);
	}
	

	function fnUpdateCnt() {
		var cnt = AUIGrid.getGridData(auiGrid).length;
		$("#total_cnt").html(cnt);
	}
	

	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validation(auiGrid);
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

			// 새로 등록하는 것만 체크 하도록 변경
			// 지급구분코드 ( asset_owner_cd ) -  01: 개인  , 02 :부서 , 03: 센터 , 04: 폐기
			if( gridAllList[i].asset_payment_no == 0 ) {
				if (gridAllList[i].asset_owner_cd != "") {

					if (gridAllList[i].asset_owner_cd == "01") {
						if (gridAllList[i].use_mem_no == "") {
							AUIGrid.showToastMessage(auiGrid, i, 6, "보관처를 입력하세요.");
							return;
						}
					}
					if (gridAllList[i].asset_owner_cd == "02" || gridAllList[i].asset_owner_cd == "03") {
						if (gridAllList[i].use_org_code == "") {
							AUIGrid.showToastMessage(auiGrid, i, 7, "보관부서를 입력하세요.");
							return;
						}
					}
				}
				if (gridAllList[i].asset_owner_cd == "04" ) {
					if (gridAllList[i].use_mem_no == "" && gridAllList[i].use_org_code == "") {
						AUIGrid.showToastMessage(auiGrid, i, 4, "보관처 또는 보관부서를 입력하세요.");
						return;
					}
				}

			}



			//신규추가건은 자산지급관리번호에 -1 입력 ( DB에서 일괄 발번 할것임)
			//15288 각 추가된 row들이 고유번호로 구분될 수 있도록 -1씩 감소하는 음수 적용
			if(gridAllList[i].asset_payment_no == "" || gridAllList[i].asset_payment_no < 0){

				//15288 새로 추가될 항목의 보관처/보관부서 모두 내용이 들어간 경우 체크
				if(gridAllList[i].use_mem_no != "" && gridAllList[i].use_org_code != ""){
					AUIGrid.showToastMessage(auiGrid, i, 6, "보관처와 보관부서는 동시에 저장할 수 없습니다. 내용을 확인해주세요.");
					return;
				}

				if(gridAllList[i].asset_payment_no == "") {
					asset_payment_no = asset_payment_no - 1;
					AUIGrid.setCellValue(auiGrid, i, "asset_payment_no", String(asset_payment_no));
				}
			}

						
		}
			
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
	
	//행추가
	function fnAdd() {
		if(fnCheckGridEmpty(auiGrid)) {
    		var item = new Object();
    		item.asset_payment_no = "";
    		item.buy_mem_no = "";  	
    		item.buy_kor_name = "";      
    		item.up_asset_payment_no = ""; 
    		item.asset_owner_cd = "";
    		item.buy_dt = "";
    		item.use_mem_no = "";
    		item.use_kor_name = "";
    		item.use_org_code = "";
    		item.asset_type_cd = "";
    		item.buy_office = "";
    		item.maker_brand = "";
    		item.buy_amt = "";
    		item.use_limit_dt = "";
    		item.remark = "";
			// 15288 변동이력에도 저장할 수 있도록 seq_no 추가
			item.seq_no = "1";
			item.output_count ="1";
    		item.asset_payment_log_cnt = "0";
			AUIGrid.addRow(auiGrid, item, 'first');
		}
	}
	
	//행복사
	function fnCopy()
	{
		//행복사전 선택된 로우가 있는지 확인
		var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
		if(checkedItems.length <= 0) {
			alert("선택된 데이터가 없습니다.");
			return;
		}
		
		//행복사후 원본데이터의 자산관리번호를 상위자산관리번호에 저장
		//행복사 혹은 행추가로 생성된 데이터는 행복사대상에서 제외
		var str = "";
		var rowItem;
		var newItem;
		
		for(var i=0, len = checkedItems.length; i<len; i++) {
					
			rowItem = checkedItems[i].item;
			
			if(rowItem.asset_payment_no != "" )
			{						
				newItem = new Object();
				newItem.asset_payment_no = "";
				newItem.buy_mem_no = rowItem.buy_mem_no;  		
				newItem.buy_kor_name = rowItem.buy_kor_name;  
				newItem.up_asset_payment_no = rowItem.asset_payment_no; 	//상위자산관리번호 - 복사한 원본 자산관리번호
				newItem.asset_owner_cd = rowItem.asset_owner_cd;
				newItem.buy_dt = rowItem.buy_dt ;
				newItem.use_mem_no = rowItem.use_mem_no;
				newItem.use_kor_name = rowItem.use_kor_name;
				newItem.use_org_code = rowItem.use_org_code;
				newItem.asset_type_cd = rowItem.asset_type_cd;
				newItem.buy_office = rowItem.buy_office;
				newItem.maker_brand = rowItem.maker_brand;
				newItem.buy_amt = rowItem.buy_amt;
	    		newItem.use_limit_dt = rowItem.use_limit_dt;
	    		newItem.remark = rowItem.remark;
				// 15288 변동이력에도 저장할 수 있도록 seq_no 추가
				newItem.seq_no = "1";
	    		newItem.asset_payment_log_cnt = "0";
	    		
				AUIGrid.addRow(auiGrid, newItem, 'first');
			}
		}
		alert('행복사가 완료되었습니다.\r\n');
	}
	
	
	//삭제
	function goRemove()
	{
		//삭제전 선택된 로우가 있는지 확인
		var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
		if(checkedItems.length <= 0) {
			alert("선택된 데이터가 없습니다.");
			return;
		}
		else {
		
			frm = fnCheckedGridDataToForm(auiGrid);
			
			console.log(frm);
			
			$M.goNextPageAjaxRemove(this_page +"/remove", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);		
						$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);		
						
						//AUIGrid.removeCheckedRows(auiGrid);
						goSearch();
					};
				}
			);
		
		}
	}
	function fnPrintLabel(){
		var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
		if(rows.length <= 0) {
			alert("선택된 데이터가 없습니다.");
			return;
		}
		
		for(var i in rows) {
			if (rows[i].asset_owner_cd == "02" || rows[i].asset_owner_cd == "03") {
				rows[i].use_kor_name = rows[i].use_org_name;
			}
		}
		
		var newRows = [];
		for (var i in rows) {
			var duplRows = [];
			for (var j = 0; j < rows[i].output_count; j++) {
				newRows.push(rows[i]);
			}
		}
		
		var param = {
			"data" : newRows
		}

		// 3-2차 (Q&A 15288) 용지설정 및 항목수정.  2023-01-27 김상덕
		// openReportPanel('acnt/acnt0505_01.crf', param);
		openReportPanel('acnt/acnt0505_01_v32.crf', param);
	}
	
	// 엑셀 업로드
	function goExcelUpload() {
		//var params = {
		//	"s_current_year" : $M.getValue("s_current_year")
		//};
		//var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=950, left=0, top=0";
		//$M.goNextPage('/sale/sale0504p04', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	
	function fnDownloadExcel() {
		  // 엑셀 내보내기 속성
		  var exportProps = {
		         // 제외항목
		         //exceptColumnFields : ["removeBtn"]
		  };
		  fnExportExcel(auiGrid, "자산지급품관리목록", exportProps);
	}
	
	function fnOpenMemberOrg() {
		param = {
			  "agency_yn" : "N"
		}			
		openMemberOrgPanel('fnsetOrgMapPanel','N', $M.toGetParam(param));
	}
	
	// 21.09.02 (SR : 12438) 관리번호 검색조건 추가
	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_asset_payment_no"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
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
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="contents">
	<!-- 기본 -->					
				<div class="search-wrap">				
					<table class="table">
						<colgroup>
							<col width="80px">
							<col width="260px">								
							<col width="60px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="60px">
							<col width="120px">
							<col width="65px">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>
									<select class="form-control" name="s_date_type">
										<option value="buy_dt">매입일자</option>
										<option value="use_dt">사용기한</option>
									</select>
								</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate " id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" required="required" value="${inputParam.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate " id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}" required="required">
											</div>
										</div>
<!-- 										210830 김상덕. 유정은팀장님, 최승희 대리님 요청으로 개인기간설정버튼 없애고 2010년 1월 1일로 수정요청. -->
<%-- 										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp"> --%>
<%-- 			                     		<jsp:param name="st_field_name" value="s_start_dt"/> --%>
<%-- 			                     		<jsp:param name="ed_field_name" value="s_end_dt"/> --%>
<%-- 			                     		<jsp:param name="click_exec_yn" value="Y"/> --%>
<%-- 			                     		<jsp:param name="exec_func_name" value="goSearch();"/> --%>
<%-- 			                     		</jsp:include>	 --%>
									</div>							
								</td>
<!-- 							21.09.02 (SR : 12438) 관리번호 검색조건 추가 -->
								<th>관리번호</th>
								<td>	
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_asset_payment_no" name="s_asset_payment_no">
									</div>
								</td>								
								<th>구분</th>
								<td>
									<input class="form-control essential-bg width120px" type="text" id="s_asset_owner_cd" name="s_asset_owner_cd" easyui="combogrid" change="javascript:fnChangeAssetOwner(this);"
							   		easyuiname="assetOwnerList" panelwidth="120" idfield="code_value" textfield="code_name" multi="Y" value=""/>
									<%-- <select id="s_asset_owner_cd" name="s_asset_owner_cd" class="form-control" onchange="javascript:fnChangeAssetOwner(this);" >
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['ASSET_OWNER']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
										<option value="05">전체(폐기제외)</option>
									</select>	 --%>
								</td>
								<th>
									<label id="gubun_name" name="gubun_name"  >보관처</label> 
								</th>
								<td>
									<div id="asset_owner_01" style="display:none;" >
										<div class="input-group">
											<input type="text" id="s_kor_name" name="s_kor_name" class="form-control border-right-0" readonly="readonly" >
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenMemberOrg();"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div id="asset_owner_02"  style="display:none;"  >
										<input class="form-control essential-bg width120px" type="text" id="s_center_org_code" name="s_center_org_code" easyui="combogrid"
								   		easyuiname="easyCenterList" panelwidth="120" idfield="org_code" textfield="org_name" multi="Y" value=""/>
										<%-- <select id="s_center_org_code" name="s_center_org_code" class="form-control" onchange="javascript:fnChangeUsePlase(this);"  >
											<option value="">전체</option>
											<c:forEach items="${centerList1}" var="item"  >
													<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>	 --%>			
									</div>
									<div id="asset_owner_03"  style="display:none;"  >
										<input class="form-control essential-bg width120px" type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
								   		easyuiname="easyOrgList" panelwidth="120" idfield="org_code" textfield="org_name" multi="Y" value=""/>
										<%-- <select  class="form-control" onchange="javascript:fnChangeUsePlase(this);"  >
											<option value="">전체</option>
											<c:forEach var="orgListItem" items="${orgList}">
												<option value="${orgListItem.org_code }">${orgListItem.org_name }</option>
											</c:forEach>
										</select>	 --%>
									</div>
									<div id="asset_owner_all"    >
										<input type="text"  class="form-control" readonly="readonly" >
									</div>
									<input type="hidden" id="s_use_place" name="s_use_place" class="input"/>				
								</td>								
								<th>물품구분</th>
								<td>
									<input class="form-control essential-bg width120px" type="text" id="s_asset_type_cd" name="s_asset_type_cd" easyui="combogrid"
								   	easyuiname="assetTypeList" panelwidth="120" idfield="code_value" textfield="code_name" multi="Y" value=""/>
									<%-- <select id="s_asset_type_cd" name="s_asset_type_cd" class="form-control">
										<option value="">- 전체 -</option>
										<c:forEach items="${codeMap['ASSET_TYPE']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select> --%>	
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();" >조회</button>
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
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>