<%@ page contentType="text/html;charset=utf-8" language="java"%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<link rel="shortcut icon" type="image/x-icon" href="/static/img/favicon.ico" />
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<script type="text/javascript">
	$(document).ready(function(){
		var userId = getCookie('SPRING_SECURITY_REMEMBER_ME');
		if(typeof userId != 'undefined' && userId != ''){
			$("#user_id").val(userId);
			$("#save_user_id").prop("checked", true);
		}
	});
	
	function getCookie(cname) {
	    var name = cname + "=";
	    var ca = document.cookie.split(';');
	    for(var i = 0; i < ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') {
	            c = c.substring(1);
	        }
	        if (c.indexOf(name) == 0) {
	            return c.substring(name.length, c.length);
	        }
	    }
	    return "";
	}
	
	function goLogin(frm){
		if($M.validation(document.open_layer_passFind, {field:['user_id', 'passwd']}) == false) {
			return;
		}
	 	$M.goNextPageAjax('/login', frm, {method:'post'},
			function(result) {
		 		if(result.success) {	// 로그인 성공
		 			$M.goNextPage('/main');
		 		} 
			}
		);
	}
	
	function goCellCertification(){
		$M.goNextPageLayerDiv('open_layer_passFind');
	}
	
	function goSendAuthNo(){
		if($M.validation(document.open_layer_passFind, {field:['user_find_id']}) == false) {
			return;
		}
		
		var param = {'user_find_id' : $M.getValue('user_find_id') };
		
		$M.goNextPageAjax('/userCheck', $M.toGetParam(param), {method : 'get'}, 
			function(result){
				if(result.success){

					var subParam = {
						'smart_no' : result.cell_no,
						'target_code' : result.cell_no,
						'sms_auth_cd' : '02',
					}
					
					$M.goNextPageAjax("/sms/saveSmsAuth", $M.toGetParam(subParam), {method : 'post'},
						function(result){
							alert("인증번호를 전송하였습니다.");
							
		 					$("#confirmAuth").attr("href", "javascript:goConfirmAuth();");
		 					$M.setValue("smsAuthSeq", result.seq);
						}
					);
				}
			}
		);
	}
	
	function goConfirmAuth(){
		if($M.validation(document.open_layer_passFind, {field:['p_auth_code']}) == false) {
			return;
		}
		
		var param = {
				'sms_auth_seq' 	: $M.getValue('smsAuthSeq'),
				'auth_code'		: $M.getValue('p_auth_code')
		}
		
		$M.goNextPageAjax('/sms/checkCellCertification', $M.toGetParam(param), {method : 'post'},
			function(result){
				if(result.success){
					if(result.auth_yne == 'Y'){
						processDisabled(['change_pass', 'confirm_change_pass', 'savePass'], false, null, [ ["savePass", "javascript:regPass();"]]);
						processDisabled(['user_find_id', 'sendAuth', 'p_auth_code', 'confirmAuth'], true, null, null);
						alert(msg.alert.auth.success);
					} else {
						alert(msg.alert.auth.fail);
					}
				}
			}
		)
	}
	
	function regPass(){
		if($M.validation(document.open_layer_passFind, {field:['change_pass', 'confirm_change_pass']}) == false) {
			return;
		}

		var pass = $('#change_pass').val();
		var confirmPass = $('#confirm_change_pass').val();
		
		if(pass.length < 6){
			alert('6자리 이상의 비밀번호를 입력해 주시기 바랍니다.');
			$("#change_pass").focus();
			return;
		}
		
		if(confirmPass.length < 6){
			alert('6자리 이상의 비밀번호를 입력해 주시기 바랍니다.');
			$("#confirm_change_pass").focus();
			return;
		}
		
		if(pass != confirmPass){
			alert('패스워드가 일치하지 않습니다.');
			$("#confirm_change_pass").focus();
			return;
		}
		
		var param = {
				'user_id' : $M.getValue('user_find_id'),
				'passwd' : $M.getValue('change_pass'),
		}
		
		$M.goNextPageAjax('/changePass', $M.toGetParam(param), {method : 'post'},
			function(result){
				if(result.success){
					alert("정상적으로 변경 되었습니다.");
					fnResetAndClose();
				}
			}
		);
		
	}
	
	function fnResetAndClose(){
		$.each(['user_find_id', 'p_auth_code', 'change_pass', 'confirm_change_pass'], function(index, value){
			$("#"+value).val("");
		})
		$M.setHiddenValue("smsAuthSeq", "");
		
		processDisabled(['change_pass', 'confirm_change_pass', 'savePass'], true, null, null);
		processDisabled(['user_find_id', 'sendAuth', 'p_auth_code', 'confirmAuth'], false, null, [["sendAuth","javascript:goSendAuthNo()"]]);
		
		$.magnificPopup.close();
	}
	
	function enter(fieldObj) {
		var field = ["user_id", "passwd"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goLogin(document.main_form);
			}
		});
	}
	
	function fnChangeUserId(obj){
		obj.value = obj.value.toUpperCase();
	}

</script>
<body class="login_page">
<form id="main_form" name="main_form">
<div class="login_wrap">
    <img src="/static/img/login_logo.png" alt="셀트리온 스킨큐어 로고" />
	<div class="login_box">
		<img src="/static/img/login_title.png" alt="SCC 방판 영업 관리 시스템" />
		<input class="textbox-re" type="text" id="user_id" name="user_id" style="width:100%;" value='' required="required" placeholder="아이디" alt="아이디" onchange="javascript:fnChangeUserId(this);">
		<input class="textbox-re" type="password" id="passwd" name="passwd" style="width:100%;" value='' required="required" placeholder="비밀번호" alt="비밀번호">
		<div style="height:15px;">
			<div style="display: inline; float: left; padding-top : 3px;">
				<input type="checkbox" id="save_user_id" name="save_user_id"/><label for="save_user_id" >아이디 자동저장</label>
			</div>
			<div style="display: inline; float: right;">
				<a href="javascript:goCellCertification();" class="btn_pass" style="float: right;">비밀번호 변경</a>
			</div>
		</div>
		<a href="javascript:" class="btn_login" onclick="javascript:goLogin(document.main_form)">로그인</a>
<!-- 		<div class="info_text"> -->
<!-- 			아이디/비밀번호 문의는 012-3456-1234로 문의해 주시기 바랍니다. -->
<!-- 		</div> -->
	</div>
	<div class="copyright">Copyright© 2017 Celltrion Skincure Inc. All rights reserved.</div>
</div>

<div id="open_layer_passFind" name="open_layer_passFind" class="popup-wrap mfp-hide">
	<div class="window-re wd400">
		<div class="popup-tit-area">
			<h2>비밀번호 변경</h2>
		</div>
		<div class="popup-con-area mt10">
			<table cellpadding="0" cellspacing="0" class="form_table">
				<colgroup>
					<col width="120px" />
					<col width="" />
				</colgroup>
				<tbody>	
					<tr>
						<th colspan="2">아이디에 등록되어 있는 휴대폰으로 인증문자가 발송 됩니다.</th>
					</tr>
					<tr>
						<th>아이디</th>
						<td>
							<input type="text" id="user_find_id" name="user_find_id" alt="아이디" class="textbox-re" required="required" onchange="javascript:fnChangeUserId(this);">
 							<a id="sendAuth" class="btn_tb" href="javascript:goSendAuthNo();">인증번호발송</a>
						</td>
					</tr>
					<tr>
						<th>인증번호</th>
						<td>
							<input id="p_auth_code" name="p_auth_code"  alt="인증번호" type="text" class="textbox-re" datatype="int" minlength=4 maxlength=4>
							<a id="confirmAuth" class="btn_tb" href="javascript:alert('인증번호를 받지 않았습니다.')">인증번호확인</a>
						</td>
					</tr>
					<tr>
						<th colspan="2">변경규칙 : 비밀번호 6자리 이상</th>
					</tr>
					<tr>
						<th>새로운 비밀번호</th>
						<td>
							<input type="password" id="change_pass" name="change_pass" class="textbox-re readonly" disabled="disabled" required="required" alt="새로운비밀번호">
						</td>
					</tr>
					<tr>
						<th>비밀번호 확인</th>
						<td>
							<input type="password" id="confirm_change_pass" name="confirm_change_pass" class="textbox-re readonly" disabled="disabled" required="required" alt="비밀번호확인">
							<a id="savePass" href="javascript:regPass();" class="btn gray"><i class="ok"></i>비밀번호 초기화</a>
						</td>
					</tr>
				</tbody>
			</table>				
			<div class="btn_group mt10">
				<div class="btn_right">
					<a href="javascript:fnResetAndClose();" class="btn gray"><i class="cancel"></i>닫기</a>
				</div>
			</div>
		</div>
	</div>
</div>

</form>
</body>
</html>