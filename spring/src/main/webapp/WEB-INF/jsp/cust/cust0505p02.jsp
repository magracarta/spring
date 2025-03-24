<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 뉴스 > 뉴스 미리보기
-- 작성자 : 정선경
-- 최초 작성일 : 2023-08-04 11:57:14
-- 고객앱 모바일 디자인 화면
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<link rel="stylesheet" type="text/css" href="/static/css/yk-mobile-customer.css" />
		<script type="text/javascript">
			$(document).ready(function () {
				var content = "${inputParam.content}";
				if (content != "") {
					$("#contents").html(decodeURIComponent(content));
				}

				if (${not empty video_list}) {
					var videoList = ${video_list};
					for (var i = 0; i < videoList.length; i++){
                        var videoHtml = '<div class="view-avi">'
								      + '	<img src="https://img.youtube.com/vi/' + videoList[i].video_key + '/mqdefault.jpg" alt="유튜브주소' + i + '" class="img-view avi">'
								      + '	<i class="icon-view-avi-white"></i>'
									  + '</div>';
                        $("#video").append(videoHtml);
					}
				}
			});

			// 닫기
			function fnClose() {
				window.close();
			}
		</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-backdrop"></div>
	<div class="popup-wrap full">
		<!-- 상단 타이틀 영역 -->
		<div class="popup-top">
			<div class="header">
				<button class="icon-close-white-lg" onclick="javascript:fnClose();">
					<span class="visually-hidden">닫기</span>
				</button>
				<span class="title">뉴스 미리보기</span>
			</div>
		</div>
		<!-- /상단 타이틀 영역 -->

		<div class="popup-content" style="padding-top: 3.125rem;">
			<div class="list-group view">
				<div class="list-item">
					<div class="list-item-link no-right-btn">
						<div class="content">
							<div>${inputParam.title}</div>
							<div>
								<span class="text-gray">${inputParam.reg_dt}</span>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- 이미지 -->
			<div class="p-content-common">
				<div class="news-item">
					<!-- 대표이미지 -->
					<img src="/file/${inputParam.img_file_seq}" alt="대표이미지" class="img-view" onerror="this.src='/static/img/cust/no-img.png'">

					<!-- 추가이미지 -->
					<c:if test="${not empty inputParam.file_seq_str}">
						<c:set var="file_seq_list" value="${fn:split(inputParam.file_seq_str, '#')}" />
						<c:forEach var="file_seq" items="${file_seq_list}" varStatus="status">
							<img src="/file/${file_seq}" alt="추가이미지${status.index}" class="img-view">
						</c:forEach>
					</c:if>
				</div>

				<!-- 유튜브영상 -->
				<div id="video"></div>

				<!-- 내용 -->
				<div id="contents"></div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>