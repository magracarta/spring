<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동처리 > null > 부품이동요청상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-06 10:01:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
			createAUIGridSend();
			fnStatusInit();
		});
		
		function fnStatusInit() {
			// 미처리량이 0이면 마감처리됨. 마감되면 이동처리, 삭제 불가능
			// 이동처리서 생성 시 수정, 이동처리요청 불가능
			if($M.getValue("mst_end_yn") == "N" && $M.getValue("mody_yn") == "Y") {
				$("#_goModify").removeClass("dpn");
				$("#_goTransProcess").removeClass("dpn");
				$("#_goRemove").removeClass("dpn");
			} else if ($M.getValue("mst_end_yn") == "N" && $M.getValue("mody_yn") != "Y") {
				$("#_goTransProcess").removeClass("dpn");
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			} else {
				$("#_goModify").addClass("dpn");
				$("#_goTransProcess").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			}
			
			if($M.getValue("mst_end_yn") == "Y") {
				// 권한에 따라 그리드 변경 (수정 중) 
				AUIGrid.hideColumnByDataField(auiGrid, "already_qty");
			}
			
		}
		
		// 행 추가
		function fnAdd() {
			if ($M.getValue("mst_from_warehouse_cd") == "") {
				alert("From창고를 선택해주세요.");
				$("#from_warehouse_grid").find(".combo-arrow").get(0).click();
				return;
			};
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
			fnSetCellFocus(auiGrid, colIndex, "part_no");

    		var item = new Object();
			// 그리드 필수값 체크
			if(fnCheckGridEmpty(auiGrid)) {
	    		item.part_trans_req = "";
	    		item.req_qty = 0;
	    		item.already_qty = 0;
	    		item.qty = 0;
	    		item.mi_proc_qty = 0;
	    		item.seq_no = 0;
	    		item.add_yn = "Y";
	    		item.part_use_yn = "Y";
				AUIGrid.addRow(auiGrid, item, "first");
			}; 
		}
		
		// 부품조회
		function goPartList() {
			var items = AUIGrid.getAddedRowItems(auiGrid);
			for (var i = 0; i < items.length; i++) {
				if (items[i].part_no == "") {
					alert("추가된 행을 입력하고 시도해주세요.");
					return;
				}
			}
			if ($M.getValue("mst_from_warehouse_cd") == "") {
				alert("From창고를 선택해주세요.");
				$("#from_warehouse_grid").find(".combo-arrow").get(0).click();
				return;
			};
			
			
// 			if($M.getValue("org_gubun_cd") == "CENTER") {
// 				onlyWarehouseYn = "Y";
// 			}
			
			var param = {
	    			 's_warehouse_cd' : $M.getValue('warehouse_cd'),
	    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
// 	    			 's_cust_no' : $M.getValue('cust_no')
	    	};
			
			openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
		}
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
			var params = AUIGrid.getGridData(auiGrid);
			// 부품조회 창에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", rowArr[i].part_no);
				 if (rowItems.length != 0){
					 return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";					 
				 }
			}
			
			var partNo ='';
			var partName ='';
			var unitPrice ='';
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					row.seq_no = 0;
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.qty = 0;
					row.req_qty = 0;
					row.mi_proc_qty = 0;
					row.current_stock = rowArr[i].part_warehouse_current;		// 전체 현재고가 아닌 소속창고의 현재고
					row.storage_name = rowArr[i].storage_name;
					AUIGrid.addRow(auiGrid, row, 'last');
				}
			}
		}
		
		
		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["part_no", "part_name", "qty"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		// 송장정보 갱신
		function fnNew() {
			var param = {
    			invoice_warehouse 		: "",	// 송장창고(to)
    			invoice_no 				: "",	// 송장번호
    			invoice_qty 			: "",	// 수량
    			receive_name 			: "", 	// 성명
    			receive_tel_no 			: "", 	// 전화번호
    			receive_hp_no 			: "",	// 핸드폰번호
    			invoice_remark			: "",	// 비고
    			invoice_money_cd 		: "",	// 송장비용방식 코드
    			invoice_send_cd 		: "0",	// 송장발송구분 코드(방문)
    			invoice_post_no			: "",	// 우편번호
    			invoice_addr1 			: "",	// 주소1
    			invoice_addr2 			: "",	// 주소2
    			invoice_address 		: "",	// 주소
			}
			$M.setValue(param);
		}
		
		function goStockDtlPopup() {
			  
			var param = {
				machine_doc_no : $M.getValue("machine_doc_no"),
			}
			
			var popupOption = "";
			$M.goNextPage('/sale/sale0101p09', $M.toGetParam(param), {popupStatus : popupOption});
			
		}
		
		// 그리드생성
		function createAUIGrid() {
			// 상세 모드
			var modiYn = $M.getValue("mody_yn");
			
			var	gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				showStateColumn : false,
				editable : false,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : true,
				rowIdTrustMode : true
			};
			
			var endYn = $M.getValue("mst_end_yn");
			
			if(endYn == 'N') {
				gridPros.editable = true;
				gridPros.showStateColumn = true;
			};
			
			if(modiYn != "Y") {
				gridPros.editable = false;
				gridPros.showStateColumn = false;
			}
			
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "15%",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (modiYn == "Y" && endYn == 'N' && item.add_yn == "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
					editRenderer : {
						type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
								s_search_kind : "DEFAULT_PART",
								s_warehouse_cd : $M.getValue("mst_from_warehouse_cd"),
								's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
				    			's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param);
						},
					},
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "18%",
					style : "aui-left",
					editable : false 
				},
				{
					headerText: "가용재고",
					dataField: "current_able_stock",
					width : "5%",
					style : "aui-center aui-popup",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
				},
				{
				    headerText: "요청수량",
				    dataField: "req_qty",
					width : "5%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (endYn == 'N' && item.add_yn == "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{
				    headerText: "처리수량",
				    dataField: "qty",
					width : "7%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true, // 숫자만
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (endYn == 'N' && modiYn == "Y") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{
				    headerText: "미처리량",
				    dataField: "mi_proc_qty",
					width : "5%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
				},
				{
				    headerText: "기처리수량",
				    dataField: "already_qty",
					width : "6%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false 
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (endYn == 'N') {
							return "aui-editable"
						};
						return "aui-left";
					},
				},
				{
				    headerText: "저장위치", 
				    dataField: "storage_name",
					width : "12%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false && event.item["already_qty"] == 0) {
								AUIGrid.updateRow(auiGrid, {part_use_yn : "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
								
							} else if (isRemoved == false && event.item["already_qty"] != 0 ){
								alert("이미 처리된 부품이 있습니다.");
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
								AUIGrid.updateRow(auiGrid, {part_use_yn : "Y"}, event.rowIndex);
							};
						},
						visibleFunction : function(rowIndex, columnIndex, value, item, dataField) {
							if (endYn == 'N' && modiYn == "Y") {
								return true;
							};
							return false;
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					width : "7%",
					editable : false,
				},
				{
				    dataField: "part_trans_req_no",
				    visible : false, 
				},
				{
				    dataField: "part_trans_req_part_no",
				    visible : false, 
				},
				{
				    dataField: "orign_mi_proc_qty",
				    visible : false,
				},
				{
				    dataField: "seq_no",
				    visible : false,
				},
				{
				    dataField: "req_seq_no",
				    visible : false,
				},
				{
				    dataField: "add_yn",
				    visible : false,
				},
				{
				    dataField: "part_use_yn",
				    visible : false,
				},
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${transDtlList});
			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
			    if (event.dataField == "req_qty") {
			        // 추가된 행 아이템인지 조사하여 추가된 행인 경우만 에디팅 진입 허용
			        if (AUIGrid.isAddedById(auiGrid, event.item._$uid)) {
			            return true;
			        } else {
			            return false; // false 반환하면 기본 행위 안함(즉, cellEditBegin 의 기본행위는 에디팅 진입임)
			        }
			    }
			    return true; // 다른 필드들은 편집 허용
			});
			
			// 에디팅 시작 체크
			AUIGrid.bind(auiGrid, "cellEditBegin", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
			
			
			// 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var popupOption = "";
				var param = {
					"part_no" : event.item["part_no"]
				};
				// if(event.dataField == 'current_stock') {
				// 	$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
				// };
				// 23.06.29 가용재고 클릭 시 팝업 호출
				if(event.dataField == 'current_able_stock') {
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
				};
			});
		}
		
		// 서버로 보낼 그리드생성
		function createAUIGridSend() {
			
			var	gridPros = {
				rowIdField : "_$uid",
			};
			
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    dataField: "part_no",
				    visible : false
				},
				{
				    dataField: "seq_no",
				    visible : false
				},
				{
				    dataField: "proc_qty",
				    visible : false
				},
				{
				    dataField: "qty",
				    visible : false
				},
				{
				    dataField: "dtl_remark",
				    visible : false
				},
				{
				    dataField: "req_qty",
				    visible : false
				},
				{
				    dataField: "part_name",
				    visible : false
				},
				{
				    dataField: "part_trans_req_no",
				    visible : false
				},
				{
				    dataField: "req_part_no",
				    visible : false
				},
				{
				    dataField: "req_seq_no",
				    visible : false
				},
			];
		
			auiGridSend = AUIGrid.create("#auiGridSend", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridSend, []);
		}
		
		// part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
		function fnGetPartItem(part_no) {
			var item;
			$.each(recentPartList, function(index, row) {
				if(row.part_no == part_no) {
					item = row;
					return false; // 중지
				}
			});
	 		return item;
		 };
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
			switch(event.type) {
				case "cellEditEndBefore" :
					if(event.dataField == "part_no") {
						if (event.value == "") {
							return event.oldValue;							
						};
					};
				break;
				
				case "cellEditEnd" :
					if(event.dataField == "part_no") {
						if (event.value == ""){
							return "";
						}
						// remote renderer 에서 선택한 값
						var item = fnGetPartItem(event.value);
						console.log(item);
						if(item === undefined) {
							AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
						} else {
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
							AUIGrid.updateRow(auiGrid, {
								part_name : item.part_name,
								current_stock : item.part_warehouse_current,
								req_qty : 0,
								qty : 0,
								mi_proc_qty : 0,
								already_qty : 0,
								storage_name : item.storage_name,
							}, event.rowIndex);
						} 
				    } else if(event.dataField == "qty") {
						var qty   = event.value;
						var oldQty   = event.oldValue;
						var miQty = $M.nvl(event.item['orign_mi_proc_qty'], "");
						
						var reqQty = event.item["req_qty"];
						var alreadyQty = event.item["already_qty"];
						if(reqQty != 0 && qty > reqQty-alreadyQty) {
							alert("요청수량+기처리수량보다 큰 수량을 입력할 수 없습니다.\n" + reqQty + "보다 작거나 같은 수량을 입력하십시오.");
							AUIGrid.updateRow(auiGrid, { "qty" : oldQty }, event.rowIndex);
							if(miQty != "") {
								AUIGrid.updateRow(auiGrid, {"qty" : reqQty-alreadyQty}, event.rowIndex);
// 								AUIGrid.updateRow(auiGrid, {"mi_proc_qty" : 0}, event.rowIndex);
							};
							return false;
						} else {
							// 처리수량이 요청수량을 초과하지 않을 때
// 							AUIGrid.updateRow(auiGrid, {"mi_proc_qty" : reqQty-qty-alreadyQty}, event.rowIndex);
						}
						
						
					};
				break;
			} 
		};
		
		// 부품이동처리요청 등록
		function goTransProcess() {
			AUIGrid.setGridData(auiGridSend, []);
			
			if (fnCheckGridEmpty(auiGrid) === false){
				return false;
			};
			 
			var gridData = AUIGrid.getGridData(auiGrid);
			
			var sumQty = 0;
			for(var i=0, len=gridData.length; i<len; i++) {
				sumQty += gridData[i]["qty"];
			}
			
			if(sumQty === 0) {
				alert("처리수량을 입력해 주세요.");
				return;
			};
			
			var rowCount 	= AUIGrid.getRowCount(auiGrid);
			
			if(gridData.length < 1) {
				alert("처리예정목록에 부품이 없습니다.");
				return false;
			};

			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			
			var part_no = [];
			var seq_no 	= [];
			var qty 	= [];
			var reqQty 	= [];
			var remark 	= [];
			var useYn 	= [];
			var partName 	= [];
			
			var part_trans_req_no 		= [];
			var part_trans_req_part_no  = [];
			var part_trans_req_seq_no   = [];
			
			console.log(gridData);
			
			var sendDataList = [];
			
			for(var i = 0, n = gridData.length; i < n; i++) {
				if(gridData[i].part_use_yn = 'Y' && gridData[i].qty > 0) {
					
					var item = {
						part_no : gridData[i].part_no
						, seq_no : gridData[i].seq_no
						, proc_qty : gridData[i].qty
						, qty : gridData[i].qty
						, dtl_remark : gridData[i].remark
						, req_qty : gridData[i].req_qty
						, part_name : gridData[i].part_name
						
						, part_trans_req_no : gridData[i].part_trans_req_no
						, req_part_no : gridData[i].part_trans_req_part_no
						, req_seq_no : gridData[i].req_seq_no
					};
					
					sendDataList.push(item);
				}
			}
			
			var sendGridForm = AUIGrid.getGridData(auiGridSend);
			
			
			AUIGrid.setGridData(auiGridSend, sendDataList);
			var afterSendGridForm = AUIGrid.getGridData(auiGridSend);

			var gridForm = fnGridObjDataToForm(auiGridSend);
			$M.copyForm(gridForm, frm);
			
			$M.goNextPageAjaxMsg("이동처리 요청하시겠습니까?", this_page + "/partTransCmp/", gridForm, {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			alert("정상적으로 처리되었습니다.");
		    			location.reload();
		    			window.opener.goSearch();
					};
				}
			); 
		}
		
		// 부품이동처리요청 수정
		function goModify() {
			if (fnCheckGridEmpty(auiGrid) === false){
				return false;
			};
			 
			var gridData = AUIGrid.getGridData(auiGrid);
			var removedItems = AUIGrid.getRemovedItems(auiGrid);
			
			var sumQty = 0;
			for(var i=0, len=gridData.length; i<len; i++) {
				sumQty += gridData[i]["req_qty"];
			}
			
			if(sumQty === 0) {
				alert("요청수량을 입력해 주세요.");
				return;
			};
			
			var rowCount 	= AUIGrid.getRowCount(auiGrid);
			
			if(gridData.length < 1) {
				alert("처리예정목록에 부품이 없습니다.");
				return false;
			};

			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var part_no = [];
			var seq_no 	= [];
			var req_qty = [];
			var remark 	= [];
			var useYn 	= [];
			var partName 	= [];
			
			var part_trans_req_no 		= [];
			var part_trans_req_part_no  = [];
			var part_trans_req_seq_no   = [];
			
// 			console.log(gridData);
			for(var i = 0, n = gridData.length; i < n; i++) {
				part_no.push(gridData[i].part_no);
				seq_no.push(gridData[i].seq_no);
				req_qty.push(gridData[i].req_qty);
				remark.push(gridData[i].remark);
				useYn.push(gridData[i].part_use_yn);
				partName.push(gridData[i].part_name);
				
				part_trans_req_no.push(gridData[i].part_trans_req_no);
				part_trans_req_part_no.push(gridData[i].part_trans_req_part_no);
				part_trans_req_seq_no.push(gridData[i].req_seq_no);
			}
			
			var option = {
				isEmpty : true
			};
			
			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no, option));
			$M.setValue(frm, "seq_no_str", 	$M.getArrStr(seq_no, option));
			$M.setValue(frm, "req_qty_str", 	$M.getArrStr(req_qty, option));
			$M.setValue(frm, "dtl_remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(useYn, option));
			$M.setValue(frm, "part_name_str", $M.getArrStr(partName, option));

			$M.setValue(frm, "part_trans_req_no_str", 	$M.getArrStr(part_trans_req_no, option));
				

			$M.goNextPageAjaxMsg("이동요청서를 수정하시겠습니까?", this_page + "/modify", $M.toValueForm(frm), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			location.reload();
		    			window.opener.goSearch();
					};
				}
			); 
		}
		
	    // 배송정보 팝업
	    function goDeliveryInfo() {
	    	var endYn = $M.getValue("mst_end_yn");

	    	var params = {
    			send_invoice_seq	: $M.getValue("send_invoice_seq"),
    			to_warehouse_cd     : $M.getValue("mst_to_warehouse_cd"),
    			invoice_type_cd 	: $M.getValue("invoice_type_cd"),
    			invoice_money_cd	: $M.getValue("invoice_money_cd"),
    			invoice_send_cd 	: $M.getValue("invoice_send_cd"),
    			receive_name 		: $M.getValue("receive_name"),
    			invoice_no 			: $M.getValue("invoice_no"),
    			receive_hp_no 		: $M.getValue("receive_hp_no"),
    			receive_tel_no 		: $M.getValue("receive_tel_no"),
    			qty 				: $M.getValue("invoice_qty"),
    			remark 				: $M.getValue("invoice_remark"),
    			post_no 			: $M.getValue("invoice_post_no"),
    			addr1				: $M.getValue("invoice_addr1"),
    			addr2				: $M.getValue("invoice_addr2"),
    			show_yn 			: endYn == "Y" ? 'Y' : '',
	    	};
	    	

	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }
	    
	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	fnNew();
	    	$M.setValue(data);
			$M.setValue("invoice_warehouse", $M.getValue("mst_to_warehouse_cd"));
			$M.setValue("invoice_address", data.invoice_addr1 + " " + data.invoice_addr2);
	    }
		
		
		function fnClose() {
			window.close();
		}
		
		function goRemove() {
			
			if($M.getValue("part_trans_no") != "") {
				alert("해당 요청서로 요청된 이동처리서가 있습니다.\n이동처리서를 삭제 후 진행해주세요.");
				return false;
			}
			
			var param = {
					"part_trans_req_no" : $M.getValue("mst_part_trans_req_no"),
					"send_invoice_seq" : $M.getValue("send_invoice_seq"),
					"preorder_inout_doc_no" : $M.getValue("preorder_inout_doc_no")
			}
			
			$M.goNextPageAjaxMsg("이동요청서를 삭제하시겠습니까?\n이동처리서가 있을 시 삭제할 수 없습니다.", this_page + "/remove", $M.toGetParam(param), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리되었습니다.");
		    			fnClose();
		    			window.opener.goSearch();
					};
				}
			); 
		}
		
		// 이동처리서 상세 페이지 오픈
		function goReferDetailPopup() {
			if($M.getValue("s_part_trans_no") == "") {
				alert("이동처리서가 없습니다.");
				return false;
			}
			var popupOption = "";
				var param = {
					"part_trans_no" : $M.getValue("s_part_trans_no")
				}
			$M.goNextPage("/part/part0202p03", $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 창고간 물류이동 인쇄
		function goTransPrint() {
			if($M.getValue("s_part_trans_no") == "") {
				alert("이동처리서가 없습니다.");
				return false;
			}
			openReportPanel('part/part0202p01_01.crf','part_trans_no=' + $M.getValue("s_part_trans_no"));
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
		<!-- 부품 이동 요청서 마감여부 -->
		<input type="hidden" id="mst_end_yn" name="mst_end_yn" value="${transMst.end_yn}">
		<!-- 부품이동상태코드 -->
		<input type="hidden" class="form-control" id="part_trans_status_cd"   name="part_trans_status_cd"   readonly="readonly" value="${transMst.part_trans_status_cd}">
		<!-- 부품이동타입 -->
		<input type="hidden" class="form-control" id="part_trans_req_type_cd"   name="part_trans_req_type_cd"   readonly="readonly" value="${transMst.part_trans_req_type_cd}">
		<input type="hidden" class="form-control" id="mody_yn"   name="mody_yn"   readonly="readonly" value="${mody_yn}">
		<!-- 처리완료 부품이동타입 -->
		<input type="hidden" id="transType" name="transType" value="${transMst.part_trans_type_cd}">
		<!-- 부품이동처리 완료 장비품의서번호 -->
		<input type="hidden" id="machine_doc_no" name="machine_doc_no" value="${transMst.machine_doc_no}">
		<!-- 부품이동처리 완료 장비품의서번호 -->
		<input type="hidden" id="part_trans_no" name="part_trans_no" value="${transMst.part_trans_no}">
		<!-- 송장발송 -->
		<!-- 송장발송번호 -->
		<input type="hidden" name="send_invoice_seq" id="send_invoice_seq" value="${transMst.send_invoice_seq}"> 
		<!-- 송장창고(to창고) -->
		<input type="hidden" name="invoice_warehouse" id="invoice_warehouse" value="${transMst.invoice_warehouse}"> 
		<!-- 발송구분 송장발송구분(01:수주(정비)매출, 02:정비, 04:주문(이동요청), 05:수주, 08:출하부품, 99:창고이동)-->
		<input type="hidden" name="invoice_type_cd" id="invoice_type_cd" value="99">
		<!-- 송장번호 -->
		<input type="hidden" name="invoice_no" id="invoice_no" value="${transMst.invoice_no}">
		<!-- 수량 -->
		<input type="hidden" name="invoice_qty" id="invoice_qty" 	value="${transMst.invoice_qty}">
		<!-- 성명 -->
		<input type="hidden" name="receive_name" id="receive_name" value="${transMst.receive_name}">
		<!-- 전화번호 -->
		<input type="hidden" name="receive_tel_no" id="receive_tel_no" value="${transMst.receive_tel_no}">
		<!-- 핸드폰번호 -->
		<input type="hidden" name="receive_hp_no" id="receive_hp_no" value="${transMst.receive_hp_no}">
		<!-- 비고 -->	
		<input type="hidden" name="invoice_remark" id="invoice_remark" value="${transMst.invoice_remark}">		
		<!-- 송장비용방식코드 -->					
		<input type="hidden" name="invoice_money_cd" id="invoice_money_cd" value="${transMst.invoice_money_cd}">
		<!-- 우편번호 -->
		<input type="hidden" name="invoice_post_no" id="invoice_post_no" value="${transMst.invoice_post_no}">
		<!-- 주소1 -->
		<input type="hidden" name="invoice_addr1" id="invoice_addr1" value="${transMst.invoice_addr1}">
		<!-- 주소2 -->		
		<input type="hidden" name="invoice_addr2" id="invoice_addr2" value="${transMst.invoice_addr2}">
		<input type="hidden" name="part_trans_req_no" id="part_trans_req_no" value="${transMst.part_trans_req_no}">
		<input type="hidden" name="preorder_inout_doc_no" id="preorder_inout_doc_no" value="${transMst.preorder_inout_doc_no}">
		<!-- // 송장발송 -->
		
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
			<!-- 상세페이지 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /상세페이지 타이틀 -->
	        <div class="content-wrap">
				<div class="btn-group mt5" style="margin-bottom: 5px;">
					<div class="right" style="width:400px">
						<span style="font-weight:bold;">이동처리서 : </span>
						<span>
						<select class="form-control width140px" id="s_part_trans_no" name="s_part_trans_no" style="display:inline-block;">
							<c:forEach items="${TransNoList}" var="item">
							<option value="${item.part_trans_no}">${item.part_trans_no}</option>
							</c:forEach>
						</select>
						</span>
						<span>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</span>
					</div>
				</div>
				<!-- 폼테이블 -->	
					<!-- 이동요청서 상세 -->
					<!-- 상단 폼테이블 -->	
					<div>
						<table class="table-border">
							<colgroup>
								<col width="70px">
								<col width="">
								<col width="60px">
								<col width="">
								<col width="80px">
								<col width="80px">
								<col width="70px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">처리일자</th>
									<td colspan="4">
										<div class="form-row">
											<div class="col width100px" style="padding-right: 0;">
												<input type="text" class="form-control" id="reg_dt" name="reg_dt" dateformat="yyyy-MM-dd" alt="요청일" value="${inputParam.s_current_dt}" readonly="readonly" onclick="this.blur()">
											</div>
										</div>
									</td>
									<th class="text-right">이동요청번호</th>
									<td colspan="3">
										<input type="text" class="form-control width120px" id="mst_part_trans_req_no" name="mst_part_trans_req_no" value="${transMst.part_trans_req_no}" readonly="readonly">
									</td>
								</tr>
								<tr>
									<th class="text-right">이동창고</th>
									<td colspan="4">
										<div class="form-row">
										<c:choose>
										<c:when test="${transMst.end_yn eq 'Y'}">
											<div class="col-2">
												<input type="text" class="form-control" value="${transMst.from_warehouse_name}" readonly="readonly">
												<input type="hidden" value="${transMst.from_warehouse_cd}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
											</div>
											<div class="auto">
												에서
											</div>
											<div class="col-2">
												<input type="text" class="form-control" value="${transMst.to_warehouse_name}" readonly="readonly">
												<input type="hidden" value="${transMst.to_warehouse_cd}" id="mst_to_warehouse_cd" name="mst_to_warehouse_cd" readonly="readonly">
											</div>
											<div class="col-auto">
												로 이동
											</div>
											</c:when>
										<c:when test="${end_yn eq 'N'}">
											<c:choose>
												<c:when test="${page.fnc.F01181_001 eq 'Y'}">
													<div class="col-4" id="from_warehouse_grid">
														<div class="input-group">
															<input type="text" style="width : 200px";
																value="${transMst.from_warehouse_cd}"
																id="mst_from_warehouse_cd" 
																name="mst_from_warehouse_cd" 
																idfield="code_value"
																easyui="combogrid"
																header="Y"
																easyuiname="fromWarehouseList" 
																panelwidth="200"
																maxheight="155"
																enter=""
																textfield="code_name"
																multi="N"/>
														</div>
													</div>
													<div class="col-1">
														에서
													</div>
													<div class="col-4" id="to_warehouse_grid">
														<div class="input-group">
															<input type="text" style="width : 200px";
																value="${transMst.to_warehouse_cd}"
																id="mst_to_warehouse_cd" 
																name="mst_to_warehouse_cd"
																alt="to창고"  
																idfield="code_value"
																easyui="combogrid"
																header="Y"
																easyuiname="toWarehouseList" 
																panelwidth="200"
																maxheight="155"
																enter="toWarehouseCheck()"
																textfield="code_name"
																multi="N"/>
														</div>
													</div>
													<div class="col-auto">
														로 이동
													</div>
												</c:when>
												
												<c:when test="${page.fnc.F01181_002 eq 'Y'}">
													<div class="col-2">
														<div class="col width100px" style="padding-right: 0;">
															<input type="text" class="form-control" value="${transMst.from_warehouse_name}" readonly="readonly">
															<input type="hidden" value="${transMst.from_warehouse_cd}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
														</div> 
													</div>
													<div class="col-auto">
														에서
													</div>
													<div class="col-2">
														<div class="col width100px" style="padding-right: 0;">
															<input type="text" class="form-control" value="${transMst.to_warehouse_name}" readonly="readonly">
															<input type="hidden" value="${transMst.to_warehouse_cd}" id="mst_to_warehouse_cd" name="mst_to_warehouse_cd" readonly="readonly">
														</div> 
													</div>
													<div class="col-auto">
														로 이동
													</div>
												</c:when>
												<c:when test="${page.fnc.F01181_003 eq 'Y'}">
													<div class="col-2">
														<div class="col width100px" style="padding-right: 0;">
															<input type="text" class="form-control" value="${transMst.from_warehouse_name}" readonly="readonly">
															<input type="hidden" value="${transMst.from_warehouse_cd}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
														</div> 
													</div>
													<div class="col-auto">
														에서
													</div>
													
													<div class="col-4" id="to_warehouse_grid">
														<div class="input-group">
															<input type="text" style="width : 200px";
																value="${transMst.to_warehouse_cd}"
																id="mst_to_warehouse_cd" 
																name="mst_to_warehouse_cd"
																alt="to창고"  
																idfield="code_value"
																easyui="combogrid"
																header="Y"
																easyuiname="toWarehouseList" 
																panelwidth="200"
																maxheight="155"
																enter="toWarehouseCheck()"
																textfield="code_name"
																multi="N"/>
														</div>
													</div>
													로 이동
												</c:when>
											</c:choose>
											</c:when>
											</c:choose>
										</div>
									</td>
									<th class="text-right" rowspan="2">비고</th>
									<td colspan="3" rowspan="2">
										<textarea class="form-control" id="mst_remark" name="mst_remark" maxlength="200" style="height: 100%;">${transMst.remark}</textarea>
									</td>
								</tr>							
								<tr>
									<th class="text-right essential-item">발송구분</th>
									<td colspan="4">
										<div class="form-row inline-pd">
											<div class="col-2">
												<select class="form-control width100px essential-bg" id="invoice_send_cd" name="invoice_send_cd" required="required" alt="전송구분">
													<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
													<option value="${item.code_value}" ${item.code_value == transMst.invoice_send_cd ? 'selected' : '' }>${item.code_name}</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-1.5">
												<button type="button" class="btn btn-primary-gra width100px" onclick="javascript:goDeliveryInfo();">배송정보설정</button>
											</div>
											<div class="col-8">
												<input type="text" class="form-control" maxlength="200" id="invoice_address" name="invoice_address" value="${transMst.invoice_address}" readonly="readonly">
											</div>
										</div>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
					<!-- /상단 폼테이블 -->
	
					<!-- 하단 폼테이블 -->		
					<div class="row">					
						<div class="col" style="width: 100%;">
							<div class="title-wrap mt5">
								<h4>처리예정목록</h4>
									<div class="btn-group">
										<div class="right">
										<c:if test="${end_yn eq 'Y'}">
										<span class="text-danger">&#91;마감완료&#93;</span> <!-- dpn으로 show/hide -->
										</c:if>
									<c:if test="${transMst.complete_yn eq 'Y' && transMst.end_yn eq 'N' && mody_yn eq 'Y'}">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									</c:if>
										</div>
									</div>
							</div>
							<div id="auiGrid" style="margin-top: 5px; height: 300px;width:100%;"></div>
							<!-- 데이터 전송용도 그리드 -->
							<div id="auiGridSend" class="dpn"></div>
						</div>
					</div>
					<!-- /하단 폼테이블 -->	
					<!-- /이동요청서 상세 -->
					<!-- /폼테이블 -->
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