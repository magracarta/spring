<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동처리 > null > 부품이동처리상세
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
			fnStatusInit();
		});
		
		function fnStatusInit() {
			// 수동입력이 아닐때는 수정 불가
			if($M.getValue("transType") != "IN") {
				$("#_goModify").addClass("dpn");
				$("#_goSave").addClass("dpn");
				$("#_goRemove").addClass("dpn");
				$("#_fnAdd").addClass("dpn");
				$("#_goTransProcess").addClass("dpn");
			} else if ($M.getValue("transType") == "IN" && $M.getValue("part_trans_status_cd") != "04") {
				$("#_goModify").removeClass("dpn");
				$("#_goSave").removeClass("dpn");
				$("#_goRemove").removeClass("dpn");
				$("#_fnAdd").removeClass("dpn");
			} else if($M.getValue("transType") == "IN" && $M.getValue("part_trans_status_cd") == "04") {
				$("#_goModify").addClass("dpn");
				$("#_goSave").addClass("dpn");
				$("#_goRemove").removeClass("dpn");
				$("#_fnAdd").addClass("dpn");
				$("#_goTransProcess").addClass("dpn");
			}
			// 이동요청일 때
			if($M.getValue("transType") == "REQ" && $M.getValue("part_trans_status_cd") != "04") {
				$("#_goTransProcess").removeClass("dpn");
				$("#_goRemove").removeClass("dpn");
			} else if ($M.getValue("transType") == "REQ" && $M.getValue("part_trans_status_cd") == "04") {
				$("#_goTransProcess").addClass("dpn");
				$("#_goRemove").removeClass("dpn");
			}
			
			// 보내는 창고가 입고창고일 경우면 입고참조 보임
			if($M.getValue("mst_from_warehouse_cd") == "9142") {
				$("#_goInWarehousePopup").removeClass("dpn")
		  		if($M.getValue("part_trans_status_cd") != "04") {
					$('#mst_from_warehouse_cd').combogrid("setText", "입고창고");
			  		$('#mst_from_warehouse_cd').combogrid('disable');
		  		}
			} else {
				$("#_goInWarehousePopup").addClass("dpn")
			}
			
		}
		
		// 참조쪽지
		function goSendPaper() {
			
			var paperContents = "【 부품발송요청】#"
				+	"이동처리번호 : " + $M.getValue("part_trans_no") + "#"
				+	"이동창고 : " + $M.getValue("paper_from_warehouse_name") + "→" + $M.getValue("paper_to_warehouse_name") + "#"
				+	"비고 : " + $M.getValue("mst_remark") + "#"
				+	"발송구분 : " + $M.getValue("invoice_send_name") + "#"
				+	"배송정보 : " +  $M.getValue("invoice_address") + "#"
				+	$M.getValue("receive_name") + " " + $M.getValue("receive_hp_no") + "#"
				+ "####"
				+	"자료조회버튼으로 참조자료를 확인하십시오 ." + "#";

			$M.setValue("paper_send_yn", "Y");
			$M.setValue("paper_contents", paperContents);
			
			
			var option = {
					isEmpty : true
			};
			
			var jsonObject = {
					"paper_send_yn" : $M.getValue("paper_send_yn"),
					"paper_contents" : $M.getValue("paper_contents"),
					"ref_key" : $M.getValue("part_trans_no"),
 					"receiver_mem_no_str" : "",	// 참조자
 					"refer_mem_no_str" : "",		// 수신자
 					"menu_seq" : "${page.menu_seq}",
 					"pop_get_param" : "part_trans_no="+$M.getValue("part_trans_no")
			}
			openSendPaperPanel(jsonObject);
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
	    		item.qty = 0;
	    		item.seq_no = 0;
	    		item.add_yn = "Y";
	    		item.part_use_yn = "Y";
				AUIGrid.addRow(auiGrid, item, "first");
			}; 
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
// 			var transReqType = $M.getValue("part_trans_req_type_cd");
			
			var	gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				showStateColumn : false,
				editable : false,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : true,
				rowIdTrustMode : true
			};
			
			var partTransStatusCd = $M.getValue("part_trans_status_cd");
			
			// 수동입력이면서 완료가 아닐때만 수정 가능
			if($M.getValue("transType") == "IN" && partTransStatusCd != '04') {
				gridPros.editable = true;
				gridPros.showStateColumn = true;
			};
			
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "15%",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ($M.getValue("transType") == "IN" && partTransStatusCd != '04') {
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
					width : "20%",
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
						if ($M.getValue("transType") == "IN" && partTransStatusCd != "04") {
							return "aui-editable"
						};
						return "aui-center";
					},
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if ($M.getValue("transType") == "IN" && partTransStatusCd != '04' && item.add_yn == "Y") {
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
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGrid, {part_use_yn : "N"}, event.rowIndex);					
								AUIGrid.removeRow(event.pid, event.rowIndex);			
							} else if (isRemoved == true){
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
								AUIGrid.updateRow(auiGrid, {part_use_yn : "Y"}, event.rowIndex);					
							};
						},
						visibleFunction : function(rowIndex, columnIndex, value, item, dataField) {
							if ($M.getValue("transType") == "IN" && partTransStatusCd != '04') {
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
			   	if(event.dataField == "part_no" && transReqType != "IN" && partTransStatusCd != '04') {
			   		return false;
			   	}
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
				if(event.dataField == 'current_able_stock') {
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
				};
			});
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
								qty : 0,
								storage_name : item.storage_name,
							}, event.rowIndex);
						} 
				    } 
				break;
			} 
		};
		
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
		
		// 인쇄
		function goPrint() {
			openReportPanel('part/part0202p01_01.crf','part_trans_no=' + $M.getValue("part_trans_no"));
		}
		
		// 이동처리서 삭제
		function goRemove() {
			
			var gridData = AUIGrid.getGridData(auiGrid);
			
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			if(gridData.length > 0) {
				
				var part_no = [];
				var seq_no 	= [];
				var qty 	= [];
				var remark 	= [];
				
				var part_trans_req_no 		= [];
				var part_trans_req_part_no  = [];
				var part_trans_req_seq_no   = [];
				
				
				for(var i = 0, n = gridData.length; i < n; i++) {
					if(gridData[i].qty > 0) {
						part_no.push(gridData[i].part_no);
						seq_no.push(gridData[i].seq_no);
						qty.push(gridData[i].qty);
						remark.push(gridData[i].remark);
						part_trans_req_no.push(gridData[i].part_trans_req_no);
						part_trans_req_part_no.push(gridData[i].part_trans_req_part_no);
						part_trans_req_seq_no.push(gridData[i].req_seq_no);
					}; 
				}

				var option = {
					isEmpty : true
				};
				
				$M.setValue(frm, "part_no_str", $M.getArrStr(part_no, option));
				$M.setValue(frm, "seq_no_str", 	$M.getArrStr(seq_no, option));
				$M.setValue(frm, "qty_str", 	$M.getArrStr(qty, option));
				$M.setValue(frm, "dtl_remark_str", $M.getArrStr(remark, option));

				$M.setValue(frm, "part_trans_req_no_str", 	$M.getArrStr(part_trans_req_no, option));
				$M.setValue(frm, "req_part_no_str", 	$M.getArrStr(part_trans_req_part_no, option));
				$M.setValue(frm, "req_seq_no_str", 	$M.getArrStr(part_trans_req_seq_no, option));
				
			};
			
			$M.goNextPageAjaxMsg("이동처리서를 삭제하시겠습니까?", this_page + "/remove", $M.toValueForm(frm), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리되었습니다.");
		    			window.opener.goSearch();
		    			fnClose();
					};
				}
			); 
		}
	
		// 부품이동처리
		function goTransProcess() {
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
			
			var part_trans_req_no 		= [];
			var part_trans_req_part_no  = [];
			var part_trans_req_seq_no   = [];
			// 21.08.23 (Q&A 12269) 이원영 파트장님 요청으로 입고센터 -> 센터로 이동 시에만 마이너스 수량 가능하도록 수정
			for(var i = 0, n = gridData.length; i < n; i++) {
				if(gridData[i].part_use_yn = 'Y') {
					if(($M.getValue("mst_from_warehouse_cd") == "9142")
							|| ($M.getValue("mst_from_warehouse_cd") != "9142" && gridData[i].qty > 0)) {
						part_no.push(gridData[i].part_no);
						seq_no.push(gridData[i].seq_no);
						qty.push(gridData[i].qty);
						remark.push(gridData[i].remark);
						reqQty.push(gridData[i].req_qty);
							
						part_trans_req_no.push(gridData[i].part_trans_req_no);
						part_trans_req_part_no.push(gridData[i].part_trans_req_part_no);
						part_trans_req_seq_no.push(gridData[i].req_seq_no);
					}
				}
			}

			var option = {
				isEmpty : true
			};
			
			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no, option));
			$M.setValue(frm, "seq_no_str", 	$M.getArrStr(seq_no, option));
			$M.setValue(frm, "proc_qty_str", 	$M.getArrStr(qty, option));
			$M.setValue(frm, "qty_str", 	$M.getArrStr(qty, option));
			$M.setValue(frm, "dtl_remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "req_qty_str", $M.getArrStr(reqQty, option));

			$M.setValue(frm, "part_trans_req_no_str", 	$M.getArrStr(part_trans_req_no, option));
			$M.setValue(frm, "req_part_no_str", 	$M.getArrStr(part_trans_req_part_no, option));
			$M.setValue(frm, "req_seq_no_str", 	$M.getArrStr(part_trans_req_seq_no, option));
				
			$M.goNextPageAjaxMsg("이동처리 하시겠습니까?", this_page + "/partTrans", $M.toValueForm(frm), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			alert("정상적으로 처리되었습니다.");
		    			location.reload();
		    			window.opener.goSearch();
					};
				}
			); 
		}
		
		// 부품이동처리서 수정
		function goModify() {
			if (fnCheckGridEmpty(auiGrid) === false){
				return false;
			};
			 
			var gridData = AUIGrid.getGridData(auiGrid);
			var removedItems = AUIGrid.getRemovedItems(auiGrid);
			
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
			var qty = [];
			var remark 	= [];
			var useYn 	= [];
			
			var part_trans_req_no 		= [];
			var part_trans_req_part_no  = [];
			var part_trans_req_seq_no   = [];
			
			for(var i = 0, n = gridData.length; i < n; i++) {
				part_no.push(gridData[i].part_no);
				seq_no.push(gridData[i].seq_no);
				qty.push(gridData[i].qty);
				remark.push(gridData[i].remark);
				useYn.push(gridData[i].part_use_yn);
				
				part_trans_req_no.push(gridData[i].part_trans_req_no);
				part_trans_req_part_no.push(gridData[i].part_trans_req_part_no);
				part_trans_req_seq_no.push(gridData[i].req_seq_no);
			}
			
			
			var option = {
				isEmpty : true
			};
			
			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no, option));
			$M.setValue(frm, "seq_no_str", 	$M.getArrStr(seq_no, option));
			$M.setValue(frm, "qty_str", 	$M.getArrStr(qty, option));
			$M.setValue(frm, "dtl_remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(useYn, option));

			$M.setValue(frm, "part_trans_req_no_str", 	$M.getArrStr(part_trans_req_no, option));
			$M.setValue(frm, "req_part_no_str", 	$M.getArrStr(part_trans_req_part_no, option));
			$M.setValue(frm, "req_seq_no_str", 	$M.getArrStr(part_trans_req_seq_no, option));
				

			$M.goNextPageAjaxMsg("이동처리서를 수정하시겠습니까?", this_page + "/modify", $M.toValueForm(frm), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			location.reload();
		    			window.opener.goSearch();
					};
				}
			); 
		}
		
		function goInWarehousePopup() {
		  	openInWarehousePanel('setPartList');
		  }
		
		function setPartList(rowArr) {
			  console.log(rowArr);
		  	var partList = [];
				for (var i = 0; i < rowArr.length; i++ ) {
					partList[i] = {
						part_no : rowArr[i].part_no,
			    		part_name : rowArr[i].part_name,
			    		seq_no : 0,
						qty : rowArr[i].current_stock,
			    		remark : "",
			    		current_stock : rowArr[i].current_stock,
			    		storage_name : rowArr[i].storage_name,
			    		part_use_yn : "Y",
					}	
				}
				
		  	if(rowArr.length > 0) {
		  		$('#mst_from_warehouse_cd').combogrid("setValues", ${inWarehouseCd});  
		  		$('#mst_from_warehouse_cd').combogrid("setText", "입고창고");
		  		$('#mst_from_warehouse_cd').combogrid('disable');
		  		
		  		$M.setValue("mst_from_warehouse_cd", ${inWarehouseCd});
		  	};
				AUIGrid.addRow(auiGrid, partList, "last");
		}
		    
		    
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- <button type="button" onclick="javascript:goSendPaper();">test</button> -->
		<!-- 부품요청번호 -->
		<input type="hidden" class="form-control" id="part_trans_req_no"   name="part_trans_req_no"   readonly="readonly" value="${transMst.part_trans_req_no}">
		<!-- 부품상태타입 -->
		<input type="hidden" class="form-control" id="part_trans_status_cd"   name="part_trans_status_cd"   readonly="readonly" value="${transMst.part_trans_status_cd}">
		<!-- 부품이동타입 -->
		<input type="hidden" class="form-control" id="part_trans_req_type_cd"   name="part_trans_req_type_cd"   readonly="readonly" value="${transMst.part_trans_req_type_cd}">
		<!-- 요청서 or 처리완료 상세모드 -->
		<input type="hidden" id="searchMode" name="searchMode" value="${transMst.mode}">
		<!-- 처리완료 부품이동타입 -->
		<input type="hidden" id="transType" name="transType" value="${transMst.part_trans_type_cd}">
		<!-- 부품이동처리 완료 장비품의서번호 -->
		<input type="hidden" id="machine_doc_no" name="machine_doc_no" value="${transMst.machine_doc_no}">
		<input type="hidden" id="doc_barcode_no" name="doc_barcode_no" value="${transMst.doc_barcode_no}">
		
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
		<input type="hidden" name="invoice_send_name" id="invoice_send_name" value="${transMst.invoice_send_name}">
		<input type="hidden" name="paper_from_warehouse_name" id="paper_from_warehouse_name" value="${transMst.from_warehouse_name}">
		<input type="hidden" name="paper_to_warehouse_name" id="paper_to_warehouse_name" value="${transMst.to_warehouse_name}">
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
					<div class="right">
						<c:choose>
							<c:when test="${transMst.part_trans_type_cd eq 'STOCK_OUT'}">
								<button type="button" class="btn btn-primary-gra" onclick="javascript:goStockDtlPopup();">Stock출하의뢰서</button>
							</c:when>
						</c:choose>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<!-- 폼테이블 -->	
				
				<!-- 이동처리상세 -->
				<!-- 상단 폼테이블 -->	
				<div>
					<table class="table-border">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="60px">
							<col width="">
							<col width="80px">
							<col width="">
							<col width="70px">
							<col width="80px">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">이동처리번호</th>
								<td colspan="3">
									<div class="form-row">
										<div class="col" style="padding-right: 0;">
											<input type="text" class="form-control width120px" id="part_trans_no" name="part_trans_no" value="${transMst.part_trans_no}" readonly="readonly">
										</div>
									</div>
								</td>
								<th class="text-right">이동요청타입</th>
								<td colspan="2">
									<div class="form-row">
										<div class="col" style="padding-right: 0;">
											<input type="text" class="form-control width100px" id="part_trans_type_name" name="part_trans_type_name" value="${transMst.part_trans_type_name}" readonly="readonly">
										</div>
									</div>
								</td>
								<th class="text-right">이동요청번호</th>
								<td colspan="3">
									<input type="text" class="form-control width120px" id="part_trans_req_no" name="part_trans_req_no" value="${transMst.part_trans_req_no}" readonly="readonly">
								</td>
							</tr>
							<tr>
								<th class="text-right">이동창고</th>
								<td colspan="6">
									<div class="form-row">
									<c:choose>
									<c:when test="${transMst.part_trans_type_cd ne 'IN' || (part_trans_status_cd eq '04' && transMst.part_trans_type_cd eq 'IN')}">
										<div class="col-2">
											<input type="text" class="form-control" value="${transMst.from_warehouse_name}" readonly="readonly" id="mst_from_warehouse_name" name="mst_from_warehouse_name">
											<input type="hidden" value="${transMst.from_warehouse_cd}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
										</div>
										<div class="auto">
											에서
										</div>
										<div class="col-2">
											<input type="text" class="form-control" value="${transMst.to_warehouse_name}" readonly="readonly" id="mst_to_warehouse_name" name="mst_to_warehouse_name">
											<input type="hidden" value="${transMst.to_warehouse_cd}" id="mst_to_warehouse_cd" name="mst_to_warehouse_cd" readonly="readonly">
										</div>
										<div class="col-auto">
											로 이동
										</div>
									</c:when>
									<c:when test="${part_trans_status_cd ne '04' && transMst.part_trans_type_cd eq 'IN'}">
										<c:choose>
											<c:when test="${page.fnc.F01689_001 eq 'Y'}">
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
											
											<c:when test="${page.fnc.F01689_002 eq 'Y'}">
												<div class="col-2">
													<div class="col width100px" style="padding-right: 0;">
														<input type="text" class="form-control" value="${transMst.from_warehouse_name}" readonly="readonly" id="mst_from_warehouse_name" name="mst_from_warehouse_name">
														<input type="hidden" value="${transMst.from_warehouse_cd}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
													</div> 
												</div>
												<div class="col-auto">
													에서
												</div>
												<div class="col-2">
													<div class="col width100px" style="padding-right: 0;">
														<input type="text" class="form-control" value="${transMst.to_warehouse_name}" readonly="readonly" id="mst_to_warehouse_name" name="mst_to_warehouse_name">
														<input type="hidden" value="${transMst.to_warehouse_cd}" id="mst_to_warehouse_cd" name="mst_to_warehouse_cd" readonly="readonly">
													</div> 
												</div>
												<div class="col-auto">
													로 이동
												</div>
											</c:when>
											<c:when test="${page.fnc.F01689_003 eq 'Y'}">
												<div class="col-2">
													<div class="col width100px" style="padding-right: 0;">
														<input type="text" class="form-control" value="${transMst.from_warehouse_name}" readonly="readonly" id="mst_from_warehouse_name" name="mst_from_warehouse_name">
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
									<div class="col-auto">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
									</div>
									</div>
								</td>
								<th class="text-right" rowspan="2">비고</th>
								<td colspan="3" rowspan="2">
									<textarea class="form-control" id="mst_remark" name="mst_remark" maxlength="200" style="height: 100%;">${transMst.remark}</textarea>
								</td>
							</tr>							
							<tr>
								<th class="text-right essential-item">발송구분</th>
								<td colspan="6">
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
							<h4>처리완료목록</h4>
							<div class="btn-group">
										<div class="right">
										<c:if test="${part_trans_status_cd eq '04'}">
										<span class="text-danger">&#91;이동완료&#93;</span> <!-- dpn으로 show/hide -->
										</c:if>
									<c:if test="${transMst.part_trans_status_cd ne '04' && transMst.part_trans_type_cd eq 'IN'}">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									</c:if>
										</div>
									</div>
						</div>
			
						<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
					</div>
				</div>
				<!-- /하단 폼테이블 -->	
				<!-- /이동처리 상세 -->
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