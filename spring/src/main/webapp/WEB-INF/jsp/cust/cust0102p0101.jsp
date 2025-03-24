<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 고객조회/등록 > 고겍정보상세 > 서비스충성도
-- 작성자 : 정선경
-- 최초 작성일 : 2024-03-08 13:26:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function () {
		});

		// 닫기
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
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap">
					<h4><span class="font-15">${result.cust_name}님 서비스충성도 ${empty result.svc_loyal_cd? '' : ' > '} ${result.svc_loyal_name}</span></h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
					</colgroup>
					<tbody>
					<tr>
						<th class="th-skyblue" rowspan="2">구분</th>
						<th class="th-skyblue" colspan="2">통합</th>
						<th class="th-skyblue" colspan="2">정비</th>
						<th class="th-skyblue" colspan="2">수주</th>
						<th class="th-skyblue" colspan="2">렌탈</th>
						<th class="th-skyblue" rowspan="2">정비율</th>
					</tr>
					<tr>
						<th>횟수</th>
						<th>금액</th>
						<th>횟수</th>
						<th>금액</th>
						<th>횟수</th>
						<th>금액</th>
						<th>횟수</th>
						<th>금액</th>
					</tr>
					<tr>
						<th>누적</th>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.total_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.total_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.total_repair_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.total_repair_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.total_sale_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.total_sale_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.total_rent_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.total_rent_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber type="percent" pattern="#,##0.##%" value="${result.total_maintenance_rate}"/></td>
					</tr>
					<tr>
						<th>전년</th>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.last_year_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.last_year_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.last_year_repair_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.last_year_repair_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.last_year_sale_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.last_year_sale_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.last_year_rent_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.last_year_rent_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber type="percent" pattern="#,##0.##%" value="${result.last_year_maintenance_rate}"/></td>
					</tr>
					<tr>
						<th>당해</th>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.curr_year_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.curr_year_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.curr_year_repair_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.curr_year_repair_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.curr_year_sale_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.curr_year_sale_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber value="${result.curr_year_rent_cnt}"/></td>
						<td class="text-right text-dark"><fmt:formatNumber value="${result.curr_year_rent_amt}"/></td>
						<td class="text-center text-dark"><fmt:formatNumber type="percent" pattern="#,##0.##%" value="${result.curr_year_maintenance_rate}"/></td>
					</tr>
					</tbody>
				</table>

				<table class="table-border mt15">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">최초거래일</th>
							<td class="text-center text-dark"><c:out value="${empty result.first_inout_dt? '-' : result.first_inout_dt}"/></td>
							<th class="text-right">거래간<br/>간격(개월)</th>
							<td class="text-center text-dark"><fmt:formatNumber value="${result.deal_day_cnt}" maxFractionDigits="1"/></td>
							<th class="text-right">장비구매<br/>횟수</th>
							<td class="text-center text-dark"><fmt:formatNumber value="${result.mch_sale_cnt}"/></td>
							<th class="text-right">장비구매간<br/>간격(개월)</th>
							<td class="text-center text-dark"><fmt:formatNumber value="${result.mch_sale_day_cnt}" maxFractionDigits="1"/></td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
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