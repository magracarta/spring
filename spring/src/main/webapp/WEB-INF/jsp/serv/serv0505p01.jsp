<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 워렌티리포트 통합관리 > null > 수납금액조정
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-23 13:23:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		// 수납금액 계산
		function fnChangeCalc() {
			var applyErPrice = $M.getValue("apply_er_price"); // 환율
			var rcvPartFeYn = $M.getValue("rcv_part_fe_yn"); // 부품비 외화여부
			var rcvTravelFeYn = $M.getValue("rcv_travel_fe_yn"); // 출장비 외화여부
			var rcvWorkFeYn = $M.getValue("rcv_work_fe_yn"); // 공임비 외화여부

			var rcvPartAmt = $M.getValue("rcv_part_amt"); // 부품비 수납금액
			var rcvKorPartAmt = $M.getValue("rcv_kor_part_amt"); // 부품비 수납액*환율
			var rcvTravelAmt = $M.getValue("rcv_travel_amt"); // 출장비 수납금액
			var rcvKorTravelAmt = $M.getValue("rcv_kor_travel_amt"); // 출장비 수납액*환율
			var rcvWorkAmt = $M.getValue("rcv_work_amt"); // 공임 수납금액
			var rcvKorWorkAmt = $M.getValue("rcv_kor_work_amt"); // 공임 수납액*환율

			var params = {};
			// 부품비
			if(rcvPartFeYn == "Y") {
				rcvKorPartAmt = rcvPartAmt * applyErPrice;
			} else if(rcvPartFeYn == "N") {
				rcvKorPartAmt = rcvPartAmt;
			}
			params.rcv_kor_part_amt = rcvKorPartAmt;

			// 출장비
			if(rcvTravelFeYn == "Y") {
				rcvKorTravelAmt = rcvTravelAmt * applyErPrice;
			} else if(rcvTravelFeYn == "N") {
				rcvKorTravelAmt = rcvTravelAmt;
			}
			params.rcv_kor_travel_amt = rcvKorTravelAmt;

			// 공임
			if(rcvWorkFeYn == "Y") {
				rcvKorWorkAmt = rcvWorkAmt * applyErPrice;
			} else if(rcvWorkFeYn == "N") {
				rcvKorWorkAmt = rcvWorkAmt;
			}
			params.rcv_kor_work_amt = rcvKorWorkAmt;

			$M.setValue(params);
		}

		// 저장
		function goSave() {
			var frm = document.main_form;
			if ($M.validation(frm, {field: ["reclaim_yn"]}) == false) {
				return;
			}

			$M.goNextPageAjax(this_page + "/save", $M.toValueForm(frm), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("처리가 완료되었습니다.");
							fnClose();
							window.opener.goSearch();
						}
					}
			)
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="as_warranty_no" name="as_warranty_no" value="${result.as_warranty_no}">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="55px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="essential-item">환율</th>
						<td>
							<input type="text" class="form-control text-right essential-bg width120px" id="apply_er_price" name="apply_er_price" format="decimal" value="${result.apply_er_price}" onchange="javascript:fnChangeCalc();">
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->
			<!-- 상단 폼테이블 -->
			<div>
				<table class="table-border mt10">
					<colgroup>
						<col width="100px">
						<col width="240px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>구분</th>
						<th class="th-gray">청구액 대비 수납금액</th>
						<th class="th-gray">수납액 * 환율(원화)</th>
					</tr>
					<tr>
						<th>부품비</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-4">
									<select class="form-control" id="rcv_part_fe_yn" name="rcv_part_fe_yn" onchange="javascript:fnChangeCalc();">
										<option value="Y" <c:if test="${'Y' eq result.rcv_part_fe_yn}">selected="selected"</c:if> >외화</option>
										<option value="N" <c:if test="${'N' eq result.rcv_part_fe_yn}">selected="selected"</c:if> >원화</option>
									</select>
								</div>
								<div class="col-8">
									<input type="text" class="form-control text-right" id="rcv_part_amt" name="rcv_part_amt" format="decimal" onchange="javascript:fnChangeCalc();" value="${result.rcv_part_amt}">
								</div>
							</div>
						</td>
						<td>
							<input type="text" class="form-control text-right" id="rcv_kor_part_amt" name="rcv_kor_part_amt" format="decimal" readonly="readonly" value="${result.rcv_kor_part_amt}">
						</td>
					</tr>
					<tr>
						<th>출장비용</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-4">
									<select class="form-control" id="rcv_travel_fe_yn" name="rcv_travel_fe_yn" onchange="javascript:fnChangeCalc();">
										<option value="Y" <c:if test="${'Y' eq result.rcv_travel_fe_yn}">selected="selected"</c:if> >외화</option>
										<option value="N" <c:if test="${'N' eq result.rcv_travel_fe_yn}">selected="selected"</c:if> >원화</option>
									</select>
								</div>
								<div class="col-8">
									<input type="text" class="form-control text-right" id="rcv_travel_amt" name="rcv_travel_amt" format="decimal" onchange="javascript:fnChangeCalc();" value="${result.rcv_travel_amt}">
								</div>
							</div>
						</td>
						<td>
							<input type="text" class="form-control text-right" id="rcv_kor_travel_amt" name="rcv_kor_travel_amt" format="decimal" readonly="readonly" value="${result.rcv_kor_travel_amt}">
						</td>
					</tr>
					<tr>
						<th>공임</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-4">
									<select class="form-control" id="rcv_work_fe_yn" name="rcv_work_fe_yn" onchange="javascript:fnChangeCalc();">
										<option value="Y" <c:if test="${'Y' eq result.rcv_work_fe_yn}">selected="selected"</c:if> >외화</option>
										<option value="N" <c:if test="${'N' eq result.rcv_work_fe_yn}">selected="selected"</c:if> >원화</option>
									</select>
								</div>
								<div class="col-8">
									<input type="text" class="form-control text-right" id="rcv_work_amt" name="rcv_work_amt" format="decimal" onchange="javascript:fnChangeCalc();" value="${result.rcv_work_amt}">
								</div>
							</div>
						</td>
						<td>
							<input type="text" class="form-control text-right" id="rcv_kor_work_amt" name="rcv_kor_work_amt" format="decimal" readonly="readonly" value="${result.rcv_kor_work_amt}">
						</td>
					</tr>
					<tr>
						<th>결정사항</th>
						<td colspan="2">
							<input type="text" class="form-control" id="result_text" name="result_text" value="${result.result_text}">
						</td>
					</tr>
					<tr>
						<th>수납구분</th>
						<td colspan="2">
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="reclaim_yn_n" name="reclaim_yn" required="required" alt="수납구분" value="N" <c:if test="${'N' eq result.reclaim_yn}">checked="checked"</c:if> >
								<label for="reclaim_yn_n" class="form-check-label">마감</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="reclaim_yn_y" name="reclaim_yn" required="required" alt="수납구분" value="Y" <c:if test="${'Y' eq result.reclaim_yn}">checked="checked"</c:if> >
								<label for="reclaim_yn_y" class="form-check-label">Re-Claim</label>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /상단 폼테이블 -->
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