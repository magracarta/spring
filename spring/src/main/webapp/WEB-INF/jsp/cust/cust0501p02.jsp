<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 앱 고객정보관리 > 매칭이력
-- 작성자 : 정선경
-- 최초 작성일 : 2023-07-26 10:43:39
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;

        $(document).ready(function () {
            createAUIGrid();
        });

        function createAUIGrid() {
            var gridPros = {
                rowIdField : "_$uid",
                showRowNumColumn : true,
                fillColumnSizeMode : true
            };
            var columnLayout = [
                {
                    headerText : "매칭일시",
                    dataField : "mapping_date",
                    dataType: "date",
                    formatString: "yyyy-mm-dd HH:MM:ss",
                    width: "35%",
                    style : "aui-center"

                },
                {
                    headerText : "매칭 고객명",
                    dataField : "cust_name",
                    width: "30%",
                    style : "aui-center"
                },
                {
                    headerText : "휴대폰",
                    dataField : "hp_no",
                    width: "35%",
                    style : "aui-center"
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, ${list});
            $("#auiGrid").resize();
        }

        // 닫기
        function fnClose() {
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
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 폼테이블 -->
            <div>
                <div class="title-wrap">
                    <h4>매칭이력</h4>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>
