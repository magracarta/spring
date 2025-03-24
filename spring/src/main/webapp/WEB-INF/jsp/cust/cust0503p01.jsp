<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 장비컨텐츠관리 > null > 장비상세정보 미리보기
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-07-13 14:38
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function () {
			// fnInit();
		});

		function fnInit() {
			<%--var file = "${dtl_file_seq}";--%>
			<%--if (file == "") {--%>
			<%--	file = null;--%>
			<%--} else {--%>
			<%--	fileSeq = file;--%>
			<%--	$("#image_area1").empty();--%>
			<%--	$("#image_area1").append("<div class='attach-delete' style='display:none;' ><button type='button' class='btn btn-icon-lg text-light'><i class='material-iconsclose'></i></button></div><img id='dtlImage' name='dtlImage' src='/file/" + fileSeq + "' class='icon-profilephoto' tabindex=0 style='width: 100%' />");--%>

			<%--}--%>
		}

		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="detail-info-summary">
				<div class="left">
					<img src="/file/${rep_file_seq}" alt="" class="detail-img" style="width: 100%;">
					<!-- no-img일 경우
                    <div class="no-img">
                      <i class="icon-noimg"></i>
                      <div class="no-img-txt">no images</div>
                    </div>
                    no-img일 경우 -->
				</div>
				<div class="right">
					<div class="detail-info-summary-title">${maker_name} ${machine_name}</div>
					<div class="detail-info-summary-content">
						<c:forEach var="item" items="${dataList}" varStatus="status">
							<span class="inline">${item.code_name} : ${item.value}</span>
							<br/>
						</c:forEach>
					</div>
				</div>
			</div>

			<div class="title-wrap">
				<h4>상세정보</h4>
			</div>

			<c:forEach var="item" items="${imgList}">
				<img src="/file/${item.dtl_file_seq}" alt="" class="detail-img" style="width: 100%;" >
			</c:forEach>

<%--			<div class="mt10">--%>
<%--				<div class="mch-checklist-item">--%>
<%--					<div class="no-img" id="image_area1" style="width: 100%">--%>
<%--						<i class="icon-noimg"></i>--%>
<%--						<div class="no-img-txt">no images</div>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>

			<div class="title-wrap mt20">
				<h4>영상정보</h4>
			</div>
			<c:forEach var="item" items="${videoList}">
				<div class="mt10"><!-- 첨부파일이 동영상일 경우 -->
					<div class="view-avi">
						<div class="mch-video-checklist-item">
							<div class="no-img" id="image_area2" style="width: 100%">
								<i class="icon-view-avi-white"></i>

								<div class='attach-delete' style='display:none;'>
									<button type='button' class='btn btn-icon-lg text-light'>
										<i class='material-iconsclose'></i>
									</button>
								</div>
								<c:if test="${item.video_key ne ''}">
								<a href='${item.video_url}' onclick='window.open(this.href, "window_name", "width=800, height=600, location=no,status=no,scrollbars=yes"); return false;' target='_blank' style='width: 100%'>
									<img id='videoImage' name='videoImage' src='https://img.youtube.com/vi/${item.video_key}/mqdefault.jpg' style='width: 100%' />
									<a/>
									</c:if>
							</div>
						</div>
					</div>
				</div>
			</c:forEach>

			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>