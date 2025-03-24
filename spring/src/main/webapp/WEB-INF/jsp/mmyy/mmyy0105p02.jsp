<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 법인카드 사용이력 > null > 가맹점상세정보
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body>
<!-- 팝업 -->
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 카드사용내역상세 -->
		<div>
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
				<tr>
					<th class="text-right">가맹점명</th>
					<td>투썸플레이스</td>
				</tr>
				<tr>
					<th class="text-right">사업자번호</th>
					<td>119-45-45446</td>
				</tr>
				<tr>
					<th class="text-right">가맹점번호</th>
					<td>45154455</td>
				</tr>
				<tr>
					<th class="text-right">과세유형</th>
					<td>일반과세</td>
				</tr>
				<tr>
					<th class="text-right">대표자명</th>
					<td>장현석</td>
				</tr>
				<tr>
					<th class="text-right">전화번호</th>
					<td></td>
				</tr>
				<tr>
					<th class="text-right">우편번호</th>
					<td></td>
				</tr>
				<tr>
					<th class="text-right">우편주소</th>
					<td></td>
				</tr>
				<tr>
					<th class="text-right">기타주소</th>
					<td></td>
				</tr>
				<tr>
					<th class="text-right">업종코드/명</th>
					<td></td>
				</tr>
				</tbody>
			</table>
		</div>
		<!-- /카드사용내역상세 -->
		<div class="btn-group mt10">
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->

</body>
</html>