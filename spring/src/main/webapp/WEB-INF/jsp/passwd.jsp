<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	
	<script>
		$(document).ready(function() {
			if (opener == null) {
				alert("비정상 접근");
				return false;
			}
			
			$M.getComp('passwd').focus();
		});
		
		function goCheck(frm) {
			if($M.validation(frm) == false) {
				return;
			}
		 	$M.goNextPageAjax('/checkPw', frm, {method:'post'},
				function(result) {
			 		if(result.success) {
		 				//opener.sessionStorage.setItem('chrome', "Y");
	 					opener.location.reload();
	 					window.close();
			 		} 
				}
			);
		}
		
		function enter(fieldObj) {
			var field = ["passwd"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goCheck(document.main_form);
				}
			});
		}
	</script>
</head>
<body  class="bg-white" >
<form name="main_form" id="main_form" autocomplete="off" style="height: auto;">
<!-- 팝업 -->
     <div class="popup-wrap width-100per" style="height : 100%">
		<div class="right-loginform" style="padding-left : 0; padding-top : 30px;">
			<div><img src="/static/img/login-logo.png" alt="YK건기 로고"></div>
			<div class="yk-text">정보보호를 위해, 비밀번호를 다시 입력해주세요.</div>
			
				<div class="form">
					<div class="icon-btn-cancel-wrap login">
						<input type="password" name="passwd" id="passwd" required="required" alt="비밀번호" placeholder="비밀번호" maxlength="20" size="20">
					</div>
				</div>
				<button type="button" class="btn-login-submit" onclick="javascript:goCheck(document.main_form);">확인</button>	
			
	        <!-- /부서별 계정정보 -->
		</div>
	</div>
<input type="hidden" id="menu_seq" name="menu_seq" value="${param.page }"/>
</form>
</body>
</html>