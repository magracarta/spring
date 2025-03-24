<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > null > null > 파일 썸네일 확인
-- 작성자 : 이강원
-- 최초 작성일 : 2023-06-15 19:36:27
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
		var nowPage;
		var maxPage;
		var viewUrl;
		var seqList = [];
		var videoArr = ['avi', 'mpg', 'wmv', 'mp4'];
		var fileArr = ['doc', 'docx', 'excel', 'hwp', 'pdf', 'ppt', 'pptx', 'txt', 'xls', 'xlsx'];

		$(document).ready(function() {
			var fileSeqStr = "${inputParam.file_seq_str}";
			if(fileSeqStr == undefined || fileSeqStr == "") {
				alert("확인할 파일이 없습니다.");
				fnClose();
			}

			var fileSeqArr = "${inputParam.file_seq_str}".split("#");
			nowPage = 1;
			maxPage = fileSeqArr.length;
			fileSeqArr.forEach(fileSeq => seqList.push(fileSeq));

			fnLoadPage(nowPage);
		});
		
		//페이지 로딩
		function fnLoadPage(nowPage) {
			$("#file_info").remove();
			//이미지 세팅
			var fileSeq = seqList[nowPage-1];

			//이미지 로딩
			if(fileSeq > 0 ){
				$M.goNextPageAjax("/file/info/" + fileSeq, '', {method : "GET"},
					function(result){
						if(result.success) {
							if(result.file_exists_yn == 'Y') {
								addFileInfo(result.file_seq, result.file_ext);
							} else {
								alert('파일이 없습니다.');
								// var str = '<img id="file_info" src="/static/img/no-image.png" width="100%">'
								var str = '<img id="file_info" src="/static/img/no-image.png" width="100%">'
								$("#file-info-div").append(str);
							}

							viewUrl = result.view_url;

							$("#_fnDownload").attr("disabled", result.file_exists_yn == 'N');
							$("#_goSearchFile").attr("disabled", result.view_url_yn == 'N');
						}

						//페이지 번호 설정 및 이전&다음 버튼 show
						fnSetPageNumber(nowPage);
					});
			}
		}
		
		//페이지 번호 설정 및 이전&다음 버튼 show
		function fnSetPageNumber(nowPage) {
			//페이지 쪽수 설정
			$("#nowPage").html(nowPage);
			$("#maxPage").html(maxPage);

			//이전 버튼 show
			if(nowPage > 1) {
				$("#before_button").removeClass('invisible');
			} else {
				$("#before_button").addClass('invisible');
			}
			
			//다음 버튼 show
			if(nowPage < maxPage ) {
				$("#next_button").removeClass('invisible');
			} else {
				$("#next_button").addClass('invisible');
			}
		}
		
		// 다운로드
		function fnDownload() {
			var fileSeq = seqList[nowPage-1];
			fileDownload(fileSeq);
        }

		function addFileInfo(fileSeq, fileExt) {
			var str = "";
			if(!videoArr.includes(fileExt)) {
				var src = "";
				if(fileArr.includes(fileExt)) {
					src = "/static/img/icon-" + fileExt + ".png";
				} else {
					src = "/file/" + fileSeq;
				}
				str += '<img id="file_info" src="'+ src +'" width="100%">';
			} else {
				str += '<video controls id="file_info" width="100%" height="800" style="margin-top: 10px;">';
				str += '<source src="/file/'+ fileSeq +'">';
				str += '</video>';
			}

			$("#file-info-div").append(str);
		}

		function goSearchFile() {
			console.log(viewUrl);
			$M.goNextPage(viewUrl, '', {popupStatus : getPopupProp(1600, 800)});
		}

		//팝업 끄기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form" style="height : 100%">
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
				<div class="left text-warning">
				</div>
				<div class="right">
                	<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
				</div>
            </div>
            <div id="file-info-div" class="mt10">
            </div>
<!-- /폼테이블 -->
<!-- 이전, 다음 버튼 모두 있을 경우 -->
			<div class="btn-group mt10 info-docpagination-wrap" style="width: 760px; align: center;">
				<button type="button" id="before_button" class="btn btn-md btn-info invisible" onclick="javascript:fnLoadPage(--nowPage)"><i class="material-iconschevron_left text-light"></i>이전</button>
				<div class="info-docpagination">
					<span class="current" id="nowPage"></span>
					<span>/</span>
					<span id="maxPage"></span>
				</div>
				<button type="button" id="next_button" class="btn btn-md btn-info invisible" onclick="javascript:fnLoadPage(++nowPage)">다음<i class="material-iconschevron_right text-light"></i></button>
			</div>
<!-- /이전, 다음 버튼 모두 있을 경우 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
				</div>
			</div>
		</div>
	</div>
<!-- /팝업 -->
</form>
</body>
</html>