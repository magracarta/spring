<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 재고조정요청현황 > null > 재고조정요청서상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-08-19 13:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var partName = '';
		var apprStatus = "${apprBean.appr_proc_status_cd}"; // 결재상태 01:작성중  02:결재요청  03:결재중  04:반려  05:완료
		var partCnt = 0;
		var partAdjustJson = JSON.parse('${codeMapJsonObj['PART_ADJUST']}');		//부품조정사유

		$(document).ready(function() {

			// 그리드 생성
			createAUIGrid();
			fnCalcTotal();
			// 버튼 숨김여부 확인
			fnBtnHideChk();

			if(${page.add.AVG_PRICE_SHOW_YN ne 'Y'}) {
				//평균매입가는 권한있는 사람만 보여줌
				var hideList = ["sale_price", "sale_amt","buy_price","buy_amt"];
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
				$("#avg_price_sum").hide();
			}

		});

		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				showStateColumn : true,
				editableOnFixedCell : true,
				editable : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "부품번호",
				    dataField: "part_no",
				    width: "10%",
					style : "aui-center",
					required : true,
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
									s_search_kind : 'PART_ADJUST',
									s_warehouse_cd : "${SecureUser.org_code}"
							};
							return fnGetPartSearchRenderer(dataField, param);
						},
					},
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						var editable = "aui-editable";
						if (apprStatus == "01" ) {
							return editable;
						}
					}
				},
				{
					headerText : "부품명",
					dataField : "part_name",
				    width: "15%",
					style : "aui-left",
					editable : false
				},
				{
				    headerText: "저장위치",
				    dataField: "storage_name",
				    width: "10%",
					style : "aui-center",
					editable : false
				},
				{
				    headerText: "센터재고",
				    dataField: "current_stock",
				    style : "aui-center",
				 	dataType : "numeric",
				 	formatString : "#,##0",
				 	width : "8%",
				 	editable : false
				},
				{
					 headerText: "실사수량",
					 dataField: "check_stock",
					 style : "aui-center",
					 dataType : "numeric",
					 formatString : "#,##0",
					 width : "8%",
					 editable : true,
					 required : true,
					 styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						var editable = "aui-editable";
						if (apprStatus == "01" && ${SecureUser.mem_no == adjust.reg_id })  {
							return editable;
						}
					}
				},
				{
					headerText: "차이수량",
				    dataField: "diff_cnt",
				    style : "aui-center",
				 	dataType : "numeric",
				 	formatString : "#,##0",
				 	width : "8%",
				 	editable : false,
				 	required : true
				},
				{
				    dataField: "diff_amt",
				    visible : false
				},
				{
				    headerText: "사유",
				    dataField: "remark",
				    width: "15%",
					style : "aui-left",
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
					      maxlength : 100,
					      // 에디팅 유효성 검사
					      validator : AUIGrid.commonValidator

					},
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						var editable = "aui-editable";
						if (apprStatus == "01" && ${SecureUser.mem_no == adjust.reg_id }) {
							return editable;
						}
					}
				},
				{
				    headerText: "소비자가",
				    dataField: "sale_price",
				    style : "aui-right",
				 	dataType : "numeric",
				 	formatString : "#,##0",
				 	visible : true,
				 	editable : false
				},
				{
				    headerText: "금액",
				    dataField: "sale_amt",
					style : "aui-right",
				 	dataType : "numeric",
				 	formatString : "#,##0",
				 	visible : true,
					editable : false,
				},
				{
				    headerText: "평균매입가",
				    dataField: "buy_price",
				    style : "aui-right",
				 	dataType : "numeric",
				 	formatString : "#,##0",
				 	visible : true,
				 	editable : false
				},
				{
				    headerText: "금액",
				    dataField: "buy_amt",
				    style : "aui-right",
				 	dataType : "numeric",
				 	formatString : "#,##0",
				 	visible : true,
				 	editable : false
				},
				{
				    headerText: "승인코드",
				    dataField: "part_adjust_cd",
				    width: "8%",
				    style : "aui-center",
				    editable : true,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						list : partAdjustJson,
						keyField : "code_value",
						valueField : "code_name"
					},
					labelFunction : function(rowIndex, columnIndex, value){
						for(var i=0; i<partAdjustJson.length; i++){
							if(value == partAdjustJson[i].code_value){
								return partAdjustJson[i].code_name;
							}
							else if(value == "") {

								AUIGrid.updateRow(auiGrid, { "part_adjust_cd" : partAdjustJson[0].code_value }, rowIndex);

								return partAdjustJson[0].code_name;
								break;
							}
						}
						return value;
					}
				},
				{
				    headerText: "실사참조자료키",
				    dataField: "part_check_stock_seq",
				    width: "10%",
					style : "aui-center",
					editable : false,
				},
				{
				    dataField: "part_adjust_no",
				    visible : false
				},
				{

					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if (apprStatus != "01") {
								alert("작성중인 자료만 삭제가능합니다.");
								return false;
							} else {
								var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);
								} else {
									AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								}
								fnCalcTotal();
							}

						}

					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},

					style : "aui-center",
					editable : false
				}
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid,  ${listDtl});
			// AUIGrid.setFixedColumnCount(auiGrid, 2);

			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", auiCellEditHandler);
			// 에디팅 정상 종료전 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);

			AUIGrid.resize(auiGrid);


		}

		// 편집 핸들러 (부품)
		function auiCellEditHandler(event) {
			switch(event.type) {
			case "cellEditEndBefore" :
				// 작성중이 아니거나 본인이 아니면 아래 항목 수정 불가
				<%--if ((apprStatus != "01" && apprStatus != "03") || ('${lastApprMemNo}' != '${SecureUser.mem_no}' && '${adjust.reg_id}' != '${SecureUser.mem_no}') )  {--%>
				if ((apprStatus != "01" && apprStatus != "03") || (${page.fnc.F00863_001 ne 'Y'} && '${adjust.reg_id}' != '${SecureUser.mem_no}') )  {
					return false;
				<%--} else if (apprStatus == "03" && '${lastApprMemNo}' != '${SecureUser.mem_no}' )  {--%>
				} else if (apprStatus == "03" && ${page.fnc.F00863_001 ne 'Y'} )  {
					return false;
				}

				if(event.dataField == "part_no") {
					var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);
					if (isUnique == false && event.value != "") {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
						}, 1);
						return "";
					} else {
						if (event.value == "") {
							return event.oldValue;
						}
					}
				}
				break;
				case "cellEditBegin" :
					<%--if ((apprStatus != "01" && apprStatus != "03") || ('${lastApprMemNo}' != '${SecureUser.mem_no}' && '${adjust.reg_id}' != '${SecureUser.mem_no}'))  {--%>
					if ((apprStatus != "01" && apprStatus != "03") || (${page.fnc.F00863_001 ne 'Y'} && '${adjust.reg_id}' != '${SecureUser.mem_no}'))  {
						return false;
					<%--} else if (apprStatus == "03" && '${lastApprMemNo}' != '${SecureUser.mem_no}' )  {--%>
					} else if (apprStatus == "03" && ${page.fnc.F00863_001 ne 'Y'} )  {
						return false;
					}

					// Q&A 12621 작성중일때 사유수정 가능하도록 20210917 김상덕
					//재고실사참조로 가져온 값은 수정 불가
					if(event.dataField != "remark") {
						if(event.item.part_check_stock_seq != "" && event.dataField != "part_adjust_cd"){
							return false;
						}
					}

					if(event.dataField == "remark") {
						// 차이수량이 0아닌 경우에만 에디팅허용
						if(event.item.diff_cnt != 0) {
							return true;
						} else {
							return false;
						}
					}

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
								// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
								AUIGrid.updateRow(auiGrid, {
									part_name : item.part_name,
									storage_name :  item.storage_name,
									sale_price : item.sale_price,
									sale_amt : "0",
									current_stock : item.current_stock,
									diff_cnt : 0 - item.current_stock,
									diff_amt : item.sale_price * ( 0 - item.current_stock ),
									buy_price : item.in_avg_price,
									buy_amt : "0",
									part_check_stock_seq : "",
									part_adjust_cd : 10
								}, event.rowIndex);
							}

				    }

					//조사수량 , 차이수량 변경하기
					if(event.dataField == "check_stock") {

						//변경값 - 원래값
						var checkStockValue = event.value - event.oldValue;

						//수량이 변결될때만
						if ( event.value != event.oldValue ) {
							// 차이수량 갱신
						   	AUIGrid.updateRow(auiGrid, { "diff_cnt" : event.item.check_stock - event.item.current_stock }	, event.rowIndex );
							// 금액 갱신 ( 판매금액)
						   	AUIGrid.updateRow(auiGrid, { "sale_amt" : event.item.sale_price *  event.item.check_stock   }	, event.rowIndex );
						 	// 금액 갱신 ( 차이금액(판매가) )
						   	AUIGrid.updateRow(auiGrid, { "diff_amt" : event.item.sale_price * ( event.item.check_stock - event.item.current_stock ) }	, event.rowIndex );
						 	// 금액 갱신 ( 차이금액(매입가))
						   	AUIGrid.updateRow(auiGrid, { "buy_amt" : event.item.buy_price * ( event.item.check_stock - event.item.current_stock ) }	, event.rowIndex );
						}
						fnCalcTotal();

					}
					break;
				}
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


		// 총판매가,매입가, 요청품목수 ㄱㅖ산}
		function fnCalcTotal() {
			var saleTotalAmt = 0;
			var buyTotalAmt = 0;
			var overTotalAmt = 0;
			var underTotalAmt = 0;
			var adjustQty = 0;

			// 화면에 보여지는 그리드 데이터 목록
			var gridAllList = AUIGrid.getGridData(auiGrid);
			if(gridAllList.length > 0 ){

				for (var i = 0; i < gridAllList.length; i++) {

					if( gridAllList[i].diff_cnt != 0  ) {

						saleTotalAmt += Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].sale_price;
						buyTotalAmt +=  Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].buy_price;

						if(gridAllList[i].diff_cnt > 0){
							overTotalAmt += Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].buy_price;
						}
						else {
							underTotalAmt +=  Math.abs(gridAllList[i].diff_cnt) * gridAllList[i].buy_price;
						}
						adjustQty +=1;
					}
				}

				$M.setValue("sale_total_amt",saleTotalAmt);
				$M.setValue("buy_total_amt",buyTotalAmt);
				$("#lbl_buy_total_amt").text($M.setComma(buyTotalAmt));
				$("#lbl_over_total_amt").text($M.setComma(overTotalAmt));
				$("#lbl_under_total_amt").text($M.setComma(underTotalAmt));
				$M.setValue("adjust_qty",adjustQty);

			}
	 	}

		function fnBtnHideChk() {

			//작성중이 아니거나 등록자 본인이 아닌경우  등록관련 버튼 숨김처리
			if (apprStatus != "01" || ${SecureUser.mem_no != adjust.reg_id }){
				$("#btnRef").css({  display: "none"  });
				$("#btnHide").children().eq(1).css({  display: "none"  });
				$("#btnHide").children().eq(2).css({  display: "none"  });
				//$("#btnHide").children().eq(3).css({  display: "none"  });
			}

		}

		function goRefCheckStock() {

			var param = {
					s_warehouse_cd : "${SecureUser.org_code}"
			};

			var poppupOption = "";
			$M.goNextPage("/part/part0505p02", $M.toGetParam(param), {popupStatus : poppupOption});

		}

		// 실사참조 팝업에서 받아온 값
		function setCheckStockInfo(rowArr) {
			var params = AUIGrid.getGridData(auiGrid);
			// 실사참조 팝업에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", rowArr[i].part_no);
				 if (rowItems.length != 0){
					 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
					 return false;
				 }
			}

			var partNo ='';
			var partName ='';
			var partUnit ='';
			var outputCount ='';
			var storageName ='';
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					storageName = typeof rowArr[i].storage_name == "undefined" ? storageName : rowArr[i].storage_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.storage_name =   rowArr[i].storage_name;
					row.sale_price =  rowArr[i].sale_price;
					row.sale_amt =  rowArr[i].sale_price *  rowArr[i].current_stock;
					row.current_stock =  rowArr[i].current_stock;
					row.check_stock =  rowArr[i].check_stock;
					row.diff_cnt =  rowArr[i].diff_cnt;
					row.diff_amt =  rowArr[i].diff_amt;
					row.buy_price =  rowArr[i].buy_price;
					row.buy_amt =  rowArr[i].buy_amt;
					row.part_check_stock_seq =  rowArr[i].part_check_stock_seq;
					row.part_adjust_cd =   10;
					AUIGrid.addRow(auiGrid, row, 'last');
				}
			}
		}

		// 상신취소
		function goApprCancel() {
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				appr_cancel_yn : "Y"
			};
			openApprPanel("goApprovalResultCencel", $M.toGetParam(param));
		}

		function goApprovalResultCencel(result) {
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

			var gridAllList = AUIGrid.getGridData(auiGrid);
			for (var i = 0; i < gridAllList.length; i++) {
				if( gridAllList[i].part_adjust_cd == "") {

					AUIGrid.showToastMessage(auiGrid, i, 6, "결재시 승인코드는 필수값입니다.");
					return false;
				}
			}
			var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}"

			};
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}

		// 결재처리 결과
		function goApprovalResult(result) {

			// 반려이면 페이지 리로딩
			if(result.appr_status_cd == '03') {
				alert("반려가 완료되었습니다.");
				location.reload();
			}
			else if(result.appr_status_cd == '02') {

				var frm = fnChangeGridDataToForm(auiGrid);
				//최종결재자가 결재를 하는 경우 재고조정처리하기
				<%--if('${lastApprMemNo}' == '${SecureUser.mem_no}' ){--%>
				if(${page.fnc.F00863_001 eq 'Y'}){
					var partAdjustNo = $M.getValue("part_adjust_no");
					$M.goNextPageAjax(this_page+"/"+partAdjustNo+"/adjustProcess", frm, {method : 'POST'},
						function(result) {
				    		if(result.success) {
				    			alert("재고조정 처리가 완료되었습니다.");
				    			location.reload();
							}
						}
					);
				}
			}
			else{
				alert("처리가 완료되었습니다.");
	    		location.reload();
			}

		}


		//행추가
		function fnAdd() {

    		var item = new Object();
    		item.part_no = "";
    		item.part_name = "";
    		item.part_storage_seq = "";
    		item.current_stock = "";
    		item.check_stock = "";
    		item.diff_cnt = "";
    		item.remark = "";
    		item.sale_price = "0";
    		item.buy_price = "0";
    		item.buy_amt = "0";
    		item.sale_amt = "0";
    		item.part_check_stock_seq = "";
    		item.part_adjust_cd="10"
			AUIGrid.addRow(auiGrid, item, 'last');

		}

		function goPartList() {
			var items = AUIGrid.getAddedRowItems(auiGrid);
			for (var i = 0; i < items.length; i++) {
				if (items[i].part_no == "") {
					alert("추가된 행을 입력하고 시도해주세요.");
					return;
				}
			}
			if(fnCheckGridEmpty(auiGrid)) {

				var param = {
						s_warehouse_cd 	: "${SecureUser.org_code}" ,
						s_only_warehouse_yn : "Y"
					}
				openSearchPartPanel('setPartInfo', 'Y',$M.toGetParam(param));
			}
		}

		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
			var params = AUIGrid.getGridData(auiGrid);
			// 부품조회 창에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", rowArr[i].part_no);
				 if (rowItems.length != 0){
// 					 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
					 return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";
				 }
			}

			var partNo ='';
			var partName ='';
			var sale_price ='';
			var current_stock ='';
			var sale_amt ='';

			var row = new Object();
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					sale_price = typeof rowArr[i].cust_price == "undefined" ? sale_price : rowArr[i].cust_price;
					current_stock = typeof rowArr[i].part_warehouse_current == "undefined" ? current_stock : rowArr[i].part_warehouse_current;
					sale_amt = "0";

					row.part_no = partNo;
					row.part_name = partName;
					row.sale_price = sale_price;
					row.current_stock = current_stock;
					row.check_stock = "";
					row.sale_amt = sale_amt;
					row.buy_price = rowArr[i].part_avg_price;
					row.buy_amt = "0";
					row.storage_name = rowArr[i].storage_name;
					row.diff_cnt = 0 - current_stock;
					row.diff_amt = sale_price * ( 0 - current_stock );
					row.remark = "";
					row.part_check_stock_seq = "";
					row.part_adjust_cd = "10";
					AUIGrid.addRow(auiGrid, row, 'last');
				}
				fnCalcTotal();
			}
		}


		//결재요청버튼
		function goRequestApproval() {
			goSave('appr');
		}


		// 수정버튼
		function goModify() {
			goSave();
		}

		function goSave(appr) {
			var frm = document.main_form;
			if ($M.validation(frm) == false) {
				return false;
			}

			// 화면에 보여지는 그리드 데이터 목록
			var gridAllList = AUIGrid.getGridData(auiGrid);
			var getRemovedItems = AUIGrid.getRemovedItems(auiGrid);

			if(appr != "appr"){

				if (fnChangeGridDataCnt(auiGrid) == 0 ){
					alert("변경된 데이터가 없습니다.");
					return false;
				};

		    	// 벨리데이션
				if (fnCheckGridEmpty() === false){
					alert("필수 항목은 반드시 값을 입력해야합니다.");
					return false;
				}


				if(gridAllList.length < 1 ){
					alert("저장할 정보가 없습니다.");
					return false;
				}
			}

			// 21.09.01 (SR: 11878) 재고조정요청시 사유필수체크.
			for (var i = 0; i < gridAllList.length; i++) {
				if( gridAllList[i].diff_cnt == 0){
					AUIGrid.showToastMessage(auiGrid, i, 5, "차이수량이 없습니다");
					return;
				}


				if( gridAllList[i].diff_cnt != 0 && $.trim(gridAllList[i].remark) == '') {

					AUIGrid.showToastMessage(auiGrid, i, 6, "차이수량이 있는경우 사유 값은 필수값입니다.");
					return false;
				}
			}

			partCnt= gridAllList.length;
			partName = gridAllList[0].part_name;

			var msg = appr == "appr" ? "결재요청하시겠습니까?" : "수정하시겠습니까?";


			$M.setValue("count_remark",partName + " 외 " + partCnt + "건");

			var adjustQty = gridAllList.length - getRemovedItems.length;
			$M.setValue("adjust_qty", adjustQty);

			var frm = $M.toValueForm(frm);
			var gridForm = fnChangeGridDataToForm(auiGrid);

			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);

			var partAdjustNo = $M.getValue("part_adjust_no");

			appr = appr == undefined ? "modify" : appr;
			$M.setValue("save_mode", appr);
			$M.goNextPageAjaxMsg(msg, this_page+"/"+partAdjustNo+"/modify", gridForm, {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			//최종결재자가 결재요청을 하는경우
						<%--if('${lastApprMemNo}' == '${SecureUser.mem_no}' && appr == 'appr'){--%>
						if(${page.fnc.F00863_001 eq 'Y'}){
							var partAdjustNo = $M.getValue("part_adjust_no");
							$M.goNextPageAjax(this_page+"/"+partAdjustNo+"/adjustProcess", "", {method : 'POST'},
								function(result) {
						    		if(result.success) {
						    			alert("재고조정 처리가 완료되었습니다.");
						    			location.reload();
									}
								}
							);
						}
						else {
							alert("처리가 완료되었습니다.");
			    			location.reload();
						}
					}
				}
			);
		}

		function goRemove() {

			var apprProcStatusCd 	= $M.nvl($M.getValue("appr_proc_status_cd"), "");
			if ( apprProcStatusCd != "01") {
				alert("작성중인 자료만 삭제가능합니다.");
				return false;
			};

			var partAdjustNo = $M.getValue("part_adjust_no");

			$M.goNextPageAjaxRemove(this_page +"/"+ partAdjustNo + "/remove", "", {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("삭제에 성공했습니다.");
		    			fnClose();
					};
				}
			);
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validation(auiGrid);
		}

		function fnClose() {
			window.close();
		}

		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품재고조정요청 상세");
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">

   		<input type="hidden" id="save_mode" 			name="save_mode">
		<input type="hidden" id="appr_job_seq" 			name="appr_job_seq" 			value="${adjust.appr_job_seq}">
		<input type="hidden" id="part_adjust_no" 		name="part_adjust_no" 			value="${adjust.part_adjust_no}">
		<input type="hidden" id="appr_proc_status_cd" 	name="appr_proc_status_cd" 		value="${adjust.appr_proc_status_cd}">
		<input type="hidden" id="buy_total_amt" 		name="buy_total_amt" 			value="${adjust.buy_total_amt}">
		<input type="hidden" id="sale_total_amt" 		name="sale_total_amt" 			value="${adjust.sale_total_amt}">
		<input type="hidden" id="count_remark" 			name="count_remark" 			value="${adjust.count_remark}" >

<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 타이틀, 결재영역 -->
			<div class="approval">
				<div class="title-wrap approval-left">
					<h4 class="primary">재고조정요청서상세</h4>
					<div>
						<span class="condition-item">상태 :
							<c:choose>
								<c:when test="${'01' eq adjust.appr_proc_status_cd }">작성중</c:when>
								<c:when test="${'03' eq adjust.appr_proc_status_cd }">결재중</c:when>
								<c:when test="${'05' eq adjust.appr_proc_status_cd and  adjust.adjust_dt eq '' }">결재완료</c:when>
								<c:when test="${'05' eq adjust.appr_proc_status_cd and  adjust.adjust_dt ne '' }">반영완료</c:when>

								<c:otherwise>작성중</c:otherwise>
							</c:choose>
						</span>
					</div>
				</div>
<!-- 결재영역 -->
				<div style="width:40%; margin-left:10px">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->
			</div>
<!-- /타이틀, 결재영역 -->
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
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">요청번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-5">
										<input type="text" class="form-control" value="${ adjust.part_adjust_no }" readonly="readonly" >
									</div>
									<div class="col-3" id="btnRef">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goRefCheckStock();">실사참조</button>
									</div>
								</div>
							</td>
							<th class="text-right">요청창고</th>
							<td>
								<input type="text" class="form-control  width120px" id="warehouse_name" name="warehouse_name" value="${ adjust.warehouse_name }" readonly="readonly" >
							</td>
							<th class="text-right">요청품목수</th>
							<td>
								<input type="text" class="form-control  width100px text-right" value="${ adjust.adjust_qty }"  readonly="readonly" >
							</td>
							<th class="text-right">작성일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0  calDate" id="s_reg_dt"
											name="s_reg_dt"  alt="작성일" disabled="disabled"
											value="${ adjust.reg_date }" >
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">결재요청일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0  calDate" id="s_req_dt"
											name="s_req_dt" dateformat="yyyy-MM-dd" alt="결재요청일"  disabled="disabled"
											value="${adjust.appr_req_dt }">
								</div>
							</td>
							<th class="text-right">반영완료일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0  calDate" id="s_apply_dt"
											name="s_apply_dt" dateformat="yyyy-MM-dd" alt="반영완료일"  disabled="disabled"
											value="${adjust.adjust_dt}">
								</div>
							</td>
							<th rowspan="2" class="text-right">결재자의견</th>
							<td rowspan="2" colspan="3" class="v-align-top">
								<div style="min-height: 82px;">
									<!--  -->
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
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 100%;" id="remark_master" name="remark_master" ${adjust.appr_proc_status_cd != '01' ? 'readonly' : '' } >${adjust.remark}</textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->
			<div>
<!-- 부품내역 -->
				<div class="title-wrap mt10">
					<h4>부품내역</h4>
					<div id="btnHide" >
						<span class="text-warning">※  평균매입가는 매입자료에 따라 매일 업데이트 되며, 재고조정요청시 재고반영일 기준으로 최종저장되어 관리됩니다.</span>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>

				<div id="auiGrid" style="margin-top: 5px; height: 210px;"></div>
<!-- /부품내역 -->
			</div>
<!-- /하단 폼테이블 -->
<!-- 합계그룹 -->
			<div class="row inline-pd mt10"  id="avg_price_sum" name="avg_price_sum"  >
				<div class="col-3">
					<table class="table-border">
						<colgroup>
							<col width="100%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right"><label >금액(매입가)</label></th>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col-3">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">과다금액</th>
								<td class="text-right td-gray"><label id="lbl_over_total_amt" name="lbl_over_total_amt" format="decimal" ></label></td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col-3">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">부족금액</th>
								<td class="text-right td-gray"><label id="lbl_under_total_amt" name="lbl_under_total_amt" format="decimal" ></label></td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="col-3">
					<table class="table-border">
						<colgroup>
							<col width="40%">
							<col width="60%">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right th-sum">차이금액합계</th>
								<td class="text-right td-gray"><label id="lbl_buy_total_amt" name="lbl_buy_total_amt" format="decimal"  ></label></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
<!-- /합계그룹 -->
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="mem_no" value="${adjust.reg_id}"/>
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
