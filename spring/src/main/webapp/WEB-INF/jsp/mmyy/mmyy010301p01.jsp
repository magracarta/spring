<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
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
<!-- 팝업 -->
      <div class="popup-wrap width-100per" style="height : 100%">
          <!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<div class="content-wrap" style="height : 90%">
	          <!-- /타이틀영역 -->
	          <c:choose>
	          	<c:when test="${fn:contains(s_work_text, '</p>') || fn:contains(s_work_text, '</span>') || fn:contains(s_work_text, '</div>')}">
	          		<div contenteditable="true" style="height: 100%; overflow-y: scroll;" class="form-control mt5 editor">${s_work_text}</div>
	          	</c:when>
	          	<c:otherwise>
	          		<textarea class="form-control mt5" style="height: 100%; background: #fff" id="work_text" name="work_text" required="required" alt="당일특이사항" readonly="readonly">${s_work_text}</textarea>
	          	</c:otherwise>
	          </c:choose>
          </div>
          <div class="btn-group mt10">
          	
				
          </div>
      </div>
      <!-- /팝업 -->
</form>
</body>
</html>