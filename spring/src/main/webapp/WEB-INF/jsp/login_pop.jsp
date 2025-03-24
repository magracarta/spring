<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	
	<script>
		$(document).ready(function() {

		});
		
		function goLogin(frm) {
			if($M.validation(frm) == false) {
				return;
			}
		
		 	$M.goNextPageAjax('/login', frm, {method:'post'},
				function(result) {
			 		if(result.success) {	// 로그인 성공
			 			alert("로그인 성공");
			 			window.close();
			 		} 
				}
			);
		}
		
		function enter(fieldObj) {
			var field = ["user_id", "passwd"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goLogin(document.main_form);
				}
			});
		}
	</script>
</head>
<body  class="bg-white" >
<!-- 팝업 -->
     <div class="popup-wrap width-100per" style="height : 100%">
		<div class="right-loginform" style="padding-left : 0; padding-top : 30px;">
			<div><img src="/static/img/login-logo.png" alt="YK건기 로고"></div>
			<div class="yk-text">항상 정확하고 올바른 서비스를 제공하기 위해<br>끊임없이 노력하는 YK건기</div>
			<form name="main_form" id="main_form" autocomplete="off" style="height: auto;">
				<div class="form">
					<div class="icon-btn-cancel-wrap login">
						<input type="text" name="user_id" id="user_id" required="required" alt="아이디" placeholder="메일아이디" maxlength="20" size="20">
					</div>
					<div class="icon-btn-cancel-wrap login">
						<input type="password" name="passwd" id="passwd" required="required" alt="비밀번호" placeholder="비밀번호" maxlength="20" size="20">
					</div>
				</div>
				<button type="button" class="btn-login-submit" onclick="javascript:goLogin(document.main_form);">로그인</button>	
			</form>
	        <!-- /부서별 계정정보 -->
		</div>
	</div>
</body>
</html>