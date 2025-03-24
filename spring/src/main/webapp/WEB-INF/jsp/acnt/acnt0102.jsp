<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 전도금정산서 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-08 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var tab_id;
		
		$(document).mouseup(function(e) {
		    var container1 = $("#contentFrame1")[0].contentWindow.$(".dev_search_dt_type_cd_str_div");
		    if (!container1.is(e.target) && container1.has(e.target).length === 0) {
		    	if (container1.is(":visible")) {
		    		container1.toggleClass('dpn');
		    	}
		    }
		    var container2 = $("#contentFrame2")[0].contentWindow.$(".dev_search_dt_type_cd_str_div");
		    if (!container2.is(e.target) && container2.has(e.target).length === 0) {
		    	if (container2.is(":visible")) {
		    		container2.toggleClass('dpn');
		    	}
		    }
		    var container3 = $("#contentFrame3")[0].contentWindow.$(".dev_search_dt_type_cd_str_div");
		    if (!container3.is(e.target) && container3.has(e.target).length === 0) {
		    	if (container3.is(":visible")) {
		    		container3.toggleClass('dpn');
		    	}
		    }
		});

		$(document).ready(function() {
			
			setTimeout(function() {
				$('ul.tabs-c li a').click(function() {
					tab_id = $(this).attr('data-tab');
	
					$('ul.tabs-c li a').removeClass('active');
					$('.tabs-inner').removeClass('active');
	
					$(this).addClass('active');
					$("#"+tab_id).addClass('active');
					
					var startDt = $M.getValue("s_start_dt");
					if (startDt != null) {
						startDt = $M.dateFormat(startDt, 'yyyy-MM-dd');
					}
					var endDt = $M.getValue("s_end_dt");
					if (endDt != null) {
						endDt = $M.dateFormat(endDt, 'yyyy-MM-dd');
					}
					var orgCode = $M.getValue("s_org_code");
					var status = $M.getValue("s_imprest_status_cd");
					$('#s_except_acnt_confirm', window.parent.document).prop('checked', $("#s_except_acnt_confirm").prop("checked"));
					
					if(tab_id == 'inner1') {
						$("#contentFrame1")[0].contentWindow.$("#s_start_dt").val(startDt);
						$("#contentFrame1")[0].contentWindow.$("#s_end_dt").val(endDt);
						$("#contentFrame1")[0].contentWindow.$("#s_org_code").val(orgCode);
						$("#contentFrame1")[0].contentWindow.$("#s_imprest_status_cd").val(status);
						$("#contentFrame1")[0].contentWindow.$("#s_except_acnt_confirm").prop('checked', $("#s_except_acnt_confirm").prop("checked"));
				    } else if (tab_id == 'inner2') {
						$("#contentFrame2")[0].contentWindow.$("#s_start_dt").val(startDt);
						$("#contentFrame2")[0].contentWindow.$("#s_end_dt").val(endDt);
						$("#contentFrame2")[0].contentWindow.$("#s_org_code").val(orgCode);
						$("#contentFrame2")[0].contentWindow.$("#s_imprest_status_cd").val(status);
						$("#contentFrame2")[0].contentWindow.$("#s_except_acnt_confirm").prop('checked', $("#s_except_acnt_confirm").prop("checked"));
				    } else if (tab_id == 'inner3') {
				    	$("#contentFrame3")[0].contentWindow.$("#s_start_dt").val(startDt);
						$("#contentFrame3")[0].contentWindow.$("#s_end_dt").val(endDt);
						$("#contentFrame3")[0].contentWindow.$("#s_org_code").val(orgCode);
						$("#contentFrame3")[0].contentWindow.$("#s_imprest_status_cd").val(status);
						$("#contentFrame3")[0].contentWindow.$("#s_except_acnt_confirm").prop('checked', $("#s_except_acnt_confirm").prop("checked"));
				    }
					
				});
			}, 1000);
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
				<ul class="tabs-c">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12 active"  data-tab="inner1">카드사용내역</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner2">카드매출내역</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12"  data-tab="inner3">금전출납부</a>
					</li>
				</ul>
				<!-- /탭 -->

				<!-- /메인 타이틀 -->
				<div id="inner1" class="tabs-inner active"  style="min-height: 710px;">
					<iframe src="/acnt/acnt010201" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 700px;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="min-height: 710px;">
					<iframe src="/acnt/acnt010202" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 700px;" scrolling="no"></iframe>
				</div>
				<div id="inner3" class="tabs-inner " style="height: 710px;">
					<iframe src="/acnt/acnt010203" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 700px;" scrolling="no"></iframe>
				</div>
					<input type="text" id="s_start_dt" name="s_start_dt" style="visibility: hidden;" dateformat="yyyy-MM-dd">
					<input type="text" id="s_end_dt" name="s_end_dt" style="visibility: hidden;" dateformat="yyyy-MM-dd">
					<input type="text" id="s_org_code" name="s_org_code" style="visibility: hidden;">
					<input type="text" id="s_imprest_status_cd" name="s_imprest_status_cd" style="visibility: hidden;">
					<input type="checkbox" id="s_except_acnt_confirm" name="s_except_acnt_confirm" style="visibility: hidden;">
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
</div>
</body>
</html>