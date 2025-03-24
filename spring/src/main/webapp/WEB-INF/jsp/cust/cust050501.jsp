<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 뉴스 > 뉴스 등록
-- 작성자 : 정선경
-- 최초 작성일 : 2023-08-02 17:44:51
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/SmartEditor/js/HuskyEZCreator.js" charset="utf-8"></script>
	<script type="text/javascript">
		var videoIndex = 0;

		$(document).ready(function () {

		});

		// 미리보기
		function fnPreview() {
			if (fnCheckValid() == false) {
				return false;
			}

			// 추가이미지
			var fileSeqArr = [];
			$("#main_form [name=file_seq]").each(function () {
				fileSeqArr.push($(this).val());
			});

			// 유튜브주소
			var videoUrlArr = [];
			$("#main_form [name=video]").each(function () {
				if ($(this).find("input[name=show_yn]").is(":checked")) {
					var encUrl = encodeURIComponent($(this).find("input[name=video_url]").val());
					if (encUrl != "") {
						videoUrlArr.push(encUrl);
					}
				}
			});

			var param = {
				"title" : $M.getValue("title"),
				"reg_dt" : $M.getValue("reg_dt"),
				"img_file_seq" : $M.getValue("img_file_seq"),
				"file_seq_str" : $M.getArrStr(fileSeqArr),
				"video_url_str" : $M.getArrStr(videoUrlArr),
				"content" : encodeURIComponent($M.getValue("content"))
			}

			$M.goNextPage("/cust/cust0505p02", $M.toGetParam(param), {popupStatus: "", method: "post"});
		}

		// 저장
		function goSave() {
			var frm = document.main_form;
			if (fnCheckValid() == false) {
				return false;
			}

			// 추가이미지
			var fileSeqArr = [];
			$("#main_form [name=file_seq]").each(function () {
				fileSeqArr.push($(this).val());
			});

			// 유튜브주소
			var videoUrlArr = [];
			var showYnArr = [];
			var videoShowCheck = false;
			$("#main_form [name=video]").each(function () {
				var url = $(this).find("input[name=video_url]").val();
				if (url != "") {
					videoUrlArr.push(url);
					if ($(this).find("input[name=show_yn]").is(":checked")) {
						showYnArr.push("Y");
					} else {
						showYnArr.push("N");
						videoShowCheck = true;
					}
				}
			});

			var param = {
				"title" : $M.getValue(frm, "title"),
				"main_yn" : $M.getValue(frm, "main_yn"),
				"img_file_seq" : $M.getValue(frm, "img_file_seq"),
				"file_seq_str" : $M.getArrStr(fileSeqArr, {"sep": "^"}),
				"video_url_str" : $M.getArrStr(videoUrlArr, {"sep": "^"}),
				"show_yn_str" : $M.getArrStr(showYnArr, {"sep": "^"}),
				"content" : $M.getValue("content")
			}

			var msg = "저장하시겠습니까?";
			if (videoShowCheck) {
				msg = "전시 체크하지 않은 유튜브주소가 있습니다. 저장하시겠습니까?";
			}

			if (!confirm(msg)) {
				return false;
			}
			$M.goNextPageAjax(this_page + '/save', $M.toForm(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							$M.goNextPage("/cust/cust0505");
						}
					}
			);
		}

		// 필수체크
		function fnCheckValid() {
			// 내용 input으로 등록
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
			$M.setValue("content", $M.getValue("ir1"));

			var frm = document.main_form;
			if($("#main_form input[name='img_file_seq']").size() < 1) {
				alert("대표이미지를 등록해주세요.");
				return false;
			}
			if($M.validation(frm) == false) {
				return false;
			}
			if($M.getValue("content").trim() == "") {
				alert("내용은 필수입력입니다.");
				return false;
			}
			return true;
		}

		// 목록
		function fnList() {
			history.back();
		}

		// 이미지 파일첨부팝업 (대표이미지: Rep, 추가이미지: Add)
		function goFileUploadPopup(gubun) {
			var frm = document.main_form;
			// 대표이미지 1개만 첨부 가능
			if (gubun == "Rep") {
				if($("#main_form input[name='img_file_seq']").size() >= 1 && $M.getValue(frm, "img_file_seq") != "0" && $M.getValue(frm, "img_file_seq") != "") {
					alert("대표이미지는 1개만 첨부하실 수 있습니다.");
					return false;
				}
			}

			var param = {
				upload_type : 'NEWS',
				file_type : 'img',
				max_width : '476',
				max_height : '330',
				pixel_resize_yn : 'Y'
			}

			var callBackFuncName = "fnPrintFile" + gubun;
			openFileUploadPanel(callBackFuncName, $M.toGetParam(param));
		}

		// 대표이미지 파일세팅
		function fnPrintFileRep(file) {
			var str = '';
			str += '<div class="table-attfile-item submit_rep_' + file.file_seq + '">';
			str += '	<a href="javascript:fileDownload(' + file.file_seq + ');" style="color: blue;">' + file.file_name + '</a>&nbsp;';
			str += '	<input type="hidden" name="img_file_seq" value="' + file.file_seq + '"/>';
			str += '	<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'rep\', ' + file.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.submit_rep_div').append(str);
			$("#btn_rep_submit").hide();
		}

		// 추가이미지 파일세팅 (대표이미지: Rep, 추가이미지: Add)
		function fnPrintFileAdd(file) {
			var str = '';
			str += '<div class="table-attfile-item submit_add_' + file.file_seq + '">';
			str += '	<a href="javascript:fileDownload(' + file.file_seq + ');" style="color: blue;">' + file.file_name + '</a>&nbsp;';
			str += '	<input type="hidden" name="file_seq" value="' + file.file_seq + '"/>';
			str += '	<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'add\', ' + file.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.submit_add_div').append(str);
		}

		// 이미지 첨부파일 삭제
		function fnRemoveFile(gubun, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				var removeClassName = '.submit_' + gubun + "_" + fileSeq;
				$(removeClassName).remove();

				if (gubun == "rep") {
					$("#btn_rep_submit").show();
				}
			} else {
				return false;
			}
		}

		// 유튜브주소 추가
		function fnAdd() {
			videoIndex++;
			var appendHtml =  '<div id="video_'+ videoIndex +'" name="video" class="row pt10">'
							+ '	<div class="col-10">'
							+ '		<input type="text" class="form-control" id="video_url_'+ videoIndex +'" name="video_url" alt="영상링크">'
							+ '	</div>'
							+ '	<div class="col-auto">'
							+ '		<label style="line-height: 24px; margin-left: 3px;">'
							+ '			<input type="checkbox" id="show_yn_'+ videoIndex +'" name="show_yn" value="Y">'
							+ '			<label for="show_yn_'+ videoIndex +'">전시</label>'
							+ '		</label>'
							+ '	</div>'
							+ '	<div class="col-1">'
							+ '		<button type="button" class="btn btn-default" onclick="javascript:fnRemove(\''+ videoIndex +'\');"><i class="material-iconsclose text-default"></i>삭제</button>'
							+ '	</div>'
							+ '</div>';
			$("#video").append(appendHtml);
		}

		// 유튜브주소 삭제
		function fnRemove(videoIndex) {
			var removeDivId = "video_" + videoIndex;
			document.getElementById(removeDivId).remove();
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
				<!-- /상세페이지 타이틀 -->
				<div class="contents" style="width:70%;">
					<!-- 폼테이블 -->
					<div>
						<table class="table-border">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">등록일</th>
							<td>
								<div class="input-group">
									<jsp:useBean id="toDay" class="java.util.Date"/>
									<input type="text" class="form-control border-right-0 calDate" id="reg_dt" name="reg_dt" value="<fmt:formatDate value="${toDay}" pattern="yyyy-MM-dd"/>" alt="등록일" disabled>
								</div>
							</td>
							<th class="text-right">작성자</th>
							<td>
								<input type="text" class="form-control width120px" name="reg_mem_name" id="reg_mem_name" value="${SecureUser.user_name}" readonly="readonly">
								<input type="hidden" name="reg_id" id="reg_id" value="${SecureUser.mem_no}" >
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">대표이미지</th>
							<td>
								<div class="table-attfile submit_rep_div">
									<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('Rep')" id="btn_rep_submit">파일찾기</button>
								</div>
							</td>
							<th class="text-right">메인노출여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="main_y" name="main_yn" value="Y" alt="메인노출여부" required="required">
									<label class="form-check-label" for="main_y">Y</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="main_n" name="main_yn" value="N" alt="메인노출여부" required="required" checked="checked">
									<label class="form-check-label" for="main_n">N</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">추가이미지</th>
							<td colspan="3">
								<div class="table-attfile submit_add_div">
									<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('Add')" id="btn_add_submit">파일찾기</button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">유튜브주소</th>
							<td colspan="3">
								<div id="video">
									<div id="video_0" name="video" class="row pt">
										<div class="col-10">
											<input type="text" class="form-control" id="video_url_0" name="video_url" alt="영상링크">
										</div>
										<div class="col-auto">
											<label style="line-height: 24px; margin-left: 3px;">
												<input type="checkbox" id="show_yn_0" name="show_yn" value="Y">
												<label for="show_yn_0">전시</label>
											</label>
										</div>
										<div class="col-1">
											<button type="button" class="btn btn-default" onclick="javascript:fnAdd()"><i class="material-iconsadd text-default"></i>추가</button>
										</div>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">제목</th>
							<td colspan="3">
								<input type="text" class="form-control essential-bg" id="title" name="title" required="required" alt="제목">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">내용</th>
							<td colspan="3" class="v-align-top" style="height: 500px;">
								<textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:450px; display:none;" ></textarea>
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
											fOnBeforeUnload : function(){
												//alert("완료!");
											}
										},
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
							</td>
						</tr>
						</tbody>
					</table>
					</div>
					<!-- /폼테이블 -->
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>