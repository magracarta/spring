<%@ page pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><c:set var="btnList" value="${btnAuthMap[param.pos] }"/>
<c:set var="memNo" value="${param.mem_no eq null ? SecureUser.mem_no : param.mem_no}"/>
<c:set var="writerYn" value="${SecureUser.mem_no eq memNo ? 'Y' : 'N'}"/>
<c:set var="showYn" value="${param.show_yn eq null ? 'Y' : param.show_yn}"/>
<c:set var="hide_f" value="${param.hide_field}"/><%-- 감추는 필드 display:none --%>
<%-- param 설명
- hide_field : 감추는(display:none) 필드값을 나열하면 js로 제어 가능...  구분자는 #
- mem_no : access_gwm(W) 일때, 영향
- show_yn : access_gwm(W/M) 일때, 영향 
#### access_gwm - G(일반), W(등록자), M(관리자) ==> W일때는 호출페이지에서 mem_no 를 넘겨 받아 매핑되야 노출함, M은 버튼 가져올때 필터링함
--%>
<%-- 결재관련 아닐때 --%>
<c:if test="${param.appr_yn ne 'Y'}">
	<c:forEach var="list" items="${btnList }">
		<c:set var="display_html" value="${list.display_html}"/><c:if test="${fn:contains(hide_f, list.js_name)}"><c:set var="display_html" value="${fn:replace(display_html, '<button', '<button style=\\'display:none;\\'') }"/></c:if>
		<c:choose>
		<c:when test="${list.access_gwm eq 'G'}">${display_html }</c:when>	
		<c:when test="${list.access_gwm eq 'W' && showYn eq 'Y'}">
			<c:if test="${writerYn eq 'Y' or fn:contains(list.mng_org_code_str, SecureUser.org_code) or fn:contains(list.mng_grade_str, SecureUser.grade_cd) or fn:contains(list.mng_mem_str, SecureUser.mem_no)}">${display_html }</c:if></c:when>	
		<c:when test="${list.access_gwm eq 'M' && showYn eq 'Y'}">${display_html }</c:when>	
		</c:choose>
	</c:forEach>
</c:if>
<%-- 결재관련 일때    --%>
<c:if test="${param.appr_yn eq 'Y'}">
<c:forEach var="list" items="${btnList }">
	<c:forEach var="jsName" items="${apprBean.appr_btn }">
		<c:set var="display_html" value="${list.display_html}"/><c:if test="${fn:contains(hide_f, list.js_name)}"><c:set var="display_html" value="${fn:replace(display_html, '<button', '<button style=\\'display:none;\\'') }"/></c:if>
		<c:if test="${jsName eq list.js_name }">${list.display_html }</c:if>
	</c:forEach>
</c:forEach>
</c:if>
