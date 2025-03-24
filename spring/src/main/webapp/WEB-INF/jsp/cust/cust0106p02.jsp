<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 거래원장 > null > 입금연기
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-09 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function () {
		});

		// 저장
		function goSave() {
			var frm = document.main_form;
			// validation check
			if($M.validation(frm,
					{field:["cust_deposit_chg_cd", "cust_no", "cust_name"]}) == false) {
				return;
			};

			var params = {
				"cust_no" : $M.getValue("cust_no"),
				"cust_name" : $M.getValue("cust_name"),
				"deposit_plan_dt" : $M.getValue("deposit_plan_dt"),
				"deposit_old_dt" : $M.getValue("deposit_old_dt"),
				"cust_deposit_chg_cd" : $M.getValue("cust_deposit_chg_cd"),
				"desc_text" : $M.getValue("desc_text")
			};

			$M.goNextPageAjaxSave(this_page +"/save", $M.toGetParam(params), {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("정상 처리되었습니다.");
						fnClose();
						window.opener.goSearch();
					};
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no" value="${info.cust_no}">
<input type="hidden" id="cust_name" name="cust_name" value="${info.cust_name}">
<input type="hidden" id="deposit_old_dt" name="deposit_old_dt" value="${info.deposit_plan_dt}">

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
					<h4>입금연기등록</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">연기사유</th>
						<td>
							<select class="form-control width100px" id="cust_deposit_chg_cd" name="cust_deposit_chg_cd" required="required" alt="연기사유">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['DEPOSIT_DELAY_REASON']}" var="item">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
					</tr>
					<tr>
						<th class="text-right">입금예정일</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 calDate" id="deposit_plan_dt" name="deposit_plan_dt" dateFormat="yyyy-MM-dd" readonly="readonly" required="required" alt="입금예정일" value="${info.deposit_plan_dt}">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td>
							<input type="text" class="form-control" id="desc_text" name="desc_text">
						</td>
					</tr>
					<tr>
						<th class="text-right">등록자</th>
						<td>
							${info.mem_name}
						</td>
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