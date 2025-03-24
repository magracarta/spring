<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 받을어음관리 > 어음신규등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			
			if($M.getValue("billin_type_mp") == "M") {
				if($M.getValue("machine_doc_no") == "") {
					alert("장비를 다시 선택해주세요.");
					return false;
				}
				$M.setValue("inout_money_type_cd", "MCH");
			} else if($M.getValue("billin_type_mp") == "P") {
				$M.setValue("inout_money_type_cd", "PART");
			}

			$M.setValue("deposit_text", $M.getValue("corp_cust_name") + " " + $M.getValue("bill_no") + " " + $M.dateFormat($M.getValue("end_dt"), "yyyyMMdd"));
			
			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						$M.goNextPage('/acnt/acnt0203');
					}
				}
			);
		}
		
		function fnList() {
			history.back();
		}
	
		// 임금처 셋팅
		function setDepositCustInfo(row) {
			var frm = document.main_form;
			$M.setValue(frm, "deposit_cust_name", row.real_cust_name);
			$M.setValue(frm, "cust_name", row.real_cust_name);
			$M.setValue(frm, "deposit_cust_no", row.cust_no);
			$M.setValue(frm, "cust_no", row.cust_no);
			$M.setValue(frm, "proc_cust_name", row.real_cust_name);
			$M.setValue(frm, "proc_cust_no", row.cust_no);
		}
		
		// 발행처 셋팅
		function setCorpCustInfo(row) {
			var frm = document.main_form;
			$M.setValue(frm, "corp_cust_name", row.real_cust_name);
		}
		
		// 처리처 셋팅
		function setProcCustInfo(row) {
			var frm = document.main_form;
			$M.setValue(frm, "proc_cust_name", row.real_cust_name);
			$M.setValue(frm, "proc_cust_no", row.cust_no);
		}
	
		// 초기화
		function fnInit() {
			var setParam = {
					'machine_doc_no' : '',
					'machine_pay_type_cd' : '',
					'plan_dt' : '',
					'plan_amt' : '',
					'misu_amt' : '',
					'day_cnt' :  '',
					'interest_rate' :  '',
					'delay_amt' : '',
					'delay_discount_amt' : '',
					'out_dt' : '',
					'billin_no' : '',
					'tx_amt' : '',
					'inout_type_io' : '',
			};
			$M.setValue(setParam);
		}
		
		// 장비버튼 클릭 시 고객장비거래원장 팝업 오픈
		function goTradeLedger() {
			fnInit();
			
			if($M.getValue("deposit_cust_no") == "") {
				alert("입금처를 먼저 검색해주세요.");
				$("#billin_type_m").prop('checked', false);
				return false;
			}
			
			if($M.getValue("amt") == "") {
				alert("금액을 입력해주세요.");
				$("#billin_type_m").prop('checked', false);
				return false;
			}
			// 입금처리 구분자 bill有시 받을어음관리 
			var param = {
					"s_cust_no" : $M.getValue("deposit_cust_no"),
					"s_amt" : $M.getValue("amt"),
					"parent_js_name" : "fnSetDepositInfo"
			}
			openCustMachineDealLedgerPanel($M.toGetParam(param));
		}
		
		// 선택한 품의서의 입금정보 셋팅
		function fnSetDepositInfo(data) {
			$M.setValue("machine_doc_no", data.machine_doc_no); 
			$M.setValue("machine_pay_type_cd", data.machine_pay_type_cd); 
			$M.setValue("plan_dt", data.plan_dt); 
			$M.setValue("plan_amt", data.plan_amt); 
			$M.setValue("misu_amt", data.misu_amt); 
			$M.setValue("day_cnt", data.day_cnt); 
			$M.setValue("interest_rate", data.interest_rate); 
			$M.setValue("delay_amt", data.delay_amt); 
			$M.setValue("delay_discount_amt", data.delay_discount_amt); 
			$M.setValue("balance_amt", data.balance_amt); 
			$M.setValue("out_dt", data.out_dt); 
			$M.setValue("deposit_dt", data.deposit_dt); 
			$M.setValue("billin_no", data.billin_no); 
			$M.setValue("tx_amt", data.tx_amt); 
			$M.setValue("inout_type_io", data.inout_type_io);
			
			$M.setValue("cust_hp_no", data.cust_hp_no);
			$M.setValue("cust_fax_no", data.cust_fax_no);
			$M.setValue("breg_no", data.breg_no);
			$M.setValue("breg_name", data.breg_name);
			$M.setValue("breg_rep_name", data.breg_rep_name);
			$M.setValue("biz_addr1", data.biz_addr1);
			$M.setValue("biz_addr2", data.biz_addr2);
			$M.setValue("biz_post_no", data.biz_post_no);
			$M.setValue("breg_seq", data.breg_seq);
			$M.setValue("breg_cor_type", data.breg_cor_type);
			$M.setValue("breg_cor_part", data.breg_cor_part);
			
		}
		
		function fnBillinProcType() {
			// 만기 클릭 시 
			if($M.getValue("billin_proc_type_cd") == "1") {
				var now = "${inputParam.s_current_dt}";
				$M.setValue("proc_dt", $M.toDate(now));
			} else {
				$M.setValue("proc_dt", "");
			}
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="machine_doc_no" name="machine_doc_no"><!-- 품의번호 -->
<input type="hidden" id="machine_pay_type_cd" name="machine_pay_type_cd"><!-- 장비결제타입 -->
<input type="hidden" id="plan_dt" name="plan_dt"><!-- 예정일 -->
<input type="hidden" id="acc_type_cd" name="acc_type_cd" value="2"><!-- 입출금계정코드 어음으로 고정 -->
<input type="hidden" id="plan_amt" name="plan_amt"><!-- 예정액 -->
<input type="hidden" id="misu_amt" name="misu_amt"><!-- 미입금액 -->
<input type="hidden" id="day_cnt" name="day_cnt"><!-- 일수 -->
<input type="hidden" id="interest_rate" name="interest_rate"><!-- 적용금리 -->
<input type="hidden" id="delay_amt" name="delay_amt"><!-- 산출지연금 -->
<input type="hidden" id="delay_discount_amt" name="delay_discount_amt"><!-- 지연금삭감액 -->
<input type="hidden" id="out_dt" name="out_dt"><!-- 판매일자(출하일자) -->
<input type="hidden" id="balance_amt" name="balance_amt"> <!-- 잔액 -->
<input type="hidden" id="billin_no" name="billin_no"> <!-- 어음번호 -->
<input type="hidden" id="plan_deposit_amt" name="plan_deposit_amt"> <!-- 실입금액 -->
<input type="hidden" id="result_deposit_amt" name="result_deposit_amt"><!-- 원금입금액 -->
<input type="hidden" id="tx_amt" name="tx_amt"><!-- 은행입금액 -->
<input type="hidden" id="inout_type_io" name="inout_type_io" value="I"><!-- 입출구분 -->
<input type="hidden" id="deposit_text" name="deposit_text"><!-- 비고 -->
<input type="hidden" id="inout_money_type_cd" name="inout_money_type_cd" value=""> <!-- 입출금타입코드 장비:MCH, 부품:PART -->

<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="cust_name" name="cust_name">

<input type="hidden" id="cust_hp_no" name="cust_hp_no">
<input type="hidden" id="cust_fax_no" name="cust_fax_no">
<input type="hidden" id="breg_no" name="breg_no">
<input type="hidden" id="breg_name" name="breg_name">
<input type="hidden" id="breg_rep_name" name="breg_rep_name">
<input type="hidden" id="biz_addr1" name="biz_addr1">
<input type="hidden" id="biz_addr2" name="biz_addr2">
<input type="hidden" id="biz_post_no" name="biz_post_no">
<input type="hidden" id="breg_seq" name="breg_seq">
<input type="hidden" id="breg_cor_type" name="breg_cor_type">
<input type="hidden" id="breg_cor_part" name="breg_cor_part">

<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left">
					<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
			</div>
<!-- /상세페이지 타이틀 -->
			<div class="contents" style="width:50%;">
				<!-- 폼테이블 -->
				<div>
					<table class="table-border">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">관리번호</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right">담당자</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" value="${SecureUser.user_name}">
								<input type="hidden" class="form-control width120px" readonly="readonly" id="reg_id" name="reg_id" value="${SecureUser.mem_no}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">어음번호</th>
							<td>
								<input type="text" class="form-control width200px essential-bg" id="bill_no" name="bill_no" required="required" alt="어음번호">
							</td>
							<th class="text-right essential-item">어음종류</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="billin_type_cd_1" name="billin_type_cd" value="1" checked="checked">
									<label for="billin_type_cd_1" class="form-check-label">약속어음</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="billin_type_cd_2" name="billin_type_cd" value="2">
									<label for="billin_type_cd_2"  class="form-check-label">가계수표</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="billin_type_cd_3" name="billin_type_cd" value="3">
									<label for="billin_type_cd_3" class="form-check-label">당좌수표</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">입금일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate essential-bg" id="deposit_dt" name="deposit_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="입금일자" required="required">
								</div>
							</td>
							<th class="text-right essential-item">금액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right essential-bg" required="required" format="decimal" id="amt" name="amt" alt="금액">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">발행일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate essential-bg" id="make_dt" name="make_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="발행일자">
								</div>
							</td>
							<th class="text-right essential-item">만기일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate essential-bg" id="end_dt" name="end_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="만기일자" required="required">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">입금처</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0" required="required" id="deposit_cust_name" name="deposit_cust_name" alt="입금처" readonly="readonly">
											<input type="hidden" class="form-control border-right-0" id="deposit_cust_no" name="deposit_cust_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setDepositCustInfo');"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col width140px pl10">
										<div class="dpf algin-item-center">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" onClick="javascript:goTradeLedger();" value="M" id="billin_type_m" name="billin_type_mp" required="required">
												<label for="billin_type_m" class="form-check-label">장비</label>
											</div>
											<div class="form-check form-check-inline mr3">
												<input class="form-check-input" type="radio" required="required" value="P" id="billin_type_p" name="billin_type_mp" required="required">
												<label for="billin_type_p" class="form-check-label">부품</label>
											</div>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right essential-item">발행처</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 essential-bg" required="required" id="corp_cust_name" name="corp_cust_name" alt="발행처">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setCorpCustInfo');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">지급장소</th>
							<td>
								<input type="text" class="form-control width180px essential-bg" id="give_place" name="give_place" required="required" alt="지급장소">
							</td>
							<th class="text-right essential-item">처리구분</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" required="required" id="billin_proc_type_0" name="billin_proc_type_cd" value="0" checked="checked" onChange="fnBillinProcType();">
									<label for="billin_proc_type_0" class="form-check-label">입금</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" required="required" id="billin_proc_type_1" name="billin_proc_type_cd" value="1" onChange="fnBillinProcType();">
									<label for="billin_proc_type_1" class="form-check-label">만기</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" required="required" id="billin_proc_type_2" name="billin_proc_type_cd" value="2" onChange="fnBillinProcType();">
									<label for="billin_proc_type_2"  class="form-check-label">할인</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" required="required" id="billin_proc_type_3" name="billin_proc_type_cd" value="3" onChange="fnBillinProcType();">
									<label for="billin_proc_type_3" class="form-check-label">지불</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" required="required" id="billin_proc_type_4" name="billin_proc_type_cd" value="4" onChange="fnBillinProcType();">
									<label for="billin_proc_type_4" class="form-check-label">부도</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">처리일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="proc_dt" name="proc_dt" dateFormat="yyyy-MM-dd" value="" alt="처리일자">
								</div>
							</td>
							<th class="text-right">처리처</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0" id="proc_cust_name" name="proc_cust_name" readonly="readonly">
									<input type="hidden" class="form-control border-right-0" id="proc_cust_no" name="proc_cust_no">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setProcCustInfo');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 100px;" id="bill_remark" name="bill_remark"></textarea>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /폼테이블 -->
				<!-- /폼테이블 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>