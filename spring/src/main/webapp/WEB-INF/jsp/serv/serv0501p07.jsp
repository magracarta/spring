<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 장비내용평가 & AS전산평가
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 10:51:29
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
                    headerText: "처리일자",
                    dataField: "as_dt",
                    style: "aui-center",
					width : "75",
					minWidth : "75",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
				{ 
					headerText : "매출전표", 
					dataField : "inout_doc_no", 
					style : "aui-center aui-popup",
					width : "90",
					minWidth : "90",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var str = value != "" ? value.substring(4, 16) : value;
						return str;
					}
				},
                {
                    headerText: "차대번호",
                    dataField: "body_no",
					width : "150",
					minWidth : "150",
                    style: "aui-center",
                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (item.as_dt == "") {
                            return "";
                        }
                        return "aui-popup"
                    }
                },
                {
                    headerText: "장비명",
                    dataField: "machine_name",
					width : "150",
					minWidth : "150",
                    style: "aui-center",
                },
                {
                    headerText: "판매일자",
                    dataField: "sale_dt",
                    style: "aui-center",
					width : "75",
					minWidth : "75",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
                {
                    headerText: "차주명",
                    dataField: "cust_name",
					width : "120",
					minWidth : "120",
                    style: "aui-center",
                },
                {
                    headerText: "업체명",
                    dataField: "breg_name",
					width : "120",
					minWidth : "120",
                    style: "aui-center",
                },
                {
                    headerText: "작성자",
                    dataField: "mem_name",
					width : "70",
					minWidth : "70",
                    style: "aui-center",
                },
                {
                    headerText: "구분",
                    dataField: "clm_name",
                    style: "aui-center",
					width : "45",
					minWidth : "45",
                },
                {
                    headerText: "정비내용평가",
                    style: "aui-center",
                    children: [
                        {
                            headerText: "난이도",
                            dataField: "repair_level",
        					width : "45",
        					minWidth : "45",
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return  value == "" || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "기능도",
                            dataField: "repair_skill",
        					width : "45",
        					minWidth : "45",
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return  value == "" || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "비중도",
                            dataField: "special_review",
        					width : "45",
        					minWidth : "45",
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return  value == "" || value == null ? "" : $M.setComma(value);
                            }
                        },
                    ]
                },
                {
                    headerText: "AS전산평가",
                    style: "aui-center",
                    children: [
                        {
                            headerText: "정상",
                            dataField: "doc_delay_y",
        					width : "45",
        					minWidth : "45",
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return  value == "" || value == null ? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "밀림",
                            dataField: "doc_delay_n",
        					width : "45",
        					minWidth : "45",
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return  value == "" || value == null ? "" : $M.setComma(value);
                            }
                        },
                    ]
                },
                {
                    headerText: "정비일지타입",
                    dataField: "as_repair_type_ro",
					width : "45",
					minWidth : "45",
                    visible: false
                },

				{ 
					headerText : "정비지시서", 
					dataField : "job_report_no", 
					style : "aui-center aui-popup",
					width : "90",
					minWidth : "90",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var str = value != "" ? value.substring(4, 16) : value;
						return str;
					}
				},
            ];

            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "clm_name",
                },
                {
                    dataField: "repair_level",
                    positionField: "repair_level",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "repair_skill",
                    positionField: "repair_skill",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "special_review",
                    positionField: "special_review",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "doc_delay_y",
                    positionField: "doc_delay_y",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "doc_delay_n",
                    positionField: "doc_delay_n",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, ${list});

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                var popupOption = "";
                if (event.dataField == "body_no") {
                    var params = {
                        "s_as_no": event.item.as_no,
                    };
                    if (event.item.clm_name == '유상' || event.item.clm_name == '무상') {
                        // 서비스일지 상세
                        if(event.item.as_repair_type_ro == "R") {
                            $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                        } else if(event.item.as_repair_type_ro == "O") {
                            // 출하일지
                            $M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus: popupOption});
                        }
                    } else if (event.item.clm_name == '전화') {
                        // 전화상담일지 상세
                        $M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
                    }
                } else if(event.dataField == "inout_doc_no") {
            		var param = {
        					"inout_doc_no" : event.item.inout_doc_no
        				};
        			$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus: popupOption});
                } else if(event.dataField == "job_report_no") {
              		var param = {
                        "s_job_report_no": event.item.job_report_no
                    };
                    $M.goNextPage('/serv/serv0101p01', $M.toGetParam(param), {popupStatus: popupOption});
                }
            });

            $("#auiGrid").resize();
        }
        
        //엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "정비내용평가 & AS전산평가");
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
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 폼테이블 -->
            <div>
                <div class="title-wrap">
                    <h4>정비내용평가 & AS전산평가</h4>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
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