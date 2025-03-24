<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<html>
<head>
	<script type="text/javascript">
		var logoutTimerMin = window.top.__logoutTimerMin;		// 로그아웃 타이머(분)
		var logoutDelayMin = window.top.__logoutDelayMin;		// 로그아웃 대기시간(분)
		var logoutDelayTime = 0;	// 로그아웃 대기시간(밀리세컨드)
		var logoutTimerSec = 0;		// 로그아웃 타이머(초)

		var logoutModalTimeout;		// 로그아웃 모달 timeout
		var logoutTimerInterval;	// 로그아웃 타이머 interval
		var checkTimeInterval;		// 로그아웃 시간체크 interval

		// 로그아웃 연장팝업 timeout, 시간체크 interval 세팅
		function __fnLogoutModalHandler() {
			fnClearTimeoutInterval();
			fnCehckLogoutLimit(function() {
				checkTimeInterval = setInterval(fnCehckLogoutLimit, 60000);	// 1분에 한번씩 체크
			});
		}

		// 로그아웃 연장팝업 대기시간, 타이머 시간 세팅
		function __fnSetLogoutModalTime(delayMin, timerMin) {
			logoutTimerSec = $M.toNum(timerMin) == 0? $M.toNum(logoutTimerMin)*60 : $M.toNum(timerMin)*60;
			logoutDelayTime = $M.toNum(delayMin) == 0? $M.toNum(logoutDelayMin)*60*1000 : $M.toNum(delayMin)*60*1000;
		}

		// 로그아웃 연장 팝업 Show
		function fnLogoutTimerModal() {
			// 모달 팝업 띄우기 전 대기시간 체크
			fnCehckLogoutLimit(function(delayMin) {
				if (delayMin <= 0) {
					// 미확인 쪽지팝업 있는 경우 팝업 닫고 쪽지 interval 중지
					if (window.timers) {
						fnDialogClose();
						window.timers.pause();
					}
					fnClearTimeoutInterval(2);
					$("#logoutTimerMin").text(logoutTimerMin);
					$("#logoutTimerSec").text(getMinSecTimerFormat(logoutTimerSec));
					var options = { enableEscapeKey: false };
					$M.goNextPageLayerDiv("layer_logout_timer", options);
					logoutTimerInterval = setInterval(fnLogoutTimer, 1000); // 타이머 1초단위로 반복호출
				}
			});
		}

		// 로그아웃 연장 팝업 타이머 Interval
		function fnLogoutTimer() {
			logoutTimerSec -= 1;
			$("#logoutTimerSec").text(getMinSecTimerFormat(logoutTimerSec));
			if(logoutTimerSec <= 0) {
				// 로그아웃 전 대기시간 한번 더 체크
				fnCehckLogoutLimit(function() {
					if (logoutTimerInterval) {
						console.log(":: fnLogoutTimer 자동로그아웃");
						fnClearTimeoutInterval();
						__fnSetLogoutModalTime();
						goAutoLogout();
					}
				});
			}
		}

		// 로그아웃 연장팝업 대기시간, 타이머 시간 재설정
		// - 세션에 저장된 비밀번호 체크 날짜로 제한시간 체크
		function fnCehckLogoutLimit(callBackFunc) {
			$M.goNextPageAjax("/logout/limitMin", "", {method: "get", loader: false}, function(result){
				if(result.success) {
					var delayMin = result.logout_delay_min;

					// 대기시간이 있는 경우 로그아웃 모달 timeout 시간 재설정
					if (delayMin > 0) {
						var todayTime = new Date().getTime();
						var popupDate = new Date(todayTime + (delayMin*60*1000));
						console.log(":: fnCehckLogoutLimit Call!! " + $M.dateFormat(popupDate, "HH:mm:ss") + " 팝업 호출");
						fnClearTimeoutInterval(1);
						__fnSetLogoutModalTime(delayMin, logoutTimerMin);
						logoutModalTimeout = setTimeout(fnLogoutTimerModal, logoutDelayTime);

						// 이미 모달이 떠있으면 모달 닫기 (중지했던 쪽지 interval 재시작)
						if (logoutTimerInterval) {
							fnClearTimeoutInterval(2);
							$.magnificPopup.close();
							if (window.timers) {
								window.timers.resume();
							}
						}
					}
					if (callBackFunc && typeof callBackFunc == "function") {
						callBackFunc(delayMin);
					}
				}
			});
		}

		// 로그아웃 연장팝업 닫기
		function fnCloseLogoutTimerModal(flag) {
			fnClearTimeoutInterval();
			__fnSetLogoutModalTime();
			if(flag) {
				console.log(":: fnCloseLogoutTimerModal 연장");
				// 사용자 action 날짜 저장 후 팝업 닫기
				__fnSetActionDate(function() {
					fnClearTimeoutInterval(2);
					$.magnificPopup.close();
					// 중지했던 쪽지 interval 재시작
					if (window.timers) {
						window.timers.resume();
					}
					__fnLogoutModalHandler();
				});
			} else {
				console.log(":: fnCloseLogoutTimerModal 로그아웃");
				goAutoLogout();
			}
		}

		// 로그아웃 (confirm 메세지 없음)
		function goAutoLogout() {
			console.log(":: goAutoLogout Call!!");
			$M.goNextPageAjax("/logout", "", "", function (result) {
				if(result.success) {
					$M.goNextPage("/");
				}
			});
		}

		// timeout, interval 클리어
		// flag : 1(logoutModalTimeout), 2(logoutTimerInterval), 3(checkTimeInterval)
		function fnClearTimeoutInterval(flag) {
			switch (flag) {
				case 1:		// 모달 Show timeout
					clearTimeout(logoutModalTimeout);
					logoutModalTimeout = null;
					break;
				case 2:		// 타이머 interval
					clearInterval(logoutTimerInterval);
					logoutTimerInterval = null;
					break;
				case 3:		// 제한시간 체크 interval
					clearInterval(checkTimeInterval);
					checkTimeInterval = null;
					break;
				default:
					clearTimeout(logoutModalTimeout);
					logoutModalTimeout = null;
					clearInterval(logoutTimerInterval);
					logoutTimerInterval = null;
					clearInterval(checkTimeInterval);
					checkTimeInterval = null;
					break;
			}
		}
	</script>
<!-- 로그아웃 팝업 레이어 -->
</head>
<body>
	<input type="hidden" id="timerMin" name="timerMin" value="">
	<input type="hidden" id="delayMin" name="delayMin" value="">
	<div id="layer_logout_timer" class="popup-wrap width-400 mfp-hide" style="margin-top: -100px;">
		<div class="main-title">
			<h2>로그아웃 연장</h2>
			<div onclick="fnCloseLogoutTimerModal(true);" class="mfp-close"><i class="material-iconsclose" ></i></div>
		</div>
		<div class="content-wrap">
			<div class="alert alert-secondary mt10">
				<div class="font-14 pb10">자동로그아웃 남은 시간 : <span class="text-primary" id='logoutTimerSec'></span></div>
				<div class="font-14">사이트의 안전한 사용을 위해 약 <span id='logoutTimerMin'></span>분 동안 서비스</div>
				<div class="font-14 pb10">이용이 없으면 자동 로그아웃 됩니다.</div>
				<div class="font-14 center">로그인 시간을 연장하시겠습니까?</div>
			</div>
			<div class="btn-group">
				<div class="center">
					<button type="button" class="btn btn-default" style="width: 100px;" onclick="fnCloseLogoutTimerModal(true);">연장하기</button>
					<button type="button" class="btn btn-default" style="width: 100px;" onclick="fnCloseLogoutTimerModal(false);">로그아웃</button>
				</div>
			</div>
		</div>
	</div>
	<!-- /로그아웃 팝업 레이어 -->
</body>
</html>