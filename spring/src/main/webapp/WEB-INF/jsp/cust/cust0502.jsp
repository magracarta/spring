<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 메인이미지관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-08-14 14:29:13
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var imgIndex = 0;

		$(document).ready(function() {
			goSearch();
		});
	
		// 조회
		function goSearch() {
			imgIndex = 0;
			var param = {
				"s_title" : $M.getValue("s_title"),
				"s_show_yn" : $M.getValue("s_show_yn")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							$("#total_cnt").html(result.total_cnt);
							fnSetCMainImgHtml(result.list);
						}
					}
			);
		}

		// 조회결과 메인이미지 html 추가
		function fnSetCMainImgHtml(list) {
			if (list != null || list.length > 0) {
				$(".main-gallery-item").remove();
				var innerHtml = '';
				for (var i=0; i<list.length; i++) {
					imgIndex ++;
					innerHtml += fnMakeImgHtml(list[i]);
				}
				$(".gallery-board").prepend(innerHtml);
			}
		}

		// 이미지 html 만들기
		function fnMakeImgHtml(data) {
			var imgHtml = '<div class="main-gallery-item">'
					+ '	<div class="header">'
					+ '	   <div class="num">' + imgIndex + '</div>'
					+ '	   <div class="info">'
					+ '	      <span class="pr5">'+ $M.dateFormat(data.reg_dt, 'yyyy-MM-dd') +'</span><span>'+ data.reg_mem_name +'</span>'
					+ '	   </div>'
					+ '	</div>'
					+ '	<div class="body">'
					+ '	   <div class="thumb pointer" style="height : 140px; text-align: center;">'
					// + '	      <img src="/file/'+ data.file_seq +'" alt="'+ data.title +'" style="max-width: 95%; max-height: 95%; margin-top: 5px;" onclick="javascript:goCMainImgDetailPopup('+ data.c_main_img_seq +')">'
					+ '	      <div style="background-image: url(\'/file/' + data.file_seq +'\'); background-repeat: no-repeat; background-size: cover; width: 100%;height: 110px; margin-top: 25px;" onclick="javascript:goCMainImgDetailPopup('+ data.c_main_img_seq +')"></div>'
					+ '	   </div>'
					+ '	   <div class="body-bottom">'
					+ '	      <div class="title">'+ data.title +'</div>'
					+ '	      <div class="setting">'
					+ '	         <div class="left">'
					+ '	            <div class="form-check form-check-inline">'
					+ '	               <input class="form-check-input" type="radio" id="dis_show_y_'+ imgIndex +'" name="dis_show_yn_'+ imgIndex +'" value="Y" ' + (data.show_yn == 'Y'? 'checked': '') + '>'
					+ '	               <label class="form-check-label" for="dis_show_y_'+ imgIndex +'">노출</label>'
					+ '	            </div>'
					+ '	            <div class="form-check form-check-inline">'
					+ '	               <input class="form-check-input" type="radio" id="dis_show_n_'+ imgIndex +'" name="dis_show_yn_'+ imgIndex +'" value="N" ' + (data.show_yn == 'N'? 'checked': '') + '>'
					+ '	               <label class="form-check-label" for="dis_show_n_'+ imgIndex +'">미노출</label>'
					+ '	            </div>'
					+ '	         </div>'
					// + '	         <div class="right">'
					// + '	            <span class="pr5" style="margin-top : -4px;">롤링순서</span>'
					// + '	            <input type="text" id="sort_no_'+ imgIndex +'" name="sort_no" value="'+ data.sort_no +'" style="margin-top : -2px; width: 40px;" alt="롤링순서"/>'
					// + '	         </div>'
					+ '	      </div>'
					+ '	   </div>'
					+ '	</div>'
					+ '	<input type="hidden" id="show_yn_'+ imgIndex +'" name="show_yn" value="'+ data.show_yn +'">'
					+ '	<input type="hidden" id="c_main_img_seq_'+ imgIndex +'" name="c_main_img_seq" value="'+ data.c_main_img_seq +'">'
					+ '</div>';
			return imgHtml;
		}

		// 엔터키
		function enter(fieldObj) {
			var field = ["s_title"];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		// 순서 저장
		function goSave() {
			if (${result.total_cnt eq 0}) {
				alert('저장할 데이터가 없습니다.');
				return false;
			}

			$(".main-gallery-item").each(function () {
				$(this).find("input[name=show_yn]").val($(this).find("input[name^=dis_show_yn]:checked").val());
			});

			$M.goNextPageAjaxSave(this_page + '/save', document.main_form, {method : "POST"},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

		// 신규등록
		function goNew() {
			$M.goNextPage("/cust/cust050201");
		}

		// 상세팝업
		function goCMainImgDetailPopup(cMainImgSeq) {
			var param = {
				"c_main_img_seq" : cMainImgSeq,
			}
			$M.goNextPage("/cust/cust0502p01", $M.toGetParam(param), {popupStatus : ""});
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
										<input type="text" class="form-control" id="s_title" name="s_title" value="${inputParam.s_title}">
									</td>
									<th>노출여부</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<select class="form-control" id="s_show_yn" name="s_show_yn">
												<option value="">- 전체 -</option>
												<option value="Y" ${inputParam.s_show_yn eq 'Y' ? 'selected' : ''}>노출</option>
												<option value="N" ${inputParam.s_show_yn eq 'N' ? 'selected' : ''}>미노출</option>
											</select>
										</div>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 갤러리 게시판 -->
					<div class="gallery-board">
						<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">${result.total_cnt}</strong>건
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
					<!-- 갤러리 게시판 -->
				</div>
			</div>
		</div>
	</div>
	<!-- /contents 전체 영역 -->
	<div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
</form>
</body>
</html>