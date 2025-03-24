<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > null > null
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	var tab_id;

	$(document).ready(function() {
		$('ul.tabs-c li a').click(function() {
			tab_id = $(this).attr('data-tab');

			$('ul.tabs-c li a').removeClass('active');
			$('.tabs-inner').removeClass('active');

			$(this).addClass('active');
			$("#"+tab_id).addClass('active');
		});
	});
	</script>
</head>
<body>
<div class="layout-box">
	<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- 탭 -->
			<div class="contents">
				<ul class="tabs-c" >
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12 active"  data-tab="inner1">전체</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner2">DI Call</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner3">종료점검 Call</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner4">Happy Call</a>
					</li>
<%--					<li class="tabs-item">--%>
<%--						<a href="#" class="tabs-link font-12"  data-tab="inner5">미수금 Call</a>--%>
<%--					</li>--%>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner6">정기검사 Call</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner7">CAP Call</a>
					</li>
				</ul>
				<!-- /탭 -->

				<!-- /메인 타이틀 -->
				<div id="inner1" class="tabs-inner active"  style="height: 700px;">
					<iframe src="/serv/serv040401" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 700px;">
					<iframe src="/serv/serv040402" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner3" class="tabs-inner " style="height: 700px;">
					<iframe src="/serv/serv040403" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner4" class="tabs-inner " style="height: 700px;">
					<iframe src="/serv/serv040404" id="contentFrame4" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
<%--				<div id="inner5" class="tabs-inner " style="height: 700px;">--%>
<%--					<iframe src="/serv/serv040405" id="contentFrame5" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>--%>
<%--				</div>--%>
				<div id="inner6" class="tabs-inner " style="height: 700px;">
					<iframe src="/serv/serv040406" id="contentFrame6" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner7" class="tabs-inner " style="height: 700px;">
					<iframe src="/serv/serv040407" id="contentFrame7" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
</div>
</body>
</html>