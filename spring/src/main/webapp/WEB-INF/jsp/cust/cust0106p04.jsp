<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 거래원장 > null > 메모상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-12-07 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function () {
		});

		// 수정
		function goModify() {
			var frm = document.main_form;
			// validation check
			if($M.validation(frm,
					{field:["inout_doc_no"]}) == false) {
				return;
			};

			var params = {
				"inout_doc_no" : $M.getValue("inout_doc_no"),
				"cust_no" : $M.getValue("cust_no"),
				"desc_text" : $M.getValue("desc_text")
			};

			$M.goNextPageAjaxModify(this_page +"/modify", $M.toGetParam(params), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("정상 처리되었습니다.");
							fnClose();
							window.opener.goSearch();
						};
					}
			);
		}

		// 삭제
		function goRemove() {
			var frm = document.main_form;
			// validation check
			if($M.validation(frm,
					{field:["inout_doc_no"]}) == false) {
				return;
			};

			var params = {
				"inout_doc_no" : $M.getValue("inout_doc_no"),
				"cust_no" : $M.getValue("cust_no")
			};

			$M.goNextPageAjaxRemove(this_page +"/remove", $M.toGetParam(params), {method : 'POST'},
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
<input type="hidden" id="inout_doc_no" name="inout_doc_no" value="${result.inout_doc_no}">
<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">

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
					<h4>메모 상세</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">비고</th>
						<td>
							<input type="text" class="form-control" id="desc_text" name="desc_text" value="${result.desc_text}">
						</td>
					</tr>
					<tr>
						<th class="text-right">등록자</th>
						<td>
							${result.reg_mem_name}
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