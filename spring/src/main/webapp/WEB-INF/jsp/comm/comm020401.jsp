<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무 > 전산 Q&A > 문의하기 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-03-16 10:48:19
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
	
		$(document).ready(function() {
			// 에디터 내용 초기화
// 			CKEDITOR.instances.content.setData(
// 				'<p><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">## 문의 사항을 작성할 때 아래 예문을 보고 형식에 맞춰서 작성해 주시기 바랍니다. ##</span><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">## 필요시 사진을 첨부 하시기 바랍니다. ##</span><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">[문제발생 메뉴]</span><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">[참고정보]</span><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">[문제 발생 내용]</span><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">[요청사항]</span><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><br style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;">[긴급도]</span>'
// 			);
		});
	
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
		
		function goSave() {
			var frm = document.main_form;
			//내용 input으로 등록
// 			$M.setValue("content", CKEDITOR.instances.content.getData());
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
 			$M.setValue("content", $M.getValue("ir1"));

			if($M.validation(frm) == false) {
				return false;
			}

			if (confirm("저장하시겠습니까?") === false) {
				return false;
			}

			var idx = 1;
			$("input[name='file_seq']").each(function() {
				var str = 'bbs_file_seq_' + idx
				if ($(this).attr("id") == undefined || $(this).attr("id") == '') {
					$M.setValue(str, $(this).val());
				}
				idx++;
			});
			for(; idx <= fileCount; idx++) {
				$M.setValue('bbs_file_seq_' + idx, ''); 
			}

			$M.setValue('tag_cd_str', $M.getValue('arr_tag_cd'));
 			$M.goNextPageAjax(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						$M.goNextPage("/comm/comm0204");
					}
				}
			);
		}
		
		function fnList() {
			history.back();
		}
		
		// 작성자 변경
		function setRegMemNo(result) {
			$M.setValue("reg_mem_no", result.mem_no);
		}
		
		// 작성자 변경 취소
		function setRegMemNoRollback() {
			$M.setValue("reg_mem_no", "${SecureUser.mem_no}");
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
									<th class="text-right">부서</th>
									<td>
										<input type="text" class="form-control width140px" name="org_name" id="org_name" value="${SecureUser.org_name}" readonly="readonly" alt="부서명">
										<input type="hidden" name="org_code" id="org_code" value="${SecureUser.org_code}" >
									</td>
									<th class="text-right">고객담당자</th>
									<td>
										<div class="form-row inline-pd" >
											<div class="col-3" >
												<input type="text" class="form-control width120px" name="reg_mem_name" id="reg_mem_name" value="${SecureUser.user_name}" readonly="readonly" >
												<input type="hidden" name="reg_mem_no" id="reg_mem_no" value="${SecureUser.mem_no}" >
											</div>
											<c:if test="${page.fnc.F00490_001 eq 'Y'}">
				                                <div class="col-9" >
				                                    <jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
				                                        <jsp:param name="required_field" value=""/>
				                                        <jsp:param name="s_org_code" value=""/>
				                                        <jsp:param name="s_work_status_cd" value=""/>
				                                        <jsp:param name="readonly_field" value=""/>
				                                        <jsp:param name="execFuncName" value="setRegMemNo"/>
				                                        <jsp:param name="focusInFuncName" value="setRegMemNoRollback"/>
				                                    </jsp:include>
				                                </div>
				                           </c:if>
			                            </div>
									</td>
									<th class="text-right">작성일</th>
									<td>
										<input type="text" class="form-control width120px" name="dis_reg_dt" id="dis_reg_dt" value="${inputParam.s_current_dt}" dateFormat="yyyy-MM-dd" readonly="readonly" style="display: inline;">
										${SecureUser.kor_name}
									</td>							
								</tr>
								<tr>
									<th class="text-right">상태</th>
									<td>
										<input type="text" class="form-control width120px" value="요청" readonly>
										<input type="hidden" name="bbs_proc_cd" id="bbs_proc_cd" value="R" >
									</td>	
									<th class="text-right essential-item">메뉴구분</th>
									<td>
										<select class="form-control essential-bg width140px" id="bbs_cate_cd" name="bbs_cate_cd" alt="구분" required="required">
											<option value="">- 선택 -</option>
											<c:forEach var="item" items="${codeMap['BBS_CATE']}">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th class="text-right essential-item">완료요청일</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 essential-bg width120px calDate" id="reser_comp_dt" name="reser_comp_dt" dateformat="yyyy-MM-dd" alt="완료예정일" required="required">
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">제목</th>
									<td colspan="3">
										<input type="text" class="form-control essential-bg" id="title" name="title" alt="제목" maxlength="2000" required="required">
									</td>
									<th class="text-right">태그</th>
									<td>
										<input class="form-control" style="width: 99%;" type="text" id="arr_tag_cd" name="arr_tag_cd" easyui="combogrid" required
											   easyuiname="tagList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">내용</th>
									<td colspan="5" class="v-align-top" style="height: 500px;">
<!-- 										<textarea name="content" id="content" cols="10" rows="10" style="width:100%;height:555px" alt="내용" required="required"></textarea> -->
										<textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:650px; display:none;" ></textarea>
<!-- 										<textarea name="content" id="content" alt="내용" required="required" style="width:100%;height:555px"/> -->
										<script type="text/javascript">
											
// 											CKEDITOR.replace( 'content',{
// 												language : "ko",
// 												enterMode :  CKEDITOR.ENTER_BR,
// 												toolbar : [['Bold','Italic','Underline','Strike','-','Subscript','Superscript','-','TextColor','BGColor','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','Link','Unlink','-','Find','Replace','SelectAll','RemoveFormat','-','Flash','Table','SpecialChar']],
// 												width: "100%",
// 												height: "500"
// 											});

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
									</td>
								</tr>
								<tr>
									<th class="text-right">첨부파일</th>
									<td colspan="5">
										<div class="table-attfile bbs_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
											&nbsp;&nbsp;
											</div>
										</div>
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
</form>	
</body>
</html>