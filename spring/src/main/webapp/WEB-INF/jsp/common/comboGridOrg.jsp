<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
	<script type="text/javascript">		
		<c:forEach var="item" items="${orgcenterMap}">${item}</c:forEach>
	</script>
	<%
		String strOrgCenterCode = (request.getParameter("org_filed_id") == null )? "s_org_center_code":request.getParameter("org_filed_id");
	%>   	
	<c:if test="${SecureUser.org_type ne 'BASE'}">
		<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly"  style="width:120px;">
		<input type="hidden" value="${SecureUser.org_code}" id="<%=strOrgCenterCode %>" name="<%=strOrgCenterCode %>" readonly="readonly">
	</c:if>
	<c:if test="${SecureUser.org_type eq 'BASE'}">
		<input type="text" style="width : 200px";
			value="${SecureUser.org_name}"
			id="<%=strOrgCenterCode %>"
			name="<%=strOrgCenterCode %>"
			idfield="org_code"
			textfield="org_name"
			easyui="combogrid"
			header="Y"
			easyuiname="orgcenterList"
			panelwidth="200"
			maxheight="155"
			enter="goSearch()"
			multi="N"/>
	</c:if>
