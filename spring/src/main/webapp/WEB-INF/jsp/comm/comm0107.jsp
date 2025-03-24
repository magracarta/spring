<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 로그인이미지관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	$(document).ready(function() {
	});	
	
	// 조회
	function goSearch() {
		var param = {
				"s_title" : $M.getValue("s_title"),
				"s_show_yn" : $M.getValue("s_show_yn")
		};
		
		$M.goNextPage(this_page, $M.toGetParam(param), '');
	}
	
	// 엔터키
	function enter(fieldObj) {
		console.log(fieldObj);
		var field = ["s_title"];
		$.each(field, function() {
			if (fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	// 순서 저장
	function goSave() {
		if(${list.size()} == 0) {
			alert('저장할 데이터가 없습니다.');
			return;
		}
		
		var listCnt = 0;
		
		for(var i=0, n=${list.size()}; i<n; i++) {
			// 정렬순서는 별도로 체크안함.
			document.getElementById('show_yn' + i).value = $M.getValue('dis_show_yn' + i);
			
			// 롤링순서 체크
			if ($M.getValue('dis_show_yn' + i) == 'Y' && document.getElementById('sort_no' + i).value == '0') {
				alert("롤링순서는 1이상으로 입력해주세요.");
				$("#sort_no"+i).focus();
				return;
			}
			
			
// 			if($M.getValue('dis_show_yn' + i) == "Y") {
// 				listCnt++;
// 				if(listCnt > 8) {
// 					alert("롤링이미지는 8개 이하만 가능합니다.");
// 					return false;
// 				}
// 			}
		}
 		
 		$M.goNextPageAjaxSave(this_page, document.main_form, {method : "POST"},
			function(result) {
				if(result.success) {
					goSearch();
				};
			}
		);
	}
	
	// 신규등록
	function goNew() {
		$M.goNextPage("/comm/comm010701");
	}
	
	// 상세팝업
	function goLoginImagePopup(index) {
		// 해당 값 가져오기.
		var loginImageSeq = $("#login_image_seq"+index).val();
		var param = {
    		login_image_seq : loginImageSeq,
    	}
	    var poppupOption = "";
	    $M.goNextPage('/comm/comm0107p01/', $M.toGetParam(param) , {popupStatus : poppupOption});
	}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 기본 -->					
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="40px">
								<col width="180px">
								<col width="70px">
								<col width="90px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>제목</th>
									<td>
										<input type="text" class="form-control" id="s_title" name="s_title" value="${inputParam.s_title }">
									</td>
									<th>노출여부</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<select class="form-control" id="s_show_yn" name="s_show_yn">
												<option value="">- 전체 -</option>
												<option value="Y" ${inputParam.s_show_yn eq 'Y' ? 'selected' : '' }>노출</option>
												<option value="N" ${inputParam.s_show_yn eq 'N' ? 'selected' : '' }>미노출</option>
											</select>
										</div>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
									<td class="text-right text-warning">
										※ 롤링이미지는 페이지 로딩속도를 감안하여 8개로 제한합니다.
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /기본 -->
<!-- 갤러리 게시판 -->
					<div class="gallery-board">
		<!-- 그리드 서머리, 컨트롤 영역 -->

		<!-- /그리드 서머리, 컨트롤 영역 -->
						<%-- 이미지 하나씩 보임 // --%>
						<c:forEach var="list" items="${list}" varStatus="index">
						<div class="gallery-item">
							<div class="header">
								<div class="num">${index.count}</div>
								<div class="info">
									<span class="pr5"><fmt:formatDate value="${list.reg_date}" pattern="yyyy-MM-dd"/></span><span>${list.reg_mem_name}</span>
								</div>
							</div>
							<div class="body">
								<div class="thumb" style="height : 250px; text-align: center;">
									<img src="${list.file_url}" alt="${list.title}" style="width:95%; height: 95%;" onclick="javascript:goLoginImagePopup(${index.index})">
								</div>
								<div class="body-bottom">
									<div class="title">${list.title}</div>
									<div class="setting">
										<div class="left">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="radio1${index.index}" name="dis_show_yn${index.index}" value="Y" ${list.show_yn eq 'Y' ? 'checked' : '' }>
												<label class="form-check-label" for="radio1${index.index}">노출</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="radio2${index.index}" name="dis_show_yn${index.index}" value="N" ${list.show_yn eq 'N' ? 'checked' : '' }>
												<label class="form-check-label" for="radio2${index.index}">미노출</label>
											</div>
										</div>
										<div class="right">
											<span class="pr5" style="margin-top : -4px;">롤링순서</span>
											<input type="text" name="sort_no" id="sort_no${index.index}" value="${list.sort_no}" style="margin-top : -2px; width: 40px;" alt="롤링순서"/>
										</div>
									</div>
									</div>
								</div>
							</div>
							<input type="hidden" id="login_image_seq${index.index}" name="login_image_seq" value="${list.login_image_seq}">
							<input type="hidden" id="show_yn${index.index}" name="show_yn" value="${list.show_yn}">
						</c:forEach>
						
							<div class="btn-group mt5">
								<div class="left">
									총 <strong class="text-primary">${list.size()}</strong>건 
								</div>		
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>				
							</div>
						</div>
						<%-- 이미지 하나씩 보임 // --%>
<!-- 갤러리 게시판 -->				
				</div>
			</div>		
		</div>
	</div>
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>