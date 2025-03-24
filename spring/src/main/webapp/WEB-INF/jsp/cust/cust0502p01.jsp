<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 메인이미지관리 > 메인이미지 상세
-- 작성자 : 정선경
-- 최초 작성일 : 2023-08-16 09:48:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 저장(수정)
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return false;
			}

			if ($M.getValue("file_seq") == "") {
				alert("이미지를 등록해 주세요.");
				return false;
			}

			$M.goNextPageAjaxModify(this_page+"/modify", $M.toValueForm(frm), {method : "POST"},
				function(result) {
					if(result.success) {
						fnClose();
						window.opener.goSearch();
					}
				}
			);
		}

		// 삭제
		function goRemove() {
			var param = {
				"c_main_img_seq" : $M.getValue("c_main_img_seq")
			};

			$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						fnClose();
						window.opener.goSearch();
					}
				}
			);
		}

		// 파일찾기
		function goSearchFile() {
			var param = {
				upload_type	: 'CMAIN',
				file_type : 'img',
				max_width : '476',
				max_height : '130'
			};
			openFileUploadPanel("fnSetImage", $M.toGetParam(param));
		}

		// 팝업창에서 받아온 값
		function fnSetImage(file) {
			if (file != null && file.file_seq != null) {
				// 이미지 그려주기 작업
				$(".no-img").hide();
				$(".thumb").show();
				$("#image_area").attr("src", '/file/'+ file.file_seq);
				$M.setValue("file_seq", file.file_seq);
			} else {
				$(".no-img").show();
				$(".thumb").hide();
				$M.setValue("file_seq", 0);
			}
		}

		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="c_main_img_seq" value="${result.c_main_img_seq}">
	<input type="hidden" name="file_seq" value="${result.file_seq}">

	<!-- 팝업 -->
    <div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
        <div class="content-wrap">
			<!-- 폼테이블 -->
			<div class="title-wrap">
				<h4>메인이미지 상세</h4>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">작성자</th>
						<td>
							${result.reg_mem_name}
						</td>		
						<th class="text-right">등록일시</th>
						<td>
							<fmt:formatDate value="${result.reg_date}" pattern="yyyy-MM-dd HH:mm:ss"/>
						</td>						
					</tr>
					<tr>
						<th class="text-right essential-item">제목</th>
						<td>
							<input type="text" class="form-control essential-bg" id="title" name="title" alt="제목" value="${result.title}" required="required">
						</td>
						<th class="text-right essential-item">노출여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="show_y" name="show_yn" value="Y" ${result.show_yn eq 'Y' ? 'checked' : '' } >
								<label class="form-check-label" for="show_y">노출</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="show_n" name="show_yn" value="N" ${result.show_yn ne 'Y' ? 'checked' : '' }>
								<label class="form-check-label" for="show_n">미노출</label>
							</div>
						</td>
					</tr>
					<!-- 이미지 첨부 후 -->
					<tr>
						<th class="text-right essential-item" style="height: 220px">이미지 첨부</th>
						<td colspan="3" class="text-center">
							<div class="no-img" style="display: none;">
								<i class="icon-noimg"></i>
								<div class="no-img-txt">no images</div>
							</div>
							<div class="thumb" style="height : 200px; text-align: center;">
								<img src="/file/${result.file_seq}" alt="${result.title}" style="max-width: 100%; max-height: 100%;" id="image_area">
							</div>
						</td>
					</tr>	
					<!-- /이미지 첨부 후 -->
				</tbody>
			</table>
			<span class="text-warning" tooltip>
						※ 메인이미지는 고정된 영역으로 권장사이즈에 맞는 이미지만 정상적으로 노출됩니다.<br/>
						&nbsp;&nbsp;&nbsp;&nbsp;권장 이미지 사이즈 : 가로 - 476px 세로 - 130px
					</span>
			<!-- /폼테이블 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="left">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
	<!-- /팝업 -->
</form>
</body>
</html>