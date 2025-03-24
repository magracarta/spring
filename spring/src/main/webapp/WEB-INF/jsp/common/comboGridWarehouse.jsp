<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
	<script type="text/javascript">		
		<c:forEach var="item" items="${warehouseMap}">${item}</c:forEach>
	</script>
	<%
		String strWarehouseCode = (request.getParameter("warehouse_filed_id") == null )? "s_warehouse_code":request.getParameter("warehouse_filed_id");
	%>
	<c:if test="${SecureUser.org_type ne 'BASE'}">
		<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly" style="width : 120px">
		<input type="hidden" value="${SecureUser.org_code}" id="<%=strWarehouseCode %>" name="<%=strWarehouseCode %>" readonly="readonly">
	</c:if>
	<c:if test="${SecureUser.org_type eq 'BASE'}">
		<input type="text" style="width : 200px";
			value="${SecureUser.org_name}"			
			id="<%=strWarehouseCode %>"
			name="<%=strWarehouseCode %>"
			idfield="code_value"
			textfield="code_name"
			easyui="combogrid"
			header="Y"
			easyuiname="warehouseList"
			panelwidth="200"
			maxheight="155"
			enter="goSearch()"
			multi="N"/>
	</c:if>
