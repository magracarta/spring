<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 위탁판매점정산확인 > null > 정산확인
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-10-10 17:52:04
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>

		$(document).ready(function() {
			// AUIGrid 생성
			fnInitCalc();
		});

		function fnInitCalc() {
			/**
				동적계산 및 페이지로딩시 세팅 및 값 변경시 세팅

				calc_commission_amt 산출수수료     --> 판매수수료 + 인센티브 - 공제액 - 서비스료
				sale_vat_amt 부가세           		  --> 산출수수료 * 0.1

				account_commition_amt 정산예정 수수료      -->  산출수수료 - 유보금
				account_vat_amt 정산예정 부가세			-->  부가세 (sale_vat_amt)

			*/

			var saleCommissionAmt = Number($M.getValue("sale_commission_amt"));   // 판매수수료
			var incentiveAmt = Number($M.getValue("incentive_amt"));			  // 인센티브
			var deductAmt = Number($M.getValue("deduct_amt"));					  // 공제액
// 			var serviceAccountAmt = Number($M.getValue("service_account_amt"));	  // 서비스료
			var delayAmt = Number($M.getValue("delay_amt"));	 				  // 유보금

			// 산출수수료
// 			$M.setValue("calc_commission_amt", saleCommissionAmt + incentiveAmt - deductAmt - serviceAccountAmt);
			$M.setValue("calc_commission_amt", saleCommissionAmt + incentiveAmt - deductAmt);
			var calcCommissionAmt = Number($M.getValue("calc_commission_amt"));

			$M.setValue("sale_vat_amt", calcCommissionAmt * 0.1);  				 // 부가세
			$M.setValue("account_commition_amt", calcCommissionAmt - delayAmt);  // 정산예정 수수료
			$M.setValue("account_vat_amt", $M.getValue("sale_vat_amt"));  		 // 정산예정 부가세
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 정산확인
		function goModify() {
			var frm = document.main_form;
			// 입력폼 벨리데이션
			if($M.validation(frm) == false) {
				return;
			}

			if (confirm("수정 하시겠습니까 ?") == false) {
				return false;
			}

			frm = $M.toValueForm(frm);

			console.log("frm : ", frm);

			$M.goNextPageAjax(this_page + "/modify", frm , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("수정이 완료되었습니다.");
		    			fnClose();
		    			window.opener.goSearch();
					}
				}
			);
		}

	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
<form id="main_form" name="main_form">
<input type="hidden" id="machine_doc_no" name="machine_doc_no" value="${map.machine_doc_no}">
<input type="hidden" id="machine_out_doc_seq" name="machine_out_doc_seq" value="${map.machine_out_doc_seq}">
<input type="hidden" id="agency_pay_yn" name="agency_pay_yn">
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 원화 + 외화예금 -->
		<div>
			<table class="table-border mt5">
				<colgroup>
					<col width="120px">
					<col width="">
				</colgroup>
				<tbody>

				<tr>
					<th class="text-right">판매금액</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width180px">
								<input type="text" class="form-control text-right" id="sale_price" name="sale_price" value="${map.sale_amt}" format="decimal" datatype="int" alt="판매금액" readonly>
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
					<%--<th class="text-right">대리점가</th>--%>
					<th class="text-right">위탁판매점가</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width180px">
								<input type="text" class="form-control text-right" id="agency_price" name="agency_price" value="${map.agency_price}" format="decimal" datatype="int" alt="위탁판매점가" readonly>
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">판매수수료</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width180px">
								<input type="text" class="form-control text-right essential-bg" id="sale_commission_amt" name="sale_commission_amt" value="${map.sale_commission_amt}" format="decimal" datatype="int" alt="판매수수료" required="required" onchange="javascript:fnInitCalc();">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">인센티브(+)</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width180px">
								<input type="text" class="form-control text-right essential-bg" id="incentive_amt" name="incentive_amt" value="${map.incentive_amt}" format="decimal" datatype="int" alt="인센티브" required="required" onchange="javascript:fnInitCalc();">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">공제액(-)</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width180px">
								<input type="text" class="form-control text-right essential-bg" id="deduct_amt" name="deduct_amt" value="${map.deduct_amt}" format="decimal" datatype="int" alt="공제액" required="required" onchange="javascript:fnInitCalc();">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
<!-- 				<tr> -->
<!-- 					<th class="text-right essential-item">서비스료(-)</th> -->
<!-- 					<td> -->
<!-- 						<div class="form-row inline-pd widthfix"> -->
<!-- 							<div class="col width180px"> -->
<%-- 								<input type="text" class="form-control text-right essential-bg" id="service_account_amt" name="service_account_amt" value="${map.service_account_amt}" format="decimal" datatype="int" alt="서비스료" required="required" onchange="javascript:fnInitCalc();"> --%>
<!-- 							</div> -->
<!-- 							<div class="col width22px">원</div> -->
<!-- 						</div>						 -->
<!-- 					</td> -->
<!-- 				</tr> -->
				<tr>
					<th class="text-right">산출수수료(=)</th>
					<td>
						<div class="form-row inline-pd widthfix">
							&nbsp;&nbsp;&nbsp; = &nbsp;&nbsp;
							<div class="col width140px">
								<input type="text" class="form-control text-right" id="calc_commission_amt" name="calc_commission_amt" format="decimal" datatype="int" alt="산출수수료" readonly>
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">부가세</th>
					<td>
						<div class="form-row inline-pd widthfix">
							&nbsp; X 10% &nbsp;
							<div class="col width120px">
								<input type="text" class="form-control text-right" id="sale_vat_amt" name="sale_vat_amt" format="decimal" datatype="int" alt="부가세" readonly>
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">유보금</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width180px">
								<input type="text" class="form-control text-right essential-bg" id="delay_amt" name="delay_amt" value="${map.delay_amt}" format="decimal" datatype="int" alt="유보금" onchange="javascript:fnInitCalc();">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				</tbody>
			</table>
			<table class="table-border mt5">
				<colgroup>
					<col width="65px">
					<col width="">
					<col width="65px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th rowspan="2">정산예정</th>
						<th class="text-right">수수료</th>
						<td colspan="5">
							<div class="form-row inline-pd widthfix">
								<div class="col width180px">
									<input type="text" class="form-control text-right" id="account_commition_amt" name="account_commition_amt" format="decimal" datatype="int" alt="수수료" readonly>
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">부가세</th>
						<td colspan="5">
							<div class="form-row inline-pd widthfix">
								<div class="col width180px">
									<input type="text" class="form-control text-right" id="account_vat_amt" name="account_vat_amt" format="decimal" datatype="int" alt="부가세" readonly>
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th rowspan="2">기정산액</th>
						<th class="text-right essential-item">수수료</th>
						<td colspan="5">
							<div class="form-row inline-pd widthfix">
								<div class="col width180px">
									<input type="text" class="form-control text-right essential-bg" id="agency_pay_sale_amt" name="agency_pay_sale_amt" value="${map.agency_pay_sale_amt}" format="decimal" datatype="int" alt="수수료">
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">부가세</th>
						<td colspan="5">
							<div class="form-row inline-pd widthfix">
								<div class="col width180px">
									<input type="text" class="form-control text-right essential-bg" id="agency_pay_vat_amt" name="agency_pay_vat_amt" value="${map.agency_pay_vat_amt}" format="decimal" datatype="int" alt="부가세">
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
					</tr>
				</tbody>
			</table>

		</div>
		<!-- /원화 + 외화예금 -->
		<div class="btn-group mt10">
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->
</form>
</body>
</html>
