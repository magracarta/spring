<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC OPEN선적 > null > 첨부서류
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>

	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
				
		});
		
		var fileNum = 1;
		
		// 저장
		function goSave() {
			alert("본창이 저장되야 완료됩니다.");
			var param = {};
			for (var i = 1; i <= 5; ++i) {
				param["send_file_seq_"+i] = $M.getValue("send_file_seq_"+i);
			}
			<c:if test="${not empty inputParam.parent_js_name}">
				opener.${inputParam.parent_js_name}(param);
			</c:if>
			window.close();
		}
		
		// 파일첨부팝업
		function goFileUploadPopup(num) {
			var param = {
				upload_type : 'LC',
				file_type : 'both',
				file_ext_type : 'pdf#img',
				max_size : '5000'
			}
			fileNum = num
			openFileUploadPanel('fnSetImage', $M.toGetParam(param));
		}
		
		// 파일세팅
		function fnSetImage(img) {
			
			console.log(img);
			
			var parent = $("#file"+fileNum).parent().parent().parent();
			parent.children('.no-img').remove();
	        parent.children('.upload-display').remove();
	        if (img.file_ext.toLowerCase() == "pdf") {
	        	parent.prepend('<div class="upload-display"><div class="upload-thumb-wrap"><img src="/static/img/icon-pdf.png" onclick="javascript:fileDownload('+img.file_seq+')"></div></div>');
	        } else {
	        	parent.prepend('<div class="upload-display"><div class="upload-thumb-wrap"><img src="/file/'+img.file_seq+'" class="upload-thumb" onclick="fnPreview('+img.file_seq+')"></div></div>');
	        }
			$M.setValue("send_file_seq_"+fileNum, img.file_seq);
			$("#send_file_name_"+fileNum).html(img.file_name);
		}
		
		// 썸네일 확대
		function fnPreview(fileSeq) {
			/* var src = img.src;
			$M.goNextPageLayerImage(src); */
			var params = {
					file_seq : fileSeq
			};
			var popupOption = "";
			$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 닫기
		function fnClose() {
			window.close(); 
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form" enctype="multipart/form-data">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>첨부서류</h2>
            <button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="checklist-comment">
				이미지 해상도는 768(가로) x 1024(세로)에 jpg로 저장하시기 바랍니다.
			</div>
			<div class="filebox preview-image">
			
				<c:forEach var="item" items="${list}" varStatus="status">
					<div class="checklist-item thumb-sm">
						<c:if test="${empty item.send_file_img}">
							<div class="no-img">
								<i class="icon-noimg"></i>
								<div class="no-img-txt">no images</div>
							</div>
						</c:if>
						<c:if test="${not empty item.send_file_img}">
							<div class="upload-display">
								<div class="upload-thumb-wrap">
									<c:if test = "${fn:endsWith(fn:toLowerCase(item.send_file_name_text), '.pdf') == true}">
										<img id="upt_img" name="upt_img" src="/static/img/icon-pdf.png" onclick="javascript:fileDownload(${item.send_file_seq})">
									</c:if>
									<c:if test = "${fn:endsWith(fn:toLowerCase(item.send_file_name_text), '.pdf') == false}">
										<img id="send_file_img_${status.count}" src="/file/${item.send_file_seq}" alt="" onclick="javascript:fnPreview(${item.send_file_seq})">
									</c:if>
								</div>
							</div>
						</c:if>
						<div class="pr flex-1">	
	                        <div class="mb10 att-title">첨부파일${status.count}</div>
	                        <div class="custom-file" onclick="javascript:goFileUploadPopup('${status.count}')">
	                            <input type="text" id="file${status.count}" class="custom-file-input pointer">
	                            <label class="custom-file-label align-bottom" id="send_file_name_${status.count}">${item.send_file_name_text}</label>
	                            <input type="hidden" name="send_file_seq_${status.count}" value="${item.send_file_seq}">
	                        </div>						
						</div>
					</div>
				</c:forEach>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
					<button type="button" id="_goSave" class="btn btn-info" onclick="javascript:goSave();">저장</button>
					<button type="button" id="_fnClose" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
        </div>
    </div>	
</form>
</body>
</html>