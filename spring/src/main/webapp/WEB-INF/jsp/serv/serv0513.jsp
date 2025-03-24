<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 신)서비스업무평가-개인 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-12-10 09:53:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var dataFieldName = []; // 펼침 항목(create할때 넣음)

        $(document).mouseup(function(e) {
            var container = $(".dev_search_dt_type_cd_str_div");
            if (!container.is(e.target) && container.has(e.target).length === 0) {
                if (container.is(":visible")) {
                    container.toggleClass('dpn');
                }
            }
        });

        $(document).ready(function () {
            createAUIGrid();
            fnInit();

            $('.dev_popover_activator').click(function(event) {
                var container = $('.dev_search_dt_type_cd_str_div');
                container.toggleClass('dpn');
            });

            $('input[type=radio][name=_s_search_dt_type_cd]').click(function(event) {
                var today = "${inputParam.s_current_dt}";
                var st = today;
                var ed = $M.getValue("${s_end_dt}");
                if (ed == "") {
                    ed = today;
                }
                // 당일 기준일 경우, 당일 기준이 아닌 끝날자 기준일 경우 주석처리
                if (event.ctrlKey == false) {
                    ed = today;
                }

                var edDate = $M.toDate(ed);

                var s_val = this.value;
                var dt_cnt = $M.toNum(s_val.substr(0, 1));
                var dt_type = s_val.substr(1, 2);

                switch(s_val) {
                    case '00' : st = ""; ed = ""; break;
                    case '0D' : st = ed; break;
                    case '0M' : st = ed.substr(0, 6) || '01'; break;
                    default :
                        switch(dt_type) {
                            case 'W' : st = $M.addDates(edDate, -7 * dt_cnt); break;
                            case 'M' : st = $M.addMonths(edDate, -1 * dt_cnt); break;
                            case 'Y' : st = $M.addMonths(edDate, -12 * dt_cnt); break;
                            default : st =  ed.substr(0, 6) || '01'; break;
                        }
                        break;
                }

                var startYear =  $M.dateFormat(st, "yyyy");
                var startMon = $M.toNum($M.dateFormat(st, "MM"));
                $M.setValue("s_start_year", startYear);
                $M.setValue("s_start_mon", startMon)

                var endYear = $M.dateFormat(ed, "yyyy");
                var endMon = $M.toNum($M.dateFormat(ed, "MM"));
                $M.setValue("s_end_year", endYear);
                $M.setValue("s_end_mon", endMon);

                $M.setValue("s_search_dt_type_cd", this.value);

                $('.dev_search_dt_type_cd_str_div').toggleClass('dpn');

                goSearch();
            });
        });

        function fnInit() {
            var st = "${searchDtMap.s_start_dt}";
            var ed = "${searchDtMap.s_end_dt}";

            var startYear =  $M.dateFormat(st, "yyyy");
            var startMon = $M.toNum($M.dateFormat(st, "MM"));
            $M.setValue("s_start_year", startYear);
            $M.setValue("s_start_mon", startMon)

            var endYear = $M.dateFormat(ed, "yyyy");
            var endMon = $M.toNum($M.dateFormat(ed, "MM"));
            $M.setValue("s_end_year", endYear);
            $M.setValue("s_end_mon", endMon);
        }

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_mem_name"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
        }

        // 부품부 매출포함 클릭
        function fnChangePartSearch(event) {
            var target = event.target;
            if(!target)	return;

            var checked = target.checked;
            $M.setValue("s_part_yn", checked ? "Y" : "N");

            goSearch();
        }

        // 펼침
        function fnChangeColumn(event) {
            var data = AUIGrid.getGridData(auiGrid);
            var target = event.target || event.srcElement;
            if(!target)	return;

            var dataField = target.value;
            var checked = target.checked;

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];

                if(checked) {
                    AUIGrid.showColumnByDataField(auiGrid, dataField);
                } else {
                    AUIGrid.hideColumnByDataField(auiGrid, dataField);
                }
            }
        }

        // 조회
        function goSearch() {
            var sStartYearMon = $M.getValue("s_start_year");
            var sStartMon = $M.getValue("s_start_mon")
            var sEndYearMon = $M.getValue("s_end_year");
            var sEndMon = $M.getValue("s_end_mon");

            if(sStartMon.length == 1) {
                sStartMon = "0" + sStartMon;
            }

            if(sEndMon.length == 1) {
                sEndMon = "0" + sEndMon;
            }

            sStartYearMon += sStartMon;
            sEndYearMon += sEndMon;

            var sMonYn = $M.isCheckBoxSel("s_mon_yn") ? "Y" : "N";
            var param = {
                "s_center_code": $M.getValue("s_center_code"),
                "s_mem_name": $M.getValue("s_mem_name"),
                "s_start_year_mon" : sStartYearMon,
                "s_end_year_mon" : sEndYearMon,
                "s_mon_yn" : sMonYn,
                "s_search_dt_type_cd" : $M.getValue("s_search_dt_type_cd"),
                "s_part_yn" : $M.getValue("s_part_yn") == undefined ? "N" : $M.getValue("s_part_yn"),
                "this_page" : this_page
            };
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if (result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.setGridData(auiGrid, result.list);

                        if(sMonYn == "Y") {
                            AUIGrid.showColumnByDataField(auiGrid, ["year_mon"]);
                        } else {
                            AUIGrid.hideColumnByDataField(auiGrid, ["year_mon"]);
                        }
                    }
                }
            );
        }

        function createAUIGrid() {
            var gridPros = {
                showFooter: true,
                footerPosition : "top",
                fixedColumnCount: 4
            };

            var columnLayout = [
                {
                    headerText: "부서",
                    dataField: "org_name",
                    width : "80",
                    minWidth : "70",
                    headerStyle : "aui-fold",
                },
                {
                    headerText: "부서코드",
                    dataField: "org_code",
                    visible: false
                },
                {
                    headerText : "년월",
                    dataField : "year_mon",
                    dataType: "date",
                    formatString: "yy-mm",
                    width : "70",
                    minWidth : "60",
                    style: "aui-center"
                },
                {
                    headerText: "사원",
                    dataField: "reg_mem_name",
                    width : "60",
                    minWidth : "50",
                    style: "aui-center aui-popup"
                },
                // {
                //     headerText: "사원번호",
                //     dataField: "reg_mem_no",
                //     style: "aui-center",
                //     width : "90",
                //     minWidth : "80",
                //     headerStyle : "aui-fold",
                // },
                {
                    headerText: "최종매출",
                    dataField: "final_sales",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "90",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                    headerTooltip : { // 헤더 툴팁 표시 일반 스트링
                        show : true,
                        tooltipHtml : '<div style="width:180px;"><p><span style="color:#F29661;">최종매출</span></p><p>=D+W+L+Q+R+V</p></div>'
                    }
                },
                {
                    headerText: "전년도<br>최종순익",
                    dataField: "pre_tot_profit",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "90",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                    headerTooltip : { // 헤더 툴팁 표시 일반 스트링
                        show : true,
                        tooltipHtml : '<div style="width:180px;"><p><span style="color:#F29661;">최종순익</span></p><p>=E+X+M+Q+U+V</p></div>'
                    }
                },
                {
                    headerText: "최종순익",
                    dataField: "tot_profit",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "90",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                    headerTooltip : { // 헤더 툴팁 표시 일반 스트링
                        show : true,
                        tooltipHtml : '<div style="width:180px;"><p><span style="color:#F29661;">최종순익</span></p><p>=E+X+M+Q+U+V</p></div>'
                    }
                },
                {
                    headerText: "업무내용집계표",
                    headerStyle : "aui-fold",
                    children: [
                        {
                            headerText : "근무일수",
                            dataField: "work_total_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            headerStyle : "aui-fold",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                return "";
                            }
                        },
                        {
                            headerText : "정비",
                            dataField: "job_report_total_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            headerStyle : "aui-fold",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                return "";
                            }
                        },
                        {
                            headerText : "On Time",
                            dataField: "on_time_total_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            headerStyle : "aui-fold",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                return "";
                            }
                        },
                        {
                            headerText : "상담",
                            dataField: "consult_cnt2",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            headerStyle : "aui-fold",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                return "";
                            }
                        },
                        {
                            headerText : "렌탈계약",
                            dataField: "rental_contract_total_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            headerStyle : "aui-fold",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                return "";
                            }
                        },
                        {
                            headerText : "렌탈점검",
                            dataField: "rental_job_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            headerStyle : "aui-fold",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                return "";
                            }
                        },
                        {
                            headerText : "기타",
                            dataField: "etc_total_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            headerStyle : "aui-fold",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                return "";
                            }
                        }
                    ]
                },
                {
                    headerText: "서비스업무평가",
                    // headerStyle : "aui-fold",
                    children: [
                        {
                            headerText: "전체",
                            dataField: "as_tot",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "50",
                            minWidth : "40",
                            style: "aui-right",
                            // headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "전화",
                            headerStyle : "aui-fold",
                            children : [
                                {
                                    headerText : "전화상담일지",
                                    dataField: "as_call_cnt",
                                    dataType: "numeric",
                                    formatString: "#,##0",
                                    width : "80",
                                    minWidth : "70",
                                    style: "aui-right",
                                    headerStyle : "aui-fold",
                                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                        value = AUIGrid.formatNumber(value, "#,##0");
                                        return value == 0 ? "" : value;
                                    },
                                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                        if (value == 0) {
                                            return "";
                                        }
                                        return "aui-popup"
                                    }
                                },
                                {
                                    headerText : "안건상담",
                                    dataField: "consult_cnt",
                                    dataType: "numeric",
                                    formatString: "#,##0",
                                    width : "70",
                                    minWidth : "60",
                                    style: "aui-right",
                                    headerStyle : "aui-fold",
                                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                        value = AUIGrid.formatNumber(value, "#,##0");
                                        return value == 0 ? "" : value;
                                    },
                                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                        if (value == 0) {
                                            return "";
                                        }
                                        return "aui-popup"
                                    }
                                }
                            ]
                        },
                        {
                            headerText: "유상",
                            dataField: "as_cost_repair_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "50",
                            minWidth : "40",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "무상",
                            dataField: "as_free_repair_cnt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "50",
                            minWidth : "40",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        }
                    ]
                },
                {
                    headerText: "전년도<br>총정비시간<br>(총이동+총정비)",
                    dataField: "pre_tot_job_hour",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "80",
                    style: "aui-right",
                    headerStyle : "aui-fold",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0.0####");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "총정비시간<br>(총이동+총정비)",
                    dataField: "tot_job_hour",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "80",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0.0####");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "유효활동시간<br>(총이동+총규정<br>+렌탈업무시간)",
                    dataField: "tot_valid_hour",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "80",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0.0####");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "유상정비시간평가",
                    // headerStyle : "aui-fold",
                    children: [
                        {
                            headerText: "이동H",
                            dataField: "cost_move_hour",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            style: "aui-right",
                            // headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0.0####");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "정비H",
                            dataField: "cost_repair_hour",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0.0####");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "규정H",
                            dataField: "cost_standard_hour",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            style: "aui-right",
                            // headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0.0####");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        }
                    ]
                },
                {
                    headerText: "유상정비금액",
                    children: [
                        {
                            headerText: "부품(A)",
                            dataField: "cost_part_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "출장(B)",
                            dataField: "cost_travel_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "공임(C)",
                            dataField: "cost_work_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        }
                    ]
                },
                {
                    headerText: "유상정비 매출(D)<br>=A+B+C",
                    dataField: "cost_sale_amt",
                    dataType: "numeric",
                    width : "100",
                    minWidth : "90",
                    style: "aui-right",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "유상정비 순익(E)<br>=A*15%+B+C",
                    dataField: "cost_profit_amt",
                    dataType: "numeric",
                    width : "100",
                    minWidth : "90",
                    style: "aui-right",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "무상정비시간평가",
                    // headerStyle : "aui-fold",
                    children: [
                        {
                            headerText: "이동H",
                            dataField: "free_move_hour",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            style: "aui-right",
                            // headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0.0####");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "정비H",
                            dataField: "free_repair_hour",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0.0####");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "규정H",
                            dataField: "free_standard_hour",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "60",
                            minWidth : "50",
                            style: "aui-right",
                            // headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0.0####");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        }
                    ]
                },
                {
                    headerText: "무상정비집계",
                    children: [
                        {
                            headerText: "부품비(F)",
                            dataField: "m_free_part_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "출장비(G)",
                            dataField: "free_travel_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "공임(O)",
                            dataField: "free_work_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "지출총계<br>(J0)=G+O",
                            dataField: "free_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                        },
                    ]
                },
                {
                    headerText: "서비스비용(무상정비)",
                    children: [
                        {
                            headerText: "워렌티비용<br>(J1)",
                            dataField: "warranty_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "출하정비비용<br>(J2)",
                            dataField: "out_cost_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "서비스비용<br>합계(J3)",
                            dataField: "free_cost_amt",
                            dataType: "numeric",
                            formatString: "#,##0",
                            width : "100",
                            minWidth : "90",
                            style: "aui-right",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        // {
                        // 	headerText: "서비스잔여비용<br>수익(J)=J3+J2-J1",
                        //     dataField: "svc_profit_amt",
                        //     dataType: "numeric",
                        //     formatString: "#,##0",
                        //     width : "100",
                        //     minWidth : "90",
                        //     style: "aui-right",
                        //     labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        //         value = AUIGrid.formatNumber(value, "#,##0");
                        //         return value == 0 ? "" : value;
                        //     },
                        // },
                    ]
                },
                // {
                // 	headerText: "무상정비매출(W)<br>=F+J",
                //     dataField: "free_sale_amt",
                //     dataType: "numeric",
                //     formatString: "#,##0",
                //     width : "100",
                //     minWidth : "90",
                //     style: "aui-right",
                //     labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                //         value = AUIGrid.formatNumber(value, "#,##0");
                //         return value == 0 ? "" : value;
                //     },
                // },
                {
                    headerText: "무상정비매출(W)<br>=F+J0+J1+J2+J3",
                    dataField: "free_sale_amt",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "90",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                // {
                // 	headerText: "무상정비순익(X)<br>=F*15%+J",
                //     dataField: "free_profit_amt",
                //     dataType: "numeric",
                //     formatString: "#,##0",
                //     width : "100",
                //     minWidth : "90",
                //     style: "aui-right",
                //     labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                //         value = AUIGrid.formatNumber(value, "#,##0");
                //         return value == 0 ? "" : value;
                //     },
                // },
                {
                    headerText: "부품판매(L)",
                    dataField: "part_amt",
                    dataType: "numeric",
                    width : "100",
                    minWidth : "90",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (value == 0) {
                            return "";
                        }
                        return "aui-popup"
                    },
                },
                {
                    headerText: "부품판매 순익(M)<br>=L*15%",
                    dataField: "part_profit_amt",
                    dataType: "numeric",
                    width : "100",
                    minWidth : "90",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "재정비",
                    dataField: "re_as_repair_cnt",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "50",
                    minWidth : "40",
                    style: "aui-right",
                    headerStyle : "aui-fold",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (value == 0) {
                            return "";
                        }
                        return "aui-popup"
                    },
                },
                /* {
                    headerText: "중고판매<br>금액(P)",
                    dataField: "machine_used_amt",
                    dataType: "numeric",
                    width : "100",
                    minWidth : "90",
                    formatString: "#,##0",
                    style: "aui-right",
                    headerStyle : "aui-fold",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                }, */
                {
                    headerText: "중고판매<br>순익(Q)",
                    dataField: "machine_used_profit_amt",
                    dataType: "numeric",
                    width : "100",
                    minWidth : "90",
                    formatString: "#,##0",
                    style: "aui-right",
                    headerStyle : "aui-fold",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (value == 0) {
                            return "";
                        }
                        return "aui-popup"
                    },
                },
                {
                    headerText: "렌탈",
                    headerStyle : "aui-fold",
                    children: [
                        {
                            headerText: "렌탈업무시간",
                            dataField: "rental_job_hour",
                            dataType: "numeric",
                            width : "100",
                            minWidth : "90",
                            formatString: "#,##0",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0.0###");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "렌탈료(R)",
                            dataField: "rental_rent_amt",
                            dataType: "numeric",
                            width : "100",
                            minWidth : "90",
                            formatString: "#,##0",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "렌탈감가(S)",
                            dataField: "reduce_total_amt",
                            dataType: "numeric",
                            width : "100",
                            minWidth : "90",
                            formatString: "#,##0",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        },
                        {
                            headerText: "수리비용(T)",
                            dataField: "rental_repair_amt",
                            dataType: "numeric",
                            width : "100",
                            minWidth : "90",
                            formatString: "#,##0",
                            style: "aui-right",
                            headerStyle : "aui-fold",
                            labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                                value = AUIGrid.formatNumber(value, "#,##0");
                                return value == 0 ? "" : value;
                            },
                            styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                                if (value == 0) {
                                    return "";
                                }
                                return "aui-popup"
                            },
                        }
                    ]
                },
                {
                    headerText: "렌탈순익(U)<br>=R-S",
                    dataField: "rental_profit_amt",
                    dataType: "numeric",
                    formatString: "#,##0",
                    width : "100",
                    minWidth : "90",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "신차판매<br>순익(V)",
                    dataField: "new_machine_profit",
                    width : "100",
                    minWidth : "90",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                // {
                //     headerText: "해피콜",
                //     dataField: "happycall_cnt",
                //     dataType: "numeric",
                //     formatString: "#,##0",
                //     width : "50",
                //     minWidth : "40",
                //     style: "aui-right",
                //     headerStyle : "aui-fold",
                //     labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                //         value = AUIGrid.formatNumber(value, "#,##0");
                //         return value == 0 ? "" : value;
                //     },
                // }
            ];
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "reg_mem_name"

                },
                {
                    dataField: "final_sales",
                    positionField: "final_sales",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "pre_tot_profit",
                    positionField: "pre_tot_profit",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "tot_profit",
                    positionField: "tot_profit",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "work_total_cnt",
                    positionField: "work_total_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "job_report_total_cnt",
                    positionField: "job_report_total_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "on_time_total_cnt",
                    positionField: "on_time_total_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "consult_cnt2",
                    positionField: "consult_cnt2",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rental_contract_total_cnt",
                    positionField: "rental_contract_total_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rental_job_cnt",
                    positionField: "rental_job_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "etc_total_cnt",
                    positionField: "etc_total_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "as_tot",
                    positionField: "as_tot",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "as_call_cnt",
                    positionField: "as_call_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "consult_cnt",
                    positionField: "consult_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "as_cost_repair_cnt",
                    positionField: "as_cost_repair_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "as_free_repair_cnt",
                    positionField: "as_free_repair_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "pre_tot_job_hour",
                    positionField: "pre_tot_job_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer aui-popup",
                },
                {
                    dataField: "tot_job_hour",
                    positionField: "tot_job_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer aui-popup",
                },
                {
                    dataField: "tot_valid_hour",
                    positionField: "tot_valid_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_move_hour",
                    positionField: "cost_move_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_repair_hour",
                    positionField: "cost_repair_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_standard_hour",
                    positionField: "cost_standard_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_part_amt",
                    positionField: "cost_part_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_travel_amt",
                    positionField: "cost_travel_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_work_amt",
                    positionField: "cost_work_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_sale_amt",
                    positionField: "cost_sale_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "cost_profit_amt",
                    positionField: "cost_profit_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "free_move_hour",
                    positionField: "free_move_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "free_repair_hour",
                    positionField: "free_repair_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "free_standard_hour",
                    positionField: "free_standard_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "m_free_part_amt",
                    positionField: "m_free_part_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "free_travel_amt",
                    positionField: "free_travel_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "free_work_amt",
                    positionField: "free_work_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "free_amt",
                    positionField: "free_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "warranty_amt",
                    positionField: "warranty_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "out_cost_amt",
                    positionField: "out_cost_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "free_cost_amt",
                    positionField: "free_cost_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                // {
                //     dataField: "svc_profit_amt",
                //     positionField: "svc_profit_amt",
                //     formatString: "#,##0",
                //     operation: "SUM",
                //     style: "aui-right aui-footer",
                // },
                {
                    dataField: "free_sale_amt",
                    positionField: "free_sale_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                // {
                //     dataField: "free_profit_amt",
                //     positionField: "free_profit_amt",
                //     formatString: "#,##0",
                //     operation: "SUM",
                //     style: "aui-right aui-footer",
                // },
                {
                    dataField: "part_amt",
                    positionField: "part_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "part_profit_amt",
                    positionField: "part_profit_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "re_as_repair_cnt",
                    positionField: "re_as_repair_cnt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                /* {
                    dataField: "machine_used_amt",
                    positionField: "machine_used_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                }, */
                {
                    dataField: "machine_used_profit_amt",
                    positionField: "machine_used_profit_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rental_job_hour",
                    positionField: "rental_job_hour",
                    formatString: "#,##0.0####",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rental_rent_amt",
                    positionField: "rental_rent_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "reduce_total_amt",
                    positionField: "reduce_total_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rental_repair_amt",
                    positionField: "rental_repair_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "rental_profit_amt",
                    positionField: "rental_profit_amt",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "new_machine_profit",
                    positionField: "new_machine_profit",
                    formatString: "#,##0",
                    operation: "SUM",
                    style: "aui-right aui-footer",
                },
                // {
                //     dataField: "happycall_cnt",
                //     positionField: "happycall_cnt",
                //     formatString: "#,##0",
                //     operation: "SUM",
                //     style: "aui-right aui-footer",
                // }
            ];

            AUIGrid.setGridData(auiGrid, []);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.bind(auiGrid, "footerClick", function( event ) {
                switch(event.footerIndex) {
                    case 12:	// 전년도 총정비시간
                    case 13:	// 총정비시간(이동정+정비)
                        if(event.footerValue == 0) {
                            alert("조회할 데이터가 없습니다.");
                            return;
                        }

                        var params = {
                            "s_start_year" : $M.getValue("s_start_year") + $M.lpad($M.getValue("s_start_mon"), 2, '0'),
                            "s_end_year" : $M.getValue("s_end_year") + $M.lpad($M.getValue("s_end_mon"), 2, '0'),
                            "s_center_code": $M.getValue("s_center_code"),
                            "s_mem_name": $M.getValue("s_mem_name"),
                            "before_yn" : event.footerIndex == 12 ? "Y" : "N", 	// 전년도일때
                        }

                        var popupOption = "";
                        $M.goNextPage('/serv/serv0501p16', $M.toGetParam(params), {popupStatus: popupOption});

                        break;
                }
            });

            AUIGrid.bind(auiGrid, "cellClick", function (event) {

                var sStartYearMon = $M.getValue("s_start_year");
                var sStartMon = $M.getValue("s_start_mon")
                var sEndYearMon = $M.getValue("s_end_year");
                var sEndMon = $M.getValue("s_end_mon");

                if(sStartMon.length == 1) {
                    sStartMon = "0" + sStartMon;
                }

                if(sEndMon.length == 1) {
                    sEndMon = "0" + sEndMon;
                }

                sStartYearMon += sStartMon;
                sEndYearMon += sEndMon;

                if (event.value == 0) {
                    return;
                }

                var params = {
                    "s_mem_no": event.item.reg_mem_no,
                    "s_org_code": event.item.org_code,
                    "s_start_year_mon" : sStartYearMon,
                    "s_end_year_mon" : sEndYearMon
                };

                if ("" != $M.getValue("s_mon_yn")) {
                    params["s_start_year_mon"] = event.item.year_mon;
                    params["s_end_year_mon"] = event.item.year_mon;
                }

                console.log(params);

                var type = "";
                if (event.dataField == "reg_mem_name") {
                    // 정비내용평가 & AS전산평가 팝업 호출
                    var popupOption = "";
                    $M.goNextPage('/serv/serv0501p07', $M.toGetParam(params), {popupStatus: popupOption});

                } else if (event.dataField == "as_tot" || event.dataField == "as_call_cnt" || event.dataField == "as_cost_repair_cnt"
                    || event.dataField == "as_free_repair_cnt" || event.dataField == "re_as_repair_cnt") {
                    // 서비스업무평가 - 전체/전화/유상/무상/재정비
                    type = "";

                    if (event.dataField == "as_call_cnt") {
                        // 전화
                        type = "CALL";
                    } else if (event.dataField == "as_cost_repair_cnt") {
                        // 유상
                        type = "Y";
                    } else if (event.dataField == "as_free_repair_cnt") {
                        // 무상
                        type = "N";
                    } else if (event.dataField == "re_as_repair_cnt") {
                        // 재정비
                        type = "RE";
                    }

                    params.type = type;

                    var popupOption = "";
                    $M.goNextPage('/serv/serv0501p01', $M.toGetParam(params), {popupStatus: popupOption});

                } else if (event.dataField == "cost_move_hour" || event.dataField == "cost_repair_hour" || event.dataField == "cost_standard_hour") {
                    // 유상정비시간 - 이동/정비/규정
                    type = "";

                    if (event.dataField == "cost_move_hour") {
                        // 이동
                        type = "MOVE";
                    } else if (event.dataField == "cost_repair_hour") {
                        // 정비
                        type = "Y";
                    } else if (event.dataField == "cost_standard_hour") {
                        // 규정
                        type = "N";
                    }

                    var popupOption = "";
                    $M.goNextPage('/serv/serv0501p02', $M.toGetParam(params), {popupStatus: popupOption});

                } else if (event.dataField == "cost_part_amt" || event.dataField == "cost_travel_amt" || event.dataField == "cost_work_amt") {
                    // 유상정비금액 - 부품비/출장비/공임
                    var popupOption = "";
                    $M.goNextPage('/serv/serv0501p03', $M.toGetParam(params), {popupStatus: popupOption});
                } else if (event.dataField == "free_move_hour" || event.dataField == "free_repair_hour" || event.dataField == "free_standard_hour") {
                    // 무상정비시간평가 - 이동/정비/규정
                    var popupOption = "";
                    $M.goNextPage('/serv/serv0501p04', $M.toGetParam(params), {popupStatus: popupOption});
                } else if (event.dataField == "m_free_part_amt" || event.dataField == "free_travel_amt" || event.dataField == "free_work_amt") {
                    // 무상정비금액 - 부품비/출장비/공임
                    type = "";

                    /* if (event.dataField == "m_free_part_amt") {
                        // 부품비
                        type = "1";
                    } else {
                        // 출장비/공임
                        type = "2";
                    } */
                    // 김태공상무님 요청으로 무상부품, 무상출장, 무상공임 같이 보여줌
                    type = "2";

                    params.type = type;

                    var popupOption = "";
                    $M.goNextPage('/serv/serv0501p05', $M.toGetParam(params), {popupStatus: popupOption});
                } else if (event.dataField == "part_amt") {
                    // 부품판매전표 - 부품판매 금액
                    var popupOption = "";
                    params.s_part_yn = $M.getValue("s_part_yn") == undefined ? "N" : $M.getValue("s_part_yn");
                    $M.goNextPage('/serv/serv0501p08', $M.toGetParam(params), {popupStatus: popupOption});
                } else if (event.dataField == "rental_rent_amt" || event.dataField == "rental_repair_amt") {
                    // 렌탈수리비 - 임대료/감가/수리비용
                    type = "";

                    if (event.dataField == "rental_rent_amt") {
                        // 렌탈료
                        type = "1";
                    } else if (event.dataField == "rental_repair_amt") {
                        // 수리비용
                        type = "2";
                    }

                    params.type = type;

                    var popupOption = "";
                    $M.goNextPage('/serv/serv0501p06', $M.toGetParam(params), {popupStatus: popupOption});
                } else if(event.dataField == "reduce_total_amt") {
                    var popupOption = "";
                    params.page_type = "personal";
                    // 감가
                    $M.goNextPage('/serv/serv0501p12', $M.toGetParam(params), {popupStatus: popupOption});
                } else if(event.dataField == "consult_cnt") {
                    // 안건상담
                    var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=440, left=0, top=0";
                    $M.goNextPage('/serv/serv0501p14', $M.toGetParam(params), {popupStatus: popupOption});
                } else if(event.dataField == "out_cost_amt" || event.dataField == "free_cost_amt") {
                    // 서비스비용(무상정비)
                    var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=440, left=0, top=0";
                    $M.goNextPage('/serv/serv0501p15', $M.toGetParam(params), {popupStatus: popupOption});
                } else if(event.dataField == "machine_used_profit_amt") {
                    // 중고판매순익
                    var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=440, left=0, top=0";
                    $M.goNextPage('/serv/serv0501p17', $M.toGetParam(params), {popupStatus: popupOption});
                } else if(event.dataField == "rental_job_hour") {
                    // 중고판매순익
                    var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=440, left=0, top=0";
                    $M.goNextPage('/serv/serv0501p18', $M.toGetParam(params), {popupStatus: popupOption});
                } else if (event.dataField == "warranty_amt") {
                    var popupOption = "";
                    $M.goNextPage('/serv/serv051401p0203', $M.toGetParam(params), {popupStatus: popupOption});
                }
            });
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.resize(auiGrid);

            // 펼치기 전에 접힐 컬럼 목록
            var auiColList = AUIGrid.getColumnInfoList(auiGrid);
            for (var i = 0; i <auiColList.length; ++i) {
                if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
                    dataFieldName.push(auiColList[i].dataField);
                }
            }

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];
                AUIGrid.hideColumnByDataField(auiGrid, dataField);
            }

            AUIGrid.hideColumnByDataField(auiGrid, ["year_mon"]);
        }

        // 개일별 랭킹
        function goFirstRank() {

            var sStartYearMon = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
            var sEndYearMon = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

            var params = {
                "s_start_year_mon" : sStartYearMon,
                "s_end_year_mon" : sEndYearMon,
                "s_inout_yn" : $M.getValue("s_inout_yn")
            };

            console.log(params);

            var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=440, left=0, top=0";
            $M.goNextPage('/serv/serv0501p13', $M.toGetParam(params), {popupStatus: popupOption});
        }

        function fnSetDate(year, mon) {
            if(mon.length == 1) {
                mon = "0" + mon;
            }
            var sYearMon = year + mon;

            return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
        }

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "서비스업무평가-개인");
        }

        // 기준정보 재생성
        function goChangeSave() {
            var s_year = $M.getValue("s_start_year");
            var s_mon = $M.lpad($M.getValue("s_start_mon"), 2, '0');

            var param = {
                "s_year_mon": s_year + s_mon,
            };

            var msg = '일지 작성월 : ' + s_year + '/' + s_mon + ' ~ 당월 까지 정보를 재성성 합니다.\n실행하시겠습니까?';
            $M.goNextPageAjaxMsg(msg, this_page + "/change/save", $M.toGetParam(param), {method: "POST", timeout : 60 * 60 * 1000},
                function (result) {
                    if (result.success) {
                        alert("기준정보 재생성을 완료하였습니다.");
                        window.location.reload();
                    }
                }
            );
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="s_search_dt_type_cd" name="s_search_dt_type_cd" value="${searchDtMap.search_dt_type_cd}"/>
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
                        <table class="table table-fixed">
                            <colgroup>
                                <col width="60px">
                                <col width="320px">
                                <col width="30px">
                                <col width="120px">
                                <col width="60px">
                                <col width="120px">
                                <col width="60px">
                                <col width="80px">
                                <col width="100px">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년월</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-auto">
                                            <%-- <select class="form-control" id="s_start_year" name="s_start_year">
                                                <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                                    <c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
                                                    <option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
                                                </c:forEach>
                                            </select> --%>
                                            <jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
                                                <jsp:param name="sort_type" value="d"/>
                                                <jsp:param name="year_name" value="s_start_year"/>
                                            </jsp:include>
                                        </div>
                                        <div class="col-auto">
                                            <select class="form-control" id="s_start_mon" name="s_start_mon">
                                                <c:forEach var="i" begin="1" end="12" step="1">
                                                    <option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_start_mon}">selected</c:if>>${i}월</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-auto">
                                            <%-- <select class="form-control" id="s_end_year" name="s_end_year">
                                                <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                                    <c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
                                                    <option value="${year_option}" <c:if test="${year_option eq inputParam.s_end_year}">selected</c:if>>${year_option}년</option>
                                                </c:forEach>
                                            </select> --%>
                                            <jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
                                                <jsp:param name="sort_type" value="d"/>
                                                <jsp:param name="year_name" value="s_end_year"/>
                                            </jsp:include>
                                        </div>
                                        <div class="col-auto">
                                            <select class="form-control" id="s_end_mon" name="s_end_mon">
                                                <c:forEach var="i" begin="1" end="12" step="1">
                                                    <option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_end_mon}">selected</c:if>>${i}월</option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div class="dev_search_dt_type_cd_str_wrap">
                                            <button type="button" class="ui-datepicker-trigger btn btn-primary-gra dev_popover_activator ml5"><i class="material-iconsmore_horiz text-dark" ></i></button>
                                            <div class="con-info dev_search_dt_type_cd_str_div dpn" title="컨트롤 키를 누른채 클릭하면 끝 날짜 기준으로 설정됩니다." style="transform: translateX(0) translateY(0);">
                                                <c:forEach items="${codeMap['SEARCH_DT_TYPE']}" var="item">
                                                    <c:if test="${fn:contains(searchDtMap.search_dt_type_cd_str, item.code_value)}">
                                                        <label><input type="radio" name="_s_search_dt_type_cd" value="${item.code_value }" ${item.code_value eq searchDtMap.search_dt_type_cd ? 'checked' : '' }>${item.code_name }</label></c:if>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <th>부서</th>
                                <td>
                                    <select class="form-control" name="s_center_code" id="s_center_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="list" items="${codeMap['WAREHOUSE']}">
                                            <option value="${list.code_value}" <c:if test="${list.code_value eq inputParam.org_code}">selected</c:if> >${list.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>사원명</th>
                                <td>
                                    <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                </td>
                                <th>대상인원</th>
                                <td>
                                    <select class="form-control" name="s_inout_yn" id="s_inout_yn">
                                        <option value="">- 전체 -</option>
                                        <option value="Y">외근직</option>
                                        <option value="N">내근직</option>
                                    </select>
                                </td>
                                <th>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label mr5" for="s_mon_yn">월별보기</label>
                                        <input class="form-check-input" type="checkbox" id="s_mon_yn" name="s_mon_yn">
                                    </div>
                                </th>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>개인별실적결과</h4>
                        <div class="btn-group">
                            <div class="left" style="margin-left:50px;">
                                <span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}</span>
                            </div>
                            <div class="right">
                                <div class="form-check form-check-inline">
                                    <label for="s_part_yn" style="color:black;">
                                        <input type="checkbox" id="s_part_yn" onclick="javascript:fnChangePartSearch(event)">부품부 매출포함
                                    </label>
                                    <label for="s_toggle_column" style="color:black;">
                                        <input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
                                    </label>
                                </div>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <div class="btn-group mt5">
                        <div class="left">
                            총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>