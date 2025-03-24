<%@ page contentType="text/html;charset=utf-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 파일 드래그앤 드랍 팝업
-- 작성자 : 박준영
-- 최초 작성일 : 2020-03-11 17:23:48

-- file_ext_type 여러개 받을 수 있게 수정 pdf#img by 김태훈
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 이미지 확장자
		var imgExt = ['jpg', 'jpeg', 'png', 'gif'];
		// 일반파일 확장자
		// 변경시 아래 첨부 가능 파일 종류 에도 수정바람.
		var etcExt = ['txt', 'ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx', 'hwp', 'pdf', 'mp4', 'mov', 'zip'];

		var etcIcon = {
	   			 'txt' : '/static/img/icon-txt.png',
	   			 'ppt' : '/static/img/icon-ppt.png',
	   			 'pptx' :'/static/img/icon-pptx.png',
	   			 'doc' : '/static/img/icon-doc.png',
	   			 'docx' : '/static/img/icon-docx.png',
	   			 'xls' : '/static/img/icon-xls.png',
	   			 'xlsx' : '/static/img/icon-xlsx.png',
	   			 'hwp' : '/static/img/icon-hwp.png',
	   			 'pdf' : '/static/img/icon-pdf.png',
	   			 'mp4' : '/static/img/icon-mp4.png',
	   			 'mov' : '/static/img/icon-mov.png'
	   	  };

		// 브라우저 체크
		// IE : 익스플로러 , ETC : 기타
		var agent = navigator.userAgent.toLowerCase();
		var browserType = "";

		var fileSeq = ${inputParam.file_seq};

		$(function() {

		   	//드래그 방지
	        $("body").on("dragover drop",function(e){
	            console.log("d"+e);
	            return false;
        	});

			if ((navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1)) {
				browserType = "IE"
			}
			else {
				browserType = "ETC"
				//드래그이벤트는 IE가 아닌 경우만 처리
				$('.img-view4').on("dragover", dragOver).on("dragleave", dragOver).on("drop", uploadFiles);
			}

			fnSetDragTap(browserType);
			$(".attach-delete").removeAttr("position");

			// 파일 존재여부 체크 후 있으면 화면에 보여주기
			// 기존 파일정보를 가져올때는 유형 체크 안함 ( 재업로드 할때만 적용 )

			if(fileSeq > 0 ){

				$M.goNextPageAjax("/file/info/" + fileSeq, '', {method : "GET"},
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

		 });

		//드래그영역문구세팅
		function fnSetDragTap(browserType) {

			var str = '';
			if (browserType == 'IE') {
				str += '<div class="font-14 text-default">파일을 업로드 해주세요!</div>';
				$('#drag_tap').html(str);
			}
			else {

				str += '<i class="icon-drag"></i>';
				str += '<div class="font-14 text-default">마우스로 드래그해서 파일을 추가해 주세요!</div>';
				$('#drag_tap').html(str);

			}

		}

		function dragOver(e){
		    e.stopPropagation();
		    e.preventDefault();
		    if (e.type == "dragover")
		    {
		        $('.drag-comment').css({
		        	"outline":"10px dashed #0c0"
		        });
		    } else {
		        $('.drag-comment').css({
		        	"outline":"0"
		        });
		    }
		}

		// 기존 파일이 있는경우 화면에 보여주기
		function fnExistsFileSelect(fileObj) {

		    // 이미지파일 체크
		    var isImageFile = $M.checkFileType(fileObj.file_ext, imgExt);

		    if(isImageFile) {	// 이미지 파일

					$("#drag_tap").hide();
					$("#upt_img").attr("src", '/file/' + fileObj.file_seq );
					$("#upt_img").attr("width", "100%");
					$(".attachfile-item").show();

					//파일 다운로드 이벤트 추가
					$('#file_info').css("cursor","pointer");
					$('#file_info').removeAttr("onclick");
					$('#file_info').attr("onclick","javascript:fileDownload( '" +fileObj.file_seq + "' );" );


				    // 파일정보 노출
					var fileInfoTxt = fileObj.origin_file_name + ' (' + fileObj.file_size + 'KB)';
					$('#file_info').html(fileInfoTxt);
					$("#file_info").show();


		    } else {	// 일반 파일
		    	// 파일확장자별 아이콘 이미지 나오게 처리
		    	var fileExt = $M.getFileExt(fileObj.origin_file_name).toLowerCase();
		    	var imgIcon = etcIcon[fileExt];

		    	$("#drag_tap").hide();
				$("#upt_img").attr("src", imgIcon);
				$("#upt_img").show();
				$(".attachfile-item").show();

				//파일 다운로드 이벤트 추가
				$('#file_info').css("cursor","pointer");
				$('#file_info').removeAttr("onclick");
				$('#file_info').attr("onclick","javascript:fileDownload( '" +fileObj.file_seq + "' );" );

			    // 파일정보 노출
				var fileInfoTxt = fileObj.origin_file_name + ' (' + fileObj.file_size + 'KB)';
				$('#file_info').html(fileInfoTxt);
				$("#file_info").show();

		    }
		}



		// 드래그해서 파일 선택후 실행됨
		function uploadFiles(e) {
		    e.stopPropagation();
		    e.preventDefault();
		    dragOver(e);

		    e.dataTransfer = e.originalEvent.dataTransfer;
		    var files = e.target.files || e.dataTransfer.files;

		    if(files.length > 1) {
		    	alert("파일은 한개만 업로드 가능합니다.");
		    	return;
		    }

		    var file  = files[0];
		    $("#file_comp").prop("files", files);

		    fnFileSelect($M.getComp('file_comp'));
		    return ;

		}


		// 파일 선택되면 실행
		function fnFileSelect(fileComp) {
			var fileObj = document.getElementById("file_comp").files[0];

		   	var checkExt = '${inputParam.file_type}' == 'img' ? imgExt : '${inputParam.file_type}' == 'etc' ? etcExt : imgExt.concat(etcExt);
		    var fileExtType = '${inputParam.file_ext_type}';

		   	//파일확장자를 지정한 경우
		   	if(fileExtType!= '') {

		   		// 확장자 제한이 이미지 + PDF 2종류만 허용해야되는데 안되서 변경함
		   		var tempExt = fileExtType.toLowerCase();
		   		var extArray = tempExt.split("#");
		   		var fileExt = $M.getFileExt(fileObj.name).toLowerCase();
		   		if(extArray.indexOf(fileExt) == -1) {
		   			if (extArray.indexOf('img') > -1 && imgExt.indexOf(fileExt) > -1) {
		   				console.log("이미지 허용");
		   			} else {
		   				alert( extArray.join(" ") +  "형식 파일만 업로드 가능합니다.");
			   			return;
		   			}
		   		}
			}


		    //확장자 제한 ( 이미지 OR 일반 파일범위)
			if($M.checkFileType(fileObj.name, checkExt) == false) {
				alert('첨부할 수 있는 유효한 파일이 아닙니다.\r\n첨부 가능 확장자 : ' + checkExt);
				return;
			}

		    //용량제한(무조건체크)
		    var maxSize = ${inputParam.max_size};
		    var fileSize = Math.ceil(fileObj.size / 1024);	// kb환산
		    if(maxSize < fileSize) {
		    	alert("파일 용량 제한이 있습니다.\n가능 용량 : " +  maxSize +"KB " +  "\n현재 파일용량 :  " + fileSize + "KB");
	            return;
		    }

		    // 이미지파일 체크
		    var isImageFile = $M.checkFileType(fileObj.name, imgExt);

		    if(isImageFile) {	// 이미지 파일
			    //해상도제한
			    //해상도제한은 반영여부 검토중

			    var _URL = window.URL || window.webkitURL;
			    var imgObj = new Image();
			    imgObj.src = _URL.createObjectURL(fileObj);

			    imgObj.onload = function() {
					var checkImgWidth = ${inputParam.max_width};
					var checkImgHeight = ${inputParam.max_height};
					if("${inputParam.pixel_limit_yn}" == "Y") {
						if(imgObj.width != checkImgWidth || imgObj.height != checkImgHeight) {
				            alert("이미지 해상도 제한이 있습니다.\n가능 사이즈 : 가로 - " + checkImgWidth +"px, 세로 - " + checkImgHeight + "px\n현재 사이즈 : 가로 - " + imgObj.width + "px, 세로 - " + imgObj.height + "px");
				            return;
				        }
					}

					$("#drag_tap").hide();
					$("#upt_img").attr("src", _URL.createObjectURL(fileObj));
					$("#upt_img").attr("width", "100%");
					$(".attachfile-item").show();

				    // 파일정보 노출
					var fileInfoTxt = fileObj.name + ' (' + fileSize + 'KB)';
					$('#file_info').html(fileInfoTxt);
					$("#file_info").show();
					$M.setValue('file_remove_yn','N');

			    }
		    } else {	// 일반 파일
		    	// 파일확장자별 아이콘 이미지 나오게 처리
		    	var fileExt = $M.getFileExt(fileObj.name).toLowerCase();
		    	var imgIcon = etcIcon[fileExt];

		    	$("#drag_tap").hide();
				$("#upt_img").attr("src", imgIcon);
				$("#upt_img").show();
				$(".attachfile-item").show();

			    // 파일정보 노출
				var fileInfoTxt = fileObj.name + ' (' + fileSize + 'KB)';
				$('#file_info').html(fileInfoTxt);
				$("#file_info").show();
				$M.setValue('file_remove_yn','N');
		    }
		}

		// 파일저장
		function goApply() {

			//기존 파일 조회건인 경우
			if ( $M.getValue('prev_file_seq') > 0 ){

				//파일 삭제 적용시
				if ($M.getValue('file_remove_yn') == 'Y' ){

					if(confirm("삭제하시겠습니까?")) {

						//부모창에 file_seq만 0으로 넘겨주기
						var param = {
								"result_code": "200",
								"result_msg": "정상 처리되었습니다.",
								"file_seq": 0
						}

						opener.${inputParam.parent_js_name}(param);
		    			window.close();
		    			return;
					}
					else{
						return;
					}
				}
				else{
					//파일을 변경하지 않고 저장하는 경우
					if ( $M.getValue('file_comp') == '') {
						alert("파일 변경 후 저장해주세요.");
						return;
					}
				}
			}
			else{
				if ( $M.getValue('file_comp') == '') {
					alert("파일을 등록해주세요.");
					return;
				}
			}

			$M.goNextPageAjaxMsg('파일을 등록하시겠습니까?', '/file/upload', document.main_form, {method : 'post'},
				function(result) {
					if(result.success) {
						try {
							result["upt_img"] = $("#upt_img").attr('src');
			    			opener.${inputParam.parent_js_name}(result);
			    			window.close();
			    		} catch(e) {
							alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
						}
					}
			});
			return;
		}

		//이미지 삭제하기
		function imgDel() {

			//input file 초기화
			if (browserType == 'IE') {
				$("#file_comp").replaceWith( $("#file_comp").clone(true) );
			}
			else {
				$("#file_comp").val("");

			}

			$M.setValue('file_remove_yn','Y');
			$("#drag_tap").show();
			$('#file_info').html("");
			$(".attachfile-item").hide();

		}

		function fnClose() {
			window.close();
		}

		function goSearchFile() {
			$("#file_comp").click();
		}

	</script>

</head>

<body  class="bg-white class" >
	<form id="main_form" name="main_form" enctype="multipart/form-data" >
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
	        <div class="main-title">
	            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
			<!-- /타이틀영역 -->
	        <div class="content-wrap">
	        	<input type="hidden" id="upload_path" 	name="upload_path" value="${inputParam.upload_path}" >
				<div class="checklist-comment">
<%--					<c:if test="${inputParam.file_type ne 'etc' and inputParam.file_ext_type eq '' }">${inputParam.pixel_limit_yn eq 'Y' ? '제한' : '권장' } 이미지 사이즈 : 가로 - ${inputParam.max_width }px, 세로 - ${inputParam.max_height}px</c:if>--%>
					<c:if test="${inputParam.file_type ne 'etc' and inputParam.file_ext_type eq '' }">${inputParam.pixel_limit_yn eq 'Y' ? '제한' : '권장' } 이미지 사이즈 : ${imgSizeComment}</c:if>
					<c:if test="${inputParam.file_type eq 'etc' and inputParam.file_ext_type eq '' }">첨부가능파일 : txt, ppt, pptx, doc, docx, xls, xlsx, hwp, pdf</c:if>
					<c:if test="${inputParam.file_ext_type ne '' }">첨부가능파일 : ${fn:join(fn:split(inputParam.file_ext_type, '#'), ', ')}</c:if>
					<br>파일 최대 사이즈 : <fmt:formatNumber value="${inputParam.max_size }"/>KB
				</div>
				<div class="img-view4">
					<div class="drag-comment" >

						<div id="drag_tap">
						</div>
						<div class="attachfile-item" style="display:none;" >
							<div id="delete_btn" style="position: fixed;right:27px;top: 117px;border-radius: 50%;background: #cc0000;opacity: 0.6;filter: Alpha(opacity=60);z-index:999;">
								<button type="button" class="btn btn-icon-md text-light"  onclick="javascript:imgDel();" ><i class="material-iconsclose"></i></button>
							</div>
							<img id="upt_img" name="upt_img" >
						</div>
					</div>

				</div>
				<div  class="file-name" id="file_info" name="file_info" style="height:20px;" ></div>
				<div class="btn-group mt10">
					<div class="left col-2">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
					</div>
					<div class="right">
						이미지 리사이징
						<select class="form-control width100px" id="img_resize_check" name="img_resize_check" style="display: inline">
							<option value="0">미적용(원본)</option>
							<option value="1">권장사이즈</option>
							<option value="2">2배수</option>
							<option value="3">3배수</option>
							<option value="4">4배수</option>
							<option value="5">5배수</option>
							<option value="6">6배수</option>
							<option value="7">7배수</option>
							<option value="8">8배수</option>
							<option value="9">9배수</option>
							<option value="10">10배수</option>
						</select>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	        </div>
	    </div>
	<!-- /팝업 -->
	<input type="file" name="file_comp" id="file_comp" style="display:none;width:5px;" onChange="javascript:fnFileSelect(this);" >
	<input type="hidden" name="upload_type" id="upload_type" value="${inputParam.upload_type }" />
	<input type="hidden" name="prev_file_seq" id="prev_file_seq" value="${inputParam.file_seq }" />
	<input type="hidden" name="file_remove_yn" id="file_remove_yn" value="N"  />
	<input type="hidden" name="img_resize" id="img_resize" value="${inputParam.img_resize}" />
	<input type="hidden" name="open_yn" id="open_yn" value="${inputParam.open_yn}" />
	<input type="hidden" name="pixel_resize_yn" id="pixel_resize_yn" value="${inputParam.pixel_resize_yn}" />
	<input type="hidden" name="max_width" id="max_width" value="${inputParam.max_width}" />
	<input type="hidden" name="max_height" id="max_height" value="${inputParam.max_height}" />
	<input type="hidden" name="kukudocs_upload_yn" id="kukudocs_upload_yn" value="${inputParam.kukudocs_upload_yn}" />
	</form>
</body>
</html>
