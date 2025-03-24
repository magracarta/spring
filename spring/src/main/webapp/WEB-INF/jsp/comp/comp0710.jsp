<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > null > null > 도움말
-- 작성자 : 임예린
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
		var nowPage;
		var maxPage;
		var seqList;
		$(document).ready(function() {
			goSearch();
		});
		
		//도움말 페이지 이동
		function goHelpSetting() {
			var param = {
				"menu_seq" : ${param.menu_seq }
			};
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=950, height=600, left=0, top=0";
			$M.goNextPage('/comp/comp0710p01', $M.toGetParam(param) , {popupStatus : poppupOption});
		}
		
		//데이터 가져오기
		function goSearch() {
			var param = {
					"s_menu_seq" : ${bean.menu_seq }
			}; 
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						nowPage = 1;
						maxPage = result.max_page;
						seqList = result.list;
						//페이지 로딩
						fnLoadPage(nowPage);
					} else {
						nowPage = 0;
						maxPage = 0;
						$("#upt_sec").text("");
						$("#upt_img").attr("src", "/static/img/no-image.png" );
						$("#upt_img").attr("width", "100%");
						$(".attachfile-item").show();
						fnSetPageNumber(nowPage);
					}
				}
			);
		}
		
		//페이지 로딩
		function fnLoadPage(nowPage) {
			//등록시간 세팅
			var uptSec = seqList[nowPage-1].reg_date;
			$("#upt_sec").text("※ 등록시간:"+uptSec);
			//일주일 이내 등록한 사진은 빨간글씨
			var date = new Date(uptSec);
			date.setDate(date.getDate() + 7);
			if(new Date() <= date) {
				$("#upt_sec").addClass("text-warning");
			} else {
				$("#upt_sec").removeClass("text-warning");
			}
			
			//이미지 세팅
			var fileSeq = "/file/" + seqList[nowPage-1].file_seq;
			$("#upt_img").attr("src", fileSeq );
			$(".attachfile-item").show();

			//이미지 로딩
			if(fileSeq > 0 ){
				$M.goNextPageAjax(fileSeq, '', {method : "GET"},
					function(result){
						if(result.success) {
							if(result.file_exists_yn == 'Y') {
								fnExistsFileSelect(result);
							} else {
								alert('파일이 없습니다.');
							}
						}
					});
			}
			
			//페이지 번호 설정 및 이전&다음 버튼 show
			fnSetPageNumber(nowPage);
		}
		
		//페이지 번호 설정 및 이전&다음 버튼 show
		function fnSetPageNumber(nowPage) {
			//페이지 쪽수 설정
			document.getElementById('nowPage').innerHTML=nowPage;
			document.getElementById('maxPage').innerHTML=maxPage;
			
			//이전 버튼 show
			if(nowPage > 1) {
				document.getElementById('before_button').classList.remove('invisible');
			} else {
				document.getElementById('before_button').classList.add('invisible');
			}
			
			//다음 버튼 show
			if(nowPage < maxPage ) {
				document.getElementById('next_button').classList.remove('invisible');
			} else {
				document.getElementById('next_button').classList.add('invisible');
			}
		}
		
		//이미지 상세보기
		function fnLayerImage() {
			var fileSeq = seqList[nowPage-1].file_seq;
			var params = {
					file_seq : fileSeq
			};
			var popupOption = "";
			$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
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
                <h4 class="primary">도움말 (${bean.menu_name })</h4>	
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
            </div>
            <div id="upt_sec" name="upt_sec" align=right style="padding-right: 25px; padding-top: 5px;"  class="text-warning"></div>	
            <div class="help-imgcon">
                <img id="upt_img" name="upt_img" onclick="javascript:fnLayerImage()">
            </div>
<!-- /폼테이블 -->
<!-- 이전, 다음 버튼 모두 있을 경우 -->
			<center>
				<div class="btn-group mt10 info-docpagination-wrap" style="width: 760px; align: center;">
					<button type="button" id="before_button" class="btn btn-md btn-info invisible" onclick="javascript:fnLoadPage(--nowPage)"><i class="material-iconschevron_left text-light"></i>이전</button>
	                <div class="info-docpagination">
	                    <span class="current" id="nowPage"></span>
	                    <span>/</span>
	                    <span id="maxPage"></span>
	                </div>
	                <button type="button" id="next_button" class="btn btn-md btn-info invisible" onclick="javascript:fnLoadPage(++nowPage)">다음<i class="material-iconschevron_right text-light"></i></button>
				</div>
			</center>
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