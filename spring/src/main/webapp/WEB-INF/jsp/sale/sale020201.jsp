<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비선적발주 > 장비선적발주등록 > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var leftAuiGrid;  // 생산발주내역 그리드
		var rightAuiGrid; // 선적발주내역 그리드
	
		$(document).ready(function() {
			// AUIGrid 생성
			createLeftAUIGrid();
			createRightAUIGrid();
		});
		
		//그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				headerHeight : 50,
				showRowNumColumn: false,
			    displayTreeOpen : true,
				enableCellMerge : false,
				showBranchOnGrouping : false,
				showFooter : true,
				footerPosition : "top",
				editable : true,
				enableMovingColumn : false,
				showRowAllCheckBox : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true,
				softRemoveRowMode : false,
			};
			var columnLayout = [
				{ 
					dataField : "machine_plant_seq", 
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
					dataField : "opt_code", 
					visible : false
				},
				{ 
					dataField : "opt_name", 
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
					width : "12%", 
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
					headerText : "선적수량", 
					dataField : "qty",
					dataType : "numeric",
					width : "8%", 
					style : "aui-center aui-editable",
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
				},
			];
			leftAuiGrid = AUIGrid.create("#leftAuiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(leftAuiGrid, footerColumnLayout);
			AUIGrid.setGridData(leftAuiGrid, []);
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
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				showRowNumColumn: false,
			    displayTreeOpen : true,
				enableCellMerge : false,
				showBranchOnGrouping : false,
				headerHeight : 50,
				//푸터 상단 고정
				showFooter : true,
				footerPosition : "top",
				editable : true,
				enableMovingColumn : false,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : false
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
					dataField : "opt_code", 
					visible : false
				},
				{
					headerText : "생산발주번호", 
					dataField : "machine_order_no", 
					width : "13%", 
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
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "13%", 
					style : "aui-right",
				},
				{ 
					headerText : "Amount", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0.00",
					width : "18%", 
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
							var isRemoved = AUIGrid.isRemovedById(rightAuiGrid, event.item._$uid);
							if (isRemoved == false) {
								console.log("event : ", event);
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
										console.log("event : ", event);
										console.log("leftAuiGridData[i]", leftAuiGridData[i]);
										// 중복값 있음
										var item = {
												"ship_poss_qty" : leftAuiGridData[i].ship_poss_qty + event.item.qty,
												"qty" : event.item.ship_poss_qty
										}
										AUIGrid.updateRow(leftAuiGrid, item, rowIndex);
										uptYn = "Y"; //업데이트 된경우
									}
								}
								
								if (uptYn == "N") {
									// 중복값 없음
									// 행 삭제시 생산발주내역에 다시 추가
									event.item.qty = event.item.ship_poss_qty; // 선적수량 초기화
									AUIGrid.addRow(leftAuiGrid, event.item, 'last');
								}
								
							} else {
								AUIGrid.restoreSoftRows(rightAuiGrid, "selectedIndex"); 
								AUIGrid.update(rightAuiGrid);
							};
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
					dataField : "total_amt",
					positionField : "total_amt",
					operation : "SUM",
					formatString : "#,##0.00",
					style : "aui-right aui-footer",
				},
			];
			rightAuiGrid = AUIGrid.create("#rightAuiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(rightAuiGrid, footerColumnLayout);
			AUIGrid.setGridData(rightAuiGrid, []);
			$("#rightAuiGrid").resize();
		}
		
		// 결재요청
		function goRequestApproval() {
			goSave('requestAppr');
		}
		
		// 저장
		function goSave(isRequestAppr) {
			var frm = document.main_form;
			// 입력폼 벨리데이션
			if($M.validation(frm) == false) {
				return;
			}

			frm = $M.toValueForm(frm);
			
			var data = AUIGrid.getGridData(rightAuiGrid);
			if (data.length == 0) {
				alert("선적발주를 추가해주세요.");
				return;
			}
			
			var gridForm = fnChangeGridDataToForm(rightAuiGrid);
			$M.copyForm(gridForm, frm);
			
			if(isRequestAppr != undefined) {
				$M.setValue("save_mode", "appr"); // 결재요청
				if(confirm("결재요청 하시겠습니까?") == false) {
					return false;
				}
			} else {
				$M.setValue("save_mode", "save"); // 저장
				if(confirm("저장하시겠습니까?") == false) {
					return false;
				}
			}
			console.log(gridForm);

			$M.goNextPageAjax(this_page + "/save", gridForm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장이 완료되었습니다.");
		    			console.log("result : ", result);
		    			$M.goNextPage("/sale/sale0202");
					}
				}
			);
		}
		
		function fnList() {
	    	history.back();
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
			console.log("rightAuiGridData : ", rightAuiGridData);
			
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
							&& rightAuiGridData[i].order_seq_no == data[item].order_seq_no) {
							console.log(rightAuiGridData);
							//우측 그리드에 이미 값이 있으면 수량 업데이트 후 for문을 나감							
							var rowIdField = AUIGrid.getProp(rightAuiGrid, "rowIdField"); // 그리드 인덱스 구하기
							var rowIndex = AUIGrid.rowIdToIndex(rightAuiGrid, rightAuiGridData[i][rowIdField]); // 그리드 인덱스 구하기
							AUIGrid.updateRow(rightAuiGrid, {"qty" : rightAuiGridData[i].qty + data[item].qty }, rowIndex);
							uptYn = "Y"; //업데이트 된경우
						}						
					}
 					
					if(uptYn == "N"){
						AUIGrid.addRow(rightAuiGrid, data[item], 'last');
					}
					// 합계금액 form에 세팅
					$M.setValue("total_amt", AUIGrid.getFooterData(rightAuiGrid)[2].text);
				}
			}
		}
		
		// 매입처 조회 팝업
		function fnSearchClientComm() {
			var param = {};
			openSearchClientPanel('setSearchClientInfo', 'wide', $M.toGetParam(param));
		}
		
		// 매입처 조회 팝업 클릭 후 리턴
	    function setSearchClientInfo(row) {
			$M.setValue("cust_name", row.cust_name);
			$M.setValue("client_cust_no", row.cust_no);
			
			var clientCustNo = row.cust_no;

			// 매입처에 따라 생산발주내역 조회
			$M.goNextPageAjax(this_page + "/machineOrderList/search/" + clientCustNo, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			AUIGrid.setGridData(leftAuiGrid, result.list);
					}
				}
			);			
		}

		// (SR : 14481 황빛찬) 해당 메이커로 작성된 가장 최근 발주 내역 상세내역에 세팅.
		// 발주서 복사
		function fnOrderCopy() {
			var clientCustNo = $M.getValue("client_cust_no");
			if (clientCustNo == '' || clientCustNo == undefined) {
				alert("메이커(TO) 선택 후 재시도 해 주세요.");
				return;
			}

			if (confirm("해당 메이커(TO)의 최근 작성된 발주서를 복사 하시겠습니까 ?") == false) {
				return;
			}

			var param = {
				"client_cust_no" : clientCustNo
			};

			$M.goNextPageAjax(this_page + "/ship/copy" , $M.toGetParam(param) , {method : 'GET'},
				function(result) {
					if(result.success) {
						if (result.client_charge_name == undefined) {
							$M.clearValue({
								field:[
									"client_charge_name", "client_rep_name", "desc_text", "job_eng_name", "mem_eng_name", "order_remark",
									"in_plan_dt", "remark_1", "remark_2", "remark_3", "remark_4", "remark_5", "remark_6"
								]
							});
						} else {
							$M.setValue(result);
						}
					}
				}
			);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->
<input type="hidden" id="mem_no" name="mem_no" value="${result.mem_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${result.appr_proc_status_cd}">
<input type="hidden" id="ship_dt" name="ship_dt" dateformat="yyyy-MM-dd" value="${inputParam.s_end_dt}">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left approval-left" style="align-items: center;">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
					<!-- 결재영역 -->
					<div class="p10">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->	
<!-- 상단 폼테이블 -->	
					<div>
						<table class="table-border mt5">
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
									<th class="text-right">발주번호</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-3">
												<input type="text" class="form-control width100px" readonly id="machine_ship_no" name="machine_ship_no">
											</div>
										</div>
									</td>
									<th class="text-right">담당자</th>
									<td>
										<input type="text" class="form-control width100px" id="reg_mem_name" name="reg_mem_name" value="${SecureUser.user_name}" readonly alt="담당자"  required="required">
										<input type="hidden" name="reg_id" id="reg_id" value="${SecureUser.mem_no}" >
									</td>
									<th class="text-right">상태</th>
									<td>
										작성중
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">To</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width200px" id="cust_name" name="cust_name" readonly alt="To"  required="required">
											<input type="hidden" id="client_cust_no" name="client_cust_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
											<div class="detail-left approval-left" style="align-items: center;">
												<button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="javascript:fnOrderCopy();" style="margin-left:10px;">발주서 복사</button>
											</div>
										</div>
									</td>
									<th rowspan="2" class="text-right essential-item">From</th>
									<td rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="col-12">
												<input type="text" class="form-control essential-bg" maxlength="40" id="mem_eng_name" name="mem_eng_name" alt="From"  required="required">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="30" id="job_eng_name" name="job_eng_name">
											</div>
										</div>
									</td>
									<th rowspan="5" class="text-right essential-item">Remark</th>
									<td rowspan="5">
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control essential-bg" maxlength="100" id="remark_1" name="remark_1" alt="Remark"  required="required">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_2" name="remark_2">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_3" name="remark_3">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_4" name="remark_4">
											</div>
										</div>
										<div class="form-row inline-pd mb5">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_5" name="remark_5">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" maxlength="100" id="remark_6" name="remark_6">
											</div>
										</div>
									</td>
								</tr>	
								<tr>
									<th class="text-right essential-item">Attn</th>
									<td>
										<input type="text" class="form-control essential-bg" maxlength="40" id="client_charge_name" name="client_charge_name" alt="Attn"  required="required">
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">CC</th>
									<td>
										<input type="text" class="form-control essential-bg" maxlength="40" id="client_rep_name" name="client_rep_name" alt="CC"  required="required">
									</td>
									<th class="text-right essential-item">RE</th>
									<td>
										<input type="text" class="form-control essential-bg" maxlength="60" id="order_remark" name="order_remark" alt="RE"  required="required">
									</td>
								</tr>
								<tr>
									<th class="text-right">합계금액</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-4">
												<input type="text" class="form-control text-right width180px" readonly name="total_amt" id="total_amt" format="decimal" alt="합계금액"  required="required">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
									<th class="text-right">입고예정일</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width100px calDate" id="in_plan_dt" name="in_plan_dt" dateformat="yyyy-MM-dd" alt="입고예정일">
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">참고</th>
									<td colspan="3">
										<input type="text" class="form-control" maxlength="80" id="desc_text" name="desc_text">
									</td>
								</tr>
<!-- 								<tr> -->
<!-- 									<th class="text-right essential-item">To</th> -->
<!-- 									<td> -->
<!-- 										<div class="input-group"> -->
<!-- 											<input type="text" class="form-control border-right-0 width200px" id="cust_name" name="cust_name" readonly alt="To"  required="required"> -->
<!-- 											<input type="hidden" id="client_cust_no" name="client_cust_no"> -->
<!-- 											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button> -->
<!-- 										</div> -->
<!-- 									</td> -->
<!-- 									<th class="text-right">합계금액</th> -->
<!-- 									<td> -->
<!-- 										<div class="form-row inline-pd"> -->
<!-- 											<div class="col-5"> -->
<!-- 												<input type="text" class="form-control text-right" readonly name="total_amt" id="total_amt" format="decimal" datatype="int" alt="합계금액" > -->
<!-- 											</div> -->
<!-- 											<div class="col-2">원</div> -->
<!-- 										</div> -->
<!-- 									</td> -->
<!-- 									<th class="text-right">입고예정일</th> -->
<!-- 									<td> -->
<!-- 										<div class="input-group"> -->
<!-- 											<input type="text" class="form-control border-right-0 width100px calDate" id="in_plan_dt" name="in_plan_dt" dateformat="yyyy-MM-dd" alt="입고예정일"> -->
<!-- 										</div> -->
<!-- 									</td> -->
<!-- 								</tr> -->
<!-- 								<tr> -->
<!-- 									<th class="text-right">참고</th> -->
<!-- 									<td colspan="5"> -->
<!-- 										<input type="text" class="form-control" maxlength="80" id="desc_text" name="desc_text"> -->
<!-- 									</td> -->
<!-- 								</tr> -->
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
							
							<div style="margin-top: 5px; height: 420px;" id="leftAuiGrid"></div>
<!-- /생산발주내역 -->
						</div>
<!-- /좌측 폼테이블 -->
<!-- 우측 폼테이블 -->
						<div class="col-6">
<!-- 옵션품목 -->
							<div class="title-wrap mt10">
								<h4>선적발주내역</h4>

							</div>
							<div style="margin-top: 5px; height: 420px;" id="rightAuiGrid"></div>
<!-- /옵션품목 -->

						</div>
<!-- /우측 폼테이블 -->
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