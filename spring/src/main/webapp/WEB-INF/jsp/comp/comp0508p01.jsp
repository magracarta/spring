<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 가격조건표(메인) > 장비상세정보
-- 작성자 : 정재호
-- 최초 작성일 : 2021-08-11 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

    <script type="text/javascript">

        $(document).ready(function () {
            var fileSeq = '${machineData.mch_file_seq}';

            if (fileSeq > 0) {
                fnAttatchImg(fileSeq);
            } else {
                fnNoImg();
            }
        });

        /////////////////////// 기본 메서드 //////////////////////

        /**
         * 이미지 없을 때
         */
        function fnNoImg() {
            $("#machine_img").attr("src", "/static/img/no-image.png");
            $("#machine_img").attr("width", "200px");
            $("#machine_img").attr("height", "280px");
        }

        /**
         * 이미지 가져오기
         * @param mchFileSeq
         */
        function fnAttatchImg(mchFileSeq) {
            var fileSeq = "/file/" + mchFileSeq;
            $("#machine_img").attr("src", fileSeq);
        }

        ////////////////////////////////////////////////////////

        /////////////////////// 버튼 메서드 //////////////////////

        // 장비 카다로그 버튼
        function goWorkDB() {
            openWorkDBPanel("", ${inputParam.machine_plant_seq});
        }

        // 견적서 발송 버튼
        function goDocSend() {
            var param = {
                open_popup_yn: 'Y',
                menu_seq: '${menu_seq}',
                machine_name: '${inputParam.machine_name}',
                machine_plant_seq: '${inputParam.machine_plant_seq}',
            }
            $M.goNextPage('/cust/cust010701', $M.toGetParam(param), {popupStatus: ""});
        }

        // 고객 카다로그 문자발송 버튼
        function goMessageSend() {

            var catalog_url = '${machineData.catalog_url}';

            if (catalog_url == '') {
                alert("장비코드관리에서 MMS 발송용 카다로그를 입력해야합니다.");
                return;
            }

            catalog_url = encodeURIComponent(catalog_url); // '=' 포함시 서버에서 짤림현상, 이를 방지하기 위해 encoding

            var param = {
                menu_seq: '${menu_seq}',
                machine_name: '${inputParam.machine_name}',
                req_msg_yn: 'Y',
                catalog_url: catalog_url
            }

            $M.goNextPage('/comp/comp0201', $M.toGetParam(param), {popupStatus: ""});
        }

        // 닫기 버튼
        function fnClose() {
            window.close();
        }

        ////////////////////////////////////////////////////////


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
        <div class="content-wrap center">
            <!-- 좌측 썸네일 영역 -->
            <div class="title-wrap">
                <h4 class="primary">${machineData.machine_name}</h4>
            </div>
            <div class="detailimg-item" style="margin-left : 90px;">
                <div style="text-align : center;">
                    <img id="machine_img" name="machine_img" alt="사진" class="detailphoto"
                         style="width: 350px; height:300px; object-fit: contain">
                </div>
            </div>
            <!-- /좌측 썸네일 영역 -->
            <div class="btn-group mt20">
                <div style="margin-left : 90px;">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_M"/>
                    </jsp:include>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>