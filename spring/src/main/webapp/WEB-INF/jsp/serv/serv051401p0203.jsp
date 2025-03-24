<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 신)서비스업무평가-센터 > null > 워렌티 비용
-- 작성자 : 황빛찬
-- 최초 작성일 : 2024-01-23 13:15:29
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
                    headerText: "정비일자",
                    dataField: "as_dt",
                    width : "100",
                    minWidth : "90",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    style: "aui-center",
                },
                {
                    headerText: "관리번호",
                    dataField: "warranty_no",
                    width : "100",
                    minWidth : "90",
                    style: "aui-center",
                },
                {
                    headerText: "차주명",
                    dataField: "cust_name",
                    width : "120",
                    minWidth : "90",
                    style: "aui-center",
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width : "150",
                    minWidth : "90",
                    style: "aui-center",
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width : "150",
                    minWidth : "90",
                    style: "aui-center",
                },
                {
                    headerText: "청구내역",
                    dataField: "warranty_text",
                    width : "200",
                    minWidth : "90",
                    style: "aui-left",
                },
                {
                    headerText: "수납내역(원화)",
                    children: [
                        {
                            headerText: "부품비",
                            dataField: "rcv_kor_part_amt",
                            width : "100",
                            minWidth : "90",
                            dataType : "numeric",
                            formatString: "#,##0",
                            style: "aui-right",
                        },
                        {
                            headerText: "출장비",
                            dataField: "rcv_kor_travel_amt",
                            width : "100",
                            minWidth : "90",
                            dataType : "numeric",
                            formatString: "#,##0",
                            style: "aui-right",
                        },
                        {
                            headerText: "공임비",
                            dataField: "rcv_kor_work_amt",
                            width : "100",
                            minWidth : "90",
                            dataType : "numeric",
                            formatString: "#,##0",
                            style: "aui-right",
                        },
                        {
                            headerText: "합계",
                            dataField: "total_amt",
                            width : "100",
                            minWidth : "90",
                            dataType : "numeric",
                            formatString: "#,##0",
                            style: "aui-right",
                        },
                    ]
                }
            ];

            var footerColumnLayout = [];

            // 출장비/공임
            footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "service_mem_name",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rcv_kor_part_amt",
                    positionField: "rcv_kor_part_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rcv_kor_travel_amt",
                    positionField: "rcv_kor_travel_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rcv_kor_work_amt",
                    positionField: "rcv_kor_work_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "total_amt",
                    positionField: "total_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                }
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
                    <h4>워렌티 비용</h4>
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