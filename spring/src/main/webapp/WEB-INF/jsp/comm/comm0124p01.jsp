<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 영업 > 장비QR코드관리 > 장비QR코드상세
-- 작성자 : 정선경
-- 최초 작성일 : 2023-04-06 15:52:10
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/qrcode.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			fnInit();
		});
		
		function fnInit() {
			// qr코드 그리기
			if (${not empty result.qr_no}) {
				new QRCode(document.getElementById("qr_image"), {
					text: "${result.qr_no}",
					width: 160,
					height: 160,
				});
				$("#qr_image > img").css({"margin":"auto"});
			}
		}

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
				<div class="btn-group">
					<div class="left">
						<h4>장비QR코드상세</h4>
					</div>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">메이커</th>
							<td><c:out value="${result.maker_name}"/></td>
							<th class="text-right">모델명</th>
							<td><c:out value="${result.machine_name}"/></td>
						</tr>
						<tr>
							<th class="text-right">차대번호</th>
							<td><c:out value="${result.body_no}"/></td>
							<th class="text-right">고객명</th>
							<td><c:out value="${result.cust_name}"/></td>
						</tr>
						<tr>
							<th class="text-right">등록일자</th>
							<td>
								<fmt:parseDate value="${result.assign_dt}" var="assign_dt" pattern="yyyyMMdd"/>
								<fmt:formatDate value="${assign_dt}" pattern="yyyy-MM-dd"/>
							</td>
							<th class="text-right">등록자</th>
							<td><c:out value="${result.assign_mem_name}"/></td>
						</tr>
						<tr>
							<th class="text-right">QR이미지</th>
							<td colspan="3" style="height: 200px;">
								<div id="qr_image" name="qr_image">
									<input type="hidden" id="qr_no" name="qr_no" value="${result.qr_no}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="3" style="white-space:pre-wrap;"><c:out value="${result.remark}"/></td>
						</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
					</jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
