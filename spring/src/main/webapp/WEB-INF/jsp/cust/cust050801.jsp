<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 자주 하는 질문 > 등록
-- 작성자 : 한승우
-- 최초 작성일 : 2023-07-20 09:12:59
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript" src="/static/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="/SmartEditor/js/HuskyEZCreator.js" charset="utf-8"></script>
    <script type="text/javascript">

        $(document).ready(function() {
            // 에디터 내용 초기화
// 			CKEDITOR.instances.content.setData(
// 				'<p><span style="color: rgb(85, 85, 85); font-family: 나눔고딕, &quot;Nanum Gothic&quot;, 굴림, gulim, 돋움, dotum, Tahoma, sans-serif; font-size: 12px;"></span>'
// 			);
        });

        function goSave() {
            var frm = document.main_form;
            //내용 input으로 등록
            oEditors.getById["ir1"].exec("UPDATE_CONTENTS_FIELD", []);	// 에디터의 내용이 textarea에 적용됩니다.
            $M.setValue("content", $M.getValue("ir1"));

            if($M.getValue("content") == "") {
                alert("내용은 필수입력입니다.");
                return false;
            }
            if ($("input[name='use_yn']:checked").length === 0){
                alert("사용여부는 필수입력입니다.");
                return false;
            }
            if($M.validation(frm) == false) {
                return false;
            };

            $M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
                function(result) {
                    if(result.success) {
                        $M.goNextPage("/cust/cust0508");
                    }
                }
            );
        }

        function fnList() {
            history.back();
        }

    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="cmd" name="cmd" value="C" />
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
                                <th class="text-right essential-item">카테고리</th>
                                <td>
                                    <select class="form-control essential-bg width180px" id="c_cs_faq_cd" name="c_cs_faq_cd" alt="카테고리" required="required" style="display: inline-block;">
                                        <option value="">- 선택 -</option>
                                        <c:forEach var="item" items="${list}">
                                            <option value="${item.code}" >${item.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">등록일</th>
                                <td>
                                    <input type="text" class="form-control width120px" id="show_st_dt" name="show_st_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_current_dt}" alt="등록일" readonly="readonly">
                                </td>
                                <th class="text-right">작성자</th>
                                <td>
                                    <input type="text" class="form-control width120px" name="reg_mem_name" id="reg_mem_name" value="${SecureUser.user_name}" readonly="readonly">
                                    <input type="hidden" name="reg_id" id="reg_id" value="${SecureUser.mem_no}" >
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right essential-item">사용여부</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="use_yn" value="Y" alt="사용여부" checked>
                                        <label class="form-check-label">Y</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="use_yn" value="N">
                                        <label class="form-check-label">N</label>
                                    </div>
                                </td>
                                <th class="text-right essential-item">노출순서</th>
                                <td>
                                    <input type="text" class="form-control essential-bg" id="sort_no" format="decimal" name="sort_no" alt="순서" required="required">
                                </td>
                                <td colspan="2">
                                    <input type="checkbox" id="after_menu_push" name="after_menu_push" checked="checked"><label for="after_menu_push">후순위 게시물 밀기</label>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right essential-item">제목</th>
                                <td colspan="5">
                                    <input type="text" class="form-control essential-bg" id="title" name="title" required="required" alt="제목">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right essential-item">내용</th>
                                <td colspan="5" class="v-align-top" style="height: 500px;">
                                    <!-- 									<textarea name="content" id="content" cols="10" rows="10" style="width:100%;height:555px" alt="내용" required="required"></textarea> -->
                                    <textarea name="ir1" id="ir1" rows="10" cols="100" style="width:100%; height:650px; display:none;" ></textarea>
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
