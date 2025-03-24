<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 메인이미지관리 > 메인이미지 신규등록
-- 작성자 : 정선경
-- 최초 작성일 : 2023-08-16 10:39:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 파일찾기 팝업
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

		// 저장
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			if ($M.getValue("file_seq") == "") {
				alert("이미지를 등록해 주세요.");
				return;
			}

			$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						$M.goNextPage("/cust/cust0502");
					}
				}
			);
		}

		// 목록
		function fnList() {
			history.back();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="file_seq" name="file_seq">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
				<!-- /상세페이지 타이틀 -->
				<div class="contents" style="width:40%;">
					<!-- 폼테이블 -->
					<div>
						<table class="table-border">
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
										${SecureUser.kor_name}
									</td>		
									<th class="text-right">등록일시</th>
									<td></td>
								</tr>
								<tr>
									<th class="text-right essential-item">제목</th>
									<td >
										<input type="text" class="form-control essential-bg" name="title" alt="제목" required="required">
									</td>
									<th class="text-right essential-item">노출여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="show_y" name="show_yn" value="Y" checked="checked">
											<label class="form-check-label" for="show_y">노출</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="show_n" name="show_yn" value="N">
											<label class="form-check-label" for="show_n">미노출</label>
										</div>
									</td>									
								</tr>
								<!-- 이미지 첨부 전 -->
								<tr>
									<th class="text-right essential-item" style="height: 220px">이미지 첨부</th>
									<td colspan="3" class="text-center">
										<div class="no-img">
											<i class="icon-noimg"></i>
											<div class="no-img-txt">no images</div>
										</div>
										<div class="thumb" style="height : 200px; text-align: center; display: none;">
											<img src="/file/${result.file_seq}" alt="${result.title}" style="max-width: 100%; max-height: 100%;" id="image_area">
										</div>
									</td>
								</tr>
								<!-- /이미지 첨부 전 -->
							</tbody>
						</table>
					</div>
					<span class="text-warning" tooltip>
						※ 메인이미지는 고정된 영역으로 권장사이즈에 맞는 이미지만 정상적으로 노출됩니다.<br/>
						&nbsp;&nbsp;&nbsp;&nbsp;권장 이미지 사이즈 : 가로 - 476px 세로 - 130px
					</span>
					<!-- /폼테이블 -->
					<div class="btn-group mt10">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
