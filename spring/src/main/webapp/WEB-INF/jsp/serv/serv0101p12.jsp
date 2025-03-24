<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 정비리콜처리
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-15 09:34:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	$(document).ready(function() {
	});

	// 저장
	function goSave() {
		var frm = document.main_form;
		//validationcheck
		if ($M.validation(frm,
				{field: ["campaign_seq", "machine_seq"]}) == false) {
			return;
		}

		frm = $M.toValueForm(frm);
		$M.goNextPageAjax(this_page + "/save", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("저장이 완료되었습니다.");
						window.opener.goSearch();
						fnClose();
					}
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
<input type="hidden" id="campaign_seq" name="campaign_seq" value="${campaignMachineDetail.campaign_seq}">
<input type="hidden" id="machine_seq" name="machine_seq" value="${campaignMachineDetail.machine_seq}">

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
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">차대번호</th>
						<td colspan="3">
							<input type="text" id="body_no" name="body_no" class="form-control width180px" readonly="readonly" value="${campaignMachineDetail.body_no}">
						</td>
					</tr>
					<tr>
						<th class="text-right">리콜명</th>
						<td colspan="3">
							<input type="text" id="campaign_name" name="campaign_name" class="form-control width180px" readonly="readonly" value="${campaignMachineDetail.campaign_name}">
						</td>
					</tr>
					<tr>
						<th class="text-right">처리사항1</th>
						<td colspan="3">
							<input type="text" id="proc_text_1" name="proc_text_1" class="form-control">
						</td>
					</tr>
					<tr>
						<th class="text-right">처리사항2</th>
						<td colspan="3">
							<input type="text" id="proc_text_2" name="proc_text_2" class="form-control">
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>