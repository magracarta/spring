<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약품의서 간편등록(스탭4 결제조건)
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<script>

	// 결제조건
	function fnChangePrice() {
		var dc = $M.toNum($M.getValue("discount_amt")); // 할인(소수점 입력 불가)
		var salePrice = $M.toNum($M.getValue("sale_price")); // 기준판매가
		var attach = $M.toNum($M.getValue("attach_amt")); // 어테치먼트
		var paid = $M.toNum($M.getValue("part_cost_amt")); // 유상
		var saleAmt = salePrice+attach-dc; // 최종판매가
		var price = {
			sale_amt : saleAmt,
			plan_amt_6 : Math.floor(saleAmt*0.1), // 부가세 : 최종판매가 * 0.1
			total_vat_amt : Math.floor(saleAmt*1.1), // 총액(VAT포함) : 최종판매가 + VAT
			total_amt : saleAmt
		};
		// 대리점일 경우 중고 직접입력가능
		// 간편등록에 제외
		/* <c:if test="${SecureUser.org_type ne 'AGENCY'}">
			$M.setValue("plan_amt_4", $M.toNum($M.getValue("used_used_price")));
		</c:if> */
		var total = 0;
		for (var i = 0; i < 6; ++i) {
			var amt = $M.getValue("plan_amt_"+i);
			if (amt != "" && amt != "0" && $M.getValue("plan_dt_"+i) == "") {
				$M.setValue("plan_dt_"+i, "${inputParam.s_current_dt}");
			}
			total += $M.toNum(amt);
		}
		price['balance'] = price.total_vat_amt-total-(saleAmt*0.1); // 결제조건잔액 = 최종판매가 - 결제조건 0~6 
		price.balance = Math.floor(price.balance);
		price.total_vat_amt = price.total_vat_amt;
		$M.setValue(price);
	}

</script>
<div class="step-title">
	<span class="step-num">step04</span> <span class="step-title">결제조건</span>
</div>
<ul class="step-info">
	<li>결재조건을 입력 하시기 바랍니다.</li>
</ul>
<table class="table-border mt5">
	<colgroup>
		<col width="">
		<col width="">
		<col width="">
		<col width="">
	</colgroup>
	<thead>
		<tr>
			<th>고객명</th>
			<th>휴대폰</th>
			<th>모델명</th>
			<th>출하희망일</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="text-center cust_name_view"></td>
			<td class="text-center hp_no_view"></td>
			<td class="text-center machine_name_view"></td>
			<td class="text-center receive_plan_dt_view"></td>
		</tr>
	</tbody>
</table>

<!-- 결제조건 -->
<div class="title-wrap mt5">
	<h4>결제조건</h4>
</div>
<div>
	<table class="table-border mt5">
		<colgroup>
			<col width="">
			<col width="">
			<col width="">
			<col width="">
		</colgroup>
		<thead>
			<tr>
				<th class="title-bg">구분</th>
				<th class="title-bg">금액</th>
				<th class="title-bg">입금예정일</th>
				<th class="title-bg">입금액</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<th class="th-gray ext-center">현금</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" id="plan_amt_0" name="plan_amt_0" format="num" onchange="fnChangePrice()">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
<%--				<td class="text-center">--%>
<%--					<div class="input-group widthfix">--%>
<%--						<input type="text" class="form-control border-right-0 calDate" id="plan_dt_0" name="plan_dt_0" dateFormat="yyyy-MM-dd">--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="deposit_amt_0" name="deposit_amt_0" format="decimal" readonly="readonly">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
				<th class="th-gray ext-center">카드</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" id="plan_amt_1" name="plan_amt_1" format="num" onchange="fnChangePrice()">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
			</tr>
<%--			<tr>--%>
<%--				<th class="th-gray ext-center">카드</th>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="plan_amt_1" name="plan_amt_1" format="num" onchange="fnChangePrice()">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="input-group widthfix">--%>
<%--						<input type="text" class="form-control border-right-0 calDate" id="plan_dt_1" name="plan_dt_1" dateFormat="yyyy-MM-dd">--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="deposit_amt_1" name="deposit_amt_1" format="decimal" readonly="readonly">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
<%--			</tr>--%>
			<tr>
				<th class="th-gray ext-center">중고</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" id="plan_amt_4" name="plan_amt_4" format="num" onchange="fnChangePrice()">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
<%--				<td class="text-center">--%>
<%--					<div class="input-group widthfix">--%>
<%--						<input type="text" class="form-control border-right-0 calDate" id="plan_dt_4" name="plan_dt_4" dateFormat="yyyy-MM-dd">--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="deposit_amt_4" name="deposit_amt_4" format="decimal" readonly="readonly">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
				<th class="th-gray ext-center">캐피탈</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" id="plan_amt_3" name="plan_amt_3" format="num" onchange="fnChangePrice()">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
			</tr>
<%--			<tr>--%>
<%--				<th class="th-gray ext-center">캐피탈</th>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="plan_amt_3" name="plan_amt_3" format="num" onchange="fnChangePrice()">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="input-group widthfix">--%>
<%--						<input type="text" class="form-control border-right-0 calDate" id="plan_dt_3" name="plan_dt_3" dateFormat="yyyy-MM-dd">--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="deposit_amt_3" name="deposit_amt_3" format="decimal" readonly="readonly">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
<%--			</tr>--%>
			<tr>
				<th class="th-gray ext-center">보조</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" id="plan_amt_5" name="plan_amt_5" format="num" onchange="fnChangePrice()">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
<%--				<td class="text-center">--%>
<%--					<div class="input-group widthfix">--%>
<%--						<input type="text" class="form-control border-right-0 calDate" id="plan_dt_5" name="plan_dt_5" dateFormat="yyyy-MM-dd">--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="deposit_amt_5" name="deposit_amt_5" format="decimal" readonly="readonly">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
				<th class="th-gray ext-center">VAT</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" id="plan_amt_6" name="plan_amt_6" format="decimal" onchange="fnChangePrice()" readonly="readonly">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
			</tr>
<%--			<tr>--%>
<%--				<th class="th-gray ext-center">VAT</th>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="plan_amt_6" name="plan_amt_6" format="decimal" onchange="fnChangePrice()" readonly="readonly">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="input-group widthfix">--%>
<%--						<input type="text" class="form-control border-right-0 calDate" id="plan_dt_6" name="plan_dt_6" dateFormat="yyyy-MM-dd">--%>
<%--					</div>--%>
<%--				</td>--%>
<%--				<td class="text-center">--%>
<%--					<div class="form-row inline-pd widthfix">--%>
<%--						<div class="col width120px">--%>
<%--							<input type="text" class="form-control text-right" id="deposit_amt_6" name="deposit_amt_6" format="decimal" readonly="readonly">--%>
<%--						</div>--%>
<%--						<div class="col width16px">원</div>--%>
<%--					</div>--%>
<%--				</td>--%>
<%--			</tr>--%>
<%--			<tr>--%>
<%--				<th class="th-gray ext-center">캐피탈선택</th>--%>
<%--				<td colspan="3">--%>
<%--					<select class="form-control" id="finance_cmp_cd" name="finance_cmp_cd">--%>
<%--						<option value="">- 선택 -</option>--%>
<%--						<c:forEach var="item" items="${codeMap['FINANCE_CMP']}">--%>
<%--							<option value="${item.code_value}">${item.code_name}</option>--%>
<%--						</c:forEach>--%>
<%--					</select>--%>
<%--				</td>--%>
<%--			</tr>--%>
			<tr>
				<th class="th-sum ext-center">총액(VAT포함)</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" readonly="readonly" id="total_vat_amt" name="total_vat_amt" format="num">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
				<th class="th-sum ext-center">결제조건잔액</th>
				<td class="text-center">
					<div class="form-row inline-pd widthfix">
						<div class="col width120px">
							<input type="text" class="form-control text-right" readonly="readonly" id="balance" name="balance" format="num">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
			</tr>
			<tr>
				<th class="th-sum">가상계좌번호</th>
				<td colspan="2">
					<input type="text" id="virtual_account_no" name="virtual_account_no" class="form-control" readonly="readonly">
				</td>
			</tr>
		</tbody>
	</table>
</div>
<!-- /결제조건 -->
<!-- 입금자정보 -->
<!-- <div class="title-wrap mt10">
	<h4>입금자정보</h4>
</div>
<div>
	<table class="table-border mt5">
		<colgroup>
			<col width="85px">
			<col width="">
			<col width="85px">
			<col width="">
			<col width="85px">
			<col width="">
		</colgroup>
		<tbody>
			<tr>
				<th class="title-bg">입금자명</th>
				<td>
					<input type="text" class="form-control text-right width120px" name="deposit_name">
				</td>
				<th class="title-bg">입금은행</th>
				<td>
					<input type="text" class="form-control text-right width120px" name="bank_name">
				</td>
				<th class="title-bg">입금예정금액</th>
				<td>
					<div class="form-row inline-pd widthfix">
						<div class="col width100px">
							<input type="text" class="form-control text-right width120px" id="deposit_plan" name="deposit_plan" alt="입금예정금액" format="decimal">
						</div>
						<div class="col width16px">원</div>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div> -->
<!-- /입금자정보 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
<div class="btn-group mt10">
	<div class="right">
		<button type="button" class="btn btn-md btn-info" style="width: 50px;" onclick="javascript:fnCompleteStep(4)">다음</button>
	</div>
</div>
