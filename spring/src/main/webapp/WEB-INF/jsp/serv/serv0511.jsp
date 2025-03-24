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
    <style>

        .cust-tot-popup {
            background: #fff8eb !important;
            text-decoration: underline !important;
            text-underline-position: under;
        }

        .cust-popup {
            text-decoration: underline !important;
            text-underline-position: under;
        }

    </style>
    <script type="text/javascript">

        var auiGrid;
        var centerListJson = ${centerListJson};
        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            goSearch();
        });

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "정비현황분석");
        }

        function goSaleArea(orgCode) {
            var params = {
                "s_org_code" : orgCode,
                "s_start_dt" : $M.getValue("s_start_dt"),
                "s_end_dt" : $M.getValue("s_end_dt"),
                "s_except_yk_yn" : $M.getValue("s_except_yk_yn") == "Y" ? "Y" : "N",
                "s_except_used_yn" : $M.getValue("s_except_used_yn") == "Y" ? "Y" : "N",
                "s_except_rental_yn" : $M.getValue("s_except_rental_yn") == "Y" ? "Y" : "N",
                "s_except_agency_yn" : $M.getValue("s_except_agency_yn") == "Y" ? "Y" : "N",
            }

            var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=430, left=0, top=0";
            $M.goNextPage('/serv/serv0511p01', $M.toGetParam(params), {popupStatus : poppupOption});
        }

        // 조회
        function goSearch() {
            if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                return;
            }

            var params = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_except_yk_yn" : $M.getValue("s_except_yk_yn") == "Y" ? "Y" : "N",
                "s_except_used_yn" : $M.getValue("s_except_used_yn") == "Y" ? "Y" : "N",
                "s_except_rental_yn" : $M.getValue("s_except_rental_yn") == "Y" ? "Y" : "N",
                "s_except_agency_yn" : $M.getValue("s_except_agency_yn") == "Y" ? "Y" : "N"
            }
            _fnAddSearchDt(params, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);
                    }
                }
            );
        }

        // isInteger는 es6 임. IE11 에서는 안되므로 함수 만듬.
        Number.isInteger = Number.isInteger || function (value) {
            return typeof value === "number" &&
                isFinite(value) &&
                Math.floor(value) === value;
        };

        // AUIGrid 생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: false,
                enableCellMerge: true, // 셀병합 사용여부
                cellMergeRowSpan: true,
                rowStyleFunction : function(rowIndex, item) {

                    if(item.center_01.indexOf("총 ") != -1) {
                        return "aui-as-tot-row-style";
                    } else if(item.center_01.indexOf("센터별 고객수") != -1 || item.center_01.indexOf("목표 전화") != -1
                        || item.center_01.indexOf("센터 근무 인원") != -1 || item.center_01.indexOf("1인당") != -1) {
                        return "aui-as-center-row-style";
                    }

                    // if(item.center_01.indexOf("총 ") != -1) {
                    //     return "aui-as-tot-row-style";
                    // } else if(item.center_01.indexOf("센터별 고객수") != -1) {
                    //     return "aui-as-center-row-style";
                    // }
                }
            };

            var columnLayout = [
                {
                    headerText: "센터",
                    dataField: "center_01",
                    width: "40",
                    minWidth: "30",
                    style: "aui-center",
                    colSpan: 2, // 헤더 가로병합
                    cellColMerge: true, // 셀 가로병합
                    cellColSpan: 2, // 셀 가로병합
                    cellMerge: true, // 셀 세로병합
                    renderer: { // 템플릿 렌더러 사용
                        type: "TemplateRenderer"
                    },
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                        if(value.indexOf("<br>") != -1) {
                            return "aui-as-cell-row-style";
                        }
                    },
                },
                {
                    dataField: "center_02",
                    width: "60",
                    minWidth: "50"
                }
            ];

            for (var i = 0; i < centerListJson.length; i++) {
                var qtyDataFieldName = "a_" + centerListJson[i].code_value + "_qty";
                var rateDataFieldName = "a_" + centerListJson[i].code_value + "_rate";

                var centerQtyObj = {
                    headerText: centerListJson[i].code_name,
                    dataField: qtyDataFieldName,
                    colSpan: 2, // 헤더 가로병합
                    cellColMerge: true, // 셀 가로병합
                    cellColSpan: 2, // 셀 가로병합
                    width: "50",
                    minWidth: "40",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == "0" ? "" : $M.setComma(value);
                    },
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {

                        if(rowIndex == 0 || rowIndex == 1) {
                            return "cust-tot-popup";
                        }

                        if(item.center_01.indexOf("<br>") != -1) {
                            return "cust-popup";
                        }

                        // if(rowIndex == 0) {
                        //     return "aui-as-tot-row-underline-style";
                        // }
                    }
                }

                var centerRateObj = {
                    headerText: centerListJson[i].code_name,
                    dataField: rateDataFieldName,
                    width: "50",
                    minWidth: "40",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        var str = "";
                        if (value == 0) {
                            str = "";
                        } else if (!Number.isInteger(value)) {
                            str = value.toFixed(1) + "%";
                        } else {
                            str = $M.setComma(value);
                        }
                        return str;
                    },
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {


                        if(rowIndex == 0) {
                            return "aui-as-tot-row-underline-style";
                        }
                    }
                }

                columnLayout.push(centerQtyObj);
                columnLayout.push(centerRateObj);
            }

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function(event) {
                // 값없으면 리턴
                if(event.value == "") {
                    return;
                }

                // 센터 타이틀 클릭시 리턴 처리
                if(event.columnIndex == 0) {
                    if(event.rowIndex <= 2) {
                        return;
                    }
                }

                // 총 장비대수 셀
                if(event.item.type_code == 'tot_machine_cnt') {
                    var orgCode = event.dataField.split("_")[1];
                    goSaleArea(orgCode);
                }

                // 총 정비건수
                if(event.item.type_code == 'tot_repair_cnt') {
                    var centerOrgCode = event.dataField.split('_')[1]; // 센터 코드
                    var params = {
                        "s_center_org_code" : centerOrgCode,
                        "s_start_dt" : $M.getValue("s_start_dt"),
                        "s_end_dt" : $M.getValue("s_end_dt"),
                        "s_except_yk_yn" : $M.getValue("s_except_yk_yn") == "Y" ? "Y" : "N",
                        "s_except_used_yn" : $M.getValue("s_except_used_yn") == "Y" ? "Y" : "N",
                        "s_except_rental_yn" : $M.getValue("s_except_rental_yn") == "Y" ? "Y" : "N",
                        "s_except_agency_yn" : $M.getValue("s_except_agency_yn") == "Y" ? "Y" : "N"
                    }

                    $M.goNextPage('/serv/serv0511p02', $M.toGetParam(params), {popupStatus : ''});
                }

                // 정비장비대수 건별
                if((event.item.type_code == 'repair_machine_cnt') && (event.columnIndex) % 2 == 0) {
                    var centerOrgCode = event.dataField.split('_')[1]; // 센터 코드
                    var cnt = event.item.center_02.indexOf("건") != -1 ? event.item.center_02.substring(0, event.item.center_02.indexOf("건")) : -1; // 상담장비대수 클릭된 건수 값
                    var params = {
                        "s_center_org_code" : centerOrgCode,
                        "s_start_dt" : $M.getValue("s_start_dt"),
                        "s_end_dt" : $M.getValue("s_end_dt"),
                        "s_cnt" : cnt,
                        "s_except_yk_yn" : $M.getValue("s_except_yk_yn") == "Y" ? "Y" : "N",
                        "s_except_used_yn" : $M.getValue("s_except_used_yn") == "Y" ? "Y" : "N",
                        "s_except_rental_yn" : $M.getValue("s_except_rental_yn") == "Y" ? "Y" : "N",
                        "s_except_agency_yn" : $M.getValue("s_except_agency_yn") == "Y" ? "Y" : "N"
                    }

                    console.log("건별");
                    console.log(params);

                    $M.goNextPage('/serv/serv0511p03', $M.toGetParam(params), {popupStatus : ''});
                }

                // 총 정비대수 셀
                // if(event.rowIndex == 0) {
                //     var orgCode = event.dataField.split("_")[1];
                //     goSaleArea(orgCode);
                // }

                // if(event.dataField == 'biz_eng_name') {
                //     var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=430, left=0, top=0";
                //
                //     var param = {
                //         "maker_cd" : event.item.maker_cd,
                //         "seq_no" : event.item.seq_no
                //     };
                //
                //     $M.goNextPage('/sale/sale0302p01', $M.toGetParam(param), {popupStatus : poppupOption});
                // } else if(event.dataField == "email" && event.item.email != "") {
                //     var param = {
                //         "to" : event.item.email
                //     };
                //     openSendEmailPanel($M.toGetParam(param));
                // }
            });
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="70px">
                                <col width="252px">
                                <col width="400px">
                                <col width="80px">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회기간</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="시작일" value="${searchDtMap.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" required="required" value="${searchDtMap.s_end_dt}">
                                            </div>
                                        </div>

                                        <!-- 조회기간 설정 -->
                                        <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                            <jsp:param name="st_field_name" value="s_start_dt"/>
                                            <jsp:param name="ed_field_name" value="s_end_dt"/>
                                            <jsp:param name="click_exec_yn" value="Y"/>
                                            <jsp:param name="exec_func_name" value="goSearch();"/>
                                        </jsp:include>
                                    </div>
                                </td>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_yk_yn" name="s_except_yk_yn" value="Y" checked="checked">
                                        <label class="form-check-label" for="s_except_yk_yn">YK건기제외</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_used_yn" name="s_except_used_yn" value="Y" checked="checked">
                                        <label class="form-check-label" for="s_except_used_yn">중고장비제외</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_rental_yn" name="s_except_rental_yn" value="Y" checked="checked">
                                        <label class="form-check-label" for="s_except_rental_yn">렌탈장비제외</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_except_agency_yn" name="s_except_agency_yn" value="Y">
                                        <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                        <%--<label class="form-check-label" for="s_except_agency_yn">대리점제외</label>--%>
                                        <label class="form-check-label" for="s_except_agency_yn">위탁판매점제외</label>
                                    </div>
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                                <td>
                                    <div class="left text-warning">
                                        [※ 총 정비 접촉률 : 0건을 제외한 정비장비대수 건수 및 비율 합계]
                                    </div>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>센터 별 정비현황</h4>
                        <div class="btn-group">
                            <div class="right">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>
