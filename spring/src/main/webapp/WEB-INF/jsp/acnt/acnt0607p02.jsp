<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 발령관리 > null > 지급품회수
-- 작성자 : 이강원
-- 최초 작성일 : 2021-06-03 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
	var auiGridPayment;
	var auiGridCar;
	var auiGridCard;
	var auiGridToDo;
	var auiGridSaleArea;
	var paymentList = ${paymentList};
	var orgList = ${orgList};

	// 15288 변동이력 수정 직후 지급품회수 변동이력 수 갱신할때 사용
	var gridRowIndex;

	// 15288 지급품회수 메뉴에서 특정권한이 아니라면, 변동이력에 진입 못하도록 변경
	var servYn = "Y";
	if ("${page.fnc.F02083_001}" == "Y") {
		servYn = "N";
	}


	// 관리,영업,부품관리만 있는 리스트
	var orgList2 = orgList.filter(function(value,index,arr){
		if(arr[index].org_code == '2000' || arr[index].org_code == '4000' || arr[index].org_code == '6000'){
			return true;
		}
		return false;
	});
	// 센터 리스트
	var centerList = orgList.filter(function(value,index,arr){
		if(arr[index].up_org_code == '4700' || arr[index].up_org_code == '5100'){
			return true;
		}
		return false;
	});
	var ownerList = JSON.parse('${codeMapJsonObj['ASSET_OWNER']}');
	
	$(document).ready(function () {
		createauiGridPayment();
		createauiGridCar();
		createauiGridCard();
		// createauiGridToDo();
		// createAUIGridMisu();
	});
	
	function createauiGridPayment() {
		var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : true,
		};
		var myDropOrgEditRenderer = {
				type : "DropDownListRenderer",
				showEditorBtn : false,
				showEditorBtnOver : true,
				editable : true,
				list : orgList2,
				keyField : "org_code", 
				valueField : "org_name",	
		};
		var myDropCenterEditRenderer = {
				type : "DropDownListRenderer",
				showEditorBtn : false,
				showEditorBtnOver : true,
				editable : true,
				list : centerList,
				keyField : "org_code", 
				valueField : "path_org_name",	
		};
		var columnLayout = [
			{
				headerText : "관리번호", 
				dataField : "payment_asset_payment_no", 
				width : "90",
				minWidth : "90",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "매입일", 
				dataField : "payment_buy_dt", 
				width : "80",
				minWidth : "80",
				dataType : "date",
				formatString : "yy-mm-dd", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "구매자", 
				dataField : "payment_buy_mem_name", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "구분", 
				dataField : "payment_asset_owner_cd", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
				/* 15288 목록에서는 수정불가하게 바꿈 (변동이력 페이지에서 수정토록 유도)
				editRenderer : {
					type : "DropDownListRenderer",
					showEditorBtn : false,
					showEditorBtnOver : true,
					editable : true,
					list : ownerList,
					keyField : "code_value",
					valueField : "code_name",
				},
				*/
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					for(var i=0;i<ownerList.length;i++){
						if(value == ownerList[i].code_value){
							return ownerList[i].code_name;
						}
					}
					return "";
				}
			},
			{
				headerText : "보관처 코드", 
				dataField : "payment_use_mem_no", 
				editable : false,
				visible : false,
			},
			{
				headerText : "보관처", 
				dataField : "payment_use_mem_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "보관부서", 
				dataField : "payment_use_org_code", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable: false,
				/* 15288 목록에서 수정불가하도록 수정
				editRenderer : {
					type : "ConditionRenderer",
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						if(item.payment_asset_owner_cd == '02' ){
							return myDropOrgEditRenderer;
						}else if(item.payment_asset_owner_cd == '03' ){
							return myDropCenterEditRenderer;
						}
					}
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					for(var i=0;i<orgList.length;i++){
						if(value == orgList[i].org_code){
							return orgList[i].org_name;
						}
					}
				}
				 */
			},
			{
				headerText : "물품구분", 
				dataField : "payment_asset_type_name", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "구입처", 
				dataField : "payment_buy_office", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "제조사/브랜드", 
				dataField : "payment_maker_brand", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "금액", 
				dataField : "payment_buy_amt", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false,
			},
			{
				headerText : "사용기한", 
				dataField : "payment_use_limit_dt", 
				width : "90",
				minWidth : "90",
				dataType : "date",
				formatString : "yy-mm-dd", 
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "비고", 
				dataField : "payment_remark", 
				width : "200",
				minWidth : "200",
				style : "aui-left",
				editable : false,
			},
			{
				headerText : "사후관리변동이력", 
				dataField : "payment_asset_payment_log_cnt", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (servYn != "Y") {
						return "aui-popup"
					};
					return "aui-center";
				},
			},
			{
				headerText : "cmd", 
				dataField : "payment_cmd", 
				visible : false,
			},
		];
		
		auiGridPayment = AUIGrid.create("#auiGridPayment", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridPayment, ${paymentList});


		AUIGrid.bind(auiGridPayment, "cellClick", function(event){
			if(event.dataField == "payment_asset_payment_log_cnt" && servYn != "Y") {
				gridRowIndex = event.rowIndex;
				param = {"asset_payment_no" : event.item.payment_asset_payment_no };							
				openAssetPaymentLogPanel('fnSetAssetPaymentLogInfo', $M.toGetParam(param));
			}

			/* 15288 목록화면에서 수정할 수 없도록 변경 (변동이력 페이지에서 수정하도록 유도)
			if(event.dataField == "payment_use_mem_name"){
				if(event.item.payment_asset_owner_cd == "01" || event.item.payment_asset_owner_cd == "04"){
					setMember('auiGridPayment',event.rowIndex);
				}else{
					console.log("aaaa");
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGridPayment, event.rowIndex, event.columnIndex, "입력할 수 없습니다.");
					}, 1);
				}
			}
			
			if(event.dataField == "payment_use_org_code"){
				if(event.item.payment_asset_owner_cd != "02" && event.item.payment_asset_owner_cd != "03"){
					setTimeout(function() {
						 AUIGrid.showToastMessage(auiGridPayment, event.rowIndex, event.columnIndex, "입력할 수 없습니다.");
					}, 1);
				}
			}
			 */


		});

		/* 15288 목록화며네서 수정할 수 없도록 수정 (상세 페이지에수 수정 유도)
		AUIGrid.bind(auiGridPayment, "cellEditEnd", function(event){
			if(event.dataField == "payment_asset_owner_cd"){
				if(event.item.payment_asset_owner_cd == '01' || event.item.payment_asset_owner_cd == '04'){
					AUIGrid.updateRow(auiGridPayment, { "payment_use_org_code" : ""}, event.rowIndex);
				}else if(event.item.payment_asset_owner_cd == '02' || event.item.payment_asset_owner_cd == '03'){
					AUIGrid.updateRow(auiGridPayment, { "payment_use_mem_no" : ""}, event.rowIndex);
					AUIGrid.updateRow(auiGridPayment, { "payment_use_mem_name" : ""}, event.rowIndex);
				}
			}
		});
		*/

	}
	

	/* 15288 목록에선 수정할 수 없도록 변경 (변동이력에서 처리하도록 유도)
	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField){
		if(headerText == '보관처'){
			if(item.payment_asset_owner_cd == '01' || item.payment_asset_owner_cd == '04'){
				return "aui-center";
			}else if(item.payment_asset_owner_cd == '02' || item.payment_asset_owner_cd == '03'){
				return "aui-background-darkgray";
			}
		}else if(headerText == '보관부서'){
			if(item.payment_asset_owner_cd == '01' || item.payment_asset_owner_cd == '04'){
				return "aui-background-darkgray";
			}else if(item.payment_asset_owner_cd == '02' || item.payment_asset_owner_cd == '03'){
				return "aui-center";
			}
		}
	}
	 */
	
	function createauiGridCar(){
		var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : true,
		};
		var columnLayout = [
			{
				headerText : "차량코드", 
				dataField : "car_car_code", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "차량번호", 
				dataField : "car_car_no", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "더존관리", 
				dataField : "car_douzon_code", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "업무차량코드", 
				dataField : "car_biz_car_code", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "부서코드", 
				dataField : "car_org_code", 
				editable : false,
				visible : false,
			},
			{
				headerText : "부서", 
				dataField : "car_org_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
				renderer : {
					type : "TemplateRenderer",
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					var template = '<div><div style="width:60%;display: inline-block;">'+value+'</div><div style="width:20%;display: inline-block;">';
					template += '<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:setMember(\'auiGridCar\','+rowIndex+');">';
					template +='<i class="material-iconssearch"></i></button></div></div>';
						
					return template;
				}
			},
			{
				headerText : "사용자번호", 
				dataField : "car_mem_no", 
				editable : false,
				visible : false,
			},
			{
				headerText : "사용자명", 
				dataField : "car_mem_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "소유구분", 
				dataField : "car_comp_own_yn", 
				width : "60",
				minWidth : "60",
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex,columnIndex, value, headerText, item){
					if(value == 'Y'){
						return "회사";
					}
					return "개인";
				}
			},
			{
				headerText : "보험사", 
				dataField : "car_car_insure_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "보험기간", 
				children:[
					{
						headerText : "시작일", 
						dataField : "car_insure_st_dt", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						dataType : "date",
						formatString : "yy-mm-dd", 
						editable : false,
					},
					{
						headerText : "종료일", 
						dataField : "car_insure_ed_dt", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						dataType : "date",
						formatString : "yy-mm-dd", 
						editable : false,
					},
				],
			},
			{
				headerText : "보험연령", 
				dataField : "car_car_insure_age_name", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "검사기간", 
				children:[
					{
						headerText : "시작일", 
						dataField : "car_check_st_dt", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						dataType : "date",
						formatString : "yy-mm-dd", 
						editable : false,
					},
					{
						headerText : "종료일", 
						dataField : "car_check_ed_dt", 
						width : "70",
						minWidth : "70",
						style : "aui-center",
						dataType : "date",
						formatString : "yy-mm-dd", 
						editable : false,
					},
				],
			},
			{
				headerText : "하이패스", 
				dataField : "car_card_code", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "비고", 
				dataField : "car_remark", 
				width : "200",
				minWidth : "200",
				style : "aui-left",
				editable : false,
			},
			{
				headerText : "등록일", 
				dataField : "car_reg_date", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				dataType : "date",
				formatString : "yy-mm-dd", 
				editable : false,
			},
			{
				headerText : "cmd", 
				dataField : "car_cmd", 
				visible : false,
			},
		];
		
		auiGridCar = AUIGrid.create("#auiGridCar", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridCar, ${carList});
	}
	
	function createauiGridCard(){
		var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : true,
		};
		var columnLayout = [
			{
				headerText : "관리코드", 
				dataField : "card_card_code", 
				width : "70",
				minWidth : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "카드번호", 
				dataField : "card_card_no", 
				width : "150",
				minWidth : "150",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "카드명", 
				dataField : "card_card_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "카드종류", 
				dataField : "card_card_type_dm", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(value == 'D'){
						return "부서";
					}else{
						return "개인";
					}
				}
			},
			{
				headerText : "부서코드", 
				dataField : "card_org_code", 
				editable : false,
				visible : false,
			},
			{
				headerText : "부서", 
				dataField : "card_org_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
				renderer : {
					type : "TemplateRenderer",
				},
				labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
					if(value == undefined){
						var template = '<div><div style="width:60%;display: inline-block;"></div><div style="width:20%;display: inline-block;">';
						template += '<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:setMember(\'auiGridCard\','+rowIndex+');">';
						template +='<i class="material-iconssearch"></i></button></div></div>';
					}else{
						var template = '<div><div style="width:60%;display: inline-block;">'+value+'</div><div style="width:20%;display: inline-block;">';
						template += '<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:setMember(\'auiGridCard\','+rowIndex+');">';
						template +='<i class="material-iconssearch"></i></button></div></div>';
					}
					return template;
				}
			},
			{
				headerText : "사용자번호", 
				dataField : "card_mem_no", 
				editable : false,
				visible : false,
			},
			{
				headerText : "사용자명", 
				dataField : "card_mem_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "계정아이디", 
				dataField : "card_web_id", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "사번", 
				dataField : "card_emp_id", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "비고", 
				dataField : "card_remark", 
				width : "200",
				minWidth : "200",
				style : "aui-left",
				editable : false,
			},
			{
				headerText : "cmd", 
				dataField : "card_cmd", 
				visible : false,
			},
		];
		
		auiGridCard = AUIGrid.create("#auiGridCard", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridCard, ${cardList});
	}
	
	function createauiGridToDo(){
		var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : true,
		};
		var columnLayout = [
			{
				headerText : "todo_as_todo_seq", 
				dataField : "todo_as_todo_seq", 
				visible : false,
			},
			{
				headerText : "todo_as_no", 
				dataField : "todo_as_no", 
				visible : false,
			},
			{
				headerText : "todo_as_todo_status_cd", 
				dataField : "todo_as_todo_status_cd", 
				visible : false,
			},
			{
				headerText : "todo_as_todo_type_cd", 
				dataField : "todo_as_todo_type_cd", 
				visible : false,
			},
			{
				headerText : "todo_machine_seq", 
				dataField : "todo_machine_seq", 
				visible : false,
			},
			{
				headerText : "todo_assign_mem_no", 
				dataField : "todo_assign_mem_no", 
				visible : false,
			},
			{
				headerText : "todo_m_ref_key", 
				dataField : "todo_m_ref_key", 
				visible : false,
			},
			{
				headerText : "todo_delay_dt", 
				dataField : "todo_delay_dt", 
				visible : false,
			},
			{
				headerText : "todo_todo_dt", 
				dataField : "todo_todo_dt", 
				visible : false,
			},
			{
				headerText : "todo_plan_dt", 
				dataField : "todo_plan_dt", 
				visible : false,
			},
			{
				headerText : "정비일", 
				dataField : "todo_show_todo_dt", 
				width : "100",
				minWidth : "100",
				dataType : "date",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "상담구분", 
				dataField : "todo_service_type", 
				width : "120",
				minWidth : "120",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "고객명", 
				dataField : "todo_cust_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "모델명", 
				dataField : "todo_machine_name", 
				width : "120",
				minWidth : "120",
				editable : false,
			},
			{
				headerText : "차대번호", 
				dataField : "todo_body_no", 
				width : "120",
				minWidth : "120",
				editable : false,
			},
			{
				headerText : "휴대폰", 
				dataField : "todo_hp_no", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "담당자", 
				dataField : "todo_assign_mem_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "작업구분", 
				dataField : "todo_as_todo_status_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "미결사항", 
				dataField : "todo_todo_text", 
				width : "200",
				minWidth : "200",
				style : "aui-left",
				editable : false,
			},
			{
				headerText : "예정일", 
				dataField : "todo_show_plan_dt", 
				width : "100",
				minWidth : "100",
				dataType : "date",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "cmd", 
				dataField : "todo_cmd", 
				visible : false,
			},
		];
		
		auiGridToDo = AUIGrid.create("#auiGridToDo", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridToDo, ${toDoList});
	}

	// 그리드 생성 - 미수담당 고객
	function createAUIGridMisu() {
		var gridPros = {
			editable : false,
		};

		var columnLayout = [
			{
				headerText: "고객번호",
				dataField: "misu_cust_no",
				width : "20%",
				style : "aui-center",
			},
			{
				headerText: "이름",
				dataField: "misu_cust_name",
				width : "15%",
				style : "aui-center",
			},
			{
				headerText: "지역",
				dataField: "misu_addr1",
				width: "50%",
				style : "aui-left",
			},
			{
				headerText: "센터",
				dataField: "misu_org_kor_name",
				style : "aui-center",
			},
		];
		auiGridMisu = AUIGrid.create("#auiGridMisu", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridMisu, ${misuList});
		$("#auiGridMisu").resize();
	}
	
	function setMember(auiName,rowIndex){
		$M.setValue("rowIndex",rowIndex);
		$M.setValue("auiName",auiName);
		openMemberOrgPanel('setMemberOrgMapPanel','N');
	}
	
	function setMemberOrgMapPanel(row){
		var auiName = $M.getValue("auiName");
		if(auiName == 'auiGridPayment'){
		    AUIGrid.updateRow(auiGridPayment, { "payment_use_mem_no" : row.mem_no }, $M.getValue("rowIndex"));
		    AUIGrid.updateRow(auiGridPayment, { "payment_use_mem_name" : row.mem_name }, $M.getValue("rowIndex"));
		}else if(auiName == 'auiGridCar'){
		    AUIGrid.updateRow(auiGridCar, { "car_mem_no" : row.mem_no }, $M.getValue("rowIndex"));
		    AUIGrid.updateRow(auiGridCar, { "car_mem_name" : row.mem_name }, $M.getValue("rowIndex"));
		    AUIGrid.updateRow(auiGridCar, { "car_org_code" : row.org_code }, $M.getValue("rowIndex"));
		    AUIGrid.updateRow(auiGridCar, { "car_org_name" : row.org_name }, $M.getValue("rowIndex"));
		}else if(auiName == 'auiGridCard'){
		    AUIGrid.updateRow(auiGridCard, { "card_mem_no" : row.mem_no }, $M.getValue("rowIndex"));
		    AUIGrid.updateRow(auiGridCard, { "card_mem_name" : row.mem_name }, $M.getValue("rowIndex"));
		    AUIGrid.updateRow(auiGridCard, { "card_org_code" : row.org_code }, $M.getValue("rowIndex"));
		    AUIGrid.updateRow(auiGridCard, { "card_org_name" : row.org_name }, $M.getValue("rowIndex"));
		}
	}
	
	function goSave(){
		var frm = $M.toValueForm(document.main_form);

		// validation
		if (!$M.validation(null, {field: ["yiguan_mem_no"]})) {
			return;
		}

		var concatCols = [];
		var concatList = [];
		var gridIds = [auiGridPayment, auiGridCar, auiGridCard];
		// var gridIds = [auiGridPayment, auiGridCar, auiGridCard, auiGridToDo];
		for(var i = 0; i < gridIds.length; ++i){
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);
		console.log(gridFrm);
		$M.goNextPageAjaxSave(this_page + "/save", gridFrm , {method : 'POST'},
			function(result){
				if(result.success){
	    			if (opener != null) {
						opener.goCheckPayment($M.getValue("s_mem_no"),$M.getValue("s_row"),1);
					}
					window.close();
				}
			}
		);
	}
	
	function setToDoMem(){
		openMemberOrgPanel('setToDoMemNo','N');
	}
	
	function setSaleAreaMem(){
		openMemberOrgPanel('setSaleAreaMemNo','N');
	}
	
	function setToDoMemNo(data){
		$M.setValue("todo_mem_no",data.mem_no);
		$M.setValue("todo_mem_name",data.mem_name);
		$M.setValue("s_todo_mem_no",data.mem_name);
	}
	
	function setSaleAreaMemNo(data){
		$M.setValue("service_mem_no",data.mem_no);
		$M.setValue("s_sale_area_mem_no",data.mem_name);
	}
	
	function fnClose(){
		window.close();
	}

	// 이관될 미수담당자 세팅
	function setMisuMemNo(data) {
		$M.setValue("misu_mem_name", data.mem_name);
		$M.setValue("misu_mem_no", data.mem_no);
	}

	// 자산지급품 사후관리변동이력 결과
	function fnSetAssetPaymentLogInfo(data) {
		AUIGrid.updateRow(auiGridPayment, { "payment_asset_payment_log_cnt" : data.asset_payment_log_count }, gridRowIndex);
	}

	// 15288 변동이력에서 gosearch() 호출 시 새로고침처리
	function goSearch() {
		window.location.reload();
	}

	// [14626] 퇴사자 업무 이관 담당자 직원 조회 후 세팅 - 김경빈
	function setYiguanMemNo(data){
		$M.setValue("yiguan_mem_name", data.mem_name);
		$M.setValue("yiguan_mem_no", data.mem_no);
	}
</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="rowIndex" name="rowIndex"/>
<input type="hidden" id="auiName" name="auiName"/>
<input type="hidden" id="s_mem_no" name="s_mem_no" value="${inputParam.s_mem_no}"/>
<input type="hidden" id="s_row" name="s_row" value = "${inputParam.s_row}"/>
<input type="hidden" id="sale_area_code_str" name="sale_area_code_str" value="${saleMap.codeStr }">
<input type="hidden" id="service_mem_no" name="service_mem_no" value="">
<input type="hidden" id="todo_mem_no" name="todo_mem_no" value="" alt="서비스 미결 이관 담당자">
<input type="hidden" id="todo_mem_name" name="todo_mem_name" value="">
<input type="hidden" id="end_dt" name="end_dt" value="${inputParam.end_dt}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 물품변경 -->						
            <div class="title-wrap">
                <h4>물품변경</h4>			
            </div>				
			<div id="auiGridPayment" style="margin-top: 5px; height: 200px;"></div>			
<!-- /물품변경 -->
<!-- 법인차량 -->						
            <div class="title-wrap mt10">
                <h4>법인차량</h4>			
            </div>				
			<div id="auiGridCar" style="margin-top: 5px; height: 100px;"></div>			
<!-- /법인차량 -->
<!-- 법인카드 -->						
            <div class="title-wrap mt10">
                <h4>법인카드</h4>			
            </div>				
			<div id="auiGridCard" style="margin-top: 5px; height: 150px;"></div>		
<!-- /법인카드 -->
<!-- [14626] 퇴사자 이관 로직 통합으로 인한 [서비스 미결 이관], [미수담당 이관], [담당지역 이관] 삭제 - 김경빈 -->
<!-- 서비스 미결 이관 -->
			<!-- <div class="title-wrap mt10">
                <h4 style="display:inline-block;">서비스 미결 이관</h4>
                <div>
                    담당자 이관
                    <input type="text" id="s_todo_mem_no" name="s_todo_mem_no" readonly="readonly">
                 <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:setToDoMem();"><i class="material-iconssearch"></i></button>
                </div>
            </div>
            <div id="auiGridToDo" style="margin-top: 5px; height: 150px;"></div> -->
<!-- /서비스 미결 이관 -->
<!-- 미수담당 이관 -->
			<!-- <div class="title-wrap mt10">
				<h4 style="display:inline-block;">미수담당 이관</h4>
				<div>
					담당자 이관
					<input type="hidden" id="misu_mem_no" name="misu_mem_no" value="" alt="미수담당 이관 담당자">
					<input type="text" id="misu_mem_name" name="misu_mem_name" readonly="readonly">
					<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('setMisuMemNo');"><i class="material-iconssearch"></i></button>
				</div>
			</div>
			<div id="auiGridMisu" style="margin-top: 5px; height: 150px;"></div> -->
<!-- /미수담당 이관 -->
<!-- 담당지역 이관 -->
			<!-- <div class="title-wrap">
                <div>
                <h4>담당지역 이관</h4>
                <table class="table-border mt5" style="width:400px;">
                	<thead>
                		<tr>
                			<th>담당구역</th>
                			<th>담당자 이관</th>
                		</tr>
                	</thead>
                	<tbody>
                		<tr>
	               			<td>
		               			${saleMap.firstSi}
				                <c:if test="${saleMap.size > 1 }">
				               	외 ${saleMap.size-1 }구역
				                </c:if>
			                </td>
	               			<td>
	               				<input type="text" id="s_sale_area_mem_no" name="s_sale_area_mem_no" readonly="readonly" alt="담당구역 이관 담당자">
	               				<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:setSaleAreaMem();"><i class="material-iconssearch"></i></button>
			                </td>
	               		</tr>
                	</tbody>
                </table>	
                </div>
            </div> -->
<!-- /담당지역 이관 -->
<!-- [14626] 퇴사자 업무 이관 로직 통합 - 김경빈 -->
			<div class="mt10">
				<h4>담당자 이관</h4>
				<div class="table-border mt5" style="width: 100%; padding: 12px; height: 50px;">
					<input type="text" id="yiguan_mem_name" name="yiguan_mem_name" readonly="readonly" alt="이관 담당자">
					<input type="hidden" id="yiguan_mem_no" name="yiguan_mem_no" value="" alt="이관 담당자">
					<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('setYiguanMemNo', 'N');"><i class="material-iconssearch"></i></button>
					<span class="text-warning ml5">※ 담당자 지정 시 기안문서를 제외한 모든 진행중인 업무가 해당 담당자에게 이관됩니다.</span>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</div>	
</form>
</body>
</html>