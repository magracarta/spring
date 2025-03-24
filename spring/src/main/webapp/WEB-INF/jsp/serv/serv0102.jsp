<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-17 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var page = 1;
        var moreFlag = "N";
        var isLoading = false;
        var dataFieldName = []; // 펼침 항목(create할때 넣음)

        $(document).ready(function () {
            fnInit();
            // AUIGrid 생성
            createAUIGrid();

            goSearch();
        });

        function fnInit() {
            // 업무일지
            if ("${inputParam.s_page_type}" == "work") {
                $M.setValue("s_as_type", "${inputParam.s_as_type_str}");
                $M.setValue("s_appr_proc_status_cd", "${inputParam.s_appr_proc_status_cd_str}");

                $M.setValue("s_start_dt", "${inputParam.s_start_dt}");
                $M.setValue("s_end_dt", "${inputParam.s_end_dt}");

                $("input[name=s_as_type]").prop("disabled", true);
                $("input[name=s_appr_proc_status_cd]").prop("disabled", true);
            } else {
                $M.setValue("s_start_dt", "${searchDtMap.s_start_dt}");
                $M.setValue("s_end_dt", "${searchDtMap.s_end_dt}");
            }
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "row",
                showRowNumColumn: true,
                rowStyleFunction : function(rowIndex, item) {
                    var style = "";
                    if(item.aui_status_cd == "D") { // 기본
                        style = "aui-status-default";
                    } else if(item.aui_status_cd == "C") { // 완료
                        style = "aui-status-complete";
                    } else if(item.aui_status_cd == "G") { // 진행중
                        style = "aui-status-ongoing";
                    }

                    return style;
                }
            };
            var columnLayout = [
                {
                    headerText: "구분",
                    dataField: "as_type_name",
                    width: "80",
                    minWidth: "70",
                    style: "aui-center aui-popup",
                },
                {
                    headerText: "상태",
                    dataField: "appr_proc_status_name",
                    width: "80",
                    minWidth: "70",
                    style: "aui-center",
                },
                {
                    headerText: "처리일자",
                    dataField: "as_dt",
                    style: "aui-center",
                    width: "70",
                    minWidth: "60",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
                {
                    headerText: "전표일자",
                    dataField: "stat_dt",
                    style: "aui-center",
                    width: "70",
                    minWidth: "60",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width: "150",
                    minWidth: "140",
                    style: "aui-center",
                },
                {
                    headerText: "휴대폰",
                    dataField: "hp_no",
                    style: "aui-center",
                    width: "100",
                    minWidth: "90",
                    editable: true,
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true,
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        if (String(value).length > 0) {
                            // 전화번호에 대시 붙이는 정규식으로 표현
                            return value.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/, "$1-$2-$3");
                        }
                        return value;
                    }
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width: "150",
                    minWidth: "140",
                    style: "aui-center",
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width: "150",
                    minWidth: "140",
                    style: "aui-center"
                },
                {
                    headerText: "판매일자",
                    dataField: "sale_dt",
                    style: "aui-center",
                    width: "70",
                    minWidth: "60",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    headerStyle: "aui-fold"
                },
                {
                    headerText: "장비일련번호",
                    dataField: "machine_seq",
                    visible: false
                },
                {
                    headerText: "차주번호",
                    dataField: "cust_no",
                    visible: false
                },
                {
                    headerText: "업체명",
                    dataField: "breg_name",
                    width: "150",
                    minWidth: "45",
                    style: "aui-center",
                },
                {
                    headerText: "AS번호",
                    dataField: "as_no",
                    visible: false
                },
                // 3차 추가
                {
                    headerText: "합계",
                    dataField: "total_amt",
                    width: "150",
                    minWidth: "45",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "부품비",
                    dataField: "part_total_amt",
                    width: "150",
                    minWidth: "45",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "출장비",
                    dataField: "travel_final_expense",
                    width: "150",
                    minWidth: "45",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 || value == null ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "공임비",
                    dataField: "work_total_amt",
                    width: "150",
                    minWidth: "45",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == 0 || value == null ? "" : $M.setComma(value);
                    }
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "as_type_name") {
                    if (event.item.as_type_name == "전화상담") {
                        var params = {
                            "s_as_no": event.item.as_no
                        };

                        var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=820, left=0, top=0";
                        $M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
                    } else if (event.item.as_type_name == "정비일지") {
                        // if(event.item.write_yn != "N") { // 미작성
                        //     var params = {
                        //         "s_as_no" : event.item.as_no,
                        //         "s_seq_no" : event.item.seq_no,
                        //         "s_job_report_no" : event.item.job_report_no,
                        //     };
                        //
                        //     var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
                        //     $M.goNextPage('/serv/serv0102p10', $M.toGetParam(params), {popupStatus : popupOption});
                        // } else {
                            var params = {
                                "s_as_no": event.item.as_no,
                                "s_job_report_no" : event.item.job_report_no,
                            };

                            var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
                            $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                        // }
                    } else if (event.item.as_type_name == "출하일지") {
                        var params = {
                            "s_as_no": event.item.as_no
                        };

                        var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
                        $M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus: popupOption});
                    }
                }
            });

            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

            // 펼치기 전에 접힐 컬럼 목록
            var auiColList = AUIGrid.getColumnInfoList(auiGrid);
            for (var i = 0; i < auiColList.length; ++i) {
                if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
                    dataFieldName.push(auiColList[i].dataField);
                }
            }

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];
                AUIGrid.hideColumnByDataField(auiGrid, dataField);
            }
        }

        // 펼침
        function fnChangeColumn(event) {
            var data = AUIGrid.getGridData(auiGrid);
            var target = event.target || event.srcElement;
            if (!target) return;

            var dataField = target.value;
            var checked = target.checked;

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];

                if (checked) {
                    AUIGrid.showColumnByDataField(auiGrid, dataField);
                } else {
                    AUIGrid.hideColumnByDataField(auiGrid, dataField);
                }
            }
        }

        function goSearch() {
            // 조회 버튼 눌렀을경우 1페이지로 초기화
            page = 1;
            moreFlag = "N";
            fnSearch(function (result) {
                AUIGrid.setGridData(auiGrid, result.list);
                $("#total_cnt").html(result.total_cnt);
                $("#curr_cnt").html(result.list.length);
                if (result.more_yn == 'Y') {
                    moreFlag = "Y";
                    page++;
                }
            });
        }

        // 조회
        function fnSearch(successFunc) {
            var frm = document.main_form;
            //validationcheck
            if ($M.validation(frm,
                {field: ["s_start_dt", "s_end_dt"]}) == false) {
                return;
            }

            if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                return;
            }

            if ($M.getValue("s_as_type") == "") {
                alert("구분(정비, 출하, 전화)은 최소 1개 이상 선택해야합니다.");
                return;
            }

            if ($M.getValue("s_appr_proc_status_cd") == "" && $M.getValue("s_not_written") == "") {
                alert("상태(작성중, 결재중, 완료, 미작성)는 최소 1개 이상 선택해야합니다.");
                return;
            }

            var params = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_as_type_str": $M.getValue("s_as_type"),
                "s_appr_proc_status_cd_str": $M.getValue("s_appr_proc_status_cd"),
                "s_not_written": $M.getValue("s_not_written"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "org_type": $M.getValue("org_type"),
                "s_mem_no": $M.getValue("s_mem_no"),
                "login_org_code": $M.getValue("login_org_code"),
                "page": page,
                "rows": $M.getValue("s_rows"),
                "s_date_type": $M.getValue("s_date_type")
            };
            
            // [재호 2023/11/30] 업무일지 상세(서비스부) 에서 열린 경우
            // - jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp 를 include 하지 않아서 fnAddSearchDt 가 없음
            if(${inputParam.s_page_type ne 'work'}) {
              _fnAddSearchDt(params, 's_start_dt', 's_end_dt');
            }
            
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: "GET"},
                function (result) {
                    isLoading = false;
                    if (result.success) {
                        successFunc(result);
                    }
                }
            )
        }

        // 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
        function fnScollChangeHandelr(event) {
            if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
                goMoreData();
            }
        }

        function goMoreData() {
            fnSearch(function (result) {
                result.more_yn == "N" ? moreFlag = "N" : page++;
                if (result.list.length > 0) {
                    console.log(result.list);
                    AUIGrid.appendData("#auiGrid", result.list);
                    $("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
                }
            });
        }

        // 전화상담일지 등록
        function goNew() {
            var params = [{}];
            var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=820, left=0, top=0";
            $M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
        }

        // 출하서비스일지 등록
        function goNewService() {
            var params = [{}];
            var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=950, left=0, top=0";
            $M.goNextPage('/serv/serv0102p11', $M.toGetParam(params), {popupStatus: popupOption});
        }

        // 엑셀 다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "서비스일지");
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="s_as_repair_type_ro" name="s_as_repair_type_ro">
    <input type="hidden" id="login_org_code" name="login_org_code" value="${inputParam.login_org_code}">
    <input type="hidden" id="org_type" name="org_type" value="${inputParam.org_type}">
    <input type="hidden" id="s_mem_no" name="s_mem_no" value="${inputParam.s_mem_no}">
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
                                <col width="100px">
                                <col width="260px">
                                <col width="30px">
                                <col width="180px">
                                <col width="40px">
                                <col width="260px">
                                <col width="200px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <td>
                                    <select id="s_date_type" name="s_date_type" class="form-control">
                                        <option value="a.as_dt">처리일자</option>
                                        <option value="stat_dt">전표일자</option>
                                    </select>
                                </td>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="시작일">
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="종료일">
                                            </div>
                                        </div>

                                        <!-- <details data-popover="up">

										</details> -->
                                        <c:if test="${inputParam.s_page_type ne 'work'}">
                                            <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                                <jsp:param name="st_field_name" value="s_start_dt"/>
                                                <jsp:param name="ed_field_name" value="s_end_dt"/>
                                                <jsp:param name="click_exec_yn" value="Y"/>
                                                <jsp:param name="exec_func_name" value="goSearch();"/>
                                            </jsp:include>
                                        </c:if>
                                    </div>
                                </td>
                                <th>구분</th>
                                <td>
                                    <div class="form-check form-check-inline v-align-middle">
                                        <input type="checkbox" id="as_type_r" name="s_as_type" class="form-check-input" checked="checked" value="R">
                                        <label class="form-check-label" for="as_type_r">정비</label>
                                    </div>
                                    <div class="form-check form-check-inline v-align-middle">
                                        <input type="checkbox" id="as_type_o" name="s_as_type" class="form-check-input" checked="checked" value="O">
                                        <label class="form-check-label" for="as_type_o">출하</label>
                                    </div>
                                    <div class="form-check form-check-inline v-align-middle">
                                        <input type="checkbox" id="as_type_c" name="s_as_type" class="form-check-input" checked="checked" value="C">
                                        <label class="form-check-label" for="as_type_c">전화</label>
                                    </div>
                                </td>
                                <th>상태</th>
                                <td>
                                    <c:forEach items="${codeMap['APPR_PROC_STATUS']}" var="item">
                                        <c:if test="${item.code_value ne '02' and item.code_value ne '04' and item.code_value ne '06'}">
                                            <div class="form-check form-check-inline">
                                                <input type="checkbox" id="${item.code_value}" name="s_appr_proc_status_cd" class="form-check-input" ${(item.code_value == "01" || item.code_value == "03" ? 'checked' : '')} value="${item.code_value}">
                                                <label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                    <!-- 미작성 삭제 -->
<%--                                    <div class="form-check form-check-inline">--%>
<%--                                        <input type="checkbox" id="s_not_written" name="s_not_written" class="form-check-input" checked value="Y">--%>
<%--                                        <label class="form-check-label" for="s_not_written">미작성</label>--%>
<%--                                    </div>--%>
                                </td>
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
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <div class="form-check form-check-inline">
                                    <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                        <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                        <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                                    </c:if>
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
                            <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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