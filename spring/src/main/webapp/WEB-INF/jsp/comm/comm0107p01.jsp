<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 로그인이미지관리 > null > 로그인이미지상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-13 13:53:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 저장(수정)
	function goSave() {
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if ($M.getValue("file_seq") == "") {
			alert("이미지를 등록해 주세요.");
			return;
		}
		
 		$M.goNextPageAjaxModify(this_page+"/save", $M.toValueForm(document.main_form), {method : "POST"},
			function(result) {
				if(result.success) {
					alert("처리가 완료되었습니다.");
					fnClose();
					window.opener.location.reload();
				};
			}
		);
	}
	
	// 삭제
	function goRemove() {
		var param = {
				"login_image_seq" : $M.getValue("login_image_seq")
		}
		
		$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), { method : "POST"},
			function(result) {
				if(result.success) {
					alert("처리가 완료되었습니다.");
					fnClose();
					window.opener.location.reload();
				};
			}
		);
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
	// 파일찾기
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
			$("#image_area").attr("src", '/file/'+ result.file_seq);
			$M.setValue("file_seq", result.file_seq);
		}
	}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="login_image_seq" value="${list.login_image_seq}">
<input type="hidden" name="file_seq" value="${list.file_seq}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>로그인이미지관리</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">		
			<div class="title-wrap">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>						
			</div>
<!-- 폼테이블 -->					
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
							${list.reg_mem_name}
						</td>		
						<th class="text-right">등록일시</th>
						<td>
							<fmt:formatDate value="${list.reg_date}" pattern="yyyy-MM-dd HH:mm:ss"/>
						</td>						
					</tr>
					<tr>
						<th class="text-right essential-item">제목</th>
						<td>
							<input type="text" class="form-control essential-bg" id="title" name="title" alt="제목" value="${list.title}" required="required"> 
						</td>
						<th class="text-right essential-item">노출여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="show_yn1" name="show_yn" value="Y" ${list.show_yn eq 'Y' ? 'checked' : '' } >
								<label class="form-check-label" for="show_yn1">노출</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="show_yn2" name="show_yn" value="N" ${list.show_yn eq 'N' ? 'checked' : '' }>
								<label class="form-check-label" for="show_yn2">미노출</label>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">링크URL</th>
						<td colspan="3">
							<input type="text" class="form-control" id="link_url" name="link_url" value="${list.link_url}"> 
						</td>
					</tr>
<!-- 이미지 첨부 후 -->
					<tr>
						<th class="text-right essential-item" style="height: 500px">이미지 첨부</th>
						<td colspan="3" class="text-center pr">
							<div class="thumb" style="height : 480px; text-align: center;">
								<img src="${list.file_url}" alt="${list.title}" style="width:100%; height: 100%;" id="image_area">
							</div>
						</td>
					</tr>	
<!-- /이미지 첨부 후 -->													
				</tbody>
			</table>					
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