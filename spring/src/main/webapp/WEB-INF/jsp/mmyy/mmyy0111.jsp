<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 기안문서 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var tab_id;
	
	// 아이프레임 로딩체크 추가 by 김태훈
	var tabLoad = [false, false, false, false, false, false, false, false, false, false];
	function fnLoadFrame(num) {
		tabLoad[num] = true;
	}
	
	$(document).ready(function() {
		$('ul.tabs-c li a').click(function() {
		    tab_id = $(this).attr('data-tab');
		    
		    // 아이프레임이 로드됬는지 확인함
		    var tabNum = tab_id.substr(5, 1);
		    console.log(tabNum);
		    if (tabLoad[tabNum-1] == false) {
		    	alert("잠시만 기다려주세요.");
		    	console.error(tabNum, "아이프레임이 아직 로드안됨 =>", tabLoad);
		    	return false;
		    }
		    
		    if (tab_id == 'inner1' || tab_id == undefined) { 
	 			iframe = document.getElementById("contentFrame1");
			} else if (tab_id == 'inner2') { 
	 			iframe = document.getElementById("contentFrame2");
			} else if (tab_id == 'inner3') { 
	 			iframe = document.getElementById("contentFrame3");
			} else if (tab_id == 'inner4') { 
	 			iframe = document.getElementById("contentFrame4");
			} else if (tab_id == 'inner5') { 
	 			iframe = document.getElementById("contentFrame5");
			} else if (tab_id == 'inner6') { 
	 			iframe = document.getElementById("contentFrame6");
			} else if (tab_id == 'inner7') { 
	 			iframe = document.getElementById("contentFrame7");
			} else if (tab_id == 'inner8') { 
	 			iframe = document.getElementById("contentFrame8");
			} else if (tab_id == 'inner9') { 
	 			iframe = document.getElementById("contentFrame9");
			} else if (tab_id == 'inner10') {
				iframe = document.getElementById("contentFrame10");
			} else if (tab_id == 'inner11') {
				iframe = document.getElementById("contentFrame11");
			}
		    
		    if (iframe.contentWindow.createAUIGrid) {
		    	iframe.contentWindow.createAUIGrid();	
		    }
		    if (iframe.contentWindow.goSearch) {
		    	iframe.contentWindow.goSearch();
		    }
			
		    $('ul.tabs-c li a').removeClass('active');
		    $('.tabs-inner').removeClass('active');
		 
		    $(this).addClass('active');
		    $("#"+tab_id).addClass('active');
		});
	});
	
	// 출장여비정산서 목록과 등록페이지 화면크기 재설정
	function fnStyleChange(pageType) {
		if (pageType == "search") {
			$("#inner3").css("height", "700px");
		} else if (pageType == "add") {
			$("#inner3").css("height", "1100px");
		}
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<!-- 탭 -->
				<ul class="tabs-c">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12 active"  data-tab="inner1">휴가원</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner2">품의서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner9">마일리지 지급품의서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner3">출장여비정산서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner4">지출결의서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner5">경조금지급신청서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner6">재직증명서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner7">경력증명서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner8">사유서</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner10">자격취득신청</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner11">사후사고보고</a>
					</li>
				</ul>
				<!-- /탭 -->

				<div id="inner1" class="tabs-inner active"  style="height: 850px;">
					<iframe src="/mmyy/mmyy0106" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(0)"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 850px;">
					<iframe src="/mmyy/mmyy011102" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(1)"></iframe>
				</div>
				<div id="inner3" class="tabs-inner " style="height: 1100px;">
					<iframe src="/mmyy/mmyy011103" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(2)"></iframe>
				</div>
				<div id="inner4" class="tabs-inner " style="height: 850px;">
					<iframe src="/mmyy/mmyy011104" id="contentFrame4" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(3)"></iframe>
				</div>
				<div id="inner5" class="tabs-inner " style="height: 570px;">
					<iframe src="/mmyy/mmyy011105" id="contentFrame5" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(4)"></iframe>
				</div>
				<div id="inner6" class="tabs-inner " style="height: 570px;">
					<iframe src="/mmyy/mmyy011106" id="contentFrame6" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(5)"></iframe>
				</div>
				<div id="inner7" class="tabs-inner " style="height: 570px;">
					<iframe src="/mmyy/mmyy011107" id="contentFrame7" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(6)"></iframe>
				</div>
				<div id="inner8" class="tabs-inner " style="height: 570px;">
					<iframe src="/mmyy/mmyy011108" id="contentFrame8" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(7)"></iframe>
				</div>
				<div id="inner9" class="tabs-inner " style="height: 700px;">
					<iframe src="/mmyy/mmyy011109" id="contentFrame9" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(8)"></iframe>
				</div>
				<div id="inner10" class="tabs-inner " style="height: 700px;">
					<iframe src="/mmyy/mmyy011110" id="contentFrame10" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(9)"></iframe>
				</div>
				<div id="inner11" class="tabs-inner " style="height: 700px;">
					<iframe src="/mmyy/mmyy011111" id="contentFrame11" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(10)"></iframe>
				</div>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
<!-- /contents 전체 영역 -->
</div>
</form>	
</body>
</html>