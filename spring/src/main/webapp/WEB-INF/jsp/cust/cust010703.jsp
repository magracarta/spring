<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 견적서관리 > 정비견적서등록 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-06 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	// 상담과 점검/정비
	var auiGridOrder;
	var auiGridParts;

	// 상담과 정검/정비 - 구분 dropbox
	var jobOrderTypeJson = JSON.parse('${codeMapJsonObj['JOB_ORDER_TYPE']}');

	var rowNum = 0;
	// 부품목록 금액 합계
	var planPartTotalAmt = 0;
	// 상담과 점검/정비 금액 합계
	var planWorkTotalAmt = 0;
	var workTotalAmt = 0;

	// var workTotalAmt = 0;

	$(document).ready(function() {
		if ( parent.fnStyleChange )
			parent.fnStyleChange('N', 'add');

		fnSetExpireDt();
		// AUIGrid 생성
		createAUIGridOrder();
		createAUIGridParts();
		fnJobCaseTi();
	});

	function fnSetExpireDt() {
		var rfqDt = $M.getValue("rfq_dt");
		$M.setValue("expire_dt", $M.addDates($M.toDate(rfqDt), 30));
	}

	function fnSendMail() {
		var emailId = $M.getValue("email_id");
		var emailDomain = $M.getValue("email_domain");
		var emailAddress = emailId + "@" + emailDomain;

		var param = {
			"to" : emailAddress
		};
		openSendEmailPanel($M.toGetParam(param));
	}

	// 고객 및 장비정보 setting
	function fnSetCustInfo(data) {
		AUIGrid.clearGridData(auiGridParts);
		
		var param = {
			"s_cust_no" : data.cust_no
		};

		if(data.cust_no == "20130603145119670") {
			$("#rental_cust_btn").attr("disabled", false);
		} else {
			$("#rental_cust_btn").attr("disabled", true);
		}
		// 렌탈수리청구고객 초기화
		$M.setValue("rental_cust_no", "");
		$M.setValue("rental_cust_name", "");

		$M.goNextPageAjax(this_page + "/data/search", $M.toGetParam(param), {method : 'GET'},
			function(result) {
				if(result.success) {
					// 고객정보
					$M.setValue(result.custInfo);
					
	    			// VIP 판매가 적용
	    			$M.setValue("vip_yn", result.custInfo.vip_yn);
					if (result.custInfo.vip_yn == 'Y') {
						// 단가 헤더 속성값 변경하기
						AUIGrid.setColumnProp(auiGridParts, 6, {
							headerText : "단가(VIP)",
							headerStyle : "aui-vip-header",
							width : "8%",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right aui-editable",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false // 소수점(.) 입력 가능 설정
							},
						});
					} else {
						// 단가 헤더 속성값 변경하기
						AUIGrid.setColumnProp(auiGridParts, 6, {
							headerText : "단가(일반)",
							headerStyle : "aui-vip-header",
							width : "8%",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right aui-editable",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false // 소수점(.) 입력 가능 설정
							},
						});
					}
					
					// select box 옵션 전체 삭제
					$("#machine_seq option").remove();

					var machineList = result.machineList;
					if (machineList.length > 0) {
						for (item in machineList) {
							// 차대번호의 고객이 보유하고 있는 List 추가.
							$("#machine_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_seq));
						}
						fnMachineListChange();
					}
				}
			}
		);
	}

	// 장비 상세정보 조회
	function fnMachineListChange() {
		var param = {
			"s_machine_seq" : $M.getValue("machine_seq")
		}
		$M.goNextPageAjax(this_page + "/machineInfo", $M.toGetParam(param), {method : 'GET'},
			function(result) {
				if(result.success) {
					// SA-R 장비일 시 운행정보 버튼 노출
					if(result.machineInfo.sar_yn == "Y") {
						$("#sar_oper_btn").css("display", "inline-block");
					} else {
						$("#sar_oper_btn").css("display", "none");
					}

					$M.setValue(result.machineInfo);
				}
			}
		);
	}

	// 견적 사업장 조회
	function fnSetOrgMapPanel(row) {
		$M.setValue("rfq_org_name", row.org_name);
		$M.setValue("rfq_org_code", row.org_code);
		$M.goNextPageAjax("/rfq/office/"+row.org_code, "", {method : 'GET'},
			function(result) {
				if(result.success) {
					var office = {
						office_post_no : result.post_no,
						office_addr1 : result.addr1,
						office_addr2 : result.addr2,
						office_fax_no : result.fax_no
					}
					$M.setValue(office);

					fnPhoneSetting(result); // 전화번호 셋팅
				}
			}
		);
	}

	// 견적사업장 전화번호 셋팅
	function fnPhoneSetting(result) {
		// 옵션 초기화
		$("#office_tel_no").children('option').remove();

		// 전화번호 배열 받기
		var originPhoneArr = [result.tel_no, result.service_tel_no, result.part_tel_no];
		var copyPhoneArr = [result.tel_no + " (전화 번호)", result.service_tel_no + " (서비스 담당자 번호)", result.part_tel_no + " (부품/렌탈 담당자 번호)"];

		// 배열 크기만큼 option 생성
		for (var i = 0; i < originPhoneArr.length; i++) {
			if (originPhoneArr[i] != '') { // 배열에 번호가 있다면
				console.log(originPhoneArr[i]);
				$("#office_tel_no").append('<option value="' + originPhoneArr[i] + '">' + copyPhoneArr[i] + '</option');
			}
		}
	}

	// 자주쓰는작업
	function goBookmark() {
		var param = {
			"parent_js_name" : "fnSetJobReportOrder"
		};

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=650, left=0, top=0";
		$M.goNextPage('/serv/serv0101p11', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 상담과 점검/정비 -> 정비불러오기 팝업
	function goBookmarkRepair() {
		if($M.getValue("machine_plant_seq") == "") {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}
		var param = {
			"s_machine_plant_seq" : $M.getValue("machine_plant_seq"),
		};
		param.parent_js_name = "fnSetJobReportOrder";
		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=650, left=0, top=0";
		$M.goNextPage('/serv/serv0101p18', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 자주쓰는작업 data Setting
	function fnSetJobReportOrder(data) {
		var item = new Object();
		var parentRowId = null;
		var planWorkAmt = 0;
		var planWorkTotalAmt = $M.toNum($M.getValue("plan_work_total_amt"));
		for(var i=0; i<data.length; i++) {

			// 비용 - 공임(예상) 계산
			planWorkAmt = $M.toNum(data[i].item.plan_work_amt);
			planWorkTotalAmt += planWorkAmt;


			item.job_order_type_cd = data[i].item.job_order_type_cd;
			item.order_text = data[i].item.order_text;
			item.plan_work_amt = planWorkAmt;
			item.work_amt = 0;
			item.work_hour = data[i].item.work_hour;
			item.rfq_repair_order_seq = data[i].item.job_order_bookmark_seq;
			item.up_rfq_repair_order_seq = data[i].item.up_job_order_bookmark_seq;
			item.bookmark_type_jr = data[i].item.bookmark_type_jr;
			item.break_part_seq = data[i].item.break_part_seq;
			item.row_num = rowNum;
			if(data[i].item._$depth == 1) {
				AUIGrid.addRow(auiGridOrder, item, 'first');

				var selectedItems = AUIGrid.getSelectedItems(auiGridOrder);
				var selItem = selectedItems[0].item;
				parentRowId = selItem._$uid;
			} else {
				item.parentRowId = parentRowId;
				AUIGrid.addTreeRow(auiGridOrder, item, parentRowId, 'first');
			}

			rowNum++;
		}

		console.log(AUIGrid.getGridData(auiGridOrder));
		// 비용 - 공임(예상) Setting
		fnDiscountInit();
		fnChangeOrderAmt();
		fnCalcOrderWorkHour();
		fnChangePrice();
		fnChangeDCAmt();
	}

	// 비용반영
	function goApplyAmt() {
		var data = AUIGrid.getCheckedRowItems(auiGridOrder);

		if(data.length == 0) {
			alert("비용반영 처리 할 내용을 먼저 체크해 주세요.");
			return;
		}

		var workAmt = 0;
		// workTotalAmt = $M.toNum($M.getValue("work_total_amt"));
		var workTotalAmt = 0;

		for(var i in data) {
			workAmt = data[i].item.work_amt;
			workTotalAmt += workAmt;
		}

		$M.setValue("work_total_amt", workTotalAmt);
		fnChangePrice();
		fnChangeDCAmt();
	}

	// 상담과 점검/정비 행추가
	function fnAddPaid() {
// 		if(fnCheckOrderGridEmpty()) {
// 			var item = new Object();
// 			item.job_order_type_name = "";
// 			item.order_text = "";
// 			item.plan_work_amt = "";
// 			item.work_amt = "";
// 			item.work_hour = "";
// 			item.row_num = rowNum;

// 			rowNum++;
// 			AUIGrid.addRow(auiGridOrder, item, 'first');
// 		}
		
		for(var i=0; i<10; i++) {
            var item = new Object();
            item.job_order_type_cd = "REPAIR";
            item.order_text = "";
            item.plan_work_amt = "";
            item.work_amt = "";
            item.work_hour = "";
            item.up_rfq_repair_order_seq = "";
            item.rfq_repair_order_seq = 0;
			item.bookmark_type_jr = "J";
            item.row_num = rowNum;

            rowNum++;
            AUIGrid.addRow(auiGridOrder, item, 'last');
        }
	}

	// 상담과 점검/정비 필수 항목 체크
	function fnCheckOrderGridEmpty() {
		return AUIGrid.validateGridData(auiGridOrder, ["order_text", "plan_work_amt", "work_amt", "work_hour"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 비용 계산
	function fnChangePrice() {
		// 출장비(예상)
		var planTravelExpense = $M.toNum($M.getValue("travel_expense_max"));
		// 부품(예상)
		planPartTotalAmt = $M.toNum($M.getValue("plan_part_total_amt"));
		// 공임(예상)
		var planWorkTotalAmt = $M.toNum($M.getValue("plan_work_total_amt"));

		// 합계(예상)
		var planTotalAmt = planTravelExpense + planPartTotalAmt + planWorkTotalAmt;
		// VAT포함 총금액(예상)
		var planTotalVatAmt = Math.floor(planTotalAmt * 1.1); // 총금액(VAT포함) ㅣ 합계 + VAT

		$M.setValue("plan_travel_expense", $M.setComma(planTravelExpense));
		$M.setValue("plan_part_total_amt", $M.setComma(planPartTotalAmt));
		$M.setValue("plan_work_total_amt", $M.setComma(planWorkTotalAmt));

		$M.setValue("plan_total_amt", $M.setComma(planTotalAmt));
		$M.setValue("plan_total_vat_amt", $M.setComma(planTotalVatAmt));

		// 출장비(최종)
		var finalTravelExpense = $M.toNum($M.getValue("travel_final_expense"));
		// 부품(최종)
		var partTotalAmt = $M.toNum($M.getValue("part_total_amt"));
		// 공임(최종)
		var workTotalAmt = $M.toNum($M.getValue("work_total_amt"));

		// 합계(최종)
		var finalTotalAmt = finalTravelExpense + partTotalAmt + workTotalAmt;
		// VAT포함 총금액(최종)
		var finalTotalVatAmt = Math.floor(finalTotalAmt * 1.1); // 총금액(VAT포함) ㅣ 합계 + VAT

		$M.setValue("final_travel_expense", $M.setComma(finalTravelExpense));
		$M.setValue("part_total_amt", $M.setComma(partTotalAmt));
		$M.setValue("work_total_amt", $M.setComma(workTotalAmt));

		$M.setValue("final_total_amt", $M.setComma(finalTotalAmt));
		$M.setValue("final_total_vat_amt", $M.setComma(finalTotalVatAmt));

		$M.setValue("total_amt", $M.getValue("final_total_amt"));
	}

	function fnCalcOrderWorkHour() {
		var data = AUIGrid.getGridData(auiGridOrder);

		var workTotalHour = 0;
		for(var i in data) {
			if(data[i].order_cmd != "D") {
				workTotalHour += $M.toNum(data[i].work_hour);
			}
		}

		// 7. 비용 -> 공임(최종)
		$M.setValue("except_repair_hour", workTotalHour);
	}


	// 정비접수 - 정비종류
	function fnJobCaseTi() {
		var jobCaseTChk = $M.getValue("job_case_ti");

		if(jobCaseTChk == 'T') {
			$("#svc_travel_expense").prop("disabled", false);
			$("#distance_min").prop("readonly", false);
			$("#distance_max").prop("readonly", false);
			$("#travel_expense_min").prop("readonly", false);
			$("#travel_expense_max").prop("readonly", false);
			$("#travel_area_name").prop("readonly", false);
			$("#travel_km").prop("readonly", false);
			$("#travel_ynf_y").prop("disabled", false);
			$("#travel_ynf_n").prop("disabled", false);
			$("#travel_ynf_f").prop("disabled", false);
			$("#in_dt").prop("disabled", true);

			fnTravelYnf();
		} else {
			$("#svc_travel_expense").prop("disabled", true);
			$M.setValue("svc_travel_expense", "");
			$("#distance_min").prop("readonly", true);
			$M.setValue("distance_min", "");
			$("#distance_max").prop("readonly", true);
			$M.setValue("distance_max", "");
			$("#travel_expense_min").prop("readonly", true);
			$M.setValue("travel_expense_min", "");
			$("#travel_expense_max").prop("readonly", true);
			$M.setValue("travel_expense_max", "");
			$("#travel_area_name").prop("readonly", true);
			$M.setValue("travel_area_name", "");
			$("#travel_km").prop("readonly", true);
			$M.setValue("travel_km", "");
			$("#travel_expense").prop("readonly", true);
			$("#travel_discount_amt").prop("readonly", true);
			$("#travel_final_expense").prop("readonly", true);
			$("#travel_ynf_y").prop("disabled", true);
			$("#travel_ynf_n").prop("disabled", true);
			$("#travel_ynf_f").prop("disabled", true);
			$("#in_dt").prop("disabled", false);
			$("#in_dt").prop("readonly", false);
		}
	}

	// 출장지역 setting
	function fnSetSvcInfo() {
		var svcTravel = $M.getValue("svc_travel_expense");
		var svcTravelArr = svcTravel.split("#");

		$M.setValue("svc_travel_expense_seq", svcTravelArr[0]);
		$M.setValue("distance_min", svcTravelArr[1]);
		$M.setValue("distance_max", svcTravelArr[2]);
		$M.setValue("travel_expense_min", svcTravelArr[3]);
		$M.setValue("travel_expense_max", svcTravelArr[4]);

		fnChangePrice();
	}

	// 출장정보 - 출장비(최종)
	function fnTravelYnf() {
		var travelYnfNChk = $("input:radio[id='travel_ynf_n']").is(":checked");

		if(travelYnfNChk) {
			$("#travel_expense").prop("readonly", false);
			$("#travel_discount_amt").prop("readonly", false);
		} else {
			$("#travel_expense").prop("readonly", false);
			$("#travel_discount_amt").prop("readonly", true);
		}
	}

	// 출장비용 계산
	function fnChangeTravelPrice() {
		// 출장비용 - 비용
		var travelExpense = $M.toNum($M.getValue("travel_expense"));
		// 출장비용 - 할인
		var travelDiscountAmt = $M.toNum($M.getValue("travel_discount_amt"));

		if(travelDiscountAmt > travelExpense) {
			alert("할인액이 비용을 초과할 수 없습니다.");
			$M.clearValue({field : ["travel_expense", "travel_discount_amt", "travel_final_expense"]});
			return;
		}

		// 출장비용 - 최종
		var travelFinalExpense = travelExpense - travelDiscountAmt;
		$M.setValue("travel_final_expense", $M.setComma(travelFinalExpense));

		fnChangePrice();
		fnChangeDCAmt();
	}

	// 지도보기
	function goMove() {
		var params = [{}];
		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
		$M.goNextPage('https://map.naver.com', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	// 부품 행추가.
	function fnAdd() {
		if ($M.getValue("cust_no") == "") {
			alert("고객 선택 후 진행해 주세요.");
			return false;
		}
		
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridParts, "part_no");
		fnSetCellFocus(auiGridParts, colIndex, "part_no");
		var item = new Object();
		if(fnCheckGridEmpty(auiGridParts)) {
			// item.seq_no = AUIGrid.getGridData(auiGridParts).length+1,
			item.seq_no = 0,
			item.part_no = "",
			item.part_name = "",
			item.part_unit = "",
			item.current_qty = "",
			item.qty = 1,
			item.unit_price = "",
			item.amount = "",
			item.out_dt = "",
			item.misu_qty = "",
			item.remark = "",
			item.removeBtn = "",
			item.part_name_change_yn = "N",
			item.part_production_cd = "0"
			AUIGrid.addRow(auiGridParts, item, 'last');
		}
	}
	
	// 부품조회
	function goPartList() {
		if ($M.getValue("cust_no") == "") {
			alert("고객 선택 후 진행해 주세요.");
			return false;
		}
		
		var items = AUIGrid.getAddedRowItems(auiGridParts);
		for (var i = 0; i < items.length; i++) {
			if (items[i].part_no == "") {
				alert("추가된 행을 입력하고 시도해주세요.");
				return;
			}
		}

		if(fnCheckGridEmpty(auiGridParts)) {
			openSearchPartPanel('setPartInfo', 'Y');
		}
	}

	// 그리드 빈값 체크
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGridParts, ["part_no", "part_name", "qty", "unit_price"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 부품 조회 후 Setting
	function setPartInfo(rowArr) {
		var params = AUIGrid.getGridData(auiGridParts);
		// 부품조회 창에서 받아온 값 중복체크
		for (var i = 0; i < rowArr.length; i++ ) {
			var rowItems = AUIGrid.getItemsByValue(auiGridParts, "part_no", rowArr[i].part_no);
			if (rowItems.length != 0){
// 				alert("부품번호를 다시 확인하세요.\n" + rowArr[i].part_no + " 이미 입력한 부품번호입니다.");
				return "부품번호를 다시 확인하세요.\n" + rowArr[i].part_no + " 이미 입력한 부품번호입니다.";
			}
		}

		var partNo ='';
		var partName ='';
		var unitPrice ='';
		var vipSalePrice ='';
		var qty = 1;
		var row = new Object();
		if(rowArr != null) {
			for(i=0; i < rowArr.length; i++) {
				// row.seq_no = AUIGrid.getGridData(auiGridParts).length+1;
				row.seq_no = 0;
				partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
				partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
				row.part_no = partNo;
				row.part_name = partName;
				row.qty = qty;
				
				if ($M.getValue("vip_yn") == 'Y') {
					row.unit_price = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice : rowArr[i].vip_sale_price;
				} else {
					row.unit_price = typeof rowArr[i].unit_price == "undefined" ? unitPrice : rowArr[i].sale_price;
				}
				
				row.part_production_cd = "0";
				row.part_name_change_yn = rowArr[i].part_name_change_yn;
				AUIGrid.addRow(auiGridParts, row, 'last');
			}
			fnDiscountInit();
			fnChangePartsAmt();
			fnChangePrice();
			fnChangeDCAmt();
		}
	}
	
    // SET조회 창 열기
    function goSearchSet() {
		var items = AUIGrid.getAddedRowItems(auiGridParts);
		for (var i = 0; i < items.length; i++) {
			if (items[i].part_no == "") {
				alert("추가된 행을 입력하고 시도해주세요.");
				return;
			}
		}

		if(fnCheckGridEmpty(auiGridParts)) {
			var popupOption = "";
			var param = {
					"cust_no" : $M.getValue("cust_no"),
					"parent_js_name" : "fnSetInputPart"
			};
			
			$M.goNextPage('/part/part0703p03', $M.toGetParam(param), {popupStatus : popupOption});
		}
    }
    
	 // 부품대량입력 팝업
    function fnMassInputPart() {
		if($M.getValue("machine_seq") == "") {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}
    	
		var popupOption = "";
		var param = {
				"cust_no" : $M.getValue("cust_no"),
				"parent_js_name" : "fnSetInputPart"
		};
		
		$M.goNextPage('/cust/cust0201p06', $M.toGetParam(param), {popupStatus : popupOption});
    	
    }

	
	// 부품대량입력, SET조회 데이터 세팅
    function fnSetInputPart(rowArr) {
		var partNo ='';
		var partName ='';
		var qty = 1;
		var salePrice = 0;
		var amount = 0;
		var unitPrice = 0;
		var vipSalePrice = 0;
		var row = new Object();
		
		if(rowArr != null) {
			for(i=0; i < rowArr.length; i++) {
				// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
				if ($M.getValue("vip_yn") == 'Y') {
                    salePrice = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice	: rowArr[i].vip_sale_price;
				} else {
					salePrice = typeof rowArr[i].sale_price == "undefined" ? salePrice	: rowArr[i].sale_price;
				}
				
				// row.seq_no = AUIGrid.getGridData(auiGridParts).length+1;
				row.seq_no = 0;
				partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
				partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
				row.part_no = partNo;
				row.part_name = partName;
				row.qty = qty;
				row.unit_price = salePrice;
				row.part_production_cd = "0";
				row.part_name_change_yn = rowArr[i].part_name_change_yn;

				AUIGrid.addRow(auiGridParts, row, 'last');
			}
		}
		
		fnDiscountInit();
		fnChangePartsAmt();
		fnChangePrice();
		fnChangeDCAmt();
    }
	

	// 부가세는 할인액을 반영한 금액의 10%
	// 최종금액은 할인액을 반영한 금액에서 부가세를 더함
	// 할인율 변경
	function fnChangeDCRate() {
		var totalAmt = $M.toNum($M.getValue("total_amt"));
		var rate = $M.toNum($M.getValue("discount_rate"));
		if (rate > 100) {
			alert("할인율은 최대 100입니다.");
			$M.setValue("discount_rate", "100");
			fnChangeDCRate();
			return false;
		}
		if (totalAmt == 0 || rate == 0) {
			var vat = Math.floor(totalAmt * 0.1);
			var calc = {
				rfq_amt : $M.setComma(Math.round(totalAmt+vat)),
				vat : $M.setComma(vat),
				discount_amt : "0"
			}
			$M.setValue(calc);
			return false;
		} else {
			var savePrice = totalAmt*rate/100;
			var resultPrice = totalAmt-savePrice;
			var vat = Math.floor(resultPrice*0.1);
			var calc = {
				rfq_amt : $M.setComma(Math.round(resultPrice+vat)),
				vat : $M.setComma(vat),
				discount_amt : $M.setComma(savePrice)
			}
			$M.setValue(calc);
		}
	}

	// 부가세는 할인액을 반영한 금액의 10%
	// 최종금액은 할인액을 반영한 금액에서 부가세를 더함
	// 할인액 변경
	function fnChangeDCAmt() {
		var totalAmt = $M.toNum($M.getValue("total_amt"));
		var saveAmt = $M.toNum($M.getValue("discount_amt"));
		if (saveAmt > totalAmt) {
			alert("할인액은 최종판매가("+$M.setComma(totalAmt)+")를 초과할 수 없습니다.");
			$M.setValue("discount_amt", totalAmt);
			fnChangeDCAmt();
			return false;
		}
		if (totalAmt == 0 || saveAmt == 0) {
			var vat = Math.floor(totalAmt*0.1);
			var calc = {
				rfq_amt :  $M.setComma(Math.round(totalAmt+vat)),
				vat : $M.setComma(vat),
				discount_rate : "0"
			}
			$M.setValue(calc);
			return false;
		} else {
			var resultPrice = totalAmt-saveAmt;
			var saveRate = 100 - (resultPrice/totalAmt * 100);
			var vat = Math.floor(resultPrice*0.1);
			var calc = {
				rfq_amt : $M.setComma(Math.round(resultPrice+vat)),
				vat : $M.setComma(vat),
				discount_rate : saveRate
			}
			$M.setValue(calc);
		}
	}

	// 할인 초기화
	function fnDiscountInit() {
		var param = {
			discount_rate : "",
			discount_amt : ""

		}
		$M.clearValue();
		$M.setValue(param);
	}

	// 저장
	function goSave() {
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm,
				{field:["machine_seq", "cust_name", "rfq_dt", "expire_dt", "job_case_ti"]})==false) {
			return;
		};

		var jobCaseTi = $M.getValue("job_case_ti");
		// var inDt = $M.getValue("in_dt");
		var svcTravelExpense = $M.getValue("svc_travel_expense");
		var travelYnf = $M.getValue("travel_ynf");
		var travelExpense = $M.getValue("travel_expense");
		if(jobCaseTi == "I") {
			// if(inDt == "") {
			// 	alert("입고일자는 필수 입력입니다.");
			// 	return;
			// }
		} else {
			if(svcTravelExpense == "") {
				alert("출장지역은 필수 입력입니다.");
				return;
			}

			// if(travelYnf == "") {
			// 	alert("출장비(최종)은 필수 입력입니다.");
			// 	return;
			// }

			if(travelExpense == "") {
				alert("출장비용 > 비용은 필수 입력입니다.");
				return;
			}
		}

		frm = $M.toValueForm(document.main_form);

		var concatCols = [];
		var concatList = [];
		var gridIds = [auiGridParts];
		for (var i = 0; i < gridIds.length; ++i) {
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		
		var orderData = [];
		var orderTempData = AUIGrid.exportToObject(auiGridOrder);
		for(var i = 0; i < orderTempData.length; i++) {
			var row = orderTempData[i];
			if ("" != row.order_text) {
				orderData.push(row);
			}
		}
		
		concatList = concatList.concat(orderData);
		concatCols = concatCols.concat(fnGetColumns(auiGridOrder));

		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);

		$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method : 'POST'},
			function (result) {
				console.log("result : ", result);
				fnList();
			}
		);
	}

	// 목록
	function fnList() {
		$M.goNextPage("/cust/cust010710");
	}

	// 작업지시 그리드
	function createAUIGridOrder() {
		var gridPros = {
			// 행 구별 필드명 지정
			rowIdField : "_$uid",
			editable : true,
			// 체크박스 출력 여부
			showRowCheckColumn : false,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : false,
			showStateColumn : true,
			treeColumnIndex : 0,
		};

		var columnLayout = [
			{
				headerText : "정검 및 정비 지시",
				dataField : "order_text",
				width : "50%",
				style : "aui-left",
			},
			{
				headerText : "예상비용",
				dataField : "plan_work_amt",
				width : "10%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right aui-editable",
				labelFunction : myLabelFunction,
			},
			{
				headerText : "발생비용",
				dataField : "work_amt",
				width : "10%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right aui-editable",
				labelFunction : myLabelFunction,
			},
			{
				headerText : "시간",
				dataField : "work_hour",
				width : "10%",
				dataType : "numeric",
				style : "aui-right aui-editable",
				labelFunction : myLabelFunction,
			},
			{
				headerText : "지시번호",
				dataField : "rfq_repair_order_seq",
				visible : false
			},
			{
				headerText : "상위지시번호",
				dataField : "up_rfq_repair_order_seq",
				visible : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == 0 || value == null ? "" : value;
				},
			},
			{
				headerText : "순서",
				dataField : "row_num",
				visible : false
			},
			{
				headerText : "작업분류",
				dataField : "break_part_seq",
				visible : false
			},
			{
				headerText : "작업구분",
				dataField : "bookmark_type_jr",
				visible : false
			},
			{
				headerText : "구분",
				dataField : "job_order_type_cd",
				visible : false
			},
			{
				headerText : "삭제",
				width : "10%",
				dataField : "removeBtn",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						// var isRemoved = AUIGrid.isRemovedById(auiGridOrder, event.item._$uid);
						// if (isRemoved == false) {
						// 	AUIGrid.removeRow(event.pid, event.rowIndex);
						// 	AUIGrid.update(auiGridOrder);
						// 	var workAmt = event.item.work_amt;
						// 	var workTotalAmt = $M.toNum($M.getValue("work_total_amt"));
						// 	workTotalAmt -= workAmt;
						// 	$M.setValue("work_total_amt", workTotalAmt);
						// } else {
						// 	AUIGrid.restoreSoftRows(auiGridOrder, "selectedIndex");
						// 	AUIGrid.update(auiGridOrder);
						// };
						var isRemoved = AUIGrid.isRemovedById(auiGridOrder, event.item._$uid);

						if(event.item.children != undefined){
							var children = event.item.children;
							for(var i=0;i<children.length;i++){
								var planWorkAmt = $M.toNum(children[i].plan_work_amt);
								planWorkTotalAmt -= planWorkAmt;

								var workAmt = $M.toNum(children[i].work_amt);
								workTotalAmt -= workAmt;
							}
						}else{
							// 공임 예상금액 Setting
							var planWorkAmt = $M.toNum(event.item.plan_work_amt);
							planWorkTotalAmt -= planWorkAmt;

							// 공임 최종금액 Setting
							var workAmt = $M.toNum(event.item.work_amt);
							workTotalAmt -= workAmt;
						}

						$M.setValue("plan_work_total_amt", planWorkTotalAmt);
						$M.setValue("work_total_amt", workTotalAmt);


						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridOrder);
						} else {
							AUIGrid.restoreSoftRows(auiGridOrder, "selectedIndex");
							AUIGrid.update(auiGridOrder);
						}
						fnDiscountInit();
						fnChangeOrderAmt();
						fnCalcOrderWorkHour();
						fnChangePrice();
						fnChangeDCAmt();
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

		// 실제로 #grid_wrap에 그리드 생성
		auiGridOrder = AUIGrid.create("#auiGridOrder", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridOrder, []);

		// 수량 변경 시 가격 변경
		AUIGrid.bind(auiGridOrder, "cellEditEnd", auiCellEditHandler);
		AUIGrid.bind(auiGridOrder, "cellEditBegin", auiCellEditHandler);
	}

	function auiCellEditHandler(event) {
		switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "part_no") {
					var isUnique = AUIGrid.isUniqueValue(auiGridParts, event.dataField, event.value);
					if (isUnique == false && event.value != "") {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGridParts, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
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
				var checkArr = ["plan_work_amt", "work_amt", "work_hour"]
				if(checkArr.indexOf(event.dataField) > -1 && event.item.bookmark_type_jr == 'R' && event.item.up_rfq_repair_order_seq != 0) {
					return false;
				}
				break;
			case "cellEditEnd" :
				if(event.dataField == "qty" || event.dataField == "unit_price") {
					fnChangePartsAmt();
				} else if(event.dataField == "plan_work_amt" || event.dataField == "work_amt") {
					fnChangeOrderAmt();
				}  else if (event.dataField == "work_hour") {
					fnCalcOrderWorkHour();
				} else if(event.dataField == "part_no") {
					// remote renderer 에서 선택한 값
					var item = fnGetPartItem(event.value);
					if(item === undefined) {
						AUIGrid.updateRow(auiGridParts, {part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						
						// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
						var unitPrice = 0;
						if ($M.getValue("vip_yn") == 'Y') {
							unitPrice = item.vip_sale_price;
						} else {
							unitPrice = item.sale_price;
						}						
						
						AUIGrid.updateRow(auiGridParts, {
							part_name : item.part_name,
							qty : 1,
// 							unit_price : item.sale_price,
							unit_price : unitPrice,
// 							total_amt : event.item.add_qty * item.sale_price,
							total_amt : event.item.add_qty * unitPrice,
							part_name_change_yn : item.part_name_change_yn
						}, event.rowIndex);
					}
					fnChangePartsAmt();
				}
				fnChangePrice();
				break;
		}
	}

	// 부품 금액 적용
	function fnChangePartsAmt() {
		var amount = AUIGrid.getColumnValues(auiGridParts, "amount");
		var totalAmt = sum(amount);
		$M.setValue("plan_part_total_amt", totalAmt);
		$M.setValue("part_total_amt", totalAmt);

		var qty = AUIGrid.getColumnValues(auiGridParts, "qty");
		var totalQty = sum(qty);
		$M.setValue("total_qty", totalQty);
	}

	// 상담과 점검/정비 금액 적용
	function fnChangeOrderAmt() {
		var planWorkAmt = AUIGrid.getColumnValues(auiGridOrder, "plan_work_amt");
		var workAmt = AUIGrid.getColumnValues(auiGridOrder, "work_amt");

		var totalPlanWorkAmt = sum(planWorkAmt);
		var totalWorkAmt = sum(workAmt);

		$M.setValue("plan_work_total_amt", totalPlanWorkAmt);
		$M.setValue("work_total_amt", totalWorkAmt);
	}

	// 단가 컬럼 sum
	function sum(array) {
		var result = 0.0;
		for (var i = 0; i < array.length; i++) {
			result += array[i];
		}
		return result;
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

	// 부품목록 그리드
	function createAUIGridParts() {
		var gridPros = {
			rowIdField : "_$uid",
			// rowNumber
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : true,
			editable : true,
		};
		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				width : "12%",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "ConditionRenderer",
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						var param = {
								's_search_kind' : 'DEFAULT_PART',
								's_warehouse_cd' : "${SecureUser.org_code}",
								's_only_warehouse_yn' : "N",
								's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : "1"
						};
						return fnGetPartSearchRenderer(dataField, param, "#auiGridParts");
					},
				},
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				width : "16%",
				style : "aui-center",
				editable : true
			},
			{
				headerText : "순번",
				dataField : "seq_no",
				visible : false
			},
			{
				headerText : "단위",
				dataField : "part_unit",
				width : "5%",
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "" || value == null ? "-" : value;
				},
			},
			{
				headerText : "현재고",
				dataField : "current_qty",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "" || value == null ? "-" : value;
				},
			},
			{
				headerText : "수량",
				dataField : "qty",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer",
					onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					min : 1,
					validator : AUIGrid.commonValidator
				},
			},
			{
				headerText : "단가",
				dataField : "unit_price",
				width : "8%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right aui-editable",
				editable : true,
				editRenderer : {
					type : "InputEditRenderer",
					onlyNumeric : true,
					autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					allowPoint : false // 소수점(.) 입력 가능 설정
				},
			},
			{
				headerText : "금액",
				dataField : "amount",
				width : "8%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				expFunction : function(  rowIndex, columnIndex, item, dataField ) {
					// 수량 * 단가 계산
					return ( item.qty * item.unit_price );
				}
			},
			{
				headerText : "출고일",
				dataField : "out_dt",
				width : "8%",
				formatString : "yyyy-mm-dd",
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "" || value == null ? "-" : value;
				},
			},
			{
				headerText : "미처리량",
				dataField : "misu_qty",
				dataType : "numeric",
				formatString : "#,##0",
				width : "5%",
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "" || value == null ? "-" : value;
				},
			},
			{
				headerText : "비고",
				dataField : "remark",
				style : "aui-left aui-editable",
				editable : true
			},
			{
				headerText : "부품생산구분",
				dataField : "part_production_cd",
				visible : false
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "4%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGridParts, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridParts);
						} else {
							AUIGrid.restoreSoftRows(auiGridParts, "selectedIndex");
							AUIGrid.update(auiGridParts);
						};
						fnDiscountInit();
						fnChangePartsAmt();
						fnChangePrice();
						fnChangeDCAmt();
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false,
			},
			{
				dataField : "part_name_change_yn",
				visible : false
			}
		];

		auiGridParts = AUIGrid.create("#auiGridParts", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridParts, []);
		// 추가행 에디팅 진입 허용
		AUIGrid.bind(auiGridParts, "cellEditBegin", function (event) {
			if (event.dataField == "part_name") {
				var changeYn = event.item.part_name_change_yn;
				if (changeYn == "Y") {
					return true;	 
				} else {
					return false;
				}
			}
			if (event.dataField == "part_no") {
				if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
					return true;
				} else {
					return false;
				}
			}
			if (event.dataField == "qty" || event.dataField == "unit_price" || event.dataField == "remark") {
				return true;
			} else {
				return false;
			}
		});
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridParts, "cellEditEndBefore", auiCellEditHandler);
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridParts, "cellEditEnd", auiCellEditHandler);
		// 에디팅 취소 이벤트 바인딩
		AUIGrid.bind(auiGridParts, "cellEditCancel", auiCellEditHandler);

		$("#auiGrid").resize();
	}

	   // 문자발송
	function fnSendSms() {
	   var param = {
			   'name' : $M.getValue('cust_name'),
			   'hp_no' : $M.getValue('hp_no')
	   }
	   openSendSmsPanel($M.toGetParam(param));
	}

    function go6() {
    	alert("부품조회 팝업 호출");
    }

	// SA-R 운행정보 팝업
	function goSarOperationMap(type) {
		if($M.getValue("machine_seq") == "") {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}

		var popupOption = "";
		var params = {
			s_type : type,
			machine_seq : $M.getValue("machine_seq")
		}
		$M.goNextPage('/sale/sale0205p04', $M.toGetParam(params), {popupStatus: popupOption});
	}

	function myLabelFunction(rowIndex, columnIndex, value, headerText, item) {
		if(item.bookmark_type_jr == 'R' && item.up_rfq_repair_order_seq != 0) {
			return "";
		}

		return value;
	}

	function fnSetRentalCust(data) {
		$M.setValue("rental_cust_no", data.cust_no);
		$M.setValue("rental_cust_name", data.cust_name);
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<input type="hidden" id="cust_no" name="cust_no" />
	<input type="hidden" id="email" name="email" />
	<input type="hidden" name="rfq_org_code" value="${SecureUser.org_code }"> <!-- 견적발행조직코드 -->
	<input type="hidden" name="rfq_mem_no" value="${SecureUser.mem_no }"><!-- 견적담당자 -->
	<input type="hidden" id="vip_yn" name="vip_yn" value=""><!-- VIP고객 여부 -->
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left">
					<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
 					<h2>정비 견적서등록</h2>
<%--					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>--%>
				</div>
			</div>
<!-- /상세페이지 타이틀 -->
			<div class="contents">
			<!-- 탭 -->
					<ul class="tabs-c">
<%--						<c:if test="${SecureUser.org_type ne 'AGENCY'}">--%>
						<c:if test="${page.fnc.F00608_001 ne 'Y'}">
							<li class="tabs-item">
								<a href="/cust/cust010702" class="tabs-link">수주</a>
							</li>
							<li class="tabs-item">
								<a href="/cust/cust010704" class="tabs-link">렌탈</a>
							</li>
							<li class="tabs-item">
								<a  href="/cust/cust010703" class="tabs-link active">정비</a>
							</li>
						</c:if>
<%--						<li class="tabs-item">--%>
<%--							<a href="/cust/cust010701" class="tabs-link">장비</a>--%>
<%--						</li>--%>
					</ul>
			<!-- /탭 -->
			<!-- 상단 폼테이블 -->					
					<div>
						<table class="table-border">
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
									<th class="text-right">견적번호</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-auto">
												<input type="text" id="rfq_no_1" name="rfq_no_1" class="form-control" readonly="readonly" value="">
											</div>
											
										</div>
									</td>	
									<th class="text-right rs">견적일자</th>
									<td>
										<div class="input-group ">
											<input type="text" class="form-control border-right-0 width120px calDate rb" id="rfq_dt" name="rfq_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_current_dt}" alt="견적일자" required="required" readonly="readonly" onchange="javascript:fnSetExpireDt()">
										</div>
									</td>	
									<th class="text-right">업체명</th>
									<td>
										<input type="text" class="form-control width120px" id="breg_name" name="breg_name" readonly="readonly">
									</td>	
									<th class="text-right">대표자</th>
									<td>
										<input type="text" class="form-control width120px" id="breg_rep_name" name="breg_rep_name" readonly="readonly">
									</td>									
								</tr>
								<tr>
									<th class="text-right rs">고객명</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width120px" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="openSearchCustPanel('fnSetCustInfo');" ><i class="material-iconssearch"></i></button>
										</div>
									</td>	
									<th class="text-right">휴대폰</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width140px rb" id="hp_no" name="hp_no" format="phone" required="required" alt="휴대폰">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();" ><i class="material-iconsforum"></i></button>
										</div>
									</td>
									<th class="text-right">사업자번호</th>
									<td>
										<input type="text" class="form-control width120px" readonly="readonly" id="breg_no" name="breg_no">
									</td>
									<th class="text-right">현미수</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width120px">
												<input type="text" class="form-control text-right width120px" readonly="readonly" format="decimal" id="misu_amt" name="misu_amt">
											</div>
											<div class="col-1">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">전화</th>
									<td>
										<input type="text" class="form-control width140px" readonly="readonly" id="tel_no" name="tel_no">
									</td>
									<th class="text-right">팩스</th>
									<td>
										<input type="text" class="form-control width140px" readonly="readonly" id="fax_no" name="fax_no">
									</td>
									<th class="text-right" rowspan="2">주소</th>
									<td colspan="3" rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="width100px" style="padding-left: 5px; padding-right: 5px">
												<input type="text" class="form-control" readonly="readonly" id="post_no" name="post_no">
											</div>
											<div class="col" style="width: calc(100% - 100px)">
												<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1">
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">이메일</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control" id="email_id" name="email_id">
											</div>
											<div class="col width16px text-center">@</div>
											<div class="col width100px">
												<input type="text" class="form-control" id="email_domain" name="email_domain">
											</div>
											<div class="col" style="width: calc(100% - 216px)">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendMail();"><i class="material-iconsmail"></i></button>
											</div>
										</div>
									</td>
									<th class="text-right rs">유효기간</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width120px calDate rb" id="expire_dt" name="expire_dt" required="required" alt="유효기간" dateFormat="yyyy-MM-dd" readonly="readonly">
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
			<!-- 장비정보 -->
					<div>
						<div class="title-wrap mt10">
							<h4>장비정보</h4>
						</div>
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
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right">차대번호</th>
								<td>
									<select class="form-control" id="machine_seq" name="machine_seq" onchange="fnMachineListChange()" required="required" alt="차대번호">
									</select>
								</td>
								<th class="text-right">엔진모델1</th>
								<td>
									<input type="text" class="form-control" id="engine_model_1" name="engine_model_1" readonly="readonly">
								</td>
								<th class="text-right">엔진모델2</th>
								<td>
									<input type="text" class="form-control" id="engine_model_2" name="engine_model_2" readonly="readonly">
								</td>
								<th class="text-right">옵션모델1</th>
								<td>
									<input type="text" class="form-control" id="opt_model_1" name="opt_model_1" readonly="readonly">
								</td>
								<th class="text-right">옵션모델2</th>
								<td>
									<input type="text" class="form-control" id="opt_model_2" name="opt_model_2" readonly="readonly">
								</td>
							</tr>
							<tr>
								<th class="text-right">장비모델</th>
								<td>
									<input type="text" class="form-control" readonly="readonly" id="maker_name" name="maker_name">
									<input type="hidden" id="maker_cd" name="maker_cd">
									<input type="hidden" id="body_no" name="body_no">
								</td>
								<th class="text-right">엔진번호1</th>
								<td>
									<input type="text" class="form-control" id="engine_no_1" name="engine_no_1" readonly="readonly">
								</td>
								<th class="text-right">엔진번호2</th>
								<td>
									<input type="text" class="form-control" id="engine_no_2" name="engine_no_2" readonly="readonly">
								</td>
								<th class="text-right">옵션번호1</th>
								<td>
									<input type="text" class="form-control" id="opt_no_1" name="opt_no_1" readonly="readonly">
								</td>
								<th class="text-right">옵션번호2</th>
								<td>
									<input type="text" class="form-control" id="opt_no_2" name="opt_no_2" readonly="readonly">
								</td>
							</tr>
							</tbody>
						</table>						
					</div>
			<!-- /장비정보 -->
					<div>
			<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>견적사업장</h4>
					</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
			
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
							<th class="text-right rs">부서</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control width120px border-right-0" id="rfq_org_name" name="rfq_org_name" readonly="readonly" value="${SecureUser.org_name }" alt="부서" required="required">
									<button type="button" class="btn btn-icon btn-primary-gra width120px" onclick="javascript:openOrgMapPanel('fnSetOrgMapPanel');" ><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right rs">견적자</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="rfq_mem_name" name="rfq_mem_name" value="${SecureUser.user_name}">
							</td>
							<th class="text-right">전화</th>
							<td>
								<select class="form-control width280px" id="office_tel_no" name="office_tel_no">
									<c:forEach var="item" items="${origin_office_phone}" varStatus="status">
										<option value="${item}">${copy_office_phone[status.index]}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">팩스</th>
							<td>
								<input type="text" class="form-control width140px" readonly="readonly" id="office_fax_no" name="office_fax_no">
							</td>
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="3">
								<div class="form-row inline-pd mb7">
									<div class="width100px" style="padding-left: 5px; padding-right:5px;">
										<input type="text" class="form-control" readonly="readonly" id="office_post_no" name="office_post_no" value="${office_addr.post_no}">
									</div>
									<div class="col" style="width: calc(100% - 110px)">
										<input type="text" class="form-control" readonly="readonly" id="office_addr1" name="office_addr1" value="${office_addr.addr1}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col">
										<input type="text" class="form-control" readonly="readonly" id="office_addr2" name="office_addr2" value="${office_addr.addr2}">
									</div>
								</div>
							</td>
							<th class="text-right">특이사항</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 97px; resize: none;" id="memo" name="memo">${rfq_default_memo}</textarea>
							</td>
						</tr>
						</tbody>
						</table>						
					</div>
			<!-- /상단 폼테이블 -->	
					<div class="row">
			<!-- 하단 좌측 폼테이블-->
					<div class="col-6">
			<!-- 상담과 점검/정비 -->							
			<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div>
							<div class="title-wrap mt10">
								<div class="left">
									<h4>상담과 점검/정비</h4>
								</div>
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
								</div>
							</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->							
							<div id="auiGridOrder" style="margin-top: 5px; height: 365px;"></div>
						</div>
			<!-- /상담과 점검/정비 -->							
						</div>
			<!-- /하단 좌측 폼테이블-->
			<!-- 하단 우측 폼테이블-->
						<div class="col-6">
			<!-- 그리드영역 -->	
			<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt10">
							<div class="left">
								<h4>견적내역</h4>
							</div>
							<div class="right">
								<button type="button" id="sar_oper_btn" style="display : none;" class="btn btn-primary-gra" onclick="javascript:goSarOperationMap('OPERATION');">SA-R 운행정보</button>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
						<table class="table-border mt5" style="height: 200px;">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right rs">정비종류</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="job_case_ti" name="job_case_ti" value="I" checked="checked" onclick="javascript:fnJobCaseTi()" required="required" alt="정비종류">
											<label class="form-check-label">입고</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="job_case_ti"  name="job_case_ti" value="T" onclick="javascript:fnJobCaseTi()" required="required" alt="정비종류">
											<label class="form-check-label">출장</label>
										</div>
									</td>
									<th class="text-right">입고일자</th>
									<td>
										<div class="input-group width120px">
											<input type="text" class="form-control border-right-0 calDate" id="in_dt" name="in_dt" dateFormat="yyyy-MM-dd">
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">정비예약시간</th>
									<td>
										<div class="col-4">
											<select class="form-control" id="reserve_repair_ti" name="reserve_repair_ti">
<%--												<option value="0830" selected="selected">08:30</option>--%>
												<c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
													<c:forEach var="min" varStatus="j" begin="0" end="1">
														<option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>">
															<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
														</option>
													</c:forEach>
												</c:forEach>
<%--												<option value="1800">18:00</option>--%>
											</select>
										</div>
									</td>
									<th class="text-right">예상정비시간</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" id="except_repair_hour" name="except_repair_hour" class="form-control text-right" readonly="readonly" value="${rfqRepair.except_repair_hour}">
											</div>
											<div class="col width33px">hr</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">출장지역</th>
									<td>
										<select id="svc_travel_expense" name="svc_travel_expense" class="form-control" disabled="disabled" onchange="javascript:fnSetSvcInfo();">
											<option value="">- 출장지역선택- </option>
											<c:forEach var="list" items="${list}">
												<option value="${list.svc_travel_info}">${list.area_name}</option>
											</c:forEach>
										</select>
									</td>
									<th class="text-right">출장위치</th>
									<td>
										<input type="text" id="travel_area_name" name="travel_area_name" class="form-control">
									</td>
								</tr>
								<tr>							
									<th class="text-right">출장비참조</th>
									<td colspan="3">
										<div class="form-row inline-pd widthfix">
											<div class="col width40px">
												거리
											</div>
											<div class="col width80px">
												<input type="text" id="distance_min" name="distance_min" class="form-control text-right width125px" placeholder="From" datatype="int" format="decimal" >
											</div>
											<div class="col width60px">
												km
											</div>
											<div class="col width80px">
												<input type="text" id="distance_max" name="distance_max" class="form-control text-right width125px" placeholder="To" datatype="int" format="decimal" >
											</div>
											<div class="col width60px">
												km,
											</div>

											<div class="col width40px pl5">
												금액
											</div>
											<div class="col width80px">
												<input type="text" id="travel_expense_min" name="travel_expense_min" class="form-control text-right width125px" placeholder="From" datatype="int" format="decimal" >
											</div>
											<div class="col width60px">
												원
											</div>
											<div class="col width80px">
												<input type="text" id="travel_expense_max" name="travel_expense_max" class="form-control text-right width125px" placeholder="To" datatype="int" format="decimal" onchange="javascript:fnChangePrice()">
											</div>
											<div class="col width60px">
												원
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">출장비용</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" id="travel_expense" name="travel_expense" class="form-control text-right" datatype="int" format="decimal" onchange="javascript:fnChangeTravelPrice();">
											</div>
											<div class="col width16px mr5">원</div>
											<input type="hidden" id="travel_discount_amt" name="travel_discount_amt" class="form-control text-right" datatype="int" format="decimal" onchange="javascript:fnChangeTravelPrice();">
											<input type="hidden" id="travel_final_expense" name="travel_final_expense" class="form-control text-right" datatype="int" format="decimal">
										</div>
									</td>
									<th class="text-right">출장거리</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" id="travel_km" name="travel_km" class="form-control text-right">
											</div>
											<div class="col width33px">km</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">렌탈수리청구고객</th>
									<td>
										<div class="form-row inline-pd pr">
											<div class="col-5">
												<div class="input-group">
													<input type="text" id="rental_cust_name" name="rental_cust_name" class="form-control border-right-0" readonly="readonly" alt="렌탈고객">
													<input type="hidden" id="rental_cust_no" name="rental_cust_no">
													<button type="button" id="rental_cust_btn" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetRentalCust');" disabled><i class="material-iconssearch"></i></button>
												</div>
											</div>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
			<!-- /그리드영역 -->
							<div class="title-wrap mt10">
								<h4>비용</h4>
							</div>
							<table class="table-border doc-table mt5">
								<colgroup>
									<col width="10%">
									<col width="18%">
									<col width="18%">
									<col width="18%">
									<col width="18%">
									<col width="18%">
								</colgroup>
								<thead>
								<tr>
									<th class="title-bg">구분</th>
									<th class="title-bg">출장비</th>
									<th class="title-bg">공임</th>
									<th class="title-bg">부품</th>
									<th class="title-bg">합계</th>
									<th class="title-bg">총금액<br>(VAT포함)</th>
								</tr>
								</thead>
								<tbody>
								<tr>
									<th>예상</th>
									<td>
										<input type="text" class="form-control text-right" id="plan_travel_expense" name="plan_travel_expense" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="plan_work_total_amt" name="plan_work_total_amt" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="plan_part_total_amt" name="plan_part_total_amt" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="plan_total_amt" name="plan_total_amt" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="plan_total_vat_amt" name="plan_total_vat_amt" format="decimal" readonly="readonly">
									</td>
								</tr>
								<tr>
									<th>최종</th>
									<td>
										<input type="text" class="form-control text-right" id="final_travel_expense" name="final_travel_expense" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="part_total_amt" name="part_total_amt" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="final_total_amt" name="final_total_amt" format="decimal" readonly="readonly">
									</td>
									<td>
										<input type="text" class="form-control text-right" id="final_total_vat_amt" name="final_total_vat_amt" format="decimal" readonly="readonly">
									</td>
								</tr>
								</tbody>
							</table>
			
					</div>
			<!-- /하단 우측 폼테이블-->
				</div>
			<!-- 부품추가 -->
				<div>
					<div class="title-wrap mt10">
						<div class="left">
							<h4>부품추가</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
					<div id="auiGridParts" style="margin-top: 5px; height: 150px;"></div>
				</div>
			<!-- /부품추가 -->							
			<!-- 합계그룹 -->
				<div class="row inline-pd mt10">
					<div class="col-2">
						<table class="table-border">
							<colgroup>
								<col width="40%">
								<col width="60%">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right th-sum">수량</th>
									<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="total_qty" name="total_qty" value="0" format="decimal"></td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="col-2">
						<table class="table-border">
							<colgroup>
								<col width="40%">
								<col width="60%">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right th-sum">금액</th>
									<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" value="0" format="decimal"></td>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="col-2">
						<table class="table-border">
							<colgroup>
								<col width="40%">
								<col width="60%">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right th-sum">할인율(%)</th>
								<td class="text-right"><input type="text" class="form-control text-right" id="discount_rate" name="discount_rate" value="0" onchange="fnChangeDCRate()" format="decimal"></td>
							</tr>
							</tbody>
						</table>
					</div>
					<div class="col-2">
						<table class="table-border">
							<colgroup>
								<col width="40%">
								<col width="60%">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right th-sum">할인액</th>
								<td class="text-right"><input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" value="0" onchange="fnChangeDCAmt()" format="decimal"></td>
							</tr>
							</tbody>
						</table>
					</div>
					<div class="col-2">
						<table class="table-border">
							<colgroup>
								<col width="50%">
								<col width="50%">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right th-sum">금액(부가세)</th>
								<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="vat" name="vat" value="0" format="decimal"></td>
							</tr>
							</tbody>
						</table>
					</div>
					<div class="col-2">
						<table class="table-border">
							<colgroup>
								<col width="50%">
								<col width="50%">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right th-sum">총견적금액</th>
									<td class="text-right td-gray"><div data-tip="(금액-할인액)*VAT"><input type="text" class="form-control text-right" readonly="readonly" id="rfq_amt" name="rfq_amt" value="0" format="decimal"></div></td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			<!-- /합계그룹 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">						
					<div class="right">
 						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
				</div>		
			</div>
			</div>						
		</div>		
<%--		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>--%>
	</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>