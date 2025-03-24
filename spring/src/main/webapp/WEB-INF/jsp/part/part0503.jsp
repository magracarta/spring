<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 바코드출력관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-02-12 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var tab_id;
		
		$(document).ready(function() {
			$('ul.tabs-c li a').click(function() {
			    tab_id = $(this).attr('data-tab');
				
			    $('ul.tabs-c li a').removeClass('active');
			    $('.tabs-inner').removeClass('active');
			 
			    $(this).addClass('active');
			    $("#"+tab_id).addClass('active');
			    
			    // 저장위치출력 일때 AUIGrid 다시 세팅 (부품창고 리스트)
			    if(tab_id == 'inner3') {
					$("#contentFrame3")[0].contentWindow.fnInit();
			    }
			});
		});
	
		// 바코드전용프린터 출력
		function fnBacodePrint(){
			goPrint('02');
		}
		
		// 일반레이저프린트 출력
		function fnPrint() {
			goPrint('01');
		}
		
		function goPrint(gubun) {
 			var iframe;
			var rows;
			
			if (tab_id == 'inner1' || tab_id == undefined) { // 부품코드출력
	 			iframe = document.getElementById("contentFrame1");
			}else if (tab_id == 'inner2') { // 창고코드출력
	 			iframe = document.getElementById("contentFrame2");
			}else if (tab_id == 'inner3') { // 저장위치출력
	 			iframe = document.getElementById("contentFrame3");
			}
			
			rows = iframe.contentWindow.fnGetPageData();
			
			if (rows.length == 0) {
				alert("최소 1개이상 선택해 주십시오.")
				return false;
			}
			
			var param = {
				"data" : rows
			}
			
			if (tab_id == 'inner1' || tab_id == undefined) { // 부품코드출력
				openReportPanel('part/part050301_v32_' + gubun + '.crf', param);
			}else  if (tab_id == 'inner2') { // 창고코드출력
				openReportPanel('part/part050302_v32_' + gubun + '.crf', param);
			}else if (tab_id == 'inner3') { // 저장위치출력
				openReportPanel('part/part050303_v32_' + gubun + '.crf', param);
			}
		}
	
		// 일반QR프린터 출력
		function fnQrPrint(){
			goQrPrint('03');
		}
		
		// 전용QR프린트 출력
		function fnPrintQr() {
			goQrPrint('04');
		}
		
		function goQrPrint(gubun) {
 			var iframe;
			var rows;
			
			if (tab_id == 'inner1' || tab_id == undefined) { // 부품코드출력
	 			iframe = document.getElementById("contentFrame1");
				 if(gubun == "03" || gubun == "04"){
					 // QR코드 출력 전 t_part_qr에 qr코드 생성 후 출력
					 iframe.contentWindow.goQrSave();
				 }
			}else if (tab_id == 'inner2') { // 창고코드출력
	 			iframe = document.getElementById("contentFrame2");
			}else if (tab_id == 'inner3') { // 저장위치출력
	 			iframe = document.getElementById("contentFrame3");
			}
			
			setTimeout(function() {
				rows = iframe.contentWindow.fnGetPageData();
			
				if (rows.length == 0) {
					alert("최소 1개이상 선택해 주십시오.")
					return false;
				}
				
				var param = {
					"data" : rows
				}
				
				if (tab_id == 'inner1' || tab_id == undefined) { // 부품코드출력
					openReportPanel('part/part050301_' + gubun + '.crf', param);
				}else  if (tab_id == 'inner2') { // 창고코드출력
					openReportPanel('part/part050302_' + gubun + '.crf', param);
				}else if (tab_id == 'inner3') { // 저장위치출력
					openReportPanel('part/part050303_' + gubun + '.crf', param);
				}
			}, 300);
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
							<a href="#" class="tabs-link font-12 active"  data-tab="inner1">부품코드출력</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner2">창고코드출력</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner3">저장위치출력</a>
						</li>
						<li class="tabs-c-right-btn" style="margin-right:2%">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</li>
					</ul>
	<!-- /탭 -->	  
			
	<!-- /메인 타이틀 -->
			
				<div id="inner1" class="tabs-inner active"  style="height: 630px;"> 
					<iframe src="/part/part050301" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner " style="height: 550px;"> 
					<iframe src="/part/part050302" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
				<div id="inner3" class="tabs-inner " style="height: 570px;"> 
					<iframe src="/part/part050303" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
				</div>
			</div>
				
				
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</body>
</html>