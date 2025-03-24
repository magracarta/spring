<%@ page pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><c:set var="uri" value="${fn:replace(pageContext.request.requestURI, '/WEB-INF/jsp/', '')}"/><c:set var="prefix" value="${fn:split(uri, '/')}"/><c:set var="tmp" value=""/><c:forEach var="str" items="${prefix}"><c:set var="tmp" value="${str}"/></c:forEach><c:set var="thisDir" value="${fn:replace(uri, tmp, '')}"/><c:set var="thisPage" value="${fn:replace(uri, '.jsp', '')}"/><c:set var="dataSet" value="${DATA_SET}"/><c:set var="pageNavi" value="${dataSet.pageNavi}"/><c:set var="listIdx" value="0"/><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<spring:eval expression="@environment.getProperty('server.type')" var="serverType" /><spring:eval expression="@environment.getProperty('ssl.host')" var="sslHost" /><spring:eval expression="@environment.getProperty('ssl.apply')" var="sslApply" />
<meta charset="utf-8">
<!-- <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no"> -->
<title>${_html_title eq null ? '(주)YK건기 ERP' : _html_title }</title>
<link rel="shortcut icon" type="image/x-icon" href="/static/img/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/static/easyui/themes/default/easyui.css?version=1201.1"/>
<link rel="stylesheet" type="text/css" href="/static/easyui/themes/icon.css?version=1201.1"/>
<link rel="stylesheet" type="text/css" href="/static/css/style.css?version=231115.1" />
<link rel="stylesheet" type="text/css" href="/static/css/jquery-ui.min.css?version=1201.1" />
<link rel="stylesheet" type="text/css" href="/static/css/jquery-ui.structure.min.css?version=1201.1" />
<link rel="stylesheet" type="text/css" href="/static/css/jquery-ui.theme.min.css?version=1201.1" />
<link rel="stylesheet" type="text/css" href="/static/css/magnific-popup.css?version=1201.1" />
<link rel="stylesheet" type="text/css" href="/static/AUIGrid/AUIGrid_style.css?version=1201.1" />
<!-- 개발자 커스텀 CSS -->
<link rel="stylesheet" type="text/css" href="/static/css/dev.css?version=231229.1" />
<!-- 그리드 커스텀 CSS -->
<link rel="stylesheet" type="text/css" href="/static/css/aui.css?version=231229.1" />

<script type="text/javascript" src="/static/js/jquery.min.js?version=1201.1"></script>
<script type="text/javascript" src="/static/easyui/jquery.easyui.min.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/jquery-ui.min.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/jquery.form.min.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/jquery.cookie.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/jquery.magnific-popup.js?version=1201.1"></script>

<script type="text/javascript" src="/static/js/db.column.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/jquery.mfactory-2.2.js?version=1004.1"></script>
<script type="text/javascript" src="/static/js/open.panel.js?version=0220.1"></script>
<script type="text/javascript" src="/static/js/common.util.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/report.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/jquery.scannerdetection.js?version=1201.1"></script>

<script type="text/javascript" src="/static/AUIGrid/AUIGridLicense.js?version=1201.1"></script>
<script type="text/javascript" src="/static/AUIGrid/AUIGrid.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/AUIGrid.extend.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/message.js?version=1201.1"></script>

<!-- SheetJS js-xlsx, https://github.com/SheetJS/js-xlsx-->
<!-- Apache License v2.0  (http://www.apache.org/licenses/LICENSE-2.0) -->
<script type="text/javascript" src="/static/js/shim.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/jszip.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/xlsx.js?version=1201.1"></script>
<script type="text/javascript" src="/static/js/FileSaver.min.js?version=1201.1"></script>

<script type="text/javascript">
		var __logoutTimerMin = "${page.logout_timer_min}";		// 로그아웃 팝업 타이머(분)
		var __logoutDelayMin = "${page.logout_delay_min}";		// 로그아웃 팝업 대기시간(분)
		var pagePasswdCheckYn = "${page.passwd_check_yn}";		// 비밀번호 체크 여부

		$(document).ready(function () {
			// 류성진 2022.09.22 - 마스킹 값 변경조작 확인
			var masking = $("input[name=s_masking_yn]"); // 재사용 보존 - 혹여나 중복값 있을지...
			masking.on("click", function (e) { // 값 변경
				var params = {
					"default_masking_yn" : masking.is(":checked") ? 'Y' : 'N',
				};

				masking.val(masking.is(":checked") ? 'Y' : 'N');
				$M.goNextPageAjax("/masking", $M.toGetParam(params), {method : 'post', loader : false, async : false}, function(){
					// 값 적용후, 필요없으나, 오류처리
				})
			});

			// [2022.10.12 jsk] 비밀번호 체크여부가 Y인 경우 로그아웃 연장 팝업 세팅
			if (pagePasswdCheckYn == 'Y') {
				if (!window.top.document.getElementById("logoutDialog")) {
					var options = {
						dataType: 'html',
						method : 'get',
						loader : false
					}
					$M.goNextPageAjax("/logout/timerPop", {}, options, function (data){
						var newDiv = $("<div/>", {id: "logoutDialog"});
						$(window.top.document.body).append(newDiv);
						var targetElm = window.top.document.getElementById("logoutDialog");
						setInnerHTML(targetElm, data);
						window.top.__fnSetLogoutModalTime();
						window.top.__fnLogoutModalHandler();
					})
				} else {
					if (window.top.__fnLogoutModalHandler) {
						window.top.__fnSetLogoutModalTime();
						window.top.__fnLogoutModalHandler();
					}
				}
			}

			$('.tabs-c').click(function() {
				__fnSetActionDate();
			});

			// 팝업 dev인경우 title영역 분홍색으로 노출
			if (opener != null) {
				if (${serverType eq 'default'}) {
					$(".main-title").css("background", "gold");
				} else if (${serverType eq 'dev'}) {
					$(".main-title").css("background", "pink");
				}
			}
		});

		// 사용자 Action date Set
		function __fnSetActionDate(callBackFunc) {
			$M.goNextPageAjax("/action/setDate", "", "", function (result) {
				if(result.success) {
					if (callBackFunc && typeof callBackFunc == "function") {
						callBackFunc();
					}
				}
			});
		}
	</script>

	<script type="text/javascript">
		<!-- 운영일때만 ssl 적용 -->
		<c:if test="${sslApply eq 'Y'}"><c:set var="ctrl_host" value="${fn:toLowerCase(pageContext.request.requestURL)}"/><c:if test="${fn:startsWith(ctrl_host, 'http:') && fn:containsIgnoreCase(ctrl_host, sslHost)}">location.href='https://${sslHost }/autoMain';</c:if></c:if>
	var this_page = '<c:if test="${fn:startsWith(thisPage, '/') eq false}">/</c:if>${thisPage}'; var this_dir = '<c:if test="${fn:startsWith(thisPage, '/') eq false}">/</c:if>${thisDir}'; var s_rows = 100000; window.focus();
	function goMain() {
		top.$M.goNextPage('/main');
	}
	try {
		window.onresize = function(){
			$("div[id*='auiGrid']").each(function() {
				if ($("#" + $(this).attr("id")).is(':visible')) {
					var gridObj = "#" + $(this).attr("id");
					AUIGrid.resize(gridObj);
					//console.log("그리드 리사이즈");
				} else {
					//console.log("그리드 display none");
				}
			});
		};
	} catch (e) {
		console.log(e);
	}
	<c:if test="${page.show_passwd_yn eq 'Y'}">
	window.open("/passwd?page=${page.menu_seq}","사용자정보확인", 'width=500,height=300,toolbar=0,menubar=0,location=0,status=0,scrollbars=1,resizable=0,left=0,top=0');
	try { window.stop(); } catch (e) { document.execCommand('Stop'); }
	</c:if>
	<%-- 인증앱 정보로 판단하여 접속허용여부 결정 --%>
	<c:if test="${page.alert_yn eq 'Y'}">alert('${page.alert_msg}');</c:if>
	<c:if test="${page.go_login eq 'Y'}">
	<c:if test="${page.pop_yn ne 'Y'}">top.$M.goNextPage('/login');</c:if><c:if test="${page.pop_yn eq 'Y'}">self.close();</c:if>
	try { window.stop(); } catch (e) { document.execCommand('Stop'); }
	</c:if>
	<c:if test="${page.menu_auth_yn eq 'N'}">
	alert("메뉴 권한이 없습니다.");
	try { window.top.stop(); } catch (e) { document.execCommand('Stop'); }
	</c:if>
	<c:forEach var="item" items="${easyuiComp}">${item}</c:forEach>
	<c:forEach var="item" items="${jsonComp}">${item}</c:forEach>
	var _memInfoMap = ${memInfoMap};
	function fnShowAuigridTooltip(owIndex, columnIndex, value, headerText, item, dataField) {
		var retStr = "";
		if(item.hasOwnProperty('s_mem_no') && _memInfoMap.hasOwnProperty(item.s_mem_no)) {
			var mem = _memInfoMap[item.s_mem_no];
			retStr += "소속 : " + mem.org_name;
			retStr += "<br>직급 : " + mem.grade_name;
		}
		return retStr;
	}
	<%-- 바코드 감지는 없앰(메인에 바코드리딩으로 처리)
            $(document).scannerDetection({
                timeBeforeScanTest: 200, // wait for the next character for upto 200ms
                startChar: [120], // Prefix character for the cabled scanner (OPL6845R)
                endChar: [13], // be sure the scan is complete if key 13 (enter) is detected
                avgTimeByChar: 40, // it's not a barcode if a character takes longer than 40ms
                minLength :6,
                onComplete: function(barcode, qty){
                    try {
                        if(fnBarcodeRead){
                            fnBarcodeRead(barcode);
                        }
                        return false;
                    } catch(e) {
                        console.log(e);
                        return false;
                    }

                }
            });
    --%>
</script>