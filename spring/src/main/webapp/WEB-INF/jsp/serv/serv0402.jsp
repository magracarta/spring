<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 서비스미결/예정 > null > null
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
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
            // AUIGrid 생성
            createAUIGrid();
            fnInit();

            goSearch();
        });

        function fnInit() {
            var orgType = "${inputParam.org_type}";
            if (orgType != "BASE") {
                $("#s_org_code").prop("disabled", true);
            }

            // 업무일지
            if ("${inputParam.s_work_gubun}" == "Y") {
                $("input[name=s_org_code]").prop("disabled", true);
                $M.setValue("s_as_todo_status", "0");
                $M.setValue("s_date_type", "plan_dt");

                $M.setValue("s_start_dt", "${inputParam.s_start_dt}");
                $M.setValue("s_end_dt", "${inputParam.s_end_dt}");
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
            };
            var columnLayout = [
                {
                    headerText: "정비일",
                    dataField: "todo_dt",
                    style: "aui-center",
                    width: "80",
                    minWidth: "70",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
                {
                    headerText: "상담구분",
                    dataField: "service_type",
                    style: "aui-center aui-popup",
                    width: "80",
                    minWidth: "70"
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    style: "aui-center",
                    width: "80",
                    minWidth: "70"
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    style: "aui-center",
                    width: "150",
                    minWidth: "140"
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    style: "aui-center",
                    width: "150",
                    minWidth: "140"
                },
                {
                    headerText: "휴대폰",
                    dataField: "hp_no",
                    style: "aui-center",
                    width: "100",
                    minWidth: "90"
                },
                {
                    headerText: "담당자",
                    dataField: "assign_mem_name",
                    style: "aui-center",
                    width: "80",
                    minWidth: "70"
                },
                {
                    headerText: "작업구분",
                    dataField: "as_todo_type_name",
                    style: "aui-center",
                    width: "80",
                    minWidth: "70"
                },
                {
                    headerText: "미결사항",
                    dataField: "todo_text",
                    width: "240",
                    minWidth: "230",
                    style: "aui-left",
                },
                {
                    headerText: "예정일",
                    dataField: "plan_dt",
                    style: "aui-center",
                    width: "80",
                    minWidth: "70",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
                {
                    headerText: "처리사항",
                    dataField: "proc_text",
                    width: "240",
                    minWidth: "230",
                    style: "aui-left",
                    headerStyle: "aui-fold"
                },
                {
                    headerText: "처리일시",
                    dataField: "proc_date",
                    style: "aui-center",
                    width: "80",
                    minWidth: "70",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    headerStyle: "aui-fold"
                },
                {
                    dataField: "as_no",
                    visible: false
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "service_type") {
                    var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=850, left=0, top=0";
                    var params = {
                        "s_as_no": event.item.as_no
                    };

                    switch (event.item.service_type) {
                        case "전화상담" :
                            $M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
                            break;
                        case "정비일지" :
                            $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                            break;
                        case "출하일지"    :
                            $M.goNextPage('/serv/serv0102p12', $M.toGetParam(params), {popupStatus: popupOption});
                            break;
                        default :
                            params = {
                                "__s_machine_seq" : event.item.machine_seq,
                                "__s_as_no" : '',
                                "__page_type" : $M.nvl($M.getValue("page_type"), "N"),
                                "parent_js_name" : "fnSetJobOrder"
                            };
                            var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
                            $M.goNextPage('/serv/serv0101p07', $M.toGetParam(params), {popupStatus : popupOption});
                            break;
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

        function enter(fieldObj) {
            var field = ["s_body_no", "s_hp_no"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch(document.main_form);
                }
            });
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
            if ($M.getValue("s_start_dt") != "" && $M.getValue("s_end_dt") != "") {
                if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                    return;
                }
            }
            var param = {
                "s_date_type": $M.getValue("s_date_type"),
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_machine_name": $M.getValue("s_machine_name"),
                "s_body_no": $M.getValue("s_body_no"),
                "s_hp_no": $M.getValue("s_hp_no"),
                "s_cust_no": $M.getValue("s_cust_no"),
                "s_as_todo_type_cd": $M.getValue("s_as_todo_type"),
                "s_as_todo_status_cd": $M.getValue("s_as_todo_status"),
                "s_org_code": $M.getValue("s_org_code"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "s_work_gubun" : $M.getValue("s_work_gubun"),
                "page": page,
                "rows": $M.getValue("s_rows")
            }
            // _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    isLoading = false;
                    if (result.success) {
                        successFunc(result);
                    }
                }
            );
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

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "장비입고관리");
        }

        function fnSetJobOrder() {
            // 해당 화면에서는 아무것도 안함
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="s_work_gubun" name="s_work_gubun" value="${inputParam.s_work_gubun}">
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
                                <col width="50px">
                                <col width="240px">
                                <col width="70px">
                                <col width="100px">
                                <col width="50px">
                                <col width="100px">
                                <col width="50px">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <td>
                                    <select id="s_date_type" name="s_date_type" class="form-control">
                                        <option value="todo_dt">정비일자</option>
                                        <option value="plan_dt">예정일자</option>
                                    </select>
                                </td>
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

                                        <!-- <details data-popover="up">

										</details> -->
										<c:if test="${inputParam.s_work_gubun ne 'Y'}">
	                                        <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
	                                            <jsp:param name="st_field_name" value="s_start_dt"/>
	                                            <jsp:param name="ed_field_name" value="s_end_dt"/>
	                                            <jsp:param name="click_exec_yn" value="Y"/>
	                                            <jsp:param name="exec_func_name" value="goSearch();"/>
	                                        </jsp:include>
                                        </c:if>
                                    </div>
                                </td>
                                <th>고객명</th>
                                <td>
                                    <jsp:include page="/WEB-INF/jsp/common/searchCust.jsp">
                                        <jsp:param name="required_field" value=""/>
                                        <jsp:param name="execFuncName" value=""/>
                                        <jsp:param name="focusInFuncName" value=""/>
                                    </jsp:include>
                                </td>
                                <th>모델명</th>
                                <td>
                                    <jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
                                        <jsp:param name="s_maker_cd" value=""/>
                                    </jsp:include>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tbody>
                        </table>
                        <table class="table table-fixed">
                            <colgroup>
                                <col width="50px">
                                <col width="120px">
                                <col width="50px">
                                <col width="120px">
                                <col width="60px">
                                <col width="80px">
                                <col width="40px">
                                <col width="60px">
                                <col width="40px">
                                <%--                                <col width="80px">--%>
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>차대번호</th>
                                <td>
                                    <input type="text" id="s_body_no" name="s_body_no" class="form-control">
                                </td>
                                <th>휴대폰</th>
                                <td>
                                    <input type="text" id="s_hp_no" name="s_hp_no" class="form-control">
                                </td>
                                <th>작업구분</th>
                                <td>
                                    <select id="s_as_todo_type" name="s_as_todo_type" class="form-control">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${codeMap['AS_TODO_TYPE']}" var="item">
                                            <option value="${item.code_value}">${item.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>상태</th>
                                <td>
                                    <select id="s_as_todo_status" name="s_as_todo_status" class="form-control">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${codeMap['AS_TODO_STATUS']}" var="item">
                                            <option value="${item.code_value}" <c:if test="${item.code_value eq '0'}">selected="selected"</c:if> >${item.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>부서</th>
                                <td>
                                    <select class="form-control width80px" id="s_org_code" name="s_org_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="item" items="${orgCenterList}">
                                            <option value="${item.org_code}" <c:if test="${item.org_code eq inputParam.org_code}">selected</c:if> >${item.org_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
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
                    <!-- 그리드 서머리, 컨트롤 영역 -->
                    <div class="btn-group mt5">
                        <div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                        </div>
                    </div>
                    <!-- /그리드 서머리, 컨트롤 영역 -->
                </div>

            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>