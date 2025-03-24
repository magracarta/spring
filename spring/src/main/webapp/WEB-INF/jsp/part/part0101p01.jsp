<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품조회 > 부품재고조회 > null > 부품재고상세
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 탭 클릭 시 이벤트
			$('ul.tabs-c li a').click(function() {
			    var tab_id = $(this).attr('data-tab');
			    $('ul.tabs-c li a').removeClass('active');
			    $('.tabs-inner').removeClass('active');
			    var url = '';
			    if(tab_id == 'inner1') {
			    	url = '/part/part0101p0101?part_no=${inputParam.part_no}';
			    } else if(tab_id == 'inner2') {
				    url = '/part/part0101p0102?part_no=${inputParam.part_no}';
			    } else if(tab_id == 'inner3') {
			    	url = '/part/part0101p02?part_no=${inputParam.part_no}&tap_type=tap';
			    }
		    	$("#"+tab_id).html('<iframe src="' + url + '" id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>');
			    $(this).addClass('active');
			    $("#" + tab_id).addClass('active');
			});
			
			fnInit();
		});
		
		function fnInit() {
			if($M.getValue("part_detail_show_yn") != "Y") {
				$("#_goPopupPart").addClass("dpn");
			}
			// 23.03.07 정윤수 팝업호출 시 원하는 탭으로 이동
			if("${inputParam.tap_no}" != "") {
				$("#tap"+"${inputParam.tap_no}").click();
			}
		}
		
		function goPopupPart() {
			var popupOption = "";
			var part_no = '${inputParam.part_no}';
			$M.goNextPage('/part/part0701p01', "part_no=" + part_no, {popupStatus : popupOption});
		}

		// 이동요청
		function goTransPart() {
			var param = {
				'part_no' : '${inputParam.part_no}',

			};
			openTransPartPanel('setMovePartInfo', $M.toGetParam(param));
		}

		// 이동요청 콜백
		function setMovePartInfo() {
			console.log("이동요청 성공");
		}

		// 부품발주요청
		function goOrderPart() {
			var param = {
				"part_no" : "${inputParam.part_no}"
			};
			openOrderPartPanel('setPartRequestInfo', $M.toGetParam(param));
		}

		// 부품발주요청 콜백
		function setPartRequestInfo() {
			location.reload();
		}

		// 납기문의
		function goSendPartInquiry() {
			var partNo = '${result.part_no}';
			var partName = '${result.part_name}'
			var titleStr = '납기문의'
			openSendPartInquiry(partNo, partName, titleStr, '');
		}

		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form" style="height:100px;">
<input type="hidden" name="part_detail_show_yn" id="part_detail_show_yn" value="${page.add.PART_DETAIL_SHOW_YN eq 'Y'? 'Y':'N'}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
<!-- 탭 -->			
			<ul class="tabs-c">
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12 active" id="tap1" data-tab="inner1">창고별재고현황</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12" id="tap2" data-tab="inner2">발주내역</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12" id="tap3" data-tab="inner3">입/출고내역</a>
				</li>
			</ul>
<!-- /탭 -->				
<!-- 탭내용 -->			
 			<div class="taps-inner-dev">
				<div class="tabs-inner-line">
					<div class="boxing bd0 pd0 vertical-line mt5" style="justify-content: space-between;">
						<div class="boxing bd0 pd0 vertical-line">
							<span>
								<span class="text-default bd0 pr5">부품번호</span>
								${result.part_no}
							</span>
							<span>
								<span class="text-default bd0 pr5">부품명</span>
								${result.part_name}
							</span>
						<%--	Q&A 15194 모든인원 표시되도록.						--%>
<%--							<c:if test="${SecureUser.in_price_show_yn eq 'Y'}">--%>
							<span>
	<%--							<span class="text-default bd0 pr5">입고단가</span>--%>
	<%--							<fmt:formatNumber value="${result.in_stock_price}" pattern="#,###" />원--%>
								<span class="text-default bd0 pr5">VIP 판매가</span>
								<fmt:formatNumber value="${result.vip_sale_price}" pattern="#,###" />원
							</span>
<%--							</c:if>--%>
							<span>
	<%--							<span class="text-default bd0 pr5">VAT별도</span>--%>
	<%--							<fmt:formatNumber value="${result.sale_price}" pattern="#,###" />원--%>
								<span class="text-default bd0 pr5">일반 판매가</span>
								<fmt:formatNumber value="${result.sale_price}" pattern="#,###" />원
								<div class="text-warning ml5" style="display: inline">※ 부가세 별도</div>
							</span>
	<%--						<span><div class="text-warning ml5" style="display: inline">※ 부가세 별도</div>--%>
	<%--							<span class="text-default bd0 pr5">VAT포함</span>--%>
	<%--							<fmt:formatNumber value="${result.sale_vat_price}" pattern="#,###" />원--%>
	<%--						</span>--%>
							<span>[${result.part_mng_name}]</span>
							<span class="bd0">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
							</span>
							<input type="hidden" value="${result.part_mng_cd}">
						</div>
						<div class="vertical-line">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>	
					<hr class="dev-hr">
					<div class="boxing bd0 pd0 vertical-line mt5" style="margin-top:10px;">
						<span>
							<span class="text-default bd0 pr5">호환모델</span>
							<c:forEach var="item" items="${partMchlist}">
				            	<span style="border-radius:5px; background-color:#ddd; padding:5px; margin:3px;">${item.machine_name}</span>
				            </c:forEach>
						</span>
					</div>
				</div>
			</div>
<!-- /탭내용 -->	
				<div id="inner1" class="tabs-inner active"  style="height: 600px; margin-top: 0px !important;"> 
					<iframe src="/part/part0101p0101?part_no=${inputParam.part_no}" id="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<div id="inner2" class="tabs-inner" style="height: 600px; margin-top: 0px !important;"> 
				</div>
				<div id="inner3" class="tabs-inner" style="height: 800px; margin-top: 0px !important;">
				</div>
			</div>
        </div>
<!-- /팝업 -->
</form>
</body>
</html>