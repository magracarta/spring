<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 유상정비금액
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 10:32:29
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
            fnExportExcel(auiGrid, "유상정비금액");
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
                    headerText: "전표번호",
                    dataField: "inout_doc_no",
                    width: "11%",
                    style: "aui-center aui-popup"
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width: "12%",
                    style: "aui-center aui-popup"
                },
                {
                    dataField: "cust_no",
                    visible: false
                },
                {
                    headerText: "업체명",
                    dataField: "breg_name",
                    width: "14%",
                    style: "aui-center"
                },
                {
                    headerText: "적요",
                    dataField: "desc_text",
                    style: "aui-left"
                },
                {
                    headerText: "작성자",
                    dataField: "mem_name",
                    width: "8%",
                    style: "aui-center"
                },
                {
                    headerText: "부품비",
                    dataField: "cost_part_amt",
                    dataType: "numeric",
                    width: "7%",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "출장비",
                    dataField: "cost_travel_amt",
                    dataType: "numeric",
                    width: "7%",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "공임비",
                    dataField: "cost_work_amt",
                    dataType: "numeric",
                    width: "7%",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "합계",
                    dataField: "sum_amt",
                    dataType: "numeric",
                    width: "7%",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                },
                /* {
                    headerText: "공임할당",
                    dataField: "work_assign_amt",
                    dataType: "numeric",
                    width: "7%",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return  value == "" || value == null ? "" : $M.setComma(value);
                    }
                }, */
                {
                    headerText: "비고",
                    dataField: "remark",
                    width: "12%",
                    style: "aui-center"
                },
            ];


            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "desc_text",
                    style: "aui-center aui-footer"
                },
                {
                    dataField: "cost_part_amt",
                    positionField: "cost_part_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_travel_amt",
                    positionField: "cost_travel_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "cost_work_amt",
                    positionField: "cost_work_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "sum_amt",
                    positionField: "sum_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "work_assign_amt",
                    positionField: "work_assign_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer"
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, ${list});

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
            	if (event.dataField == "inout_doc_no") {
                    // 매출처리 등록
                    var param = {
                        "inout_doc_no": event.item.inout_doc_no,
                    };

                    var popupOption = "";
                    $M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus: popupOption});		// 매출처리 상세
                }
                if (event.dataField == "cust_name") {
                    var params = {
                        "s_cust_no": event.item.cust_no,
                        "s_inout_doc_type_cd": "07",
                    };
                    openDealLedgerPanel($M.toGetParam(params));
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
                    <h4>유상정비금액</h4>
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