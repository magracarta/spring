<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 출하종결처리 > null > 위탁판매점출하확인
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	$(document).ready(function() {
		fnInit();
	});

	function fnInit() {
		if ("${outDoc.out_confirm_dt}" == "") {
			$M.setValue("out_confirm_dt", "${inputParam.s_current_dt}");
		}
	}

	function goContract() {
		var params = {
			"machine_doc_no" : "${outDoc.machine_doc_no}"
		};
		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
		$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
	}

	function setOrgMapCenterPanel(row) {
		var param = {
			account_org_code : row.org_code,
			account_org_name : row.org_name
		}
		$M.setValue(param);
	}

	function fnCalcCommission() {
		var saleCommissionAmt = 0;
		var contract = $M.getValue("contract_amt");
		var agencyCommission = $M.getValue("agency_base_commission_amt");
		var exceptBucket = $M.getValue("except_bucket_amt");
		var costGive = $M.getValue("cost_give_amt");
		var payFree = $M.getValue("pay_free_part_amt");
		saleCommissionAmt = $M.toNum(contract)-$M.toNum(agencyCommission)+$M.toNum(exceptBucket)+$M.toNum(costGive)-$M.toNum(payFree);
		console.log(saleCommissionAmt);
		$M.setValue("sale_commission_amt", saleCommissionAmt);
	}

	function goCalculate() {
		if($M.validation(document.main_form) == false) {
			return false;
		}
		var giveCost = $M.getValue("cost_give_amt");
		if ($M.toNum(giveCost) != 0 && $M.getValue("out_end_remark") == "" && $M.getValue("out_confirm_yn") == "Y") {
			alert("기타사항을 입력해주세요.");
			return false;
		}

		var frm = document.main_form;
		var confirmDt = $M.getValue("out_confirm_dt");
		var month = confirmDt.substring(4,6);
		var msg = "확인일자가 "+$M.dateFormat(confirmDt, 'yyyy-MM-dd')+"입니다.\n"+month+"월 정산으로 처리하시겠습니까?"
		$M.goNextPageAjaxMsg(msg, this_page, $M.toValueForm(frm), {method: 'post'},
              function (result) {
                   if (result.success) {
                	   if (opener != null && opener.goSearch) {
                		   opener.goSearch();
                	   }
                   }
              }
        );
	}

	function fnClose() {
		window.close();
	}

	// 판매가 변동내역 팝업 호출
	function fnMachinePriceHistoryPopup() {
		var param = {
			machine_plant_seq : $M.getValue("machine_plant_seq"),
			s_sort_key : "change_dt",
			s_sort_method : "desc"
		};

		var poppupOption = "";
		$M.goNextPage('/sale/sale0206p02', $M.toGetParam(param), {popupStatus : poppupOption});
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" value="${outDoc.machine_out_doc_seq}" name="machine_out_doc_seq">
<input type="hidden" value="${outDoc.machine_plant_seq}" name="machine_plant_seq">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap">
				<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체  --%>
				<%--<h4 class="primary">대리점출하확인</h4>--%>
				<h4 class="primary">위탁판매점출하확인</h4>
			</div>
<!-- 상단 폼테이블 -->
			<div>
				<table class="table-border mt5" style="min-width : 700px;">
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
							<th class="text-right">판매자</th>
							<td>${outDoc.doc_mem_name}</td>
							<th class="text-right">고객명</th>
							<td>${outDoc.cust_name}</td>
							<th class="text-right">모델명</th>
							<td>${outDoc.machine_name}</td>
						</tr>
						<tr>
							<th class="text-right rs">처리구분</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="out_confirm_yn_n" name="out_confirm_yn" value="N" <c:if test="${outDoc.out_confirm_yn eq 'N'}">checked="checked"</c:if>>
									<label class="form-check-label" for="out_confirm_yn_n">미확인</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="out_confirm_yn_y" name="out_confirm_yn" value="Y" <c:if test="${outDoc.out_confirm_yn eq 'Y'}">checked="checked"</c:if>>
									<label class="form-check-label" for="out_confirm_yn_y">확인</label>
								</div>
							</td>
							<th class="text-right">가격할인</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.discount_amt }" format="decimal" id="discount_amt" name="discount_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">지사부담</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly format="decimal" value="${outDoc.jisabudam }" id="jisabudam" name="jisabudam">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">판매금액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.sale_price }" format="decimal" id="sale_price" name="sale_price">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">중고손실</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.machine_used_loss_amt }" format="decimal" id="machine_used_loss_amt" name="machine_used_loss_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">본사부담</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.bonsabudam }" format="decimal" id="bonsabudam" name="bonsabudam">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
							<%--<th class="text-right">대리점수수료</th>--%>
							<th class="text-right">위탁판매점수수료</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" value="${outDoc.agency_base_commission_amt }" format="decimal" id="agency_base_commission_amt" name="agency_base_commission_amt" onchange="fnCalcCommission()">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">지급품계</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.out_part_amt }" format="decimal" id="out_part_amt" name="out_part_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">무상지급부품</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" value="${outDoc.pay_free_part_amt}" format="decimal" id="pay_free_part_amt" name="pay_free_part_amt" onchange="fnCalcCommission()">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">계약금액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.contract_amt }" format="decimal" id="contract_amt" name="contract_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">기회비용</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.opportunity_cost }" format="decimal" id="opportunity_cost" name="opportunity_cost">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">버켓제외</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" value="${outDoc.except_bucket_amt}" format="decimal" id="except_bucket_amt" name="except_bucket_amt" onchange="fnCalcCommission()">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">지급수수료</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.sale_commission_amt}" format="decimal" id="sale_commission_amt" name="sale_commission_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right">임의지급</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" value="${outDoc.cost_give_amt}" format="decimal" id="cost_give_amt" name="cost_give_amt" onchange="fnCalcCommission()">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>
							<th class="text-right rs">확인일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate rb width100px" id="out_confirm_dt" name="out_confirm_dt" value="${outDoc.out_confirm_dt }" dateFormat="yyyy-MM-dd" required="required" alt="확인일자">
								</div>
							</td>
						</tr>
						<tr>
							<!-- 대리점에서 정산센터 삭제 2020-11-19 -->
							<%-- <th class="text-right">정산센터</th>
							<td>
								<div class="input-group width140px">
									<input type="text" class="form-control border-right-0" value="${outDoc.account_org_name}" id="account_org_name" name="account_org_name">
									<input type="hidden" id="account_org_code" name="account_org_code" value="${outDoc.account_org_code}">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapCenterPanel('setOrgMapCenterPanel');"><i class="material-iconssearch"></i></button>
								</div>
							</td> --%>
							<th class="text-right">기타사항</th>
							<td colspan="5">
								<input type="text" class="form-control" id="out_end_remark" name="out_end_remark" value="${outDoc.out_end_remark}" alt="기타사항" maxlength="49">
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /상단 폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
