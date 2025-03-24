<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서브시관리 > 정비현황분석 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var list = ${list};
        
        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            
        });

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "정비현황분석");
        }

        function fnClose() {
            window.close();
        }

        // AUIGrid 생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField : "_$uid",
                showRowNumColumn: false,
                headerHeight : 40,
                editable : false,
                showFooter : true,
                footerPosition : "top"
            };
            var columnLayout = [
                {
                    headerText : "지역명",
                    dataField : "area_si",
                    style : "aui-center",
                },
                {
                    headerText : "총장비대수",
                    dataField : "tot_machine_cnt",
                    style : "aui-center",
                    dataType : "numeric",
                    formatString : "#,##0"
                },
                {
                    headerText : "총정비건수",
                    dataField : "tot_repair_cnt",
                    style : "aui-center aui-popup",
                    dataType : "numeric",
                    formatString : "#,##0"
                },
                {
                    headerText : "정비 접촉율",
                    dataField: "tot_cnt",
                    colSpan: 2, // 헤더 가로병합
                    dataType : "numeric",
                    formatString : "#,##0"
                },
                {
                    headerText : "정비 접촉율",
                    dataField: "tot_ratio",
                    postfix : "%",
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 21.07.23 (SR:12010) - 정비 접촉율 비율 수정. 황빛찬
						// 지역별 총장비대수 대비 정비 접촉율
						return (item.tot_cnt / item.tot_cust_cnt * 100).toFixed(1); 
					}
                },
                {
                    headerText : "센터별 고객수",
                    dataField : "tot_cust_cnt",
                    style : "aui-center",
                    dataType : "numeric",
                    formatString : "#,##0"
                },
                {
                    headerText : "매출계<br>(부품비+출장비+공임비)",
                    dataField : "sum_sale_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    width : "140",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                },
                {
                    headerText : "부품비",
                    dataField : "part_total_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                },
                {
                    headerText : "출장비",
                    dataField : "travel_total_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    formatString : "#,##0",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                },
                {
                    headerText : "공임비",
                    dataField : "work_total_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                }
            ];

            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText : "합계",
                    positionField : "area_si",
                    style : "aui-center aui-footer",
                },
                {
                    dataField : "tot_machine_cnt",
                    positionField : "tot_machine_cnt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
                {
                    dataField : "tot_repair_cnt",
                    positionField : "tot_repair_cnt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
                {
                    dataField : "tot_cnt",
                    positionField : "tot_cnt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
                {
                    dataField : "tot_ratio",
                    positionField : "tot_ratio",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer",
                    postfix : "%"
                },
                {
                    dataField : "tot_cust_cnt",
                    positionField : "tot_cust_cnt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
                {
                    dataField : "sum_sale_amt",
                    positionField : "sum_sale_amt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
                {
                    dataField : "part_total_amt",
                    positionField : "part_total_amt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
                {
                    dataField : "travel_total_amt",
                    positionField : "travel_total_amt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
                {
                    dataField : "work_total_amt",
                    positionField : "work_total_amt",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-center aui-footer"
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, ${list});

            AUIGrid.bind(auiGrid, "cellClick", function( event ) {
                console.log(event);
                // return;

                if(event.dataField == 'tot_repair_cnt') {
                    var saleAreaCode = event.item.sale_area_code; // 센터 코드
                    var params = {
                        "s_center_org_code" : ${inputParam.s_org_code},
                        "s_start_dt" : ${inputParam.s_start_dt},
                        "s_end_dt" : ${inputParam.s_end_dt},
                        "s_sale_area_code" : saleAreaCode,
                        "s_except_yk_yn" : "${inputParam.s_except_yk_yn}",
                        "s_except_used_yn" : "${inputParam.s_except_used_yn}",
                        "s_except_rental_yn" : "${inputParam.s_except_rental_yn}",
                        "s_except_agency_yn" : "${inputParam.s_except_agency_yn}",
                        "s_zero_yn" : "N",
                    }

                    $M.goNextPage('/serv/serv0511p03', $M.toGetParam(params), {popupStatus : ''});
                }
            })


            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            $("#auiGrid").resize();
        }

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, $("#title").html());
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
            <div class="title-wrap mt5">
                <h4 id="title">정비현황분석-지역별(${bean.org_kor_name})</h4>
                <div class="btn-group">
                    <div class="right">
                        <button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
                    </div>
                </div>
            </div>
            <div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>