<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 공지사항 > 공지사항 상세
-- 작성자 : 정선경
-- 최초 작성일 : 2023-08-02 18:10:28
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/SmartEditor/js/HuskyEZCreator.js" charset="utf-8"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			if (${remove_yn eq "Y"}) {
				$("#_goRemove").show();
			} else {
				$("#_goRemove").hide();
			}
		});

		// 수정
		function goModify() {
			// 내용 input으로 등록
			oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
			$M.setValue("content", $M.getValue("ir1"));

			// 필수체크
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return false;
			}
			if($M.getValue("content").trim() == "") {
				alert("내용은 필수입력입니다.");
				return false;
			}

			// 수정
			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
							if (window.opener.goSearch) {
								window.opener.goSearch();
							}
						}
					}
			);
		}

		// 공지사항 삭제
		function goRemove() {
			var frm = document.main_form;
			$M.goNextPageAjaxRemove(this_page + "/remove/" + $M.getValue(frm, "c_notice_seq"), '', { method : "POST"},
					function(result) {
						if(result.success) {
							fnClose();
							if (window.opener.goSearch) {
								window.opener.goSearch();
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
	<input type="hidden" name="c_notice_seq" id="c_notice_seq" value="${result.c_notice_seq}" >
	<!-- 팝업 -->
    <div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
		<!-- /타이틀영역 -->
		<!-- contents 전체 영역 -->
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
							<th class="text-right">등록일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate" id="reg_dt" name="reg_dt" value="<fmt:formatDate value="${result.reg_date}" pattern="yyyy-MM-dd"/>" alt="등록일" disabled>
								</div>
							</td>
							<th class="text-right">작성자</th>
							<td>
								<input type="text" class="form-control width120px" name="reg_mem_name" id="reg_mem_name" value="${result.reg_mem_name}" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">필독여부</th>
							<td colspan="3">
								<label style="line-height: 24px;">
									<input type="checkbox" id="must_read_yn" name="must_read_yn" value="Y" <c:if test="${result.must_read_yn eq 'Y'}">checked="checked"</c:if>>
									<span>필독</span>
								</label>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">제목</th>
							<td colspan="3">
								<input type="text" class="form-control essential-bg reg-auth" id="title" name="title" alt="제목" maxlength="100" required="required" value="${result.title}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">내용</th>
							<td colspan="3" class="v-align-top" style="height: 550px;">
								<textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:500px; display:none;" >${result.content}</textarea>
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
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
    	</div>
		<!-- /contents 전체 영역 -->
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>