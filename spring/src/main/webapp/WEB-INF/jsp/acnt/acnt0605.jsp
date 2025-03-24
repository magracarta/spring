<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > 개인고과평가
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var auiGrid4Excel;
        var orgAuthSecondDepth = ${orgAuthSecondDepth};

        $(document).ready(function () {
            // 그리드 생성
            createAUIGrid();
            createExcelAUIGrid();
            fnInit();
        });

        function fnInit() {
            // 전체 부서 조회 권한
            if("${showYn}" != "Y") {
                $("#s_org_code").prop("disabled", true);
            }

            goSearch();
            fnSetOrgAuthCode();
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

        function goSearch() {
            var param = {
                "s_regular_st_dt": $M.getValue("s_regular_st_dt"),
                "s_org_code" : $M.getValue("s_org_code"),
                "s_mem_name" : $M.getValue("s_mem_name"),
                "s_start_work_year" : $M.getValue("s_start_work_year"),
                "s_end_work_year" : $M.getValue("s_end_work_year"),
                "s_work_status_yn" : $M.getValue("s_work_status_yn"),  // 퇴사자제외
                "up_org_code" : $M.getValue("s_org_auth_code"), // 부서권한 1단
                "s_auth_org_code" : $M.getValue("s_second_org_auth_code"), // 부서권한 2단
            };

            $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method: "GET"},
                function (result) {
                    if (result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.setGridData(auiGrid, result.list);
                    }
                }
            );
        }

        // 엑셀다운로드
        function fnExcelDownload() {
            fnExportExcel(auiGrid, "고과평가관리");
        }

        // 그리드 생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true
            };

            var columnLayout = [
                {
                    headerText: "부서",
                    dataField: "org_name",
                    width: "60",
                },
                {
                    headerText: "직원명",
                    dataField: "mem_name",
                    width: "60",
                    minWidth: "50",
                    style: "aui-center aui-popup"
                },
                {
                    headerText: "부서권한",
                    dataField: "auth_org_name",
                    width: "100",
                },
                {
                    headerText: "입사일",
                    dataField: "ipsa_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width: "70",
                    minWidth: "60"
                },
                {
                    headerText: "수습해지일자",
                    dataField: "regular_st_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width: "80",
                    minWidth: "70"
                },
                {
                    headerText: "근무일수",
                    dataField: "work_day",
                    width: "70",
                    minWidth: "60",
                    dataType: "numeric",
                    formatString: "#,###",
                },
                {
                    headerText: "근무개월수",
                    dataField: "work_mon",
                    width: "70",
                    minWidth: "60"
                },
                {
                    headerText: "근무년차",
                    dataField: "work_year",
                    width: "70",
                    minWidth: "60"
                },
                {
                    headerText: "현 계약조건",
                    children : [
                        {
                            headerText: "계약기간",
                            dataField : "term",
                            width: "160",
                            minWidth: "150",
                            labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                                return value.length == 3 ? "" : value;
                            }
                        },
                        {
                            headerText: "연봉액",
                            dataField : "total_salary_amt",
                            width: "85",
                            style: "aui-right",
                            dataType: "numeric",
                            formatString: "#,###",
                        },
                        {
                            headerText: "월급여",
                            dataField: "mon_salary_amt",
                            width: "80",
                            style: "aui-right",
                            dataType: "numeric",
                            formatString: "#,###",
                        },
                    ]
                },
                {
                    headerText: "인사고과",
                    children: [
                        {
                            headerText: "기본",
                            dataField: "base_salary_amt",
                            width: "85",
                            style: "aui-right",
                            dataType: "numeric",
                            formatString: "#,###",
                        },
                        {
                            headerText: "취득",
                            dataField: "total_ability_amt",
                            width: "80",
                            style: "aui-right",
                            dataType: "numeric",
                            formatString: "#,###",
                        }
                  ]
                },
                {
                    headerText: "급여계",
                    children: [
                        {
                            headerText: "연봉",
                            dataField: "annual_salary",
                            width: "85",
                            style: "aui-right",
                            dataType: "numeric",
                            formatString: "#,###",
                        },
                        {
                            headerText: "월급",
                            dataField: "monthly_salary",
                            width: "80",
                            minWidth: "90",
                            style: "aui-right",
                            dataType: "numeric",
                            formatString: "#,###",
                        }
                    ]
                },
                {
                    headerText: "분기 별 평가결과",
                    children: [
                        {
                            headerText: "1/4",
                            dataField: "q1_eval_point",
                            width: "40",
                            style: "aui-center",
                        },
                        {
                            headerText: "2/4",
                            dataField: "q2_eval_point",
                            width: "40",
                            style: "aui-center",
                        },
                        {
                            headerText: "3/4",
                            dataField: "q3_eval_point",
                            width: "40",
                            style: "aui-center",
                        },
                        {
                            headerText: "4/4",
                            dataField: "q4_eval_point",
                            width: "40",
                            style: "aui-center",
                        },
                    ]
                },
                {
                    headerText: "업무결재번호",
                    dataField: "appr_job_seq",
                    visible: false
                },
                {
                    headerText: "결재",
                    dataField: "path_appr_job_status_name",
                    style: "aui-left"
                },
                {
                    headerText: "직원번호",
                    dataField: "mem_no",
                    visible: false
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                // 직원명 셀 클릭 이벤트
                if (event.dataField == "mem_name") {
                    var param = {
                        "s_mem_no": event.item.mem_no
                    };
                    var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
                    $M.goNextPage("/acnt/acnt0605p01", $M.toGetParam(param), {popupStatus: popupOption, method: "post"});
                }
            });
        }

        function fnSetServiceAbility() {
        }

        /**
         * 부서권한 1단 콤보 선택 시 2단 콤보 리스트 생성
         */
        function fnSetOrgAuthCode() {
            var orgCode = $M.getValue("s_org_auth_code");
            var select = $("#s_second_org_auth_code");

            // clear
            $("#s_second_org_auth_code option").remove();
            select.append(new Option("- 전체 -", ""));

            if (orgAuthSecondDepth.hasOwnProperty(orgCode)) {
                var authList = orgAuthSecondDepth[orgCode];
                for (var item in authList) {
                    select.append(new Option(authList[item].org_kor_name, authList[item].org_code));
                }
            }
        }

        // 평가결과 엑셀다운로드
        function fnDownloadExcel() {

            // 소속원 평가결과 데이터 조회
            var param = {
                "s_year": $M.getValue("s_regular_st_dt"), // 조회년도
                "s_mem_no_arr" : AUIGrid.getGridData(auiGrid).map(data => data.mem_no)
            };

            $M.goNextPageAjax(this_page + '/search/excel', $M.toGetParam(param), {method: "GET"},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGrid4Excel, result.list);
                        fnExportExcel(auiGrid4Excel, "소속원 평가결과");
                        AUIGrid.clearGridData(auiGrid4Excel);
                    }
                }
            );
        }

        // 평가결과 엑셀다운로드용 그리드 생성
        function createExcelAUIGrid() {
            var gridPros = {};

            var columnLayout = [
                {
                    headerText: "부서",
                    dataField: "org_name",
                },
                {
                    headerText: "직원명",
                    dataField: "mem_name",
                },
                {
                    headerText: "직책",
                    dataField: "job_name",
                },
                {
                    headerText: "년",
                    dataField: "eval_year",
                },
                {
                    headerText: "월",
                    dataField: "eval_month",
                },
                {
                    headerText: "평가자",
                    dataField: "eval_mem_name",
                },
                {
                    headerText: "평가내용",
                    dataField: "eval_text",
                    width: "300",
                },
                {
                    headerText: "평점",
                    dataField: "eval_point",
                },
            ];
            auiGrid4Excel = AUIGrid.create("#auiGrid4Excel", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid4Excel, []);
        }

        // 분기별 평가결과 일괄작성 팝업 호출
        function goPopupQuarterEval() {
            var param = {
            };
            $M.goNextPage("/acnt/acnt0605p10", $M.toGetParam(param), {popupStatus: ""});
        }
    </script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="65px">
                                <col width="80px">
                                <col width="40px">
                                <col width="100px">
                                <col width="65px">
                                <col width="220px"> <%-- 부서권한 --%>
                                <col width="50px">
                                <col width="80px">
                                <col width="65px">
                                <col width="136px">
                                <col width="110px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년도</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-auto">
                                            <select class="form-control" id="s_regular_st_dt" name="s_regular_st_dt">
                                                <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                                    <c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
                                                    <option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                </td>
                                <th>부서</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <select id="s_org_code" name="s_org_code" class="form-control">
                                                <option value="">- 전체 -</option>
                                                <c:forEach items="${list}" var="item">
                                                    <option value="${item.org_code}" <c:if test="${item.org_code eq inputParam.s_org_code}">selected</c:if> >${item.org_name}</option>
                                                </c:forEach>
                                                <c:forEach var="list" items="${codeMap['WAREHOUSE']}">
                                                    <c:if test="${list.code_value ne '6000' and list.code_v2 eq 'Y'}">
                                                        <option value="${list.code_value}" <c:if test="${list.code_value eq inputParam.s_org_code}">selected</c:if> >${list.code_name}</option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                </td>
                                <th>부서권한</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <select class="form-control" id="s_org_auth_code" name="s_org_auth_code" onchange="fnSetOrgAuthCode()">
                                                <option value="">- 전체 -</option>
                                                <c:forEach var="list" items="${orgAuthOneDepth}">
                                                    <option value="${list.org_code}">
                                                            ${list.org_name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-7">
                                            <select class="form-control" id="s_second_org_auth_code" name="s_second_org_auth_code"></select>
                                        </div>
                                    </div>
                                </td>
                                <th>직원명</th>
                                <td>
                                    <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                </td>
                                <th>근무년차</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width60px">
                                            <input type="text" class="form-control" id="s_start_work_year" name="s_start_work_year" placeholder="From">
                                        </div>
                                        <div class="col width16px text-center">~</div>
                                        <div class="col width60px">
                                            <input type="text" class="form-control" id="s_end_work_year" name="s_end_work_year" placeholder="To">
                                        </div>
                                    </div>
                                </td>
                                <td class="pl15">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_work_status_yn" name="s_work_status_yn" value="Y" checked="checked">
                                        <label class="form-check-label" for="s_work_status_yn">퇴사자제외</label>
                                    </div>
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <button type="button" class="btn btn-primary-gra" onclick="goPopupQuarterEval()">분기별 평가결과 일괄작성</button>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /조회결과 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
                    <div class="btn-group mt5">
                        <div class="left">
                            총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>
                    </div>
                    <!-- 평가결과 엑셀다운로드용 그리드 -->
                    <div class="dpn" id="auiGrid4Excel"></div>
                </div>
            </div>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>