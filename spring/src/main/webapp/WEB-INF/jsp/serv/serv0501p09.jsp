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
            fnExportExcel(auiGrid, "재정비건수");
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
            };

            var columnLayout = [
                {
                    headerText: "AS번호",
                    dataField: "as_no",
                    visible: false
                },
                {
                    headerText: "처리일자",
                    dataField: "as_dt",
                    width: "11%",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    style: "aui-center aui-popup"
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width: "12%",
                    style: "aui-center"
                },
                {
                    headerText: "장비명",
                    dataField: "machine_name",
                    width: "7%",
                    style: "aui-center"
                },
                {
                    headerText: "판매일자",
                    dataField: "sale_dt",
                    width: "7%",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    style: "aui-center"
                },
                {
                    headerText: "차주명",
                    dataField: "cust_name",
                    width: "14%",
                    style: "aui-center"
                },
                {
                    headerText: "업체명",
                    dataField: "breg_name",
                    style: "aui-center"
                },
                {
                    headerText: "작성자",
                    dataField: "reg_mem_name",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "구분",
                    dataField: "rework_ync_name",
                    width: "7%",
                    style: "aui-center",
                },
                {
                    headerText: "동행자",
                    dataField: "cowoker_name",
                    width: "7%",
                    style: "aui-center",
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, ${list});

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "as_dt") {
                    var params = {
                        "s_as_no": event.item.as_no,
                    };

                    var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=820, left=0, top=0";
                    $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                }
            });

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
                    <h4>재정비건수</h4>
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