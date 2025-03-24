<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 영업 Q&A > null > 영업 Q&A 상세
-- 작성자 : 이강원
-- 최초 작성일 : 2021-04-13 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/SmartEditor/js/HuskyEZCreator.js" charset="utf-8"></script>
	<script type="text/javascript">
		// 첨부파일의 index 변수
		var fileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var fileCount = 5;

		$(document).ready(function(){
			<c:forEach var="file" items="${fileList}">fnPrintFile('${file.file_seq}', '${file.file_name}');</c:forEach>

			// 선택된 답변자 배열
			var replyMemArr = $M.getValue("replyMemStr").split("#");

			// 콤보그리드에 답변자 입력 및 등록된 답변 존재시 비활성화
			$('#bbs_reply_mem_no').combogrid("setValues", replyMemArr);
			if($M.getValue("replyEditable") == "N"){
				$('#bbs_reply_mem_no').combogrid("disable")
			}
		});


		// 게시글 수정
		function goModify() {
			var frm = document.main_form;
			//내용 input으로 등록
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
			$M.setValue("content", $M.getValue("ir1"));
			
			var idx = 1;
			$("input[name='file_seq']").each(function() {// 파일 정보값 지정
				var str = 'bbs_file_seq_' + idx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			
			for(; idx <= fileCount; idx++) {
				$M.setValue('bbs_file_seq_' + idx, 0);
			}
			
			// 모든 frm의 값들을 검사 (존재하지 않는값이 있는지 확인)
			if($M.validation(frm) == false) { 
				return false;
			};
			
			// 답변자가 없는 경우
			if($M.getValue('bbs_reply_mem_no')==""){
				alert("답변자는 필수입력입니다.");
				return false;
			};
			
			// 에디터에서 내용이 없어도 html 태그로 인해 넘어가는 경우 체크
			if($M.getValue('content')=="<p>&nbsp;</p>"){
				alert("내용은 필수입력입니다.");
				return false;
			}
	
			// 답변자 리스트
			// $M.setValue("mem_no_str",$M.getValue('bbs_reply_mem_no')+"#"+$M.getValue("reg_id"));
			$M.setValue("mem_no_str",$M.getValue('bbs_reply_mem_no'));
	
			$M.goNextPageAjaxSave(this_page + '/modify', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
			);
		}
	
		// 게시글 삭제
		function goRemove() {
			$M.goNextPageAjaxRemove(this_page + "/remove/${inputParam.bbs_seq}", '', { method : "POST"},
				function(result) {
					if(result.success) {
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
						fnClose();
					};
				}
			);
		}
		
		// 답변 저장
		function goAnswerSave(){
			if($M.validation(null, {field:["reply_content"]}) == false) {
				return;
			};
			
			param = {
					"content" : $M.getValue("reply_content"),
					"bbs_seq" : $M.getValue("bbs_seq"),
					"mem_no" : $M.getValue("login_mem_no")
			}
			
			$M.goNextPageAjaxSave(this_page + "/reply/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
			);
		}
		
		// 답변 수정
		function goAnswerModify(){
			if($M.validation(null, {field:["reply_content"]}) == false) {
				return;
			};
			
			param = {
					"content" : $M.getValue("reply_content"),
					"bbs_seq" : $M.getValue("bbs_seq"),
					"mem_no" : $M.getValue("login_mem_no")
			}
			
			$M.goNextPageAjaxModify(this_page + "/reply/modify", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
			);
		}
		
		// 답변 삭제
		function goAnswerRemove(){
			param = {
					"bbs_seq" : $M.getValue("bbs_seq"),
					"mem_no" : $M.getValue("login_mem_no")
			}
			
			$M.goNextPageAjaxRemove(this_page + "/reply/remove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						location.reload();
					};
				}
			);
		}
	
		// 댓글 저장 (신규저장)
		function goReplyNew() {
			if($M.validation(null, {field:["comment_content"]}) == false) {
				return;
			};
			var param = {
				"content" : $M.getValue("comment_content"),
				"bbs_seq" : $M.getValue("bbs_seq"),
				"reg_id" : $M.getValue("login_mem_no")
			}
			
			$M.goNextPageAjaxSave(this_page + '/comment/save', $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						var seq_no = result.bbs_comment_seq;
						var reg_date = $M.dateFormat(new Date(result.reg_date), "yyyy-MM-dd HH:mm:ss");
						var str = ''; 
						str += '<div class="comment-item" id="idx_' + seq_no + '">';
						str += '<input type="hidden" value="' + seq_no + '" id="bbs_comment_seq_' + seq_no + '" name="bbs_comment_seq_' + seq_no + '">';
						str += '<div class="comment-info">';
						str += '<span>' + result.org_name + '</span><span>' + result.reg_mem_name + '</span><span>'+ reg_date + '</span>';
						str += '</div>';
						str += '<div>';
						str += '<div class="comment-text" id="reply-content-modify">';
						str += '<textarea type="text" class="form-control mr5" id="r_content_' + seq_no + '" name="r_content_' + seq_no + '" style="height: 50px;">' + result.content + '</textarea>';
						str += '</div>';
						str += '<div>';
						str += '<button type="button" class="btn btn-default" id="btn_modify"' + seq_no + '" value="' + seq_no + '" onclick="javascript:goReplyModify(value);">수정</button>&nbsp;';
						str += '<button type="button" class="btn btn-default" id="btn_remove"' + seq_no + '" value="' + seq_no + '" onclick="javascript:goReplyRemove(value);">삭제</button>';
						str += '<div>';
						$('.comment-body').prepend(str);
						$M.setValue("comment_content", "");
	
						// 코맨트 
						$("#total_cnt").html(parseInt($("#total_cnt").html()) + 1);
						alert("저장이 완료되었습니다.");
					}
				});
		}
	
		// 댓글 수정
		function goReplyModify(seq_no) {
			if($M.validation(null, {field:["r_content_" + seq_no]}) == false) {
				return;
			};
			var param = {
				"content" : $M.getValue("r_content_" + seq_no),
				"bbs_seq" : $M.getValue("bbs_seq"),
				"reg_id" : $M.getValue("login_mem_no"),
				"seq_no" : seq_no,
			}
	
			$M.goNextPageAjaxModify(this_page + "/comment/modify", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {

					}
				}
			);
		}
		
		// 댓글 삭제
		function goReplyRemove(seq_no) {
			var param = {
					"seq_no" : seq_no,
					"bbs_seq" : $M.getValue("bbs_seq"),
			}
			
			$M.goNextPageAjaxRemove(this_page + "/comment/remove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						$("#idx_" + seq_no).hide();
						$("#total_cnt").html(parseInt($("#total_cnt").html()) - 1);
					};
				}
			);
		}
		
		// 첨부파일 버튼 클릭
		function fnAddFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=BBS&file_type=both&max_size=2048');
		}
	
		// 파일 정보
		function setFileInfo(result) {
			fnPrintFile(result.file_seq, result.file_name);
		}
		
		// 첨부파일 출력
		function fnPrintFile(fileSeq, fileName) {
			var str = ''; 
			str += '<div class="table-attfile-item bbs_file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')" ${SecureUser.mem_no eq result.reg_mem_no ? "" : "disabled"}><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.bbs_file_div').append(str);
			fileIndex++;
		}
	
		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".bbs_file_" + fileIndex).remove();
			} else {
				return false;
			}
		}
		
		// 창 종료
		function fnClose(){
			window.close();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="bbs_seq" name="bbs_seq" value="${inputParam.bbs_seq}"> <!-- 게시글 번호 -->
<input type="hidden" id="login_mem_no" name="login_mem_no" value="${SecureUser.mem_no}"> <!-- 로그인한 유저 -->
<input type="hidden" id="replyEditable" name="replyEditable" value="${replyEditable}"> <!-- 답변자 변경 가능여부 (Y:가능, N:불가능) -->
<input type="hidden" id="replyMemStr" name="replyMemStr" value="${result.bbs_reply_mem_str}"> <!-- #으로 묶인 답변자들 mem_no -->
<input type="hidden" id="content" name="content" value="" required="required"/> <!-- content validation 체크용 -->

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
							<col width="130px">
							<col width="">
							<col width="130px">
							<col width="">
							<col width="130px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>	
								<th class="text-right">작성자</th>
								<td>
									<input type="text" class="form-control width120px check-dis" name="reg_mem_name" id="reg_mem_name" value="${result.reg_mem_name}" readonly="readonly">
									<input type="hidden" name="reg_id" id="reg_id" value="${result.reg_mem_no}" >
								</td>
								<th class="text-right">작성일</th>
								<td>
									<fmt:formatDate value="${result.reg_date}" pattern="yyyyMMdd" var="reg_dt"/>
									<input type="text" class="form-control width140px check-dis" name="dis_reg_dt" id="dis_reg_dt" value="${reg_dt}" alt="작성일" dateFormat="yyyy-MM-dd" readonly="readonly">
								</td>
								<th class="text-right essential-item">답변자</th>
								<td>
									<input class="form-control" style="width:190px;" type="text" id="bbs_reply_mem_no" name="bbs_reply_mem_no" easyui="combogrid"
										easyuiname="memNoList" panelwidth="150" idfield="mem_no" textfield="kor_name" multi="Y"/>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">제목</th>
								<td colspan="5">
									<input id="title" name="title" type="text" class="form-control essential-bg check-dis" id="title" name="title" alt="제목" maxlength="2000" required="required" value="${result.title}" ${SecureUser.mem_no eq result.reg_mem_no ? "" : "readonly"}>
								</td>
							</tr>
							<tr>
								<th class="text-right">첨부파일</th>
								<td colspan="3">
									<div class="table-attfile bbs_file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr10 check-dis" name="file_add_btn" id="file_add_btn" onclick="javascript:fnAddFile();" ${SecureUser.mem_no eq result.reg_mem_no ? '' : 'disabled'}>파일찾기</button>
										&nbsp;&nbsp;
										</div>
									</div>
								</td>
								<th class="text-right">상단고정여부</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-9">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="top_yn1" name="top_yn" value="Y" ${result.top_yn == "Y" ? 'checked' : '' } ${page.fnc.F01956_001 eq 'Y' && SecureUser.mem_no ==  result.reg_mem_no  ? '' : 'disabled'}/>
												<label class="form-check-label" for="top_yn1">Y</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="top_yn2" name="top_yn" value="N" ${result.top_yn == "N" ? 'checked' : '' } ${page.fnc.F01956_001 eq 'Y' && SecureUser.mem_no ==  result.reg_mem_no ? '' : 'disabled'}/>
												<label class="form-check-label" for="top_yn2">N</label>
											</div>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">내용</th>
								<td colspan="5" class="v-align-top" style="height: 200px;">
										<c:choose>
									<c:when test="${SecureUser.mem_no eq result.reg_mem_no}">
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
											</script>
									</c:when>
									<c:otherwise>
										${result.content}<br><br>
									</c:otherwise>
									</c:choose>
								</td>
							</tr>
							<tr>
								<!-- 게시글 유저일 경우 출력-->
								<td colspan="6" class="v-align-top writer_edit_bord">
									<div class="btn-group mt10">	
										<div class="btn-group mt5">
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
												<jsp:param name="pos" value="MID_R"/>
												<jsp:param name="mem_no" value="${result.reg_mem_no}"/>
												</jsp:include>
											</div>					
										</div>
									</div>
								</td>
							</tr>
							<!-- 코맨트 -->
							<c:forEach var="row" items="${replyList}" varStatus="status">
								<!-- 데이터 공란인지 확인 -->
								<!-- ${row} -->
								<c:choose>
									<c:when test="${row.reply_yn eq 'Y'}">
										<!--권한이 있는 사람 (본인) -->
										<tr>
											<th class="text-right">
												<strong class="comment-title" id="comment-title">${row.kor_name}</strong>님의 답변
												<c:choose>
													<c:when test="${SecureUser.mem_no eq row.mem_no}">
														<div>
															<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
														</div>
													</c:when>
												</c:choose>
											</th>
											<td colspan="5" class="v-align-top">
												<textarea class="form-control" style="height: 70px;" ${SecureUser.mem_no eq row.mem_no ? "id=\"reply_content\" name=\"reply_content\"" : "disabled"}>${row.content}</textarea>
											</td>
										</tr>
									</c:when>
									<c:when test="${SecureUser.mem_no eq row.mem_no}">
										<tr>
										<!-- 댓글은 활성화 되지 않았는데 본인 -->
											<th class="text-right">
												<strong class="comment-title" id="comment-title">${row.kor_name}</strong>님의 답변
												<div>
													<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
												</div>
											</th>
											<td colspan="5" class="v-align-top">
												<textarea class="form-control" id="reply_content" name="reply_content" style="height: 70px;"></textarea>                            
											</td>
										</tr>
									</c:when>
									<c:otherwise>
										<!-- 글은 있지만 활성화가 되지 않음 -->
									</c:otherwise>
								</c:choose>
							</c:forEach>
						</tbody>
					</table>
				</div>
	<!-- /폼테이블 -->
	<!-- 댓글영역 -->
				<div class="comment-header">
					<div class="title-comment">
						<i class="material-iconschat text-default"></i>Comment
					</div>
					<div class="comment-input-item">
						<textarea type="text" class="form-control mr5" id="comment_content" name="comment_content" alt="Comment" style="height: 50px;"></textarea>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
					</div>
				</div>
				<div class="comment-body">
					<c:forEach var="row" items="${commentList}" varStatus="status">
						<div class="comment-item" id="idx_${row.seq_no}">
								<input type="hidden" value="${row.seq_no}" id="bbs_comment_seq_${row.seq_no}" name="bbs_comment_seq_${row.seq_no}">
								<div class="comment-info">
									<span>${row.org_name}</span><span>${row.reg_mem_name}</span><span><fmt:formatDate value="${row.reg_date}" pattern="yyyy-MM-dd HH:mm:ss" var="reg_date"/>${reg_date}</span>
								</div>
								<div>
								<c:choose>
									<c:when test="${SecureUser.mem_no eq row.reg_mem_no}">
									<div class="comment-text" id="reply-content-modify">
										<textarea type="text" class="form-control mr5" id="r_content_${row.seq_no}" name="r_content_${row.seq_no}" style="height: 50px;">${row.content}</textarea>
									</div>
									<div>
										<button type="button" class="btn btn-default" id="btn_modify" value="${row.seq_no}" onclick="javascript:goReplyModify(value);">수정</button>
										<button type="button" class="btn btn-default" id="btn_remove" value="${row.seq_no}" onclick="javascript:goReplyRemove(value);">삭제</button>
									</div>
									</c:when>
									<c:otherwise>
									<div class="comment-text" id="reply-content">
										${row.content}
									</div>
									</c:otherwise>
								</c:choose>
							</div>
						</div>
					</c:forEach>
				</div>
	<!-- /댓글영역 -->
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${fn:length(commentList)}</strong>건
				</div>	
				<div class="btn-group mt5">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>					
				</div>
			</div>
	</div>
<!-- /팝업 -->
<input type="hidden" id="bbs_file_seq_1" name="bbs_file_seq_1" value="${result.bbs_file_seq_1 }"/>
<input type="hidden" id="bbs_file_seq_2" name="bbs_file_seq_2" value="${result.bbs_file_seq_2 }"/>
<input type="hidden" id="bbs_file_seq_3" name="bbs_file_seq_3" value="${result.bbs_file_seq_3 }"/>
<input type="hidden" id="bbs_file_seq_4" name="bbs_file_seq_4" value="${result.bbs_file_seq_4 }"/>
<input type="hidden" id="bbs_file_seq_5" name="bbs_file_seq_5" value="${result.bbs_file_seq_5 }"/>
</form>
</body>
</html>