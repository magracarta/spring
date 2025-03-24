<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > 센터고과평가 > 부서평가 상세
-- 작성자 : jsk
-- 최초 작성일 : 2024-06-12 14:09:10
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

        // 그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                fillColumnSizeMode : true,
                editable: false
            };

            var columnLayout = [
                {
                    headerText : "년도",
                    dataField : "eval_year",
                    width : "6%",
                    minWidth : "70",
                    style : "aui-center",
                },
                {
                    headerText : "분기",
                    dataField : "eval_qtr",
                    width : "6%",
                    minWidth : "70",
                    style : "aui-center",
                },
                {
                    headerText : "평가대상부서",
                    dataField : "org_name",
                    width : "12%",
                    minWidth : "70",
                    style : "aui-center",
                },
                {
                    headerText : "직원명",
                    dataField : "mem_name",
                    width : "8%",
                    minWidth : "70",
                    style : "aui-center",
                },
                {
                    headerText : "직급",
                    dataField : "grade_name",
                    width : "8%",
                    minWidth : "70",
                    style : "aui-center",
                },
                {
                    headerText : "평가내용",
                    dataField : "eval_remark",
                    width : "34%",
                    minWidth : "70",
                    style : "aui-left",
                },
                {
                    headerText: "평가일자",
                    dataField: "eval_dt",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    width: "10%",
                    minWidth: "90",
                    style: "aui-center",
                    editable: false
                },
                {
                    headerText: "평점",
                    dataField: "eval_origin_point",
                    style: "aui-center",
                    width: "8%",
                    minWidth: "50"
                },
                {
                    headerText: "환산",
                    dataField: "eval_point",
                    style: "aui-center",
                    width: "8%",
                    minWidth: "50"
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, ${list});
            $("#auiGrid").resize();
        }

        // 닫기 버튼
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
            <!-- 폼테이블 -->
            <div>
                <div class="title-wrap">
                    <h4>부서평가상세</h4>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10 mr5">
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