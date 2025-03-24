<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 팝업 > 고객/회사명 선택
-- 작성자 : 정재호
-- 최초 작성일 : 2022-10-13 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        $(document).ready(function () {
        });

        function fnConfirm() {
            var reportNameType = $M.getValue("report_name_type");
             <%--openReportPanel('rent/rent0101p01_01.crf','rental_doc_no=' + '${rental_doc_no}'+'&rental_machine_no='+'${rental_machine_no}' + '&report_name_type=' + reportNameType);--%>
            // 23.07.03 렌탈계약서 모두싸인 양식으로 변경
            <%-- openReportPanel('rent/rent0101p01_01_230626.crf','rental_doc_no=' + '${rental_doc_no}'+'&rental_machine_no='+'${rental_machine_no}' + '&report_name_type=' + reportNameType);--%>
            // 23.12.19 렌탈계약서 모두싸인 양식 변경되어 수정
             openReportPanel('rent/rent0101p01_01_231219.crf','rental_doc_no=' + '${rental_doc_no}'+'&rental_machine_no='+'${rental_machine_no}' + '&report_name_type=' + reportNameType);
        }

        function fnCancel() {
            window.close();
        }

    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
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
                <table class="table-border">
                    <colgroup>
                        <col width="100px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <td>
                            <div class="form-check form-check-inline">
                                <label for="mem_type" class="form-check-label">
                                    <input class="form-check-input" type="radio" id="mem_type"
                                           name="report_name_type"
                                           alt="고객명"
                                           checked="checked" value="0">고객명</label>
                            </div>
                            <div class="form-check form-check-inline">
                                <label for="breg_type" class="form-check-label">
                                    <input class="form-check-input" type="radio" id="breg_type"
                                           name="report_name_type"
                                           alt="회사명"
                                           value="1">회사명</label>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /폼테이블 -->
            <div class="btn-group mt5">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>