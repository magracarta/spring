<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비대장관리 > null > CAP해지
-- 작성자 : 성현우
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		function fnClose() {
			window.close();
		}

		function goSave() {
			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["reason_text"]})==false) {
				return;
			};

			var param = {
				"machine_seq": $M.getValue("machine_seq"),
				"seq_no": $M.getValue("seq_no"),
				"reason_text": $M.getValue("reason_text"),
			};

			$M.goNextPageAjaxSave(this_page + '/save', $M.toGetParam(param), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("해지가 완료되었습니다.");
							fnClose();
							window.opener.location.reload();
						}
					}
			);
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="machine_seq" id="machine_seq" value="${inputParam.machine_seq}">
	<input type="hidden" name="seq_no" id="seq_no" value="${inputParam.seq_no}">
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
					<h4>CAP해지</h4>
				</div>
				<!-- 검색영역 -->
				<div class="search-wrap mt5">
					<table class="table table-fixed">
						<colgroup>
							<col width="">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th style="width: 80px;">CAP 해지일</th>
							<td>
								<div class="input-group" style="width: 120px;">
									<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}">
								</div>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->
				<div class="mt10">
					<textarea class="form-control essential-bg" id="reason_text" name="reason_text" style="height: 100px;" required="required" alt="해지사유" placeholder="CAP해지 사유를 입력하세요."></textarea>
				</div>

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