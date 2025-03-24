<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비선적발주 > null > 장비선적발주상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var jsonList = ${jsonList};
		var memNo = '${SecureUser.mem_no}';
		var regMemNo = jsonList[0].reg_id;
		var apprStatus = jsonList[0].appr_proc_status_cd;
		var machineOrderList = ${machineOrderList};
		var rightAuiGrid;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createLeftAuiGrid();
			createRightAuiGrid();
			
			if (apprStatus != 01 || regMemNo != memNo) {
				fnModifyControl();
			}
		});
		
		// 결재상태에 따라 수정가능 제어
		function fnModifyControl() {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :button[onclick='javascript:goPrint();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goSearchOptDetail();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
		}
		
		//그리드생성
		function createLeftAuiGrid() {
			var gridPros = {
					rowIdField : "_$uid",
					showStateColumn : false,
					showRowNumColumn: false,
					showStateColumn : true,
					showFooter : true,
					footerPosition : "top",
					editable : true,
					//체크박스 출력 여부
					showRowCheckColumn : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
					softRemoveRowMode : false,
					headerHeight : 40
				};
			var columnLayout = [
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "opt_code", 
					visible : false
				},
				{ 
					dataField : "opt_name", 
					visible : false
				},
				{ 
					dataField : "order_seq_no", 
					visible : false
				},
				{ 
					dataField : "flag", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{
					headerText : "생산발주일", 
					dataField : "order_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					width : "13%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "생산발주번호", 
					dataField : "machine_order_no", 
					width : "14%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "발주처", 
					dataField : "cust_name", 
					width : "18%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "발주내역", 
					dataField : "machine_name", 
					width : "20%", 
					style : "aui-left",
					editable : false
				},
				{ 
					headerText : "생산발주<br>잔여수량", 
					dataField : "ship_poss_qty",
					dataType : "numeric",
					width : "8%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "수량", 
					dataField : "qty",
					dataType : "numeric",
					width : "8%", 
					style : "aui-center",
					editable : true,
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (apprStatus != 01 || regMemNo != memNo) {
							return null;
						} else {
							return "aui-editable";
						}
					},
					editRenderer : {
					      type : "InputEditRenderer",
					      min : 1,
					      onlyNumeric : true,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator
					}
				},
				{ 
					headerText : "합계금액", 
					dataField : "order_total_amt",
					dataType : "numeric",
					formatString : "#,##0.00",
					style : "aui-right",
					editable : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 수량 * 단가 계산
						return ( item.ship_poss_qty * item.unit_price ); 
					}
				},
				{
					dataField : "order_file_seq_yn",
					visible : false
				},
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_name",
				}, 
				{
					dataField : "ship_poss_qty",
					positionField : "ship_poss_qty",
					operation : "SUM",
					style : "aui-center aui-footer",
				},
				{
					dataField : "qty",
					positionField : "qty",
					operation : "SUM",
					style : "aui-center aui-footer",
				},
				{
					dataField : "order_total_amt",
					positionField : "order_total_amt",
					operation : "SUM",
					formatString : "#,##0.00",
					style : "aui-right aui-footer",
				}
			];
			
			leftAuiGrid = AUIGrid.create("#leftAuiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(leftAuiGrid, footerColumnLayout);
			AUIGrid.setGridData(leftAuiGrid, ${machineOrderList});
			AUIGrid.bind(leftAuiGrid, "cellEditBegin", function (event) {
				// 결재상태에 따라 에디팅 제어
				if (apprStatus != 01 || regMemNo != memNo) {
					if (event.dataField == "qty") {
						return false;
					}
				}
				
			});
			$("#leftAuiGrid").resize();

			AUIGrid.bind(leftAuiGrid, "rowCheckClick", function(event) {
				if(event.item.order_file_seq_yn == "N"){
					alert("해당 생산발주는 오더확인서가 없습니다.");
					AUIGrid.addUncheckedRowsByValue(leftAuiGrid, "machine_order_no", event.item.machine_order_no);
					return;
				}
			});
		}
		
		//그리드생성
		function createRightAuiGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
				editable : false,
// 				softRemoveRowMode : false,
			};
			var columnLayout = [
				{ 
					dataField : "flag", 
					visible : false
				},
				{ 
					dataField : "machine_plant_seq", 
					visible : false
				},
				{ 
					dataField : "order_seq_no", 
					visible : false
				},
				{ 
					dataField : "seq_no", 
					visible : false
				},
				{ 
					dataField : "opt_code", 
					visible : false
				},
				{
					headerText : "생산발주번호", 
					dataField : "machine_order_no", 
					width : "12%", 
					style : "aui-center"
				},
				{ 
					headerText : "Part NO", 
					dataField : "machine_name", 
					width : "12%", 
					style : "aui-center"
				},
				{ 
					headerText : "Qty", 
					dataField : "qty", 
					dataType : "numeric",
					width : "8%", 
					style : "aui-center",
				},
				{ 
					headerText : "U/Price", 
					dataField : "unit_price", 
					width : "13%", 
					dataType : "numeric",
					formatString : "#,##0.00",
					style : "aui-right",
				},
				{ 
					headerText : "Amount", 
					dataField : "ship_total_amt", 
					width : "18%", 
					dataType : "numeric",
					formatString : "#,##0.00",
					style : "aui-right",
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 수량 * 단가 계산
						return ( item.qty * item.unit_price ); 
					}
				},
				{ 
					headerText : "Option", 
					dataField : "opt_name", 
					style : "aui-left"
				},
				{ 
					headerText : "생산발주일", 
					dataField : "order_dt", 
					width : "12%", 
					style : "aui-center",
					dataType : "date",  
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "삭제", 
					dataField : "removeBtn",
					width : "6%", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (apprStatus == 01 && regMemNo == memNo) {
								var isRemoved = AUIGrid.isRemovedById(rightAuiGrid, event.item._$uid);
								if (isRemoved == false) {
// 									console.log("event : ", event);
									event.item.ship_total_amt = 0; // 행 삭제시 후 다시 추가시 합계 반영 안되는 문제로 0 세팅
									AUIGrid.updateRow(rightAuiGrid, event.item, event.rowIndex);
									AUIGrid.removeRow(event.pid, event.rowIndex);
									AUIGrid.update(rightAuiGrid);
									
									// 합계금액 세팅
									$M.setValue("total_amt", AUIGrid.getFooterData(rightAuiGrid)[2].text);
	
									// 선적발주내역에서 행 삭제시 생산발주내역으로 이동 하도록 작업.
									var leftAuiGridData = AUIGrid.getGridData(leftAuiGrid);
									var uptYn = "N";  // update, add flag 값
									for (var i = 0; i < leftAuiGridData.length; i++) {
										if( leftAuiGridData[i].machine_order_no == event.item.machine_order_no   
											&& leftAuiGridData[i].order_seq_no == event.item.order_seq_no
										) {
											var rowIdField = AUIGrid.getProp(leftAuiGrid, "rowIdField"); // 그리드 인덱스 구하기
											var rowIndex = AUIGrid.rowIdToIndex(leftAuiGrid, leftAuiGridData[i][rowIdField]); // 그리드 인덱스 구하기
											console.log("rowIndex : ", rowIndex);
											// 중복값 있음
											var item = {
													"ship_poss_qty" : leftAuiGridData[i].ship_poss_qty + event.item.qty,
													"qty" : 1
											}
											AUIGrid.updateRow(leftAuiGrid, item, rowIndex);
											uptYn = "Y"; //업데이트 된경우
										}
									}
									
									if (uptYn == "N") {
										// 중복값 없음
										// 행 삭제시 생산발주내역에 다시 추가
										event.item.ship_poss_qty = event.item["qty"]; // 생산발주잔여수량 세팅
										event.item.qty = 1; // 선적수량 1로 초기화
										AUIGrid.addRow(leftAuiGrid, event.item, 'last');
									}
									
								} else {
// 									AUIGrid.restoreSoftRows(rightAuiGrid, "selectedIndex"); 
// 									AUIGrid.update(rightAuiGrid);
								};
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "machine_name",
				}, 
				{
					dataField : "qty",
					positionField : "qty",
					operation : "SUM",
					style : "aui-center aui-footer",
				},
				{
					dataField : "ship_total_amt",
					positionField : "ship_total_amt",
					operation : "SUM",
					formatString : "#,##0.00",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(rightAuiGrid);
						var rowIdField = AUIGrid.getProp(rightAuiGrid, "rowIdField");
						var item;
						var sum = 0;
						for(var i=0, len=gridData.length; i<len; i++) {
							item = gridData[i];
							if(!AUIGrid.isRemovedById(rightAuiGrid, item[rowIdField])) {
								sum += item.ship_total_amt;
							} 
						}
						return sum;
					}
				},
			];
			rightAuiGrid = AUIGrid.create("#rightAuiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(rightAuiGrid, footerColumnLayout);
			AUIGrid.setGridData(rightAuiGrid, ${jsonList});
			$("#rightAuiGrid").resize();
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
		// 생산발주 잔여수량
		var dataQty;
		
		// 체크 후 추가버튼
		function fnAddCheck() {
			// 체크한 그리드 데이터 리스트
			var data = AUIGrid.getCheckedRowItemsAll(leftAuiGrid);
			if (data.length == 0) {
				alert("선택된 항목이 없습니다.");
				return;
			}
			
			// 화면에 보여지는 그리드 데이터 목록
			var rightAuiGridData = AUIGrid.getGridData(rightAuiGrid);
			
			// 체크된 행의 수량 벨리데이션
			for (var item in data) {
				var uptYn = "N"; // update, add flag 값
				var rowIdField = AUIGrid.getProp(leftAuiGrid, "rowIdField"); // 그리드 인덱스 구하기
				var rowIndex = AUIGrid.rowIdToIndex(leftAuiGrid, data[item][rowIdField]); // 그리드 인덱스 구하기
				
				// 수량 벨리데이션
				if (data[item].ship_poss_qty < data[item].qty) {
					alert("선적수량이 생산발주잔여수량보다 클 수 없습니다.");
					fnSetCellFocus(leftAuiGrid, rowIndex, "qty");
					return;
				} else {
					// 선적발주내역으로 데이터 추가시 생산발주 잔여수량 수량 빼주는 작업.
					AUIGrid.updateRow(leftAuiGrid, {"ship_poss_qty" : data[item].ship_poss_qty - data[item].qty}, rowIndex);
 					
					// 생산발주 잔여수량이 0이되면 행 삭제
					dataQty = data[item].ship_poss_qty - data[item].qty;
					if (dataQty == 0) {
						AUIGrid.removeRow(leftAuiGrid, rowIndex);
						AUIGrid.update(leftAuiGrid);						
					}
					// rightAuiGridData[i].order_seq_no == data[item].order_seq_no
					for (var i = 0; i < rightAuiGridData.length; i++) {
						if( rightAuiGridData[i].machine_order_no == data[item].machine_order_no   
							&& rightAuiGridData[i].order_seq_no == data[item].order_seq_no
						) {
							//우측 그리드에 이미 값이 있으면 수량 업데이트 후 for문을 나감							
							var rowIdField = AUIGrid.getProp(rightAuiGrid, "rowIdField"); // 그리드 인덱스 구하기
							var rowIndex = AUIGrid.rowIdToIndex(rightAuiGrid, rightAuiGridData[i][rowIdField]); // 그리드 인덱스 구하기
							var row = rightAuiGridData[i];
							var isRemoved = AUIGrid.isRemovedById(rightAuiGrid, row[rowIdField]); // 삭제한 행인지 여부
							// 삭제여부에따라 qty 컨트롤
							if (isRemoved == true) {
								AUIGrid.restoreSoftRows(rightAuiGrid, rowIndex);  // 삭제한 선적발주내역 삭제해제
								console.log(data[item]);
								AUIGrid.updateRow(rightAuiGrid, {"qty" : data[item].qty, "ship_total_amt" : data[item].qty * data[item].unit_price }, rowIndex);
							} else {
								AUIGrid.updateRow(rightAuiGrid, {"qty" : rightAuiGridData[i].qty + data[item].qty }, rowIndex);
							}
							uptYn = "Y"; //업데이트 된경우
						}						
					}
 					
					if(uptYn == "N"){
						data[item].seq_no = null;
						AUIGrid.addRow(rightAuiGrid, data[item], 'last');
					}
					// 합계금액 form에 세팅
					$M.setValue("total_amt", AUIGrid.getFooterData(rightAuiGrid)[2].text);
				}
			}
		}
		
		// 수정
		function goModify(isRequestAppr) {
			var msg = "수정하시겠습니까?"
			var frm = document.main_form;
			
			if($M.validation(frm) == false) {
				return;
			}
			
			frm = $M.toValueForm(frm);
			
			// 선적발주내역 벨리데이션
			var data = AUIGrid.getGridData(rightAuiGrid);
			console.log("그리드 데이터 : ", data);
			if (data.length == 0) {
				alert("선적발주를 추가해주세요.");
				return;
			}
			
			var machineShipNo = $M.getValue("machine_ship_no");
			$M.setValue("save_mode", "modify");
			
			var gridForm = fnChangeGridDataToForm(rightAuiGrid);
			$M.copyForm(gridForm, frm);
			
			// 결재 요청
			if (isRequestAppr != undefined) {
				$M.setValue("save_mode", "appr");
				msg = "결재요청 하시겠습니까?";
			}
			
			console.log(gridForm);
			
			$M.goNextPageAjaxMsg(msg, this_page + "/" + machineShipNo + "/modify", gridForm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			if (isRequestAppr != undefined) {
			    			alert("처리가 완료되었습니다.");
		    			} else {
			    			alert("수정이 완료되었습니다.");
		    			}
		    			window.opener.location.reload();
		    			location.reload();
					}
				}
			);
		}
		
		// 상신취소
		function goApprCancel() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_cancel_yn : "Y"
			};
			openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
		}
		
		function goApprovalResultCancel(result) {
			$M.goNextPageAjax('/session/check', '', {method : 'GET'},
					function(result) {
				    	if(result.success) {
				    		alert("결재취소가 완료됐습니다.");	
				    		location.reload();
						}
					}
				);
		}
		
		// 결재처리
		function goApproval() {
			if (confirm("결재하시겠습니까?") == false) {
				return false;
			}
			var param = {
					appr_job_seq : "${apprBean.appr_job_seq}",
					seq_no : "${apprBean.seq_no}"
			};
			$M.setValue("save_mode", "approval"); // 승인
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}
		
		// 결재처리 결과
		function goApprovalResult(result) {
			if(result.appr_status_cd == '03') {
				alert("반려가 완료되었습니다.");
				window.opener.location.reload();
				location.reload();
			} else {
				alert("결재처리가 완료되었습니다.");
				window.opener.location.reload();
				location.reload();
			}
		}
		
		function goRequestApproval() {
			goModify('requestAppr');
		}
		
		// 삭제
		function goRemove() {
			if (confirm("삭제하시겠습니까?") == false) {
				return false;
			}
			var machineShipNo = $M.getValue("machine_ship_no");
			
			var frm = $M.toValueForm(document.main_form);
			
			var concatCols = [];
			var concatList = [];
			var gridIds = [rightAuiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			
			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);
			
			console.log(gridFrm);
			
			$M.goNextPageAjax(this_page + "/" + machineShipNo + "/remove" , gridFrm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리 되었습니다.");
		    			fnClose();
		    			window.opener.location.reload();
					}
				}
			);	
		}
		
		function goPrint() {
			openReportPanel('sale/sale0202p01_01.crf','machine_ship_no=' + $M.getValue("machine_ship_no"));
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="save_mode" name="save_mode">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${list[0].appr_job_seq}">
<input type="hidden" name="reg_mem_no">
<input type="hidden" name="reg_id" value="${list[0].reg_mem_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<div class="doc-info" style="flex: 1;">				
					<h4>장비선적발주상세</h4>			
					<div >
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>		
					</div>
				</div>
<!-- 결재영역 -->
				<div style="width: 41.2%; margin-left: 10px;">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->				
			</div>	
<!-- 상단 폼테이블 -->	
			<div>
				<table class="table-border mt10">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">발주번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-3">
										<input type="text" class="form-control width100px" readonly id="machine_ship_no" name="machine_ship_no" value="${list[0].machine_ship_no}">
									</div>
								</div>
							</td>
							<th class="text-right essential-item">담당자</th>
							<td>
								<input type="text" class="form-control width80px" id="reg_mem_name" name="reg_mem_name" value="${list[0].reg_mem_name}" readonly alt="담당자"  required="required">
<%-- 								<input type="hidden" name="reg_id" id="reg_id" value="${list[0].reg.mem_no}" > --%>
							</td>
							<th class="text-right">상태</th>
							<td>
								${list[0].appr_proc_status_name}
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">To</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control width140px" id="cust_name" name="cust_name" readonly alt="To"  required="required" value="${list[0].cust_name}">
									<input type="hidden" id="client_cust_no" name="client_cust_no" value="${list[0].client_cust_no}">
									<button type="button" class="btn btn-icon btn-primary-gra" id="client_btn" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th rowspan="2" class="text-right essential-item">From</th>
							<td rowspan="2">
								<div class="form-row inline-pd mb7">
									<div class="col-12">
										<input type="text" class="form-control rb" maxlength="40" id="mem_eng_name" name="mem_eng_name" alt="From"  required="required" value="${list[0].mem_eng_name}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="30" id="job_eng_name" name="job_eng_name" value="${list[0].job_eng_name}">
									</div>
								</div>
							</td>
							<th rowspan="5" class="text-right essential-item">Remark</th>
							<td rowspan="5">
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control rb" maxlength="100" id="remark_1" name="remark_1" alt="Remark"  required="required" value="${list[0].remark_1}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_2" name="remark_2" value="${list[0].remark_2}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_3" name="remark_3" value="${list[0].remark_3}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_4" name="remark_4" value="${list[0].remark_4}">
									</div>
								</div>
								<div class="form-row inline-pd mb5">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_5" name="remark_5" value="${list[0].remark_5}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" maxlength="100" id="remark_6" name="remark_6" value="${list[0].remark_6}">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">Attn</th>
							<td>
								<input type="text" class="form-control rb" maxlength="40" id="client_charge_name" name="client_charge_name" alt="Attn"  required="required" value="${list[0].client_charge_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">CC</th>
							<td>
								<input type="text" class="form-control rb" maxlength="40" id="client_rep_name" name="client_rep_name" alt="CC"  required="required" value="${list[0].client_rep_name}">
							</td>
							<th class="text-right essential-item">RE</th>
							<td>
								<input type="text" class="form-control rb" maxlength="60" id="order_remark" name="order_remark" alt="RE"  required="required" value="${list[0].order_remark}">
							</td>
						</tr>
						<tr>
<!-- 							<th class="text-right essential-item">To</th> -->
<!-- 							<td> -->
<!-- 								<div class="input-group"> -->
<%-- 									<input type="text" class="form-control width140px" id="cust_name" name="cust_name" readonly alt="To"  required="required" value="${list[0].cust_name}"> --%>
<%-- 									<input type="hidden" id="client_cust_no" name="client_cust_no" value="${list[0].client_cust_no}"> --%>
<!-- 									<button type="button" class="btn btn-icon btn-primary-gra" id="client_btn" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button> -->
<!-- 								</div> -->
<!-- 							</td> -->
							<th class="text-right">합계금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control text-right" readonly name="total_amt" id="total_amt" format="decimal" datatype="int" alt="합계금액"  required="required" value="${list[0].total_amt}">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">입고예정일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control width100px calDate" id="in_plan_dt" name="in_plan_dt" dateformat="yyyy-MM-dd" value="${list[0].in_plan_dt}" alt="예상입고예정일">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">참고</th>
							<td colspan="3">
								<input type="text" class="form-control" maxlength="80" id="desc_text" name="desc_text" value="${list[0].desc_text}">
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->		
			<div class="row">					
<!-- 좌측 폼테이블 -->
				<div class="col-6">
<!-- 생산발주내역 -->
					<div class="title-wrap mt10">
						<h4>생산발주내역</h4>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>							
					</div>

					<div id="leftAuiGrid" style="margin-top: 5px; height: 500px;">
					</div>
<!-- /생산발주내역 -->
				</div>
<!-- /좌측 폼테이블 -->
<!-- 우측 폼테이블 -->
				<div class="col-6">
<!-- 옵션품목 -->
					<div class="title-wrap mt10">
						<h4>선적발주내역</h4>
					</div>
					<div id="rightAuiGrid" style="margin-top: 5px; height: 350px;">
					</div>
<!-- /옵션품목 -->
<!-- 결재자의견-->						
					<div>
						<div class="title-wrap mt10">
							<h4>결재자의견</h4>									
						</div>
						<div class="fixed-table-container" style="width: 100%; height: 115px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
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
									<tr><th class="th" style="font-size: 12px !important">구분</th>
										<th class="th" style="font-size: 12px !important">결재일시</th>
										<th class="th" style="font-size: 12px !important">담당자</th>
										<th class="th" style="font-size: 12px !important">특이사항</th>
									</tr></thead>
									<tbody>
									<c:forEach var="list" items="${apprMemoList}">
										<tr>
											<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
											<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
											<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
											<td class="td" style="font-size: 12px !important">${list.memo }</td>
										</tr>
									</c:forEach>
									</tbody>
								</table>
							</div>
						</div>
					</div>
<!-- /결재자의견-->
				</div>
<!-- /우측 폼테이블 -->
			</div>
<!-- /하단 폼테이블 -->	

<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">						
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
							<jsp:param name="pos" value="BOM_R"/>
							<jsp:param name="mem_no" value="${list[0].reg_mem_no}"/>
							<jsp:param name="appr_yn" value="Y"/>
						</jsp:include>
					</div>
				</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>