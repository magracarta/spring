<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 이미지 상세보기 및 프린트
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-03-31 11:26:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		@media print {
			@page {
				margin-top : 0;
				margin-bottom : 0;
			}
			body {
				padding-top : 72px;
				padding-bottom : 72px;
			}
		}		
	</style>
	
	<script type="text/javascript">
		$(document).ready(function() {
			var fileExt = '${file_ext}';

			var videoArr = ['avi', 'mpg', 'wmv', 'mp4'];

			if(videoArr.includes(fileExt)) {
				$("#print").addClass("dpn");
			}
		});

		// 이미지 인쇄시 (크롬인쇄) 헤더영역으로 인하여 공백이 생기는 이슈로 헤더영역을 제거하고, 인쇄 후 다시 살림 (2023-01-05 황빛찬)
		function fnGoPrint() {
			$(".main-title").css('display', 'none');
			$(".btn-group").css('display', 'none');
			$(".popup-wrap .content-wrap").css('padding', '0px 0px 0px 0px');

			window.print();

			$(".main-title").css('display', 'block');
			$(".btn-group").css('display', 'block');
			$(".popup-wrap .content-wrap").css('padding', '10px 15px 15px 15px');
		}
	</script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form" style="height : 100%">
<!-- 팝업 -->
      <div class="popup-wrap width-100per" style="height : 100%">
          <!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<div class="content-wrap">
	          <div class="btn-group mt5">
				<div class="right">
					<a href='/file/${inputParam.file_seq}' >
						<button type="button" class="btn btn-md btn-rounded btn-outline-primary">저장</button>
					</a>
<%--					2023-01-05 황빛찬 - 인쇄 할 때 menuNavi영역을 지우기 위해 수정--%>
<%--					<button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="window.print()">인쇄</button>--%>
					<button type="button" class="btn btn-md btn-rounded btn-outline-primary" id="print" onclick="fnGoPrint();">인쇄</button>
				</div>
	          </div>
				<c:if test="${file_ext eq 'avi' or file_ext eq 'mpg' or file_ext eq 'wmv' or file_ext eq 'mp4'}">
					<video controls width="100%" height="800" style="margin-top: 10px;">
						<source src="/file/${inputParam.file_seq}">
					</video>
				</c:if>
				<c:if test="${file_ext ne 'avi' and file_ext ne 'mpg' and file_ext ne 'wmv' and file_ext ne 'mp4'}">
					<img id="chkImage" name="chkImage" src='/file/${inputParam.file_seq}' class='icon-profilephoto' tabindex=0/>
				</c:if>
          </div>
      </div>
      <!-- /팝업 -->
</form>
</body>
</html>