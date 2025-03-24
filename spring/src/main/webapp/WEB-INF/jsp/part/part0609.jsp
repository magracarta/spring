<%@ page contentType="text/html;charset=utf-8" language="java" %><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 재고 서머리
-- 작성자 : 김상덕
-- 최초 작성일 : 2023-03-08 17:24:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        $(document).ready(function () {
            createAUIGrid();
            fnInit();
        });

        function fnInit() {

            goSearch();
        }

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["", ""];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
        }

        // 엑셀 다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "재고 서머리");
        }
        // 날짜 Setting
        function fnSetYearMon(year, mon) {
            return year + (mon.length == 1 ? "0" + mon : mon);
        }

        // 조회
        function goSearch() {

            var params = {
                "s_mon": fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"))
                , "s_summary_cd_str": $M.getValue("s_part_group_summary")
                , "s_maker_cd_str": $M.getValue("s_maker")
                , "s_part_production_cd" : $M.getValue("s_part_production_cd")
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
                function (result) {
                    if(result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.setGridData(auiGrid, result.list);
                    };
                }
            );
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                showFooter : true,
                footerPosition : "top",
            };

            // AUIGrid 칼럼 설정
            var columnLayout = [
                {
                    dataField: "pgs_code",
                    visible: false
                },
                {
                    headerText: "분류요약코드",
                    dataField: "summary_code",
                    width: "100",
                    minWidth: "100",
                    style: "aui-center",
                },
                {
                    headerText: "분류요약명",
                    dataField: "summary_name",
                    width: "100",
                    minWidth: "100",
                    style: "aui-center aui-popup",
                },
                {
                    dataField: "maker_cd",
                    visible: false
                },
                {
                    headerText: "메이커",
                    dataField: "maker_name",
                    width: "120",
                    minWidth: "120",
                    style: "aui-center aui-popup",
                },
                {
                    headerText: "당월",
                    dataField: "current_mon",
                    children: [
                        {
                            headerText: "재고수",
                            dataField: "current_mon_stock",
                            style: "aui-center",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                        },
                        {
                            headerText: "재고금액",
                            dataField: "current_mon_amt",
                            style: "aui-right",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                        },
                        {
                            headerText: "출고원가",
                            dataField: "current_mon_out_amt",
                            style: "aui-right",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                            visible : false,
                        },
                        {
                            headerText: "회전율(%)",
                            dataField: "current_mon_turnover",
                            style: "aui-center",
                            width: "100",
                            minWidth: "100",
                            dataType : "numeric",
                            formatString : "#,##0",
                        }
                    ]
                },
                {
                    headerText: "전월",
                    dataField: "before1",
                    children: [
                        {
                            headerText: "재고수",
                            dataField: "before_mon_stock",
                            style: "aui-center",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                        },
                        {
                            headerText: "재고금액",
                            dataField: "before_mon_amt",
                            style: "aui-right",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                        },
                        {
                            headerText: "출고원가",
                            dataField: "before_mon_out_amt",
                            style: "aui-right",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                            visible : false,
                        },
                        {
                            headerText: "회전율(%)",
                            dataField: "before_mon_turnover",
                            style: "aui-center",
                            width: "100",
                            minWidth: "100",
                            dataType : "numeric",
                            formatString : "#,##0",
                        }
                    ]
                },
                {
                    headerText: "전년동월",
                    dataField: "before2",
                    children: [
                        {
                            headerText: "재고수",
                            dataField: "before_year_mon_stock",
                            style: "aui-center",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                        },
                        {
                            headerText: "재고금액",
                            dataField: "before_year_mon_amt",
                            style: "aui-right",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                        },
                        {
                            headerText: "출고원가",
                            dataField: "before_year_mon_out_amt",
                            style: "aui-right",
                            width: "110",
                            minWidth: "110",
                            dataType : "numeric",
                            formatString : "#,##0",
                            visible : false,
                        },
                        {
                            headerText: "회전율(%)",
                            dataField: "before_year_mon_turnover",
                            style: "aui-center",
                            width: "100",
                            minWidth: "100",
                            dataType : "numeric",
                            formatString : "#,##0",
                        }
                    ]
                }
            ];

            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText : "합계",
                    positionField : "summary_code",
                    style : "aui-center aui-footer",
                    colSpan : 4
                },
                {
                    dataField : "current_mon_stock",
                    positionField : "current_mon_stock",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer",
                },
                {
                    dataField : "current_mon_amt",
                    positionField : "current_mon_amt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-right aui-footer",
                },
                {
                    dataField : "current_mon_turnover",
                    positionField : "current_mon_turnover",
                    // operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer",
                    expFunction : function(columnValues) {
                        var gridData = AUIGrid.getGridData(auiGrid);
                        var stockPrice = 0;
                        var outAmt = 0;
                        var turnover = 0;
                        for (var i = 0; i < gridData.length; i++) {
                            stockPrice += gridData[i].current_mon_amt;
                            outAmt += gridData[i].current_mon_out_amt;
                        }
                        if(stockPrice != 0 && outAmt != 0){
                            turnover = stockPrice / outAmt;
                        }
                        return turnover;
                    }
                },
                {
                    dataField : "before_mon_stock",
                    positionField : "before_mon_stock",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer",
                },
                {
                    dataField : "before_mon_amt",
                    positionField : "before_mon_amt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-right aui-footer",
                },
                {
                    dataField : "before_mon_turnover",
                    positionField : "before_mon_turnover",
                    // operation : "AVG",
                    formatString : "#,##0",
                    style : "aui-center aui-footer",
                    expFunction : function(columnValues) {
                        var gridData = AUIGrid.getGridData(auiGrid);
                        var stockPrice = 0;
                        var outAmt = 0;
                        var turnover = 0;
                        for (var i = 0; i < gridData.length; i++) {
                            stockPrice += gridData[i].before_mon_amt;
                            outAmt += gridData[i].before_mon_out_amt;
                        }
                        if(stockPrice != 0 && outAmt != 0){
                            turnover = stockPrice / outAmt;
                        }
                        return turnover;
                    }
                },
                {
                    dataField : "before_year_mon_stock",
                    positionField : "before_year_mon_stock",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer",
                },
                {
                    dataField : "before_year_mon_amt",
                    positionField : "before_year_mon_amt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-right aui-footer",
                },
                {
                    dataField : "before_year_mon_turnover",
                    positionField : "before_year_mon_turnover",
                    // operation : "AVG",
                    formatString : "#,##0",
                    style : "aui-center aui-footer",
                    expFunction : function(columnValues) {
                        var gridData = AUIGrid.getGridData(auiGrid);
                        var stockPrice = 0;
                        var outAmt = 0;
                        var turnover = 0;
                        for (var i = 0; i < gridData.length; i++) {
                            stockPrice += gridData[i].before_year_mon_amt;
                            outAmt += gridData[i].before_year_mon_out_amt;
                        }
                        if(stockPrice != 0 && outAmt != 0){
                            turnover = stockPrice / outAmt;
                        }
                        return turnover;
                    }
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            // var tempVal = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}];
            // 푸터 객체 세팅
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();
            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                var dataField = event.dataField;
                var params = {};
                if (dataField == "summary_name" || dataField == "maker_name") {
                    params.s_mon = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"));
                    params.s_part_production_cd = $M.getValue("s_part_production_cd");
                    params.summary_cd = event.item.pgs_code;
                    if (dataField == "maker_name") {
                        params.maker_cd = event.item.maker_cd;
                    }
                } else {
                    return false;
                }
                $M.goNextPage('/part/part0609p01', $M.toGetParam(params), {popupStatus : getPopupProp});
            });
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <!-- contents 전체 영역 -->
    <div class="content-wrap">
        <div class="content-box">
            <!-- 메인 타이틀 -->
            <div class="main-title">
                <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            </div>
            <!-- /메인 타이틀 -->
            <div class="contents">
                <!-- 기본 -->
                <div class="search-wrap">
                    <table class="table">
                        <colgroup>
                            <col width="60px">
                            <col width="150px">
                            <col width="80px">
                            <col width="300px">
                            <col width="80px">
                            <col width="300px">
                            <col width="80px">
                            <col width="80px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>조회년월</th>
                            <td>
                                <div class="form-row inline-pd">
                                    <div class="col-auto">
                                        <select class="form-control" id="s_year" name="s_year">
                                            <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                                <c:set var="year_option" value="${inputParam.s_current_year - i + 1 + 2000}"/>
                                                <option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-auto">
                                        <select class="form-control" id="s_mon" name="s_mon">
                                            <c:forEach var="i" begin="1" end="12" step="1">
                                                <option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" temp="${current_mm_num}" <c:if test="${i eq current_mm_num}">selected</c:if>>${i}월</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </td>
                            <th>부품분류요약</th>
                            <td>
                                <input class="form-control" style="width: 99%;" type="text" id="s_part_group_summary" name="s_part_group_summary" easyui="combogrid"
                                       easyuiname="summaryList" panelwidth="300" idfield="code_value" textfield="code_desc" multi="Y"/>
                            </td>
                            <th>메이커</th>
                            <td>
                                <input class="form-control" style="width: 99%;" type="text" id="s_maker" name="s_maker" easyui="combogrid"
                                       easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
                            </td>
                            <th>생산구분</th>
                            <td>
                                <select id="s_part_production_cd" name="s_part_production_cd" class="form-control">
                                    <option value="">- 전체 -</option>
                                    <c:forEach items="${codeMap['PART_PRODUCTION']}" var="item">
                                        <option value="${item.code_value}">${item.code_name}</option>
                                    </c:forEach>
                                </select>
                            </td>
                            <td class="">
                                <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <!-- /기본 -->
                <!-- 그리드 타이틀, 컨트롤 영역 -->
                <div class="title-wrap mt10">
                    <h4>조회결과</h4>
                    <div class="btn-group">
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                        </div>
                    </div>
                </div>
                <!-- /그리드 타이틀, 컨트롤 영역 -->
                <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                <div class="btn-group mt10">
                    <div class="left">
                        총 <strong class="text-primary" id="total_cnt">0</strong>건
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
    <!-- /contents 전체 영역 -->
</form>
</body>
</html>