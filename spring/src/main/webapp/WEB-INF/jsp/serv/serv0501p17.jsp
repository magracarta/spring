<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 중고손익 상세내역
-- 작성자 : 이강원.
-- 최초 작성일 : 2022-11-21 11:29:29
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
            fnExportExcel(auiGrid, "중고손익 상세내역 리스트");
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
                    dataField : "rental_machine_no",
                    visible: false,
                },
                {
                    headerText: "판매일자",
                    dataField: "sale_dt",
                    width : "100",
                    minWidth : "90",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    style: "aui-center",
                },
                {
                    headerText: "관리센터",
                    dataField: "mng_org_name",
                    width : "100",
                    minWidth : "90",
                    style: "aui-center"
                },
                {
                    headerText: "소유센터",
                    dataField: "own_org_name",
                    width : "100",
                    minWidth : "90",
                    style: "aui-center"
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width : "150",
                    minWidth : "90",
                    style: "aui-center aui-popup"
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width : "100",
                    minWidth : "90",
                    style: "aui-center"
                },
                {
                    headerText: "판매자",
                    dataField: "sale_mem_name",
                    width : "100",
                    minWidth : "90",
                    style: "aui-center"
                },
                {
                    headerText: "판매센터",
                    dataField: "sale_org_name",
                    width : "100",
                    minWidth : "90",
                    style: "aui-center"
                },
                {
                    headerText: "판매센터수익",
                    dataField: "sale_org_profit_amt",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 ? "" : $M.setComma(value);
                    },
                },
                {
                    headerText: "수익배분센터",
                    dataField: "amt_mng_org_name",
                    width : "100",
                    minWidth : "90",
                    style: "aui-center"
                },
                {
                    headerText: "수익배분센터수익",
                    dataField: "mng_org_profit_amt",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 ? "" : $M.setComma(value);
                    },
                }
            ];

            // 푸터레이아웃
            footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "sale_org_name",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "sale_org_profit_amt",
                    positionField: "sale_org_profit_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "mng_org_profit_amt",
                    positionField: "mng_org_profit_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, ${list});

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if(event.dataField == "body_no") {
                    if(event.item.rental_machine_no == '') { return; }
                    var params = {rental_machine_no : event.item.rental_machine_no};
                    var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=450, height=550, left=0, top=0";
                    $M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
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
                    <h4>중고손익 상세내역</h4>
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