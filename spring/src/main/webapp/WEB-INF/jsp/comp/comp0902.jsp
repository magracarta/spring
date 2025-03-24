<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 회계연관팝업 > 회계연관팝업 > null > 가맹점상세조회
-- 작성자 : 박준영
-- 최초 작성일 : 2020-05-18 10:25:25
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>

		function fnClose() {
			window.close();
		}
	</script>
</head>
<body>

<!-- contents 전체 영역 -->
<!-- 팝업 -->
<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /메인 타이틀 -->
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
					<td>${bean.chain_nm}</td>
				</tr>
				<tr>
					<th class="text-right">사업자번호</th>
					<td>${bean.chain_id}</td>
				</tr>
				<tr>
					<th class="text-right">가맹점번호</th>
					<td>${bean.chain_no}</td>
				</tr>
				<tr>
					<th class="text-right">과세유형</th>
					<td>${bean.tax_name}</td>
				</tr>
				<tr>
					<th class="text-right">대표자명</th>
					<td>${bean.master}</td>
				</tr>
				<tr>
					<th class="text-right">전화번호</th>
					<td>${bean.merchtel}</td>
				</tr>
				<tr>
					<th class="text-right">우편번호</th>
					<td>${bean.merchzipcode}</td>
				</tr>
				<tr>
					<th class="text-right">우편주소</th>
					<td>${bean.merchaddr1}</td>
				</tr>
				<tr>
					<th class="text-right">기타주소</th>
					<td>${bean.merchaddr2}</td>
				</tr>
				<tr>
					<th class="text-right">업종코드/명</th>
					<td>${bean.mcccode}/${bean.mccname}</td>
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
		<!-- /카드사용내역상세 -->
	</div>
</div>
<!-- /contents 전체 영역 -->	

</body>
</html>