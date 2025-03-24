<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동처리 > 부품이동처리등록 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-03 10:01:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
			
			// $("#_goPartList").addClass("dpn");
			
			// fromwarehouse 콤보그리드 목록 클릭 시 to창고 주소 조회 
			$(document).on("click", ".datagrid-row", function() {
				toWarehouseCheck();
			});
			
			// fromwarehouse 콤보그리드 x버튼 클릭 시 to창고 주소 조회
			$(document).on("click", ".icon-clear", function() {
				toWarehouseCheck();
			});

			// fromwarehouse 콤보그리드 focusout 시 to창고 주소 조회
			$("#_easyui_textbox_input1").focusout(function() {
				toWarehouseCheck();
			});

			// fromwarehouse 콤보그리드 focusin 시 code_name 리셋
			$("#from_warehouse_grid").focusin(function() {
	    		$('#mst_from_warehouse_cd').combogrid("setText", "");
			});
			
			// towarehouse 콤보그리드 focusin 시 code_name 리셋
			$("#to_warehouse_grid").focusin(function() {
	    		$('#mst_to_warehouse_cd').combogrid("setText", "");
			});
			
		});
		
		// towarehouse 값이 기존값과 다르면 배송정보 조회
		function toWarehouseCheck() {
			var mst_to_cd_new 	  = $M.getValue("mst_to_warehouse_cd");		// mst_from_warehouse_cd 최신값		
			var mst_to_cd_check   = $M.getValue("mst_to_cd_last");			// 마지막에 클릭 한 mst_from_warehouse_cd

			if(mst_to_cd_check !=  mst_to_cd_new) {
				$M.setValue("mst_to_cd_last", mst_to_cd_new);
				goSearchInvoice();
			};			
		}
		
		// to창고 주소조회
		function goSearchInvoice() {
			
			if($M.validation(document.main_form, {field:["mst_to_warehouse_cd"]}) == false) {
				return;
			};
			
			var param = {
				org_code 	: $M.getValue("mst_to_warehouse_cd"),
			};
			
			$M.goNextPageAjax(this_page + "/search" , $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {

						if($M.nvl(result.sendInvoice, "") != "") {
							var param = {
								invoice_post_no : result.sendInvoice.invoice_post_no,
								invoice_addr1 	: result.sendInvoice.invoice_addr1,
								invoice_addr2 	: result.sendInvoice.invoice_addr2,
								invoice_address : result.sendInvoice.invoice_address,
								receive_name 	: result.sendInvoice.receive_name,
								receive_tel_no 	: result.sendInvoice.receive_tel_no,
								receive_hp_no 	: result.sendInvoice.receive_hp_no,
							}
							
							$M.setValue(param);	
						} else {
							fnNew();
						}
					};
				}
			);
			
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
	    		item.part_no = "";
	    		item.part_name = "";
	    		item.seq_no = 0;
	    		item.qty = "";
	    		item.remark = "";
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
		
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "part_trans_no",
				showRowNumColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showStateColumn : true,
				editable : true,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : false,
				rowIdTrustMode : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					style : "aui-editable",
					width : "15%",
					editRenderer : {				
						type : "ConditionRenderer", 
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
								s_search_kind : 'DEFAULT_PART',
								's_warehouse_cd' : $M.getValue("mst_from_warehouse_cd"),
								's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
				    			's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param);
						},
					},
// 					editRenderer : {
// 						type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
// 						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
// 							var param = {
// 								s_search_kind : "PART_TRANS",
// 								s_warehouse_cd : $M.getValue("mst_from_warehouse_cd"),
// 							};
// 							return fnGetPartSearchRenderer(dataField, param);
// 						},
// 					}
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "20%",
					style : "aui-center",
					editable : false 
				},
				{
				    headerText: "현재고",
				    dataField: "current_stock",
					width : "8%",
					style : "aui-center aui-popup",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
				},
				{
				    headerText: "처리수량",
				    dataField: "qty",
					width : "8%",
					style : "aui-center aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "30%",
					style : "aui-left aui-editable",
					editable : true 
				},
				{
				    headerText: "저장위치", 
				    dataField: "storage_name",
					width : "8%",
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
								AUIGrid.removeRow(event.pid, event.rowIndex);								
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
			
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				
			AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
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
						if(item === undefined) {
							AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
						} else {
							console.log("item", item)
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
							AUIGrid.updateRow(auiGrid, {
								part_name : item.part_name,
								current_stock : item.part_warehouse_current,
								req_qty : item.req_qty,
								storage_name : item.storage_name,
							}, event.rowIndex);
						} 
				    }
				break;
			} 
		};
		
		// 그리드 필수값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["part_no", "qty"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		
		// 부품이동처리 수동 등록
		function goSave() {
			if (fnCheckGridEmpty(auiGrid) === false) {
				return false;
			};
			
			var fromWarehouseCd =  $M.nvl($M.getValue("mst_from_warehouse_cd"), "");
			var toWarehouseCd 	=  $M.nvl($M.getValue("mst_to_warehouse_cd"), "");

			if(fromWarehouseCd === "") {
				alert("FROM창고를 선택해주세요.");
				$("#from_warehouse_grid").find(".combo-arrow").get(0).click();
				return;
			};

			if(toWarehouseCd === "") {
				alert("TO창고를 선택해주세요.");
				$("#to_warehouse_grid").find(".combo-arrow").get(0).click();
				return;
			};
			
			if(fromWarehouseCd == toWarehouseCd) {
				alert("from창고와 to창고는 같을 수 없습니다.");
				return;
			};
			
			var rowCount 	= AUIGrid.getRowCount(auiGrid);

			if(rowCount == 0) {
				alert("처리예정목록에 값이 없습니다.");
				return false;
			};

			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var gridForm = fnChangeGridDataToForm(auiGrid);
			
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjaxMsg("이동 처리하시겠습니까?", this_page + "/save/", gridForm, {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			history.back();
					};
				}
			); 
		}
		
		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			
			// 현재고 셀 클릭 시 부품재고상세 팝업 호출
			 if(event.dataField == 'current_stock') {
				var param = {
						"part_no" : event.item["part_no"]
				};			
				var popupOption = "";
				$M.goNextPage('/part/part0101p01', $M.toGetParam(param),  {popupStatus : popupOption});
			};
			
			if(event.pid == "#auiGridLeft") {
				if(event.columnIndex == 3 || event.columnIndex == 6 || event.columnIndex == 8 ) {
					return;
				};
			} else if(event.pid == "#auiGridRight") {
				if(event.columnIndex == 2 || event.columnIndex == 4 ) {
					return;
				};
			};
			
			var item = event.item, rowIdField, rowId;
			rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if(AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
			}
		};
		
		
	    // 배송정보 팝업
	    function goDeliveryInfo() {

	    	var params = {
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
	    			
	    	};

	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }
	    
	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	fnNew();
	    	$M.setValue(data);
			$M.setValue("invoice_address", data.invoice_addr1 + " " + data.invoice_addr2);
	    }
	    
	    function goInWarehousePopup() {
	    	openInWarehousePanel('setPartList');
	    }
		
	    function setPartList(rowArr) {
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
				}	
			}
			
	    	if(rowArr.length > 0) {
	    		$('#mst_from_warehouse_cd').combogrid("setValues", ${inWarehouseCd});  
	    		$('#mst_from_warehouse_cd').combogrid("setText", "입고창고");
	    		$('#mst_from_warehouse_cd').combogrid('disable');
	    		
// 	    		$M.setValue("mst_from_warehouse_cd", ${inWarehouseCd});
	    	};
			AUIGrid.addRow(auiGrid, partList, "last");
	    }
		
		function fnList() {
			history.back(); 
		}	
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '부품이동처리-등록');
		}
		
		// 부품조회
		function goPartList() {
// 			var items = AUIGrid.getAddedRowItems(auiGrid);
// 			for (var i = 0; i < items.length; i++) {
// 				if (items[i].part_no == "") {
// 					alert("추가된 행을 입력하고 시도해주세요.");
// 					return;
// 				}
// 			}
			if ($M.getValue("mst_from_warehouse_cd") == "") {
				alert("From창고를 선택해주세요.");
				$("#from_warehouse_grid").find(".combo-arrow").get(0).click();
				return;
			};
			
			
			if($M.getValue("org_gubun_cd") == "CENTER") {
				onlyWarehouseYn = "Y";
			}
			
			var param = {
	    			 's_warehouse_cd' : $M.getValue('mst_from_warehouse_cd'),
	    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
// 	    			 's_cust_no' : $M.getValue('cust_no')
	    	};
			
			openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
		}
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
			var params = AUIGrid.getGridData(auiGrid);
			
			var partNo ='';
			var partName ='';
			var unitPrice ='';
			var qty = 1;
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					row.seq_no = "";
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
// 					row.qty = qty;
					row.current_stock = rowArr[i].part_warehouse_current;		// 전체 현재고가 아닌 소속창고의 현재고
					row.part_name_change_yn = rowArr[i].part_name_change_yn;
					row.storage_name = rowArr[i].storage_name;
					AUIGrid.addRow(auiGrid, row, 'last');
				}
			}
		}
		
		
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<!-- 부품이동요청타입(장바구니) -->
		<input type="hidden" class="form-control" id="part_trans_req_type_cd"   name="part_trans_req_type_cd"   readonly="readonly" value="CART">
		<!-- 콤보그리드 마지막에 클릭한 mst_towarehouse 값 -->
		<input type="hidden" id="mst_to_cd_last" name="mst_to_cd_last">
		
	<!-- 송장발송 -->
		<!-- 발송구분 -->
		<input type="hidden" name="invoice_type_cd"   id="invoice_type_cd" 	 value="99">
		<!-- 송장번호 -->
		<input type="hidden" name="invoice_no" 		  id="invoice_no" 		 value="">
		<!-- 수량 -->
		<input type="hidden" name="invoice_qty" 	  id="invoice_qty" 		 value="">
		<!-- 성명 -->
		<input type="hidden" name="receive_name" 	  id="receive_name" 	 value="${sendInvoice.receive_name}">
		<!-- 전화번호 -->
		<input type="hidden" name="receive_tel_no" 	  id="receive_tel_no" 	 value="${sendInvoice.receive_tel_no}">
		<!-- 핸드폰번호 -->
		<input type="hidden" name="receive_hp_no" 	  id="receive_hp_no" 	 value="${sendInvoice.receive_hp_no}">
		<!-- 참고 -->	
		<input type="hidden" name="invoice_remark"    id="invoice_remark" 	 value="">
		<!-- 송장비용방식코드 -->					
		<input type="hidden" name="invoice_money_cd"  id="invoice_money_cd"  value="">
		<!-- 우편번호 -->
		<input type="hidden" name="invoice_post_no"   id="invoice_post_no"   value="${sendInvoice.invoice_post_no}">
		<!-- 주소1 -->
		<input type="hidden" name="invoice_addr1" 	  id="invoice_addr1"     value="${sendInvoice.invoice_addr1}">
		<!-- 주소2 -->		
		<input type="hidden" name="invoice_addr2" 	  id="invoice_addr2"     value="${sendInvoice.invoice_addr2}">
	<!-- // 송장발송 -->
		
		<div class="layout-box">
			<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="content-box">
					<!-- 메인 타이틀 -->
					<div class="main-title detail">
						<div class="detail-left">
							<button type="button" class="btn btn-outline-light" onclick="javascript:history.back();"><i class="material-iconskeyboard_backspace text-default"></i></button>
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						</div>
					</div>
					<!-- /메인 타이틀 -->
					<div class="contents">
					<!-- 폼테이블 -->	
						<!-- 상단 폼테이블 -->	
						<div>
							<table class="table-border">
								<colgroup>
									<col width="70px">
									<col width="20">
									<col width="60px">
									<col width="">
									<col width="60px">
									<col width="">
									<col width="70px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">처리일자</th>
										<td colspan="3">
											<div class="col width100px" style="padding-right: 0;">
												<input type="text" class="form-control" id="reg_dt" name="reg_dt" dateformat="yyyy-MM-dd" alt="요청일" value="${inputParam.s_current_dt}" readonly="readonly" onclick="this.blur()">
											</div>
										</td>
										<th class="text-right" rowspan="3">비고</th>
										<td colspan="3" rowspan="3">
											<textarea class="form-control" id="mst_remark" name="mst_remark" maxlength="200" style="height: 100%;"></textarea>
										</td>
									</tr>
									<tr>
										<th class="text-right">이동창고</th>
										<td colspan="3">
											<div class="form-row inline-pd">
												<!-- a. 로그인 계정이 본사인 경우, 평택센터가 아닌 경우 창고목록 콤보그리드 선택가능 -->
												<!-- b. 로그인 계정이 본사가 아닌 경우 해당부서코드 Set -->
												<!-- c. 로그인 계정이 평택센터인 경우 -->
												<c:choose>
													<c:when test="${page.fnc.F01141_001 eq 'Y'}">
														<div class="col-4" id="from_warehouse_grid">
															<div class="input-group">
																<input type="text" style="width : 200px";
																	value="${SecureUser.part_org_yn eq 'Y' ? SecureUser.org_code : ''}"
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
																	value=""
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
													
													<c:when test="${page.fnc.F01141_002 eq 'Y'}">
														<div class="col-2">
															<div class="col width100px" style="padding-right: 0;">
																<input type="text" class="form-control" value="${SecureUser.warehouse_name}" readonly="readonly">
																<input type="hidden" value="${SecureUser.warehouse_cd}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
															</div> 
														</div>
														<div class="col-auto">
															에서
														</div>
														<div class="col-2">
															<div class="col width100px" style="padding-right: 0;">
																<input type="text" class="form-control" value="${partOrgName}" readonly="readonly">
																<input type="hidden" value="${partOrgCode}" id="mst_to_warehouse_cd" name="mst_to_warehouse_cd" readonly="readonly">
															</div> 
														</div>
														<div class="col-auto">
															로 이동
														</div>
													</c:when>
													<c:when test="${page.fnc.F01141_003 eq 'Y'}">
														<div class="col-2">
															<div class="col width100px" style="padding-right: 0;">
																<input type="text" class="form-control" value="${partOrgName}" readonly="readonly">
																<input type="hidden" value="${partOrgCode}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
															</div> 
														</div>
														<div class="col-auto">
															에서
														</div>
														
														<div class="col-4" id="to_warehouse_grid">
															<div class="input-group">
																<input type="text" style="width : 200px";
																	value=""
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
											</div>
										</td>
									</tr>							
									<tr>
										<th class="text-right essential-item">발송구분</th>
										<td colspan="3">
											<div class="form-row inline-pd">
												<div class="col-2">
													<select class="form-control width100px essential-bg" id="invoice_send_cd" name="invoice_send_cd" required="required" alt="전송구분">
														<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
														<option value="${item.code_value}" ${item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-1.5">
													<button type="button" class="btn btn-primary-gra width100px" onclick="javascript:goDeliveryInfo();">배송정보설정</button>
												</div>
												<div class="col-8">
													<input type="text" class="form-control" maxlength="200" id="invoice_address" name="invoice_address" value="${sendInvoice.invoice_address}" readonly="readonly">
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
								<div class="title-wrap mt10">
									<h4>처리예정목록</h4>
									<div class="btn-group">
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
										</div>
									</div>
								</div>
					
								<div id="auiGrid" style="margin-top: 5px; height: 520px;"></div>
							</div>
						</div>
						<!-- /하단 폼테이블 -->	
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
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
			</div>
			<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>