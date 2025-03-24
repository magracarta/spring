<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무팝업 > 공통업무팝업 > null > 정기검사 유효기간 안내
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-03-25 17:10:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		// file_seq 파일일련번호
		var fileSeq;
		var fileUrl;
		
		$(function() {
			
		   	//드래그 방지
	        $("body").on("dragover drop",function(e){
	            console.log("d"+e);
	            return false;
        	});		
		   	
			fnInit();
		});
		
		function fnInit() {
			
			fileUrl = "${list.file_url}";
			fileSeq = "${list.file_seq}";
			
			if (fileUrl == null ||fileUrl == ""  ) {
				$(".photo-wrap").hide();	
				$(".drag-comment").show();
			} else {
				
				$("#image_area").attr("src", fileUrl);
				$("#image_area").attr("alt", '정기검사 유효기간 안내');
				$(".photo-wrap").show();	
				$(".drag-comment").hide();
			}
		}

		
		// 파일찾기 팝업
		function goSearchFile() {
			var param = {
				upload_type	: 'MACHINE',
				file_type : 'img',
				max_width : 768,
				max_height : 1024,
				max_size : 1000
			};
			openFileUploadPanel("fnSetImage", $M.toGetParam(param));
		}
	
		// 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result != null && result.file_seq != null) {

				fileSeq = result.file_seq;
				// 이미지 그려주기 작업
				$("#image_area").attr("src", '/file/'+fileSeq);
				$("#image_area").attr("alt", '정기검사 유효기간 안내');
				$(".photo-wrap").show();	
				$(".drag-comment").hide();
				
			}
		}
		
		//이미지 삭제하기
		function imgDel() {			
			
			$("#image_area").attr("src", "");
			$("#image_area").attr("alt", "");
			$(".drag-comment").show();	
			$('.photo-wrap').hide();	
			
			fileSeq = "";
			fileUrl = "";
		}
			
		// 저장
		function goSave() {

			if ( fileSeq == "" || fileSeq == null ) {
				alert("이미지를 등록해 주세요.");
				return;
			}
			
			var param = {
				"group_code" : "PROP",						//고정값
				"code" : 'MACHINE_INSPEC_IMG_SEQ',			//고정값
				"code_name" : '정기검사이미지파일번호',			//고정값
				"code_v1" : fileSeq,						//파일일련번호를 code_v1에 입력
				"use_yn":"Y"
			}
			
			$M.goNextPageAjaxSave(this_page+"/save", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			//저장후 페이지 새로고침
		    			history.go(0);
					}
				}
			);

		}
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body  class="bg-white class" >
<form id="main_form" name="main_form">
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
	        <div class="main-title">
	            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
			<!-- /타이틀영역 -->
	        <div class="content-wrap">
				<!-- 이미지영역 -->			
				<div class="img-view5">
					<div class="drag-comment">
						<div class="font-16 text-default">파일찾기를 통해 이미지를 등록해주세요</div>
						<div class="text-warning">
							이미지 해상도는 768px(가로) x 1024px(세로)로 저장하시기 바랍니다.
						</div>
					</div>				
					<div class="photo-wrap" style="display:none">
						<div class="photo-delete">
							<button type="button" class="btn btn-icon-lg text-light"   onclick="javascript:imgDel();">
								<i class="material-iconsclose"></i>
							</button>
						</div>
						<img src="" alt=""  id="image_area" name="image_area"  style="width:100%;" >	
					</div>

				</div>			
				<!-- /이미지영역 -->			
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

</form>
</body>
</html>