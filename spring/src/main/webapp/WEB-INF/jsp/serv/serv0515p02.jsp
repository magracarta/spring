<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 트러블슈팅 관리 > null > 미리보기
-- 작성자 : 황다은
-- 최초 작성일 : 2024-06-11 17:54:18
-- 고객앱 모바일 디자인 화면
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <link rel="stylesheet" type="text/css" href="/static/css/yk-mobile-customer.css" />
    <script type="text/javascript">
        $(document).ready(function () {
            var content = "${inputParam.content}";
            console.log("inputParam" , ${inputParam.content});
            if (content != "") {
                $("#contents").html(decodeURIComponent(content));
            }
        });

        // 닫기
        function fnClose() {
            window.close();
        }
    </script>
</head>
<body class="bg-white">
    <div class="popup-wrap full">
        <div class="popup-top">
            <div class="header" style="position: relative;">
                <span class="title">고장진단</span>
                <div class="right" style="align-items: center;">
                    <button id="as" name="" class="icon-close-white-lg" onclick="javascript:fnClose();"></button>
                </div>
            </div>
            <div class="p-content-common content-priority">
                <div class="row gx-6">
                    <div class="col">${info.break_name}</div>
                    <button id="asd" name="" class="col-auto btn btn-primary-outline">정비신청</button>
                </div>
            </div>
        </div>
        <div class="popup-content" style="padding-top: 7.15rem;">
            <c:forEach var="item" items="${list}" varStatus="status">
                <div class="p-content-common">
                    <span>${item.check_text}</span>
                    <c:forEach var="fileSeq" items="${item.file_list}">
                        <img src="/file/${fileSeq}" class="img-view" style="">
                    </c:forEach>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

</body>
</html>