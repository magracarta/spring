<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > null
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var tab_id;

		$(document).ready(function() {
			$("#last_year").html('${last_year}');
			$('ul.tabs-c li a').click(function() {
				tab_id = $(this).attr('data-tab');

				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');

				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
			});
			
		});
		
		function fnReload(){
			location.reload();
		}
		
		//조회
		function fnNonReadCnt(startDt, endDt, tabGubun, isreload) {
			var param = {
					"s_start_dt" : startDt,
					"s_end_dt" : endDt,
					"s_tab_gubun" : tabGubun
			};

			isLoading = isreload == undefined ? true : false;
			
			$M.goNextPageAjax(this_page + "/cnt", $M.toGetParam(param), {method : 'get', loader : isLoading},
				function(result) {
					if(result.success) {
						$("#last_year").text(result.last_year);
						switch(tabGubun){
							case "R" : 
								$("#receiver_cnt").text(result.cnt);
								break;		
							case "S" : 
								$("#send_cnt").text(result.cnt);
								break;
							case "SYSTEM" : 
								$("#system_cnt").text(result.cnt);
								break;
							default   : 
								$("#box_cnt").text(result.cnt);
								break;
						}	
					};
				}
			);
		}
		
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
				<ul class="tabs-c">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12 active"  data-tab="inner1">받은쪽지(<span id="receiver_cnt">0</span>)</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner2">보낸쪽지(<span id="send_cnt">0</span>)</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner3">선택쪽지(<span id="box_cnt">0</span>)</a>
					</li>
					<c:if test="${SecureUser.mem_no eq 'MB00000431'}">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner4">시스템쪽지(<span id="system_cnt">0</span>)</a>
					</li>
					</c:if>
					<li class="tabs-item">
						<span style="margin-left:10px; color: #ff7f00;">※ <span id="last_year">0</span>년 이후데이터만 조회됩니다.</span>
					</li>
				</ul>
				<!-- /탭 -->

				<!-- /메인 타이틀 -->
				<div id="inner1" class="tabs-inner active"  style="height: 630px;">
					<iframe src="/mmyy/mmyy010201" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 630px;">
					<iframe src="/mmyy/mmyy010202" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner3" class="tabs-inner " style="height: 630px;">
					<iframe src="/mmyy/mmyy010203" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<c:if test="${SecureUser.mem_no eq 'MB00000431'}">
				<div id="inner4" class="tabs-inner " style="height: 630px;">
					<iframe src="/mmyy/mmyy010204" id="contentFrame4" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				</c:if>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
</div>
</body>
</html>