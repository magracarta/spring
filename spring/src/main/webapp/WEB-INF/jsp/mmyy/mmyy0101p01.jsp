<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 공지사항 > null > 공지사항상세
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<!-- <script type="text/javascript" src="/static/ckeditor/ckeditor.js"></script> -->
	<script type="text/javascript" src="/SmartEditor/js/HuskyEZCreator.js" charset="utf-8"></script>
	<script type="text/javascript">
		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 5;
		// 댓글 카운트
		var replyCnt;
		// 댓글 index 변수
		var idx;
	
		$(document).ready(function() {
			<c:forEach var="list" items="${list}">fnPrintFile('${list.file_seq}', '${list.file_name}');</c:forEach>
			$("#total_cnt").html(${total_cnt});
			$M.setValue("reply_cnt", ${total_cnt});
			replyCnt = ${total_cnt};
			idx = parseInt($M.getValue("reply_cnt"));
			
			fnInitBtn();
			fnChangeMenuCode();
			goConfirmMemList();
			
			try {
				// 메인에 갱신
				opener.fnCntRenewal();
			} catch (e) {
				opener.parent.fnCntRenewal();
			}
		});
		
		function fnChangeMenuCode() {
			if ($M.getValue("menu_code") == "15") {
				$("#topYnArea").css("display", "inline-block");
			} else {
				$("#topYnArea").css("display", "none");
			}
		}
		
		// 읽은사람/안읽은사람 조회
		function goConfirmMemList() {
			$M.goNextPageAjax(this_page + "/confirm/${inputParam.notice_seq}", '', { method : "GET", loader : false},
				function(result) {
					if(result.success) {
						if (result.confirmList) {
							$("#confirmList").html(result.confirmList.join(' '));
						}
						if (result.notConfirmList) {
							$("#notConfirmList").html(result.notConfirmList.join(' '));
						}
					};
				}
			);
		}
		
		// 작성자 또는 권한자가 아니면 첨부파일 삭제 버튼 숨김, 비활성화 (보류)
		function fnInitBtn() {
// 			var hasAuthYn = ${hasAuthModify};
// 			alert(hasAuthYn);
			if($M.getValue("reg_mem_no") != $M.getValue("user_mem_no") && '${page.fnc.F00582_001}' != 'Y') {
				$(".btn-auth").addClass("dpn");
				$("#_goSearchFile").prop("disabled", true);
				$(".reg-auth").prop("disabled", true);
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			} else {
				$("#_goModify").removeClass("dpn");
				$("#_goRemove").removeClass("dpn");
			}
			
			if('Y' == '${result.top_fix_yn}'){
				$("#_goSave").html("상단표기해제");
			}
		}
		
		// 첨부파일 출력
		function fnPrintFile(fileSeq, fileName) {
			var str = ''; 
			str += '<div class="table-attfile-item file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default btn-auth" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.file_div').append(str);
			fileIndex++;
		}
		
		function goSearchFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=NOTICE&file_type=both&max_size=2048');
		}
		
		function setFileInfo(result) {
			fnPrintFile(result.file_seq, result.file_name);
		}
		
		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".file_" + fileIndex).remove();
				$("#file_seq_" + fileIndex).remove();
// 				$M.setValue("file_seq_" + fileIndex, "");
			} else {
				return false;
			}
		}
		
		// 공지사항 수정
		function goModify() {
			var frm = document.main_form;
			//내용 input으로 등록
			
// 			$M.setValue("content", CKEDITOR.instances.content.getData()); 
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
			$M.setValue("content", $M.getValue("ir1"));
			if($M.getValue("content") == "") {
				alert("내용은 필수입력입니다.");
				return false;
			}
			if($M.validation(frm) == false) { 
				return;
			};
			var idx = 1;
			$("input[name='file_seq']").each(function() {
				var str = 'file_seq_' + idx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			for(; idx <= fileCount; idx++) {
				$M.setValue('file_seq_' + idx, 0);
			}
			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
		    		if(result.success) {
						fnClose();
						if (opener != null && opener.goSearch) {
							opener.goSearch('');
						}
					}
				}
			);
		}
		
		// 공지사항 삭제
		function goRemove() {
			var menuCode = "${inputParam.menu_code}";
			$M.goNextPageAjaxRemove(this_page + "/remove/${inputParam.notice_seq}", '', { method : "POST"},
				function(result) {
					if(result.success) {
						fnClose();
						if (opener != null && opener.goSearch) {
							opener.goSearch('');
						}
					};
				}
			);
		}
		
		// 답변 저장
		function goReplyNew() {
			var frm = document.main_form;
			// 게시글은 required로, 답변은 따로 필수값 체크
			if($M.validation(document.main_form, {field:["r_insert_content"]}) == false) {
				return;
			};
			
			var param = {
					"notice_seq" : $M.getValue("notice_seq"),
					"content" : $M.getValue("r_insert_content"),
			}
			$M.goNextPageAjaxSave(this_page + '/reply/save', $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						var cnt =  idx;
						var reg_date = $M.dateFormat(new Date(result.reg_date), "yyyy-MM-dd HH:mm:ss");
						var str = ''; 
						str += '<div class="comment-item" id="idx_' + cnt + '">';
						str += '<input type="hidden" value="' + result.notice_comment_seq + '" id="notice_comment_seq_' + cnt + '" name="notice_comment_seq_' + cnt + '">';
						str += '<div class="comment-info">';
						str += '<span>' + result.org_name + '</span><span>' + result.reg_mem_name + '</span><span>'+ reg_date + '</span>';
						str += '</div>';
						str += '<div>';
						str += '<div class="comment-text" id="reply-content-modify">';
						str += '<textarea type="text" class="form-control mr5" id="r_content_' + cnt + '" name="r_content_' + cnt + '" style="height: 50px;">' + result.content + '</textarea>';
						str += '</div>';
						str += '<div>';
						str += '<button type="button" class="btn btn-default" id="btn_modify" value="' + cnt + '" onclick="javascript:goReplyModify(value);">수정</button>';
						str += '<button type="button" class="btn btn-default" id="btn_remove" value="' + cnt + '" onclick="javascript:goReplyRemove(value);">삭제</button>';
						str += '<div>';
						$('.comment-body').prepend(str);
						var totalCnt = replyCnt;
						$("#total_cnt").html(totalCnt + 1);
						$M.setValue("r_insert_content", "");
						idx++;
						replyCnt++;
						alert("저장이 완료되었습니다.");
					}
				}
			);
		}
		
		// 댓글 수정
		function goReplyModify(cnt) {
			var frm = document.main_form;
			if($M.validation(document.main_form, {field:["r_content_" + cnt]}) == false) {
				return;
			};
			var param = {
					"notice_seq" : $M.getValue("notice_seq"),
					"content" : $M.getValue("r_content_" + cnt),
					"notice_comment_seq" : $M.getValue("notice_comment_seq_" + cnt),
			}
			console.log(param);
			$M.goNextPageAjaxModify(this_page + '/reply/save', $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
					}
				}
			);
		}
		
		// 댓글 삭제
		function goReplyRemove(cnt) {
			var param = {
					"notice_comment_seq" : $M.getValue("notice_comment_seq_" + cnt)
			}
			console.log(param.notice_comment_seq);
			$M.goNextPageAjaxRemove(this_page + "/" + param.notice_comment_seq, '', { method : "POST"},
				function(result) {
					if(result.success) {
						$("#idx_" + cnt).hide();
						var totalCnt = replyCnt;
						$("#total_cnt").html(totalCnt - 1);
						replyCnt--;
					};
				}
			);
		}
		
		//상단표기등록,해제
		function goSave(){
			var param = {
					"notice_seq" : $M.getValue("notice_seq"),
					"mem_no" : $M.getValue("user_mem_no"),
					"top_fix_yn" : '${result.top_fix_yn}',
			}
			
			var msg = "";
			
			if('N' == '${result.top_fix_yn}'){
				msg = "상단표기저장을 하시겠습니까?";
			}else{
				msg = "상단표기해제를 하시겠습니까?";
			}
			
			$M.goNextPageAjaxMsg(msg, this_page + '/topFix', $M.toGetParam(param), {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			if('N' == '${result.top_fix_yn}'){
			    				$("#_goSave").html("상단표기해제");
			    			}else{
			    				$("#_goSave").html("상단표기저장");
			    			}
			    			
			    			if (opener != null && opener.goSearch) {
								opener.goSearch('');
							}
					}
				}
			);
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="notice_seq" name="notice_seq" value="${inputParam.notice_seq}">
<input type="hidden" id="reply_cnt" name="reply_cnt" value="">
<input type="hidden" id="reg_mem_no" name="reg_mem_no" value="${result.reg_mem_no}">
<input type="hidden" id="user_mem_no" name="user_mem_no" value="${SecureUser.mem_no}">
<input type="hidden" id="user_org_code" name="user_org_code" value="${SecureUser.org_code}">
<input type="hidden" id="file_count" name="file_count" value="">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
<!-- 폼테이블 -->	
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">카테고리구분</th>
							<td>
								<select class="form-control essential-bg width180px reg-auth" id="menu_code" name="menu_code" alt="카테고리구분" required="required" onchange="fnChangeMenuCode()" style="display: inline-block;">
									<option value="">- 선택 -</option>
									<c:forEach var="item" items="${categoryList}">
									<option value="${item.menu_code}" ${item.menu_code == result.menu_code ? 'selected="selected"' : ''}>${item.menu_name}</option>
									</c:forEach>
								</select>
								<div style="display: none;" id="topYnArea">
									<label>
										<input type="checkbox" id="top_yn" name="top_yn" value="Y" ${result.top_yn eq 'Y' ? 'checked' : ''}>
										<span>상단 고정여부</span>
									</label>
								</div>
							</td>
							<th class="text-right">작성자</th>
							<td>
								<input type="text" class="form-control width120px reg-auth" name="reg_mem_name" id="reg_mem_name" value="${result.reg_mem_name}" readonly="readonly">
								<input type="hidden" name="reg_id" id="reg_id" value="${result.reg_mem_no}" >
							</td>					
						</tr>
						<tr>
							<th class="text-right essential-item">마감설정</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control essential-bg border-right-0 calDate reg-auth" id="show_ed_dt" name="show_ed_dt" dateFormat="yyyy-MM-dd"  value="${result.show_ed_dt}" alt="마감일" required="required">
									<label style="line-height: 24px; margin-left: 3px;">
										<input type="checkbox" id="must_read_yn" name="must_read_yn" value="Y" ${result.must_read_yn eq 'Y' ? 'checked' : ''}>
										<span>필독공지여부</span>
									</label>
								</div>
							</td>		
							<th class="text-right">작성일자</th>
							<td>
								<fmt:formatDate value="${result.reg_date}" pattern="yyyy-MM-dd" var="reg_dt"/>
								<input type="text" class="form-control width120px" name="dis_reg_dt" id="dis_reg_dt" value="${reg_dt}" readonly="readonly">
							</td>					
						</tr>
						<tr>
							<th class="text-right essential-item">제목</th>
							<td colspan="3">
								<input type="text" class="form-control essential-bg reg-auth" id="title" name="title" alt="제목" maxlength="2000" required="required" value="${result.title}">
							</td>
						</tr>
						<tr>
							<th class="text-right">첨부파일</th>
							<td colspan="3">
								<div class="table-attfile file_div" style="width:100%;">
									<div class="table-attfile" style="float:left">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
										&nbsp;&nbsp;
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">내용</th>
							<td colspan="3" class="v-align-top" style="height: 200px;">
							<c:choose>
								<c:when test="${SecureUser.mem_no eq result.reg_mem_no || page.fnc.F00582_001 eq 'Y'}">
<!-- 									<textarea name="content" id="content" cols="10" rows="10" style="width:100%;" alt="내용" required="required"> -->
<%-- 											<c:out value="${result.content}" escapeXml="true" /></textarea> --%>
<!-- 									</textarea> -->
										<textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:650px; display:none;" >${result.content}</textarea>
										<script type="text/javascript">
											var oEditors = [];
											nhn.husky.EZCreator.createInIFrame({
												oAppRef: oEditors,
												elPlaceHolder: "ir1",
												sSkinURI: "/SmartEditor/SmartEditor2Skin.html",	
												htParams : {
													bUseToolbar : true,				// 툴바 사용 여부 (true:사용/ false:사용하지 않음)
													bUseVerticalResizer : true,		// 입력창 크기 조절바 사용 여부 (true:사용/ false:사용하지 않음)
													bUseModeChanger : true,			// 모드 탭(Editor | HTML | TEXT) 사용 여부 (true:사용/ false:사용하지 않음)
													//aAdditionalFontList : aAdditionalFontSet,		// 추가 글꼴 목록
													fOnBeforeUnload : function(){
														//alert("완료!");
													}
												}, //boolean
												fOnAppLoad : function(){
													//예제 코드
													//oEditors.getById["ir1"].exec("PASTE_HTML", ["로딩이 완료된 후에 본문에 삽입되는 text입니다."]);
												},
												fCreator: "createSEditor2"
											});
											
											function pasteHTML() {
												var sHTML = "<span style='color:#FF0000;'>이미지도 같은 방식으로 삽입합니다.<\/span>";
												oEditors.getById["ir1"].exec("PASTE_HTML", [sHTML]);
											}

											function showHTML() {
												var sHTML = oEditors.getById["ir1"].getIR();
												alert(sHTML);
											}
												
											function submitContents(elClickedObj) {
												oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
												
												// 에디터의 내용에 대한 값 검증은 이곳에서 document.getElementById("ir1").value를 이용해서 처리하면 됩니다.
												
												try {
													elClickedObj.form.submit();
												} catch(e) {}
											}

											function setDefaultFont() {
												var sDefaultFont = '궁서';
												var nFontSize = 24;
												oEditors.getById["ir1"].setDefaultFont(sDefaultFont, nFontSize);
											}
											
											// 특수문자
											function GetChar(str){
												addChar(str,1);
											}
											function addChar(str,type){
												document.regForm.diaryText.value = document.regForm.diaryText.value + str;
												document.regForm.diaryText.focus();
											}
											function ck(tar){
												if(tar=="1"){
												document.getElementById("table1").style.display = "block";
												} else if(tar=="2"){
												document.getElementById("table1").style.display = "none";
												}
											}
										</script>
								</c:when>
								<c:otherwise>
									${result.content}<br><br>
								</c:otherwise>
							</c:choose>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
			<div class="btn-group mt5">
				<div class="title-wrap left"><h4>미 확인자</h4></div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="MID_R"/>
						<jsp:param name="mem_no" value="${result.reg_mem_no}"/>
					</jsp:include>
				</div>
			</div>
			<div class="mgt5">
				<span id="notConfirmList"></span><!-- 공지 읽지 않은 사람 -->
				<div style="width: 100%; border-top: 1px dashed #bbb; margin-top: 5px; margin-bottom: 5px;"></div>
			</div>
			<div class="title-wrap">
				<h4>확인자</h4>
			</div>
			<div class="mgt5">
				<span id="confirmList"></span> <!-- 공지 읽은 사람 -->
				<div style="width: 100%; border-top: 1px dashed #bbb; margin-top: 5px; margin-bottom: 5px;"></div>
			</div>
<!-- 댓글영역 -->
			<div class="comment-header">				
				<div class="title-comment">
					<i class="material-iconschat text-default"></i>Comment
				</div>
				<div class="comment-input-item">
					<textarea type="text" class="form-control mr5" id="r_insert_content" name="r_insert_content" alt="Comment" style="height: 50px;"></textarea>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
				</div>
			</div>
			<div class="comment-body">
				<c:forEach var="row" items="${replyList}" varStatus="status">
                   <div class="comment-item" id="idx_${status.index}">
                 		<input type="hidden" value="${row.notice_comment_seq}" id="notice_comment_seq_${status.index}" name="notice_comment_seq_${status.index}">
							<div class="comment-info">
								<span>${row.org_name}</span><span>${row.r_reg_mem_name}</span><span><fmt:formatDate value="${row.r_reg_date}" pattern="yyyy-MM-dd HH:mm:ss" var="reg_dt"/>${reg_dt}</span>
							</div>
							<div>
							<c:choose>
								<c:when test="${SecureUser.mem_no eq row.r_reg_mem_no}">
								<div class="comment-text" id="reply-content-modify">
									<textarea type="text" class="form-control mr5" id="r_content_${status.index}" name="r_content_${status.index}" style="height: 50px;">${row.r_content}</textarea>
								</div>
								<div>
									<button type="button" class="btn btn-default" id="btn_modify" value="${status.index}" onclick="javascript:goReplyModify(value);">수정</button>
									<button type="button" class="btn btn-default" id="btn_remove" value="${status.index}" onclick="javascript:goReplyRemove(value);">삭제</button>
								</div>
								</c:when>
								<c:otherwise>
								<div class="comment-text" id="reply-content">
									${row.r_content}
								</div>
								</c:otherwise>
							</c:choose>
							</div>
						</div>
               </c:forEach>
			</div>			
<!-- /댓글영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					
				</div>					
			</div>
        </div>
    </div>
<!-- /팝업 -->
<input type="hidden" id="file_seq_1" name="file_seq_1" value="${result.file_seq_1}"/>
<input type="hidden" id="file_seq_2" name="file_seq_2" value="${result.file_seq_2}"/>
<input type="hidden" id="file_seq_3" name="file_seq_3" value="${result.file_seq_3}"/>
<input type="hidden" id="file_seq_4" name="file_seq_4" value="${result.file_seq_4}"/>
<input type="hidden" id="file_seq_5" name="file_seq_5" value="${result.file_seq_5}"/>
</form>
</body>
</html>