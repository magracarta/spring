<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 로그인이미지관리 > 신규등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-04 13:53:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<script src="http://code.jquery.com/jquery-latest.js"></script>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 뒤로가기, 목록
	function fnList() {
		history.back();
	}
	
	// 파일찾기 팝업
	function goSearchFile() {
		var param = {
			upload_type	: 'LOGIN',
			file_type : 'img',
			max_width : '1040',
			max_height : '768',
			pixel_limit_yn : 'Y',
			max_size : 1024
		};
		openFileUploadPanel("fnSetImage", $M.toGetParam(param));
	}
	
	// 팝업창에서 받아온 값
	function fnSetImage(result) {
		if (result != null && result.file_seq != null) {
			// 이미지 그려주기 작업
			$("#image_area").empty();
			$("#image_area").append("<img id='profileImage' name='profileImage' src='/file/"+result.file_seq+"' class='icon-profilephoto' tabindex=0  />");
			$M.setValue("file_seq", result.file_seq);
		}
	}
	
	// 저장
	function goSave() {
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if ($M.getValue("file_seq") == "") {
			alert("이미지를 등록해 주세요.");
			return;
		}
		
		$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(document.main_form) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			$M.goNextPage("/comm/comm0107");
				}
			}
		);
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
				<div class="contents" style="width:50%;">
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
									<td>
										<jsp:useBean id="now" class="java.util.Date" />
										<fmt:formatDate value="${now}" pattern="yyyy-MM-dd HH:mm:ss" var="today"/>
										<c:out value="${today}"/>
									</td>						
								</tr>
								<tr>
									<th class="text-right essential-item">제목</th>
									<td >
										<input type="text" class="form-control essential-bg" name="title" alt="제목" required="required">
									</td>
									<th class="text-right essential-item">노출여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="show_yn" name="show_yn" value="Y" checked="checked">
											<label class="form-check-label" >노출</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="show_yn" name="show_yn" value="N">
											<label class="form-check-label" >미노출</label>
										</div>
									</td>									
								</tr>
								<tr>
									<th class="text-right">링크URL</th>
									<td colspan="3">
										<input type="text" class="form-control" id="link_url" name="link_url"> 
									</td>
								</tr>								
<!-- 이미지 첨부 전 -->
								<tr>
									<th class="text-right essential-item" style="height: 500px">이미지 첨부</th>
									<td colspan="3" class="text-center" id="image_area">
										<i class="icon-noimg"></i>
										<div class="no-img-txt">no images
										</div>
									</td>
								</tr>
<!-- /이미지 첨부 전 -->													
							</tbody>
						</table>
					</div>					
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
