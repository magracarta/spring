<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 재정비건수
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
        });

        //엑셀다운로드
        function fnExcelDownload() {
            fnExportExcel(auiGrid, "센터간 재렌탈 수익 정산리스트");
        }

        // 닫기
        function fnClose() {
            window.close();
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                showFooter: true,
                footerPosition : "top"
            };

            var columnLayout = [
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    style: "aui-center"
                },
                {
                    headerText: "대상센터",
                    dataField: "org_name",
                    style: "aui-center"
                },
                {
                    headerText: "수익",
                    dataField: "acnt_amt",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right"
                },
                {
                    headerText: "적요",
                    dataField: "desc_text",
                    style: "aui-center"
                }
            ];

            // 푸터레이아웃
            footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "org_name",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "acnt_amt",
                    positionField: "acnt_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, ${list});

            $("#auiGrid").resize();
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
                <div class="title-wrap">
                    <h4>센터간 재렌탈 수익 정산리스트</h4>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong class="text-primary">${total_cnt}</strong>건
                </div>
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