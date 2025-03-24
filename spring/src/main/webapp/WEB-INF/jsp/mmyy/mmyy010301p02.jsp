<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<jsp:scriptlet> pageContext.setAttribute("newline", "\n"); </jsp:scriptlet>

<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 크게보기 팝업
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-06-30 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		
	</script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form" style="height : 100%">
	<div class="popup-wrap width-100per" style="height : 100%">
          <!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<div class="content-wrap">
	          	<c:forEach var="item" items="${list }">
					<div class="width-100per mt10 mb10">
						<strong class="font-13 mb5">○ 고객명 : ${item.cust_name }
							<span class="ml5"> ${item.hp_no }</span>
							<span class="ml5"> ${item.consult_case_name }</span>
							<span class="ml5" > 상담시간 ${item.consult_ti } (${item.consult_min }분)</span>
							<c:if test="${not empty item.consult_interest_name }"><span class="ml5"> ${item.consult_interest_name }</span></c:if>
							<c:if test="${not empty item.consult_buy_plan_name }"><span class="ml5"> ${item.consult_buy_plan_name }</span></c:if>
						</strong>
						<div class="width-100per">
							<%-- <textarea>${item.consult_text }</textarea> --%>
							<c:out value="${fn:replace(item.consult_text, newline, '<br/>')}" escapeXml="false"/>
						</div>
						<br/>
					</div>
				</c:forEach>
          	</div>
      </div>
</form>
</body>
</html>