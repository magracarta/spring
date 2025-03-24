<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<spring:eval expression="@environment.getProperty('server.type')" var="serverType" /><spring:eval expression="@environment.getProperty('spring.datasource.url')" var ="datasourceUrl"/><spring:eval expression="@environment.getProperty('spring.datasource.username')" var ="userName"/>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script language="javascript">
	$(document).ready(function() {
		if('00' != '${inputParam.result_code}') {
			alert('라인웍스 연동오류입니다.\n오류코드[${inputParam.result_code}]');
			self.close();
		} else {
			goAuthSave();
		}
	});
	
	function goAuthSave() {
		var param = {
				"auth_code" : '${inputParam.code}',
				"mem_no" : opener.main_form.mem_no.value
		};
	 	$M.goNextPageAjax('/auth/line', $M.toGetParam(param), {method:'post'},
			function(result) {
		 		if(result.success) {	// 로그인 성공
		 		} 
		 		opener.location.reload();
		 		self.close();
			}
		);
	}
	</script>
</head>
</html>