<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약취소/보류
-- 작성자 : 정선경
-- 최초 작성일 : 2022-10-27 15:48:41
-- [erp3차] 계약취소/출하보류시 사유를 입력받을 수 있는 메모 기능 추가
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        $(document).ready(function() {
            $("#memo_text").focus();
        });

        // 저장
        function goSave() {
            var memoText = $M.getValue("memo_text");
            if(memoText.trim() == "") {
                alert("사유를 입력해주세요.");
                $("#memo_text").val("");
                $("#memo_text").focus();
                return false;
            }

            var url = "/sale/sale0101p03/process/hold";
            var msg = "출하업무를 보류하시겠습니까?\n보류 시, 출하처리가 제한됩니다.";
            var searchYn = "N";
            var machineDocNo = "${inputParam.machine_doc_no}";
            <c:if test="${inputParam.gubun eq 'cancel'}">
            url = "/sale/sale0101p01/"+machineDocNo+"/cancel";
            msg = "계약을 취소하시겠습니까? 취소 후 복구가 불가능하며 입금액이 있으면, 계약취소할 수 없습니다. 품의서는 삭제되지않습니다.\n정말 계약을 취소하시겠습니까?";
            searchYn = "Y";
            </c:if>
            var param = {
                machine_doc_no: machineDocNo,
                memo_text: memoText
            };
            $M.goNextPageAjaxMsg(msg, url, $M.toGetParam(param), {method : "POST"},
                function(result) {
                    if(result.success) {
                        if (opener != null) {
                            // 계약취소인 경우 계약/출하 목록 재검색
                            opener.${inputParam.parent_js_name}(searchYn);
                        }
                    }
                    fnClose();
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
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="title-wrap">
                <h4>계약취소/보류</h4>
            </div>
            <div>
				<textarea style="width: 100%; height: 60px; resize: none" maxlength="2000"
                          placeholder="사유를 입력하세요." id="memo_text" name="memo_text"></textarea>
            </div>
            <div class="btn-group mt5">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>