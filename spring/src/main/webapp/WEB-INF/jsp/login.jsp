<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<spring:eval expression="@environment.getProperty('server.type')" var="serverType" /><spring:eval expression="@environment.getProperty('spring.datasource.url')" var ="datasourceUrl"/><spring:eval expression="@environment.getProperty('spring.datasource.username')" var ="userName"/>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<%--<link  href="/static/fotorama/fotorama.css" rel="stylesheet">
	<script src="/static/fotorama/fotorama.js"></script>--%>
	
	<script>
		$(document).ready(function() {
			var userId = getCookie('SPRING_SECURITY_REMEMBER_ME');
			if(typeof userId != 'undefined' && userId != ''){
				$("#user_id").val(userId);
				$("#save_id").prop("checked", true);
			}
			
			// 부서별 계정 클릭시 id, pw set
			$(".login_id").css("cursor", "pointer").click(function() {
				var loginId = $(this).text();
				var pwd = 1;
				$M.setValue("user_id", loginId);
				$M.setValue("passwd", pwd);
				goLogin(document.main_form);
			});
			
			// fotorama 링크클릭시 오픈
//		    $(".fotorama__stage").on("click",function(){
//		        var href = $(this).find("a").attr('href');
//		        window.open(href);
		        
// 		        $(".fotorama").prop("data-autoplay", 2000);
// 		        $('.fotorama').fotorama({
// 		        	  width: '100%',
// 		        	  maxwidth: '100%',
// 		        	  autoplay: 2000,
// 		        	  swipe : false,
// 		        	  loop : true,
// 		        	  arrows : false
// 		        	  click: true,
// 		        	  nav: 'thumbs'
// 	        	});
//	        });
		});
		
		function goAuthDown() {
			var param = {
				pop_check_yn : "N"
			}
			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=831, left=0, top=0';
			$M.goNextPage('/down', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
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
		
		var isRunning = false; // 타이머 flag
		var isChecked = false; // 인증번호 확인 flag
		var timer; // 인터벌 obj
		//var regExp = /^(?=.*[a-zA-Z])(?=.*[!@#$%^~*+=-])(?=.*[0-9]).{8,10}$/; //정규식
		
		function goLogin(frm) {
			if($M.validation(frm) == false) {
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
		
		function enter(fieldObj) {
			var field = ["user_id", "passwd"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goLogin(document.main_form);
				}
			});
		}
		
		$(document).on("click", "#menuName", function() {
			$(this).next().slideToggle("slow", function() {
				var display = $(this).css("display");
				(display == 'none') ? $(this).parent().removeClass("active") : $(this).parent().addClass("active");
			});
		})
		
		// 비밀번호 변경 레이어 팝업 open
		function goPwChangePopup() {
			$M.goNextPageLayerDiv('open_layer_passFind');
			
			processDisabled(['passwd', 'confirm_change_pass', 'savePass', 'confirmAuth', 'auth_no'], true, null, null);
			processDisabled(['user_find_id', 'sendAuth'], false, null, null);
			clearInterval(timer);	
			document.querySelector('#timer').textContent = "";
			
			isRunning = false;
			isChecked = false;
			$('#sendAuth').html('인증번호발송');
		}
		
		// 인증번호 발송
		function goSendAuthNo(frm) {
			if($M.validation(document.open_layer_passFind, {field:['user_find_id']}) == false) {
				return;
			}
			// 제한시간(단위:초)
			var leftSec = 180,
			// todo: 인증번호 전송 
	        display = document.querySelector('#timer');
		 	$M.goNextPageAjax('/auth/' + $M.getValue("user_find_id") + '/smsSend', frm, {method:'post'},
				function(result) {
			 		if(result.success) {	
			 			fnStartTimer(leftSec, display);
			 			$M.setValue("sms_auth_seq", result.sms_auth_seq);
			 			processDisabled(['sendAuth', 'user_find_id'], true, null, null);
			 			processDisabled(['confirmAuth', 'auth_no'], false, null, null);
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
			      $('#confirmAuth').prop("disabled", true);
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
		
		// 인증번호 확인
		function goConfirmAuth(frm) {
			if($M.validation(document.open_layer_passFind, {field:['auth_no']}) == false) {
				return;
			} else {
				// todo: 인증번호 확인

			 	$M.goNextPageAjax('/auth/' + $M.getValue("user_find_id") + '/'+ $M.getValue("sms_auth_seq") +'/'+ $M.getValue("auth_no"), frm, {method:'post'},
					function(result) {
				 		if(result.success) {	// 전송 성공
							isChecked = true;
							document.querySelector('#timer').textContent = "";
							clearInterval(timer);
							$('.form-control').prop("disabled", false);
							processDisabled(['user_find_id', 'sendAuth', 'auth_no', 'confirmAuth'], true, null, null);
							processDisabled(['savePass'], false, null, null);
				 		} 
					}
				);
			}
		}
		
		// 새 비밀번호 저장 regPass
		function goRegPass(frm) {
			var frm = document.sec_form;
			if (!isChecked){
				alert("인증번호 입력 오류입니다. 다시 확인하시기 바랍니다.");
				return;
			} else {
				if($M.validation(document.open_layer_passFind, {field:['passwd', 'confirm_change_pass']}) == false) {
					return;
				}
				var pass = $M.getValue("confirm_change_pass");
				if(pass.length < 6) {
					alert("비밀번호는 6자리 이상으로 설정해주세요.");
					return;
				} 
				if(($M.getValue("passwd") != $M.getValue("confirm_change_pass"))) {
					alert("새로운 비밀번호와 비밀번호 확인이 맞지 않습니다. 확인하고 다시 시도해주세요.");
				}
				// todo: 새비밀번호 저장
			 	$M.goNextPageAjax('/auth/'+ $M.getValue("user_find_id") + '/pass', frm, {method:'post'},
					function(result) {
				 		if(result.success) {
							fnResetAndClose();
				 			$M.goNextPage('/');
				 		} 
					}
				);
			}	
		}
		
		// 비밀번호찾기 팝업 닫기
		function fnResetAndClose() {
			// esc 주석
			$.each(['user_find_id', 'p_auth_code', 'passwd', 'confirm_change_pass'], function(index, value) {
				$("#"+value).val("");
			})
			$M.setHiddenValue("smsAuthSeq", "");
			$.magnificPopup.close();
			$('#sendAuth').html('인증번호발송');
			clearInterval(timer);	
			document.querySelector('#timer').textContent = "";
			processDisabled(['confirm_change_pass', 'savePass', 'confirmAuth', 'auth_no'], true, null, null);
			processDisabled(['user_find_id', 'sendAuth'], false, null, null);
			$M.setValue("auth_no", "" );
			
			isRunning = false;
			isChecked = false;
			
		}
		
		function changeLoginOrg(selObj) {
			var param = {
				"s_org_name" 		: selObj.value
			};
			$M.goNextPageAjax("/smpl0104/searchOrgUser", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						var memSel = $M.getComp('s_login_mem');
						memSel.length = 0;
						memSel.add(new Option("- 사용자 선택 -", ""));
						
						var list = result.list;
						for(var i = 0, n = list.length; i < n; i++) {
							memSel.add(new Option(list[i].user_name, list[i].web_id));
						}
					};
				}
			);
		}
		
		function goMemLogin(selObj) {
			$M.setValue('user_id', selObj.value);
			$M.setValue('passwd', '1');
			
			goLogin(document.main_form);
		}
	</script>
	
	<style>
		.borderTable {
			border-top: 1px solid #444444;
		}
		.borderTr, .borderTh, .borderTd {
		    border-bottom: 1px solid #444444;
		}
		.leftTd {
			text-align : left;
		}		
	</style>
	
</head>
<body>
	<div class="login-bg">
		<div class="login-wrap">
<!-- left slider -->
			<div class="left-banner"><!-- IE에서 이미지가 제대로 안나와 Define -->
				${login_banner }
			<%-- 대표이사 지시로 롤링 없애고, 하루에 한 이미지 고정 
				<div class="fotorama" data-autoplay="3000" data-swipe="false" data-loop="true" data-arrows="false" data-stopautoplayontouch="false" data-click="true">
					<div data-img="/static/img/login/01_yanmar.jpg"><a href="http://www.sunnyyk.co.kr/product/maker_index.jsp?maker_no=1&maker_name=미니굴삭기"></a></div>
					<div data-img="/static/img/login/02_gehl.jpg"><a href="http://sunnyyk.co.kr/product/maker_index.jsp?maker_no=2&maker_name=스키드로더"></a></div>
					<div data-img="/static/img/login/03_hamm.jpg"><a href="http://sunnyyk.co.kr/product/maker_index.jsp?maker_no=104&maker_name=햄 롤러"></a></div>
					<div data-img="/static/img/login/04_vogele.jpg"><a href="http://sunnyyk.co.kr/product/maker_index.jsp?maker_no=103&maker_name=보겔 피니셔"></a></div>
					<div data-img="/static/img/login/05_manitou.jpg"><a href="http://sunnyyk.co.kr/product/maker_index.jsp?maker_no=64&maker_name=4륜구동 붐지게차"></a></div>
					<div data-img="/static/img/login/06_lightboy.jpg"><a href="http://sunnyyk.co.kr/product/maker_index.jsp?maker_no=5&maker_name=라이트타워"></a></div>
					<div data-img="/static/img/login/07_wirtgen.jpg"><a href="http://sunnyyk.co.kr/product/maker_index.jsp?maker_no=101&maker_name=빌트겐 노면파쇄기"></a></div>
					<div data-img="/static/img/login/08_manitou2.jpg"><a href="http://sunnyyk.co.kr/product/maker_index.jsp?maker_no=65&maker_name=회전식 하이랜더"></a></div>
				</div>
			--%>
			</div>
<!-- /left slider -->
<!-- right 로그인폼 -->
			<div class="right-loginform">
				<div><img src="/static/img/login-logo.png" alt="YK건기 로고"></div>
				<div class="yk-text">항상 정확하고 올바른 서비스를 제공하기 위해<br>끊임없이 노력하는 YK건기</div>
				<form name="main_form" id="main_form" style="height: auto;">
				<div class="form">
					<div class="icon-btn-cancel-wrap login">
						<input type="text" name="user_id" id="user_id" required="required" alt="아이디" placeholder="메일아이디" maxlength="20">
					</div>
					<div class="icon-btn-cancel-wrap login">
						<input type="password" name="passwd" id="passwd" required="required" alt="비밀번호" placeholder="비밀번호" maxlength="20">
					</div>
				
				</div>
				<button type="button" class="btn-login-submit" onclick="javascript:goLogin(document.main_form);">로그인</button>	
				<div class="login-btn-group">
					<div class="group-left">
						<input type="checkbox" id="save_id"  name="save_id" checked="checked" /><label for="save_id">아이디 저장하기</label>
						<input type="hidden" id="remember-me"  name="remember-me" value="true"/><%-- 자동로그인 활성화 --%>
					</div>
					<div class="group-right">
						<button type="button" class="btn btn-default" onclick="javascript:goAuthDown();" style="margin-right: 5px;">인증앱</button>
						<button type="button" class="btn btn-default" onclick="javascript:goPwChangePopup();">비밀번호변경</button>	
					</div>
				</div>
				</form>
				<br/>
				<br/>
                <!-- /부서별 계정정보 -->
                <% if( request.getParameter("pass") != null || request.getRequestURL().indexOf("localhost") > -1) { %>
                <c:if test="${pageContext.request.serverName eq 'localhost' or serverType eq 'dev'}">
						<span class="shine" style="background-image: linear-gradient(to left, violet, indigo, blue, green, yellow, orange, red);   -webkit-background-clip: text;color: transparent;">
							${datasourceUrl.indexOf('124') > -1 ? '*운영으로 접속중*' : '개발'} ${userName}
						</span>
                    <span style="color: red"># ${serverType} # ${SecureUser.mem_no} # ${SecureUser.kor_name} # ${SecureUser.org_code}</span>
                </c:if>
                <fmt:formatDate var="ymd" value="<%=new java.util.Date()%>" pattern="ddMMyy"/>
                <c:if test="${serverType ne 'prod' || (serverType eq 'prod' && param.pass eq ymd)}">
                <div class="form">
                    <h4>테스트를 위한 계정 로그인</h4>
                    <table class="borderTable" style="border-spacing: 0 2px; border-collapse: separate;">
                        <colgroup>
                            <col width="60px">
                            <col width="10px">
                            <col width="60px">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th><select class="form-control" id="s_login_org" name="s_login_org" style="width: 180px;" onchange="javascript:changeLoginOrg(this);">
                                <option value="">- 로그인 부서 선택 -</option>
                                <c:forEach var="list" items="${loginPathMap}"><option value="${list }">${list }</option></c:forEach></select>
                            </th>
                            <th>&nbsp;</th>
                            <th><select class="form-control" id="s_login_mem" name="s_login_mem" style="width: 150px;" onchange="javascript:goMemLogin(this);">
                                <option value="">- 사용자 선택 -</option>
                            </select>
                            </th>
                        </tr>
                        </tbody>
                    </table>
                </div>
                </c:if>
                <% } %>
                <!-- /부서별 계정정보 -->
			</div>
<!-- /right 로그인폼 -->			
		</div>
	</div>
<!-- 비밀번호 변경 팝업 -->
    <div class="popup-wrap width-400 mfp-hide" style="margin-top: -250px;"  id="open_layer_passFind" name="open_layer_passFind" >
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>비밀번호 변경</h2>
            <div onclick="javascript:fnResetAndClose();" class="mfp-close"><i class="material-iconsclose" ></i></div>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="item-group">
                <div class="text-com font-13">① 직원정보에 등록되어 있는 휴대폰으로 인증문자가 발송됩니다.</div>
                <div class="form-group">
                    <div class="form-row inline-pd">
                        <label class="col-2 text-right col-form-label">아이디 </label>
                        <div class="col-7">
                            <div class="icon-btn-cancel-wrap">  
                                <input type="text" class="form-control" id="user_find_id" name="user_find_id" alt="아이디">
                            </div>
                        </div>
                        <div class="col-3">
                            <button type="button" class="btn btn-default btn-cancel"  id="sendAuth" style="width: 100%;" onclick="javascript:goSendAuthNo()">인증번호발송</button>
                        </div>
                    </div>
                </div>
            </div>
			<input type="hidden" id="sms_auth_seq">
			<form name="sec_form" id="sec_form">
            <div class="item-group">
                <div class="text-com font-13">② 휴대폰으로 수신된 인증번호 6자리를 입력합니다.</div>
                <div class="form-group">
                    <div class="form-row inline-pd">
                        <label class="col-2 text-right col-form-label">인증번호 </label>
                        <div class="col-7" >
                            <div class="time-count" id="timer"></div>
                            <input type="text" class="form-control" placeholder="숫자6자리" alt="인증번호" id="auth_no" name="auth_no" datatype="int" minlength="6" maxlength="6" style="padding-right: 40px;" disabled="disabled">
                        </div>
                        <div class="col-3">
                            <button type="button" class="btn btn-default btn-cancel" id="confirmAuth" onclick="javascript:goConfirmAuth()" style="width: 100%;">인증번호확인</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="item-group">
                <div class="text-com font-13">③ 새로운 비밀번호를 설정하세요.</div>
                <div class="form-group">
                    <div class="form-row inline-pd">
                        <label class="col-3 text-right col-form-label">새로운 비밀번호 </label>
                        <div class="col-9">
                            <div class="icon-btn-cancel-wrap">
                               <input type="password" class="form-control" placeholder="6자리 이상" id="passwd" name="passwd" disabled="disabled" required="required" alt="새로운비밀번호">
                            </div>
                        </div>
                    </div>
                    <div class="form-row inline-pd">
                        <label class="col-3 text-right col-form-label">비밀번호확인</label>
                        <div class="col-9">
                            <div class="icon-btn-cancel-wrap">
                               <input type="password" class="form-control" id="confirm_change_pass" name="confirm_change_pass" disabled="disabled" required="required" alt="비밀번호확인">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="btn-group">
                    <div class="right">
                        <button type="button" class="btn btn-info" style="width: 70px;" onclick="javascript:goRegPass()" id="savePass">저장</button>
                        <button type="button" class="btn btn-info" style="width: 70px;" onclick="javascript:fnResetAndClose()">취소</button>
                    </div>
                </div>
            </div>

            <div class="alert alert-secondary mt10">
                <div class="title">
                    <i class="material-iconserror font-16"></i>
                    <span>비밀번호 변경시 주의사항</span>
                </div>
                <ul>
                    <li>6자리 이상</li>
                </ul>                    
            </div>
        </form>
        </div>
    </div>
<!-- /팝업 -->

<!-- 비밀번호 변경(6개월 팝업) -->
<div class="popup-wrap width-500 mfp-hide" style="margin-top: -250px;" id="open_layer_passFind_six" name="open_layer_passFind_six">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>비밀번호 변경</h2>
            <div class="mfp-close" onclick="javascript:fnResetAndClose()"><i class="material-iconsclose"></i></div>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="item-group">
                <div class="font-18 text-primary pb10">안전한 개인정보보호를 위해 비밀번호 변경을 안내 드립니다.</div>
                <div class="font-14">YK건기는 개인정보보호를 위해 6개월 이상 비밀번호를 변경하지 않은 경우 비밀번호 변경을 안내하고 있습니다.<br><br>
                    다음에 변경하기를 하셔도 3개월 후 다시 안내 드리오니 조금 불편하시더라도 지금 비밀번호를 변경하시기 바랍니다.
                </div>
            </div>

            <div class="item-group">
                <div class="form-group">
                    <div class="row no-gutters">
                        <label class="col-3 col-form-label">현재 비밀번호 </label>
                        <div class="col-9">
                            <div class="icon-btn-cancel-wrap">
                                <input type="password" class="form-control" readonly id="ex_passwd" name="ex_passwd" value="12345">
                            </div>
                        </div>
                    </div>
                    <div class="row no-gutters">
                        <label class="col-3 col-form-label">새로운 비밀번호 </label>
                        <div class="col-9">
                            <div class="icon-btn-cancel-wrap">
                                <input type="password" class="form-control" id="new_passwd" name="new_passwd" alt="새로운 비밀번호">
                            </div>
                        </div>
                    </div>
                    <div class="row no-gutters">                   
                        <label class="col-3 col-form-label">비밀번호 확인</label>
                        <div class="col-9">
                            <div class="icon-btn-cancel-wrap">
                                <input type="password" class="form-control" id="new_passwd_check" name="new_passwd_check" alt="비밀번호 확인">
                            </div>
                        </div>    
                    </div> 
                </div>

                <div class="btn-group">
                    <div class="right">
                        <button type="button" class="btn btn-info" style="width: 100px;" onclick="javascript:changeNewPass()">변경하기</button>
                        <button type="button" class="btn btn-info" style="width: 100px;" onclick="$M.goNextPage('/main')">다음에 변경하기</button>
                    </div>
                </div>
            </div>

            <div class="alert alert-dark mt10">
                <div class="title">
                    <i class="material-iconserror font-16"></i>
                    <span>비밀번호 변경시 주의사항</span>
                </div>
                <ul>
                    <li>최소 6자리 이상 조합</li>
                    <li>추측하기 쉬운 생일, 전화번호 등은 피할 것이며, 키보드 상에서 나란히 있는 문자열이 포함되지 않도록 함</li>
                </ul>                    
            </div>

        </div>
    </div>
<!-- 팝업 -->
	


</body>
</html>