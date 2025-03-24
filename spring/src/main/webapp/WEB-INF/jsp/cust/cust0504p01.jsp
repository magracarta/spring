<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 부품컨텐츠관리 > null > 부품위치 별 조회화면 미리보기
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-07-28 13:38
------------------------------------------------------------------------------------------------------------------%>

<!DOCTYPE html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<link rel="stylesheet" href="/static/css/yk-mobile-customer.css">
	<script type="text/javascript">
		var btnIndex = 0;
		$(document).ready(function () {
			fnInit();
			// 부품위치 버튼 세팅
			if("${inputParam.c_part_pos_cd_str}" != "") {
				<c:forEach var="list" items="${partPosList}">fnSetPartPos('${list.code_value}', '${list.code_name}');</c:forEach>
			}
		});

		function fnInit() {
			var file = "${machineInfo.part_file_seq}";
			if (file == "") {
				file = null;
			} else {
				fileSeq = file;
				$("#image_area1").empty();
				$("#image_area1").append("<img src='/file/" + fileSeq + "' class='icon-profilephoto' style='width: 100%;' />");
			}
		}
		// 부품위치 버튼 출력
		function fnSetPartPos(code_value, code_name) {
			var str = '';
			var btnClass = '';
			if(btnIndex == 0){
				btnClass = 'btn btn-primary';
			} else {
				btnClass = 'btn btn-primary-outline'
			}
			str += '<button type="button" class="' + btnClass + '" value="' + code_value + '">' + code_name + '</button>';
			$('.width-btn-srcoll').append(str);
			btnIndex ++;
		}
		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>

<body style="overflow: hidden;">

<!-- 팝업 -->
<div class="popup-backdrop"></div>
<div class="popup-wrap full"> <!-- full클래스 추가해주면 전체페이지 팝업 -->
	<!-- 상단 타이틀 영역 -->
	<div class="popup-top">
		<div class="header">
			<span class="title">부품위치 별 조회화면 미리보기</span>
			<button class="icon-close-white-lg" onclick="javascript:fnClose();"></button>
		</div>
	</div>
	<!-- /상단 타이틀 영역 -->

	<div class="popup-content" style="padding-top: 60px; "> <!-- padding-top값은 동적계산 -->
		<div class="p-content-common position-relative division-bg " id="image_area1">
			<div class="boxing flex-center" style="height: 400px;">
				<div class="icon-with-comment no-data-wrap mb-60">
					<i class="icon-none-image"></i>
					<div class="no-data-comment">
						<div class="sub-comment mt-0">
							이미지 준비 중 입니다.
						</div>
					</div>
				</div>
			</div>
<%--			<img src='/file/${machineInfo.part_file_seq}' class='icon-profilephoto' tabindex=0 style='width: 100%;' />--%>
		</div>

		<div class="p-content-common division-bg">
			<div class="mb-6">
				아래 위치버튼을 터치하면 관련부품이 조회됩니다.
			</div>
			<div class="width-btn-srcoll">
			</div>
		</div>

		<div class="p-content-common">
			<div class="row g-12 tools-list-group">
<%--				<c:forEach var="item" items="${partList}">--%>
				<c:if test="${not empty inputParam.c_part_pos_cd_str}">
					<div class="col-6">
						<div class="tools-list-item">
							<div class="thumb-wrap">
								<div class="thumb solo" style=" flex: 0 0 30vw; height: 33vw;">
									<img src='/file/${inputParam.rep_file_seq}' class='icon-profilephoto' tabindex=0 style='width: 100%;' />
								</div>
							</div>
							<div class="tools-info">
								<div class="sub-title-sm">${inputParam.part_name}</div>
								<div class="highlight-half">VIP가 ${inputParam.vip_sale_price}</div>
								<div class="text-gray">일반가 ${inputParam.sale_price}</div>
							</div>
						</div>
					</div>
				</c:if>
<%--				</c:forEach>--%>
				
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->

</body>

</html>