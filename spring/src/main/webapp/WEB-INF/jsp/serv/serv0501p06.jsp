<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 렌탈수리비
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

        // 엑셀다운로드
        function fnExcelDownload() {
            fnExportExcel(auiGrid, "렌탈수리비");
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

            var columnLayout = [];
            var footerColumnLayout = [];

            if ("${inputParam.type}" == "1" || "${inputParam.type}" == "3") {
                // 임대료
                columnLayout = [
                    {
                        headerText: "전표번호",
                        dataField: "inout_doc_no",
                        style: "aui-center aui-popup",
                        styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                            if(item.inout_doc_no != "재렌탈") {
                                return "aui-popup";
                            } else {
                                return "aui-center";
                            }
                        },
                    },
                    {
                        headerText : "모델명",
                        dataField : "machine_name",
                        style : "aui-left"
					},
                    {
                        headerText: "고객",
                        dataField: "cust_name",
                        style: "aui-center",
                    },
                    {
                        headerText: "업체명",
                        dataField: "breg_name",
                        style: "aui-center",
                    },
                    {
                        headerText: "적요",
                        dataField: "desc_text",
                        width: "15%",
                        style: "aui-left",
                    },
                    {
                        headerText: "렌탈료",
                        dataField: "rental_rent_amt",
                        dataType: "numeric",
                        formatString: "#,##0",
                        style: "aui-right",
                    },
                    {
                        headerText: "비고",
                        dataField: "remark",
                        width: "20%",
                        style: "aui-left",
                    },
                ];

                // 푸터레이아웃
                footerColumnLayout = [
                    {
                        labelText: "합계",
                        positionField: "desc_text",
                        style: "aui-center aui-footer",
                    },
                    {
                        dataField: "rental_rent_amt",
                        positionField: "rental_rent_amt",
                        operation: "SUM",
                        formatString: "#,##0",
                        style: "aui-right aui-footer",
                    },
                ];
            } else if ("${inputParam.type}" == "2") {
                // 수리비용
                columnLayout = [
                    {
                        headerText: "전표번호",
                        dataField: "inout_doc_no",
                        style: "aui-center aui-popup",
                    },
                    {
                        headerText : "모델명",
                        dataField : "machine_name",
                        style : "aui-left"
					},
                    {
                        headerText: "고객",
                        dataField: "cust_name",
                        style: "aui-center",
                    },
                    {
                        headerText: "업체명",
                        dataField: "breg_name",
                        style: "aui-center",
                    },
                    {
                        headerText: "적요",
                        dataField: "desc_text",
                        style: "aui-left",
                    },
                    {
                        headerText: "부품비",
                        dataField: "rental_part_amt",
                        dataType: "numeric",
                        formatString: "#,##0",
                        style: "aui-right",
                    },
                    {
                        headerText: "출장비",
                        dataField: "rental_travel_amt",
                        dataType: "numeric",
                        formatString: "#,##0",
                        style: "aui-right",
                    },
                    {
                        headerText: "공임비",
                        dataField: "rental_work_amt",
                        dataType: "numeric",
                        formatString: "#,##0",
                        style: "aui-right",
                    },
                    {
                        headerText: "비고",
                        dataField: "remark",
                        style: "aui-left",
                    },
                ];

                // 푸터레이아웃
                footerColumnLayout = [
                    {
                        labelText: "합계",
                        positionField: "desc_text",
                        style: "aui-center aui-footer",
                    },
                    {
                        dataField: "rental_part_amt",
                        positionField: "rental_part_amt",
                        operation: "SUM",
                        formatString: "#,##0",
                        style: "aui-right aui-footer",
                    },
                    {
                        dataField: "rental_travel_amt",
                        positionField: "rental_travel_amt",
                        operation: "SUM",
                        formatString: "#,##0",
                        style: "aui-right aui-footer",
                    },
                    {
                        dataField: "rental_work_amt",
                        positionField: "rental_work_amt",
                        operation: "SUM",
                        formatString: "#,##0",
                        style: "aui-right aui-footer",
                    },
                    {
                        dataField: "remark",
                        positionField: "remark",
                        formatString: "#,##0",
                        style: "aui-right aui-footer",
                        expFunction : function() {
                            var total = 0;
                            var gridData = AUIGrid.getGridData(auiGrid);
                            for(var i=0; i<gridData.length; i++) {
                                total += ($M.toNum(gridData[i].rental_part_amt) + $M.toNum(gridData[i].rental_travel_amt) + $M.toNum(gridData[i].rental_work_amt));
                            }

                            return total;
                        }
                    },
                ];

            }

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, ${list});

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "inout_doc_no") {
                    if(event.item.inout_doc_no != "재렌탈") {
                    	var popupOption = "";
                        var params = {
                            inout_doc_no: event.item.inout_doc_no,
                        };
    					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(params), {popupStatus : popupOption});		// 매출처리 상세
                    }
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
                    <h4>${subTitle}</h4>
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