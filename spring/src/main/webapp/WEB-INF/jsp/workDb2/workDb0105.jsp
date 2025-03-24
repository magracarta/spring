<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB > 업무DB팝업 > 파일 미리보기
-- 작성자 : 류성진
-- 최초 작성일 : 2021-03-24 15:20:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

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
        <c:choose>
            <c:when test="${result.file_ext eq 'jpg' or result.file_ext eq 'png' or result.file_ext eq 'jpeg' or result.file_ext eq 'gif' or result.file_ext eq 'tif'}">
                <!-- 이미지 -->
                <img src="/file/${inputParam.file_seq}">
            </c:when>
            <c:when test="${result.file_ext eq 'avi' or result.file_ext eq 'mpg' or result.file_ext eq 'wmv'}">
                <!-- 비디오 -->
                <video src="/file/${inputParam.file_seq}"></video>
            </c:when>
            <c:when test="${result.file_ext eq 'zip'}">
                <!-- 압축파일 -->
                <span class="icon-folder zip"></span>
                미리보기를 지원하지 않습니다!
            </c:when>
            <c:when test="${result.file_ext eq 'exe'}">
                <!-- 실행파일 -->
                <span class="icon-folder exe"></span>
                미리보기를 지원하지 않습니다!
            </c:when>
            <c:when test="${result.file_ext eq 'txt'}">
                <!-- 실행파일 -->
                미리보기를 지원하지 않습니다!
            </c:when>
            <c:when test="${result.file_ext eq 'pdf' or result.file_ext eq 'msi' or result.file_ext eq 'pptx' or result.file_ext eq 'pot' or result.file_ext eq 'hwp' or result.file_ext eq 'xlsx' or result.file_ext eq 'docx' or result.file_ext eq 'ppt' or result.file_ext eq 'doc'}">
                <!-- 문서 -->
                <span class="icon-folder doc"></span>
                <iframe src="/file/${inputParam.file_seq}"></iframe>
            </c:when>
        </c:choose>
        <div class="btn-group mt10">
            <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
            </div>
        </div>
    </div>
</form>
</body>
</html>