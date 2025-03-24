<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-20 13:01:58
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<!-- script -->
<script type="text/javascript">

	$(document).ready(function() {
		if($M.getValue("s_hp_no") == null || $M.getValue("s_hp_no") == undefined) {
			$("#authSendBtn").attr('disabled', true);
		} 
		$("#authBtn").attr('disabled', true);
	});
	
	function goAuthRequest() {
		frm = document.main_form;
		if($M.validation(frm) == false) { return;}
		var leftSec = 180;
		var display = document.querySelector('#timer');
		$M.goNextPageAjax(this_page, $M.toValueForm(frm), {method:'post'},
			function(result) {
		 		if(result.success) {
		 			fnStartTimer(leftSec, display);
		 			$M.setValue("sms_auth_seq", result.sms_auth_seq);
		 			$("#authBtn").attr('disabled', false);
		 		} 
			}
		);
	}
	
	// 타이머 시작
	function fnStartTimer(count, display) {
	    var minutes, seconds;
	    isRunning = true;
	    fnDisplayTimer(minutes, seconds, count, display);
        --count;
	    timer = setInterval(function () {
	    	fnDisplayTimer(minutes, seconds, count, display);
	        if (--count < 0) {
		      clearInterval(timer);
		      display.textContent = "요청시간 만료";
		      $('#authBtn').prop("disabled", true);
		      isRunning = false;
	        }
	    }, 1000);
	}
	
	function fnDisplayTimer(minutes, seconds, count, display) {
	    minutes = parseInt(count / 60, 10);
        seconds = parseInt(count % 60, 10);
        minutes = minutes < 10 ? "" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;
        display.textContent = minutes + ":" + seconds;
	}
	
	function goAuthConfirm() {
		if($M.validation(document.main_form, {field:['auth_no']}) == false) {
			return;
		} else {
			// todo: 인증번호 확인
		 	$M.goNextPageAjax(this_page + "/" + $M.getValue("sms_auth_seq") + '/'+ $M.getValue("auth_no") , $M.toValueForm(frm), {method:'post'},
				function(result) {
			 		if(result.success) {	// 전송 성공
						isChecked = true;
						document.querySelector('#timer').textContent = "";
						clearInterval(timer);
						var hp = $M.getValue("s_hp_no");
						try{
							// if($M.getValue("cust_no") == "") {
							// 	alert("정상 처리되었습니다.");
							// }
							
							opener.${inputParam.parent_js_name}(hp);
							window.close();	
						} catch(e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}
			 		} 
				}
			);
		}
  	}
	
</script>
<!-- /script -->
<body class="bg-white">
<!-- 여기에 content-wrap 삽입 -->
<form name="main_form" id="main_form">
<input type="hidden" id="cust_no" name="cust_no" value="${inputParam.cust_no}">
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="item-group">
                <div class="form-group">
                    <div class="form-row inline-pd">
                        <label class="col-3 text-right col-form-label">휴대전화번호</label>
                        <div class="col-7">
                            <div class="icon-btn-cancel-wrap">
                                <input type="text" class="form-control" id="s_hp_no" name="s_hp_no" format="phone" maxlength="11" value="${inputParam.hp_no}">
                                <button type="button" class="icon-btn-cancel"><i class="material-iconsclose font-16 text-default-50"></i></button>
                            </div>
                        </div>
                        <div class="col-2">
                            <button type="button" class="btn btn-info" style="width: 100%;" id="authSendBtn" name="authSendBtn" onclick="goAuthRequest()">인증요청</button>
                        </div>
                    </div>
                    <div class="form-row inline-pd">
                        <label class="col-3 text-right col-form-label">인증번호</label>
                        <input type="hidden" id="sms_auth_seq">
                        <div class="col-7">        
                            <div class="time-count" id="timer"></div>
                            <input type="text" class="form-control" id="auth_no" name="auth_no">
                        </div>
                        <div class="col-2">                            
                            <button type="button" class="btn btn-info" id="authBtn" name="authBtn" style="width: 100%;" onclick="goAuthConfirm()">인증</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="alert alert-secondary mt10">
                <div class="title">
                    <i class="material-iconserror font-16"></i>
                    <span>인증절차</span>
                </div>
                <ol>
                    <li>① 고객님 휴대전화번호 입력 후 &lt;인증요청&gt;버튼을 클릭!</li>
                    <li>② 고객님 문자로 수신된 인증번호 입력 후 &lt;인증&gt;버튼 클릭!</li>
                </ol>                    
            </div>

        </div>
    </div>
	</form>
<!-- /content-wrap -->	
</body>
</html>