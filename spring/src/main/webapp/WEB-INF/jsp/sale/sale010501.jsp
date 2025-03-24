<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 영업 Q&A > 영업 Q&A 등록
-- 작성자 : 류성진
-- 최초 작성일 : 2021-04-13 14:50:42
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

		function fnAddFile(){
			if($("input[name='file_seq']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=BBS&file_type=both&max_size=2048');
		}
		
		function setFileInfo(result) {
			var str = ''; 
			str += '<div class="table-attfile-item bbs_file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
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

		// 게시글 저장
		function goSave() {
			var frm = document.main_form;
			//내용 input으로 등록
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
 			$M.setValue("content", $M.getValue("ir1"));
			var idx = 1;
			$("input[name='file_seq']").each(function() {
				var str = 'bbs_file_seq_' + idx;
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			for(; idx <= fileCount; idx++) {
				$M.setValue('bbs_file_seq_' + idx, ''); 
			}
			if($M.validation(frm) == false) { 
				return false;
			};
			if($M.getValue('bbs_reply_mem_no')==""){
				alert("답변자는 필수입력입니다.");
				return false;
			};
			// 에디터에서 공백이 <p>&nbsp;</p>로 저장되기 때문에 해당 문자열로 validation 체크
			if($M.getValue('content')=="<p>&nbsp;</p>"){
				alert("내용은 필수입력입니다.");
				return false;
			}
			// 답변자 리스트
			// $M.setValue("mem_no_str", $M.getValue("bbs_reply_mem_no")+"#"+$M.getValue("reg_id"));
			$M.setValue("mem_no_str", $M.getValue("bbs_reply_mem_no"));
 			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						$M.goNextPage("/sale/sale0105");
					}
				}
			);
		}
		
		function fnList() {
			$M.goNextPage("/sale/sale0105");
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="bbs_proc_cd" id="bbs_proc_cd" value="R" >
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
				<div class="contents" style="width:80%;">
<!-- 폼테이블 -->	
					<div>
						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">작성자</th>
									<td>
										<input type="text" class="form-control width120px" name="reg_mem_name" id="reg_mem_name" value="${SecureUser.user_name}" readonly="readonly">
										<input type="hidden" name="reg_id" id="reg_id" value="${SecureUser.mem_no}" >
									</td>
									<th class="text-right">작성일</th>
									<td>
										<input type="text" class="form-control width120px" name="dis_reg_dt" id="dis_reg_dt" value="${inputParam.s_current_dt}" dateFormat="yyyy-MM-dd" readonly="readonly">
									</td>
									<th class="text-right essential-item">답변자</th>
									<td>
									<input class="form-control" style="width:240px;" type="text" id="bbs_reply_mem_no" name="bbs_reply_mem_no" easyui="combogrid"
								   		easyuiname="memNoList" panelwidth="150" idfield="mem_no" textfield="kor_name" multi="Y"/>	
							</td>
								</tr>
								<tr>
									<th class="text-right essential-item">제목</th>
									<td colspan="5">
										<input type="text" class="form-control essential-bg" id="title" name="title" alt="제목" maxlength="2000" required="required">
									</td>
								</tr>
								<tr>
									<th class="text-right">첨부파일</th>
									<td colspan="3">
										<div class="table-attfile bbs_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
											&nbsp;&nbsp;
											</div>
										</div>
									</td>
									<th class="text-right">상단고정여부</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-9">
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" id="top_yn1" name="top_yn" value="Y" ${page.fnc.F01955_001 eq 'Y' ? '' : 'disabled'}/>
													<label class="form-check-label" for="top_yn1">Y</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" id="top_yn2" name="top_yn" value="N" ${page.fnc.F01955_001 eq 'Y' ? '' : 'disabled'} checked />
													<label class="form-check-label" for="top_yn2">N</label>
												</div>
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">내용</th>
									<td colspan="5" class="v-align-top" style="height: 500px;">
										<textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:650px; display:none;" ></textarea>
										<script type="text/javascript">
											
											var oEditors = [];
											// 추가 글꼴 목록
											//var aAdditionalFontSet = [["MS UI Gothic", "MS UI Gothic"], ["Comic Sans MS", "Comic Sans MS"],["TEST","TEST"]];
											
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
<input type="hidden" id="bbs_file_seq_1" name="bbs_file_seq_1" value=""/>
<input type="hidden" id="bbs_file_seq_2" name="bbs_file_seq_2" value=""/>
<input type="hidden" id="bbs_file_seq_3" name="bbs_file_seq_3" value=""/>
<input type="hidden" id="bbs_file_seq_4" name="bbs_file_seq_4" value=""/>
<input type="hidden" id="bbs_file_seq_5" name="bbs_file_seq_5" value=""/>
<input type="hidden" id="content" name="content" value=""/>
</form>	
</body>
</html>