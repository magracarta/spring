<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 장비입금관리 > null > 입금처리 상세
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			fnInitPage();
			fnInitAgency();

			// 어음에서 입금처리일 시
			if("${inputParam.view}" == "bill") {
				fnDepositDate();
				fnCalcBillin();
			}
		});

		function fnInitAgency() {
			if("${managementYn}" == "Y") {
				$(".agencyYn").removeClass("dpn");
			} else {
				$(".agencyYn").addClass("dpn");
			}

		}

		function fnInitPage() {
			var info = ${info}
			$M.setValue(info);
			fnChangeStatus(info);
		}

		function fnChangeStatus(check) {
			var endYn = check.end_yn;
// 			var transYn = check.duzon_trans_yn;
// 			var endYn = "Y";
			if(endYn == "Y") {
				$(".end_check").removeClass("dpn");
			    $("#_goModify").hide();
			    $("#_goRemove").hide();
			    $(".dis_check").prop("disabled", true);
			} else {
			    $(".end_check").addClass("dpn");
			    $("#_goModify").show();
			    $("#_goRemove").show();
			    $(".dis_check").prop("disabled", false);
			}
		}

		// 입금일자 수정 시 실행 로직
// 		function fnDepositDate() {
// 			// 판매일자가 != ""
// 			if($M.getValue("out_dt") != "") {
// 				// 판매일자, 예정일, 입금일자
// 				var outDt = $M.getValue("out_dt");
// 				var planDt = $M.getValue("plan_dt");
// 				var depositDt = $M.getValue("deposit_dt");
// 				var rate;

// 				if(outDt >= depositDt) {
// 					$M.setValue("day_cnt", 0);
// 					$M.setValue("interest_rate", 0);
// 					$M.setValue("delay_amt", 0);
// 				} else {
// 					if($M.getValue("machine_pay_type_cd") == "CASH") {
// 						rate = $M.getValue("cash_rate");
// 						$M.setValue("interest_base_dt", $M.getValue("plan_dt"));
// 					} else if($M.getValue("machine_pay_type_cd") == "CARD") {
// 						rate = $M.getValue("card_rate");
// 					} else if($M.getValue("machine_pay_type_cd") == "FINANCE") {
// 						rate = $M.getValue("finance_rate");
// 					} else if($M.getValue("machine_pay_type_cd") == "USED") {
// 						rate = $M.getValue("used_rate");
// 					}

// 					var depositDt2 = $M.getValue("deposit_dt");
// 					depositDt2 = depositDt2.substring(0, 4) + '-' + depositDt2.substring(4, 6) + '-' + depositDt2.substring(6, 8);
// 					depositDt2 = depositDt2.split("-");
// 					depositDt2 = new Date(depositDt2[0], depositDt2[1]-1, depositDt2[2]);


// 					if(outDt < planDt) {
// 						if($M.getValue("machine_pay_type_cd") == "USED"){
// 							$M.setValue("interest_base_dt", $M.getValue("plan_dt"));
// 						}
// 					}

// 					var interestBaseDt = $M.getValue("interest_base_dt");
// 					interestBaseDt = interestBaseDt.substring(0, 4) + '-' + interestBaseDt.substring(4, 6) + '-' + interestBaseDt.substring(6, 8);
// 					interestBaseDt = interestBaseDt.split("-");
// 					interestBaseDt = new Date(interestBaseDt[0], interestBaseDt[1]-1, interestBaseDt[2]);

// 					var dayCnt = depositDt2.getTime() - interestBaseDt.getTime();

// 					dayCnt = Math.floor(dayCnt/(1000*60*60*24));

// 					if(dayCnt < 0){
// 						dayCnt = 0;
// 						if($M.getValue("machine_pay_type_cd") == "CASH"){
// 							rate = 0;
// 						}
// 					}

// 					$M.setValue("day_cnt", dayCnt);
// 					$M.setValue("interest_rate", rate);

// 					if(dayCnt > 1){
// 						var delayAmt = $M.toNum($M.toNum($M.getValue("misu_amt")) * $M.toNum($M.getValue("interest_rate")) / 36500 * $M.toNum(dayCnt));
// 						$M.setValue("delay_amt", delayAmt);
// 						var planDepositAmt = $M.toNum($M.toNum($M.getValue("delay_amt"))-$M.toNum($M.getValue("delay_discount_amt"))+$M.toNum($M.getValue("result_deposit_amt")));
// 						$M.setValue("plan_deposit_amt", planDepositAmt);
// 					} else {
// 						$M.setValue("delay_amt", 0);
// 					}

// 					if($M.toNum($M.getValue("delay_amt")) < 0){
// 						$M.setValue("delay_amt", 0);
// 					}
// 					if(planDt >= depositDt){		// 예정일자보다 앞으로 입금일자를 수정시에는 날자 및 이율, 지연금은 0으로 처리한다.
// 						$M.setValue("day_cnt", 0);
// 						$M.setValue("interest_rate", 0);
// 						$M.setValue("delay_amt", 0);
// 					}
// 				}
// 				fnCalcDiscountAmt();
// 			} else {
// 				$M.setValue("day_cnt", 0);
// 				$M.setValue("interest_rate", 0);
// 				fnCalcDiscountAmt();
// 			}

// 		}

		// 삭감액 입력 시 실입금액에서 차감
		// 실입금액 = 지연금-삭감액+미입금액
		// 원금입금액 = 실입금액-(지연금+삭감액)
		function fnCalcDiscountAmt() {
			var calcDepositAmt = $M.toNum($M.getValue("delay_amt"))-$M.toNum($M.getValue("delay_discount_amt"))+$M.toNum($M.getValue("misu_amt"));
			$M.setValue("plan_deposit_amt", calcDepositAmt);
			var calcResultDepositAmt = $M.toNum($M.getValue("plan_deposit_amt"))-$M.toNum($M.getValue("delay_amt"))+$M.toNum($M.getValue("delay_discount_amt"));
			$M.setValue("result_deposit_amt", calcResultDepositAmt);
		}

		// 실입금액 입력 시
		// 원금입금액 = 실입금액-지연금+삭감액
		// 잔액 = 미입금액-원금입금액
		function fnCalcPlanDepositAmt() {
			var calcDepositAmt = $M.toNum($M.getValue("plan_deposit_amt"))-$M.toNum($M.getValue("delay_amt"))+$M.toNum($M.getValue("delay_discount_amt"));
			$M.setValue("result_deposit_amt", calcDepositAmt);
			var calcBalanceAmt = $M.toNum($M.getValue("misu_amt"))-$M.toNum($M.getValue("result_deposit_amt"));
			$M.setValue("balance_amt", calcBalanceAmt);
		}



		function goA() {
			var params = [{}];
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
			$M.goNextPage('/cust/cust0301p03', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 계정구분에 따라 form 디자인 변경
		function fnChangeDepositForm() {
			var params = {
		    		"acc_type_cd" : $M.getValue("acc_type_cd"),
		    		"cust_no" : "${inputParam.cust_no}",
		    		"deposit_dt" : $M.getValue("deposit_dt"),
		    		"amt" : $M.getValue("plan_deposit_amt"),
		    		"parent_js_name" : ""

		    };
			fnReset();
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=360, height=330, left=0, top=0";
			switch($("#acc_type_cd").val()) {
			case "1" : $(".deposit_billin").addClass("dpn");
					    $(".deposit_cash").removeClass("dpn");
					    $(".deposit_card").addClass("dpn");
					    $(".deposit_replace").addClass("dpn");
					    $(".deposit_bank").addClass("dpn");
					    $("#deposit_text").prop("readonly", false);
					    break;
			case "2" : $(".deposit_billin").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						params.parent_js_name = "fnSetBillinInfo";
						$M.goNextPage('/cust/cust0301p04', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			case "3" : $(".deposit_bank").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						params.parent_js_name = "fnSetBankInfo";
						$M.goNextPage('/cust/cust0301p04', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			case "4" : $(".deposit_card").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						params.parent_js_name = "fnSetCardInfo";
						$M.goNextPage('/cust/cust0301p04', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			case "5" : $(".deposit_replace").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						params.parent_js_name = "fnSetReplaceInfo";
						$M.goNextPage('/cust/cust0301p04', $M.toGetParam(params), {popupStatus : popupOption});
						break;
			}
		}

		function fnReset() {
			var setParam = {
					// 은행
					'site_no' : '',
					'ibk_iss_acct_his_seq' : '',
					'ibk_rcv_vacct_reco_seq' : '',
					'out_tx_amt' : '',
					'ibk_bank_name' :  '',
					'ibk_bank_cd' : '',
					'acct_no' : '',
					'account_no' : '',
					'acct_txday' : '',
					'tx_amt' : '',
					'jeokyo' : '',

					// 카드
					'card_cmp_name' : '',
					'card_cmp_cd' : '',
					'approval_no' : '',

					// 어음
					'bill_no' :  '',
					'billin_no' :  '',
					'end_dt' : '',
					'corp_cust_name' : '',

					// 대체
					'in_replace_acnt_cd' : '',
					'in_replace_acnt_name' : '',
					'replace_cust_name' : '',
					'replace_cust_no' : '',

					// 비고
					'deposit_text' : '',

			};
			$M.setValue(setParam);
		}

		// 어음 데이터 셋팅
		function fnSetBillinInfo(data) {
			$M.setValue("bill_no", data.bill_no);
			$M.setValue("billin_no", data.billin_no);
			$M.setValue("end_dt", data.end_dt);
			$M.setValue("corp_cust_name", data.corp_cust_name);
			$M.setValue("deposit_text", data.corp_cust_name+ " " + data.bill_no + " " + $M.dateFormat(data.end_dt, "yyyy-MM-dd"));
		}

		// 은행 데이터 셋팅
		function fnSetBankInfo(data) {
			$M.setValue("ibk_bank_name", data.bank_name);
			$M.setValue("ibk_bank_cd", data.ibk_bank_cd);
			$M.setValue("acct_no", data.acct_no);
			$M.setValue("account_no", data.account_no);
			$M.setValue("acct_txday", data.acct_txday);
			$M.setValue("acct_txday_seq", data.acct_txday_seq);
			$M.setValue("tx_amt", data.tx_amt);
			$M.setValue("jeokyo", data.jeokyo);
			$M.setValue("site_no", data.site_no);
			$M.setValue("out_tx_amt", data.out_tx_amt);
			$M.setValue("ibk_iss_acct_his_seq", data.ibk_iss_acct_his_seq);
			$M.setValue("ibk_rcv_vacct_reco_seq", data.ibk_rcv_vacct_reco_seq);
			$M.setValue("inout_type_io", data.inout_type_io);
			var bankName = data.bank_name.trim();
			var depositText = bankName + " " + data.account_no + " " + data.jeokyo + " " + $M.setComma(data.tx_amt)
			$M.setValue("deposit_text", depositText);
		}

		// 카드 데이터 셋팅
		function fnSetCardInfo(data) {
			$M.setValue("approval_no", data.approval_no);
			$M.setValue("card_cmp_cd", data.card_cmp_cd);
			$M.setValue("card_cmp_name", data.card_cmp_name);
			$M.setValue("deposit_text", data.card_cmp_name+ " " + data.approval_no);
		}

		// 대체 데이터 셋팅
		function fnSetReplaceInfo(data) {
			$M.setValue("in_replace_acnt_name", data.in_replace_acnt_name);
			$M.setValue("in_replace_acnt_cd", data.in_replace_acnt_cd);
			$M.setValue("replace_cust_no", data.replace_cust_no);
			$M.setValue("replace_cust_name", data.replace_cust_name);
			$M.setValue("deposit_text", data.in_replace_acnt_name+ " " + data.replace_cust_name + " 대체");
		}

		// 저장
		function goModify() {
			var frm = document.main_form;

			if($M.getValue("agency_account_apply_yn") != "Y") {
				$("#agency_account_apply_yn").val("N");
			}

// 			if($M.getValue("balance_amt") < 0) {
// 				alert("잔액은 0 이상이어야 합니다.");
// 				return false;
// 			}

			if($M.validation(frm, {field:["machine_doc_no", "deposit_dt", "deposit_text", "acc_type_cd"]}) == false) {
				return false;
			};

			switch($("#acc_type_cd").val()) {
			// '어음'일 시 입금자에 발행처 저장, 계좌번호에 어음번호 저장
			case "2" :  if($M.validation(frm, {field:["billin_no"]}) == false) {
							return;
						};
						$M.setValue("acct_no", $M.getValue("bill_no"));
						$M.setValue("jeokyo", $M.getValue("corp_cust_name"));
						break;
			// '은행'일 시 만기일자에 입금일자 저장 (acctNo에 계좌번호 저장)
			case "3" :  if($M.validation(frm, {field:["site_no", "ibk_bank_cd", "acct_no", "acct_txday", "acct_txday_seq"]}) == false) {
							return;
						};
						$M.setValue("end_dt", $M.getValue("acct_txday"));
						$M.setValue("inout_gubun", "2");
						break;
			// '카드'일 시 은행명에 카드사 저장
			case "4" :  if($M.validation(frm, {field:["card_cmp_cd", "approval_no"]}) == false) {
							return;
						};
						$M.setValue("ibk_bank_name", $M.getValue("card_cmp_name"));
						break;
			// '대체'일 시   계좌번호-대체계정코드 / 입금자-대체고객 / 입출구분-출금(1) / 입금자,계좌번호-차대번호 /
			// 차대번호 != ""일 시 -> 입금자, 계좌번호에 차대번호 저장
			case "5" :  if($M.validation(frm, {field:["in_replace_acnt_cd", "replace_cust_no"]}) == false) {
							return;
						};
						$M.setValue("acct_no", $M.getValue("in_replace_acnt_cd"));
						$M.setValue("jeokyo", $M.getValue("replace_cust_name"));
						$M.setValue("inout_gubun", "1");
						if($M.getValue("body_no") != "") {
							$M.setValue("jeokyo", $M.getValue("body_no"));
							$M.setValue("acct_no", $M.getValue("body_no"));
						}
						break;
			}
			$M.setValue("misu_amt", $M.getValue("balance_amt"));

			$M.goNextPageAjaxModify('/cust/cust0301p02/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("수정이 완료되었습니다.");
						opener.location.reload();
						fnClose();
					}
				}
			);
		}

		function goRemove() {
			var frm = document.main_form;
			$M.goNextPageAjaxRemove('/cust/cust0301p05/remove', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("삭제가 완료되었습니다.");
						opener.location.reload();
						fnClose();
					}
				}
			);
		}

		function fnClose() {
			window.close();
		}


	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블1 -->
			<div>
				<div class="title-wrap end_check dpn">
					<h4 class="primary"></h4>
					<div id="end_check"><span class="text-danger">&#91;마감완료&#93;</span></div>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">관리번호</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="machine_doc_no" name="machine_doc_no">
							</td>
							<th class="text-right essential-item">입금일자</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width140px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate rb dis_check" id="deposit_dt" name="deposit_dt" dateformat="yyyy-MM-dd" alt="입금일자" required="required">
										</div>
									</div>
									<div class="col width120px mr25">
										<input type="text" class="form-control" readonly="readonly" id="inout_doc_no" name="inout_doc_no" alt="전표번호">
									</div>
									<div class="col width50px">
										<input type="text" class="form-control" id="day_cnt" name="day_cnt" readonly="readonly" alt="일수" readonly="readonly" format="decimal">
									</div>
									<div class="col width16px text-center">X</div>
									<div class="col width50px">
										<input type="text" class="form-control" id="interest_rate" readonly="readonly" name="interest_rate" alt="적용금리" readonly="readonly" format="decimal">
									</div>
									<div class="col width16px text-center">%</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">차주명</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="inout_cust_name" name="inout_cust_name">
							</td>
							<th class="text-right">지연금</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="delay_amt" name="delay_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right essential-item">계정구분</th>
							<td>
								<select class="form-control dis_check" id="acc_type_cd" name="acc_type_cd" onchange="fnChangeDepositForm();" required="required" alt="계정구분">
									<option value="">- 선택 -</option>
									<c:forEach var="item" items="${codeMap['ACC_TYPE']}">
										 <c:if test="${item.code_v1 eq 'Y'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right">판매일자</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="sale_dt" name="sale_dt" dateFormat="yyyy-MM-dd" style="width: 80px;">
							</td>
							<th class="text-right">삭감액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" id="delay_discount_amt" name="delay_discount_amt" format="decimal" readonly="readonly">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<td colspan="2" rowspan="5" class="td-gray text-right deposit_cash"></td>
							<th class="text-right essential-item deposit_billin dpn essential-item">어음번호</th>
							<td class="deposit_billin dpn">
								<input type="text" class="form-control" readonly="readonly" id="bill_no" name="bill_no">
							</td>
							<th class="text-right deposit_bank dpn essential-item">은행명</th>
							<td class="deposit_bank dpn">
								<input type="text" class="form-control" readonly="readonly" id="ibk_bank_name" name="ibk_bank_name" alt="은행명">
								<input type="hidden" class="form-control" readonly="readonly" id="ibk_bank_cd" name="ibk_bank_cd">
							</td>
							<th class="text-right deposit_card dpn essential-item">카드사</th>
							<td class="deposit_card dpn">
								<input type="text" class="form-control" readonly="readonly" id="card_cmp_name" name="card_cmp_name" alt="카드사">
								<input type="hidden" class="form-control" readonly="readonly" id="card_cmp_cd" name="card_cmp_cd">
							</td>
							<th class="text-right essential-item deposit_replace dpn essential-item">대체계정</th>
							<td class="deposit_replace dpn">
								<input type="text" class="form-control" readonly="readonly" id="in_replace_acnt_name" name="in_replace_acnt_name">
								<input type="hidden" class="form-control" readonly="readonly" id="in_replace_acnt_cd" name="in_replace_acnt_cd" alt="대체계정"> <!-- 대체계정코드 -->
							</td>
						</tr>
						<tr>
							<th class="text-right">입금구분</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="machine_pay_type_name" name="machine_pay_type_name">
								<input type="hidden" class="form-control" readonly="readonly" id="machine_pay_type_cd" name="machine_pay_type_cd">
							</td>
							<th class="text-right">원금입금</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="result_deposit_amt" name="result_deposit_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right essential-item deposit_billin dpn essential-item">만기일자</th>
							<td class="deposit_billin dpn">
								<input type="text" class="form-control" readonly="readonly" id="end_dt" name="end_dt" dateFormat="yyyy-MM-dd" style="width: 80px;">
							</td>
							<th class="text-right deposit_bank dpn essential-item">계좌번호</th>
							<td class="deposit_bank dpn">
								<input type="text" class="form-control" readonly="readonly" id="account_no" name="account_no">
								<input type="hidden" class="form-control" readonly="readonly" id="acct_no" name="acct_no">
							</td>
							<th class="text-right deposit_card dpn essential-item">승인번호</th>
							<td class="deposit_card dpn">
								<input type="text" class="form-control" readonly="readonly" id="approval_no" name="approval_no">
							</td>
							<th class="text-right essential-item deposit_replace dpn essential-item">대체고객명</th>
							<td class="deposit_replace dpn">
								<div class="input-group">
									<input type="text" class="form-control" readonly="readonly" id="replace_cust_name" name="replace_cust_name">
									<input type="hidden" class="form-control" readonly="readonly" id="replace_cust_no" name="replace_cust_no">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">예정일자</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="plan_dt" name="plan_dt" dateformat="yyyy-MM-dd" style="width: 80px;">
							</td>
							<th class="text-right">실입금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" id="plan_deposit_amt" name="plan_deposit_amt" format="decimal" readonly="readonly">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right deposit_billin dpn">발행처</th>
							<td class="deposit_billin dpn">
								<input type="text" class="form-control" readonly="readonly" id="corp_cust_name" name="corp_cust_name">
							</td>
							<th class="text-right deposit_bank dpn essential-item">입금일자</th>
							<td class="deposit_bank dpn">
								<input type="text" class="form-control" readonly="readonly" id="acct_txday" name="acct_txday" dateFormat="yyyy-MM-dd" style="width: 80px;">
							</td>
							<td colspan="2" rowspan="3" class="td-gray text-right deposit_card dpn"></td>
							<td colspan="2" rowspan="3" class="td-gray text-right deposit_replace dpn"></td>
						</tr>
						<tr>
							<th class="text-right">예정금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="plan_amt" name="plan_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">처리일시</th>
							<td>
								<input type="text" class="form-control" readonly="readonly"  name="reg_dt" id="reg_dt">
							</td>
							<td colspan="2" rowspan="2" class="td-gray text-right deposit_billin dpn"></td>
							<th class="text-right deposit_bank dpn essential-item">입금액</th>
							<td class="deposit_bank dpn">
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="tx_amt" name="tx_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">미입금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="misu_amt" name="misu_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right">담당자</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="doc_mem_name" name="doc_mem_name">
								<input type="hidden" class="form-control" readonly="readonly" id="doc_mem_no" name="doc_mem_no">
							</td>
							<th class="text-right deposit_bank dpn essential-item">입금자</th>
							<td class="deposit_bank dpn">
								<input type="text" class="form-control" readonly="readonly" id="jeokyo" name="jeokyo">
							</td>
						</tr>
						<tr>
							<th class="text-right">잔액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="balance_amt" name="balance_amt" format="decimal">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
							<th class="text-right essential-item">비고</th>
							<td colspan="3">
								<textarea class="form-control"  id="deposit_text" name="deposit_text" alt="비고" style="height: 50px;" placeholder="비고가 들어갑니다." readonly="readonly"></textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블1 -->
			<div class="btn-group mt10">
				<div class="left form-check form-check-inline agencyYn">
					<input class="form-check-input" type="checkbox" id="agency_account_apply_yn" name="agency_account_apply_yn" value="Y">
					<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
					<%--<label for="agency_account_apply_yn" class="form-check-label">대리점정산시 최종입금일자 반영여부</label>--%>
					<label for="agency_account_apply_yn" class="form-check-label">위탁판매점 정산시 최종입금일자 반영여부</label>
				</div>
				<div class="right">
 					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
<input type="hidden" id="machine_deposit_result_seq" name="machine_deposit_result_seq"> <!-- 장비입금일련번호 -->
<input type="hidden" id="inout_money_seq" name="inout_money_seq"> <!-- 입출금내역번호 -->
<input type="hidden" id="interest_base_dt" name="interest_base_dt"> <!-- 이자기산일 -->
<input type="hidden" id="inout_type_io" name="inout_type_io" value="I"> <!-- 입출금계정코드 -->
<input type="hidden" id="inout_money_type_cd" name="inout_money_type_cd" value="MCH"> <!-- 입출금타입코드 -->
<input type="hidden" id="billin_no" name="billin_no">	<!-- 어음관리번호 -->
<input type="hidden" id="body_no" name="body_no">
<input type="hidden" id="out_tx_amt" name="out_tx_amt"> <!-- 출금액 -->
<input type="hidden" id="ibk_iss_acct_his_seq" name="ibk_iss_acct_his_seq">	<!-- 계좌 seq -->
<input type="hidden" id="ibk_rcv_vacct_reco_seq" name="ibk_rcv_vacct_reco_seq">	<!-- 가상계좌 seq -->
<input type="hidden" id="cust_no" name="cust_no">	<!-- 고객번호 -->
<input type="hidden" id="cust_name" name="cust_name">	<!-- 고객명 -->
<input type="hidden" id="inout_doc_no" name="inout_doc_no">	<!-- 전표번호 -->
<input type="hidden" id="cust_hp_no" name="cust_hp_no">	<!-- 고객핸드폰 -->
<input type="hidden" id="cust_fax_no" name="cust_fax_no">	<!-- 고객팩스 -->
<input type="hidden" id="breg_no" name="breg_no">	<!-- 사업자번호 -->
<input type="hidden" id="breg_name" name="breg_name">	<!-- 업체명 -->
<input type="hidden" id="breg_rep_name" name="breg_rep_name">	<!-- 대표자명 -->
<input type="hidden" id="biz_addr1" name="biz_addr1">	<!-- 주소1 -->
<input type="hidden" id="biz_addr2" name="biz_addr2">	<!-- 주소2 -->
<input type="hidden" id="biz_post_no" name="biz_post_no">	<!-- 우편번호 -->
<input type="hidden" id="breg_seq" name="breg_seq">	<!-- 사업자일련번호 -->
<input type="hidden" id="breg_cor_type" name="breg_cor_type">	<!-- 업태 -->
<input type="hidden" id="breg_cor_part" name="breg_cor_part">	<!-- 업종 -->
<input type="hidden" id="machine_out_doc_seq" name="machine_out_doc_seq">
<input type="hidden" id="machine_seq" name="machine_seq">
</form>
</body>
</html>
