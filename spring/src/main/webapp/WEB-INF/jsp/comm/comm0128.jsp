<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%--
-- 업   무 : 공통 > 기준정보 > 라인백업관리
-- 작성자 : 황다은
-- 최초 작성일 : 2024-04-15
--%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGrid;
        var page = 1;
        var moreFlag = "N";
        var isLoading = false;

        $(document).ready(function () {
            createAUIGrid();
        });

        function goDetailPopup1(rowIndex) {
            var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
            var param = {};
            var url = "";
            if (item.backup_type_cd == '01') {    // 신차계약서류
                param = {
                    machine_doc_no: item.mng_no
                }
                url = '/sale/sale0101p01';
            } else if (item.backup_type_cd == '02') { // 정비지시서
                param = {
                    s_job_report_no: item.mng_no
                }
                url = '/serv/serv0101p01';
            } else if (item.backup_type_cd == '03') { // 렌탈계약서
                param = {
                    rental_doc_no: item.mng_no
                }
                url = '/rent/rent0102p01';
            } else if (item.backup_type_cd == '04') {    // 선적관련서류
                param = {
                    machine_lc_no: item.mng_no
                };
                url = '/sale/sale0203p01';
            }

            var poppupOption = "";

            $M.goNextPage(url, $M.toGetParam(param), {popupStatus: poppupOption});
        }

        function goDetailPopup2(rowIndex) {
            var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
            var param = {};
            var url = "";

            if (item.backup_type_cd == '01') {    // 신차계약서류
                param = {
                    machine_doc_no: item.mng_no
                }
                if (item.add_1 == "") {
                    alert("출하의뢰서가 존재하지 않습니다.");
                    return false;
                }
                url = '/sale/sale0101p03';
            } else if (item.backup_type_cd == '04') {    // 선적관련서류
                param = {
                    machine_lc_no: item.mng_no
                }
                url = '/sale/sale0203p05'
            }


            var poppupOption = "";

            $M.goNextPage(url, $M.toGetParam(param), {popupStatus: poppupOption});
        }

        // 조회
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

        function fnSearch(successFunc) {
            isLoading = true;

            var param = {
                s_start_dt: $M.getValue("s_start_dt"),
                s_end_dt: $M.getValue("s_end_dt"),
                s_backup_type_cd: $M.getValue("s_backup_type_cd"),
                s_back_not_yn: $M.getValue("s_back_not_yn"),
                s_line_not_yn: $M.getValue("s_line_not_yn"),
                s_back_target_yn: $M.getValue("s_back_target_yn"),
                "page": page,
                "rows": $M.getValue("s_rows")
            }
            _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    isLoading = false;
                    if (result.success) {
                        successFunc(result);
                    }
                    ;
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

        // 액셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "라인백업관리목록");
        }


        function fnBackupAndSync(button, reqType) {
            var param = {};

            if(reqType == "date") {
                param = {
                    s_start_dt: $M.getValue("s_start_dt"),
                    s_end_dt: $M.getValue("s_end_dt"),
                    s_backup_type_cd: $M.getValue("s_backup_type_cd")
                }
            } else {
                var items = AUIGrid.getCheckedRowItemsAll(auiGrid);

                if (items.length == 0) {
                    alert("체크된 데이터가 없습니다.");
                    return false
                }
                param = {
                    s_start_dt: $M.getValue("s_start_dt"),
                    s_end_dt: $M.getValue("s_end_dt"),
                    mng_no_str: $M.getArrStr(items, {key: 'mng_no'}),
                    backup_type_cd_str: $M.getArrStr(items, {key: 'backup_type_cd'})
                }
            }

            // 공통값 넣기
            param.req_type = reqType;
            param.button = button;

            var msg = button == 'backup' ? "백업 하시겠습니까?" : "동기화 하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, this_page + "/backupAndSync", $M.toGetParam(param), {method: 'POST', timeout : 108000000},    // timeout: 3시간
                function (result) {
                    if (result.success) {
                        goSearch();
                    }
                }
            );
        }


        // 검색란에 백업버튼
        function fnLineBackupToDate() {
            fnBackupAndSync('backup','date');
        }

        // 검색란에 동기화 버튼
        function fnSyncLineToDate() {
            fnBackupAndSync('sync','date');
        }

        // 백업 버튼
        function fnLineBackupToChecked() {
            fnBackupAndSync('backup','checked');
        }

        // 동기화 버튼
        function fnSyncLineToChecked() {
            fnBackupAndSync('sync','checked');
        }

        // 그리드 생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "mng_no",
                showRowNumColumn: true,
                // 체크박스 표시 설정
                showRowCheckColumn: true,
                // 전체 체크박스 표시 설정
                showRowAllCheckBox: true,
            };

            // 컬럼레이아웃
            var columnLayout = [
                {
                    headerText: "등록일자",
                    dataField: "backup_dt",
                    width: "8%",
                    style: "aui-center",
                    editable: true,
                    dataType: "date",
                    formatString: "yyyy-mm-dd"
                },
                {
                    headerText: "타입",
                    dataField: "backup_type_name",
                    width: "8%",
                    style: "aui-center",
                    editable: true
                },
                {
                    dataField: "backup_type_cd",
                    visible: false
                },
                {
                    headerText: "관리번호",
                    dataField: "mng_no",
                    width: "10%",
                    style: "aui-center",
                    editable: true
                },
                {
                    headerText: "문서명",
                    dataField: "remark",
                    width: "25%",
                    style: "aui-center",
                    editable: true
                },
                {
                    headerText: "파일수",
                    dataField: "cnt_1",
                    width: "7%",
                    style: "aui-center",
                    editable: true,
                    renderer: { // HTML 템플릿 렌더러 사용
                        type: "TemplateRenderer"
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) { // HTML 템플릿 작성
                        var backType = item.backup_type_cd;

                        var template = '';
                        template += '<div class="my_div">';
                        template += '   <div class="aui-grid-renderer-base" style="padding: 0px 4px; white-space: nowrap; display: inline-block; width: 35%; max-height: 24px;">';
                        template += '       <span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goDetailPopup1(' + rowIndex + ')">' + value + '</span></div>'

                        if(backType == '01' || backType == '04') {
                            template += '<div class="aui-grid-renderer-base" style="padding: 0px 4px; white-space: nowrap; display: inline-block; width: 35%; max-height: 24px;">';
                            template += '   <span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goDetailPopup2(' + rowIndex + ')">' + item.cnt_2 + '</span></div>';
                        }
                        template += '</div>';

                        return template; // HTML 형식의 스트링
                    },
                },
                {
                    dataField: "cnt_2",
                    visible: false
                },
                {
                    headerText: "백업정보",
                    children: [
                        {
                            headerText: "원본파일",
                            dataField: "mng_cnt",
                            width: "5%",
                            style: "aui-right",
                            editable: false,
                            headerTooltip: { // 헤더 툴팁 표시 HTML 양식
                                show: true,
                                tooltipHtml: '<div>원본 파일</div>'
                            }
                        },
                        {
                            headerText: "백업현황",
                            dataField: "back_status",  //수정하기
                            width: "5%",
                            style: "aui-right aui-link",
                            editable: false,
                            headerTooltip: { // 헤더 툴팁 표시 HTML 양식
                                show: true,
                                tooltipHtml: '<div>백업 파일 생성 / 원본 파일</div>'
                            },
                        },
                        {
                            headerText: "전송현황",
                            dataField: "back_ok_cnt",
                            width: "5%",
                            style: "aui-right",
                            editable: false,
                            headerTooltip: { // 헤더 툴팁 표시 HTML 양식
                                show: true,
                                tooltipHtml: '<div>라인 연동 / 백업 파일 생성</div>'
                            }
                        },
                        {
                            headerText: "동기화 수",
                            dataField: "sync_ok_cnt",
                            width: "5%",
                            style: "aui-right",
                            editable: false,
                            headerTooltip: { // 헤더 툴팁 표시 HTML 양식
                                show: true,
                                tooltipHtml: '<div>라인 연동 / 원본 파일</div>'
                            }
                        }
                    ]
                }
            ];
            // 실제로 #grid_wrap에 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

            // 팝업창 이벤트
            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=650, left=0, top=0";
                if(event.dataField == "back_status") {
                    var params = {
                        "backup_dt": event.item.backup_dt,
                        "mng_no": event.item.mng_no,
                        "backup_type_name": event.item.backup_type_name,
                        "backup_type_cd": event.item.backup_type_cd,
                        "remark": event.item.remark,
                        "back_cnt": event.item.back_cnt
                    };
                    $M.goNextPage('/comm/comm0128p01', $M.toGetParam(params), {popupStatus : popupOption});
                }
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
                <%-- 검색영역 --%>
                <div class="search-wrap">
                    <table class="table">
                        <colgroup>
                            <col width="80px">
                            <col width="260px">
                            <col width="50px">
                            <col width="150px">
                            <col width="350px">
                            <col width="400px">
                            <col width="50px">
                            <col width="50px">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>등록일자</th>
                            <td>
                                <div class="form-row inline-pd">
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate"
                                                   id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd"
                                                   alt="등록 시작일" value="${searchDtMap.s_start_dt}">
                                        </div>
                                    </div>
                                    <div class="col-auto">~</div>
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_end_dt"
                                                   name="s_end_dt" dateFormat="yyyy-MM-dd" alt="등록 종료일"
                                                   value="${searchDtMap.s_end_dt}">
                                        </div>
                                    </div>
                                    <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                        <jsp:param name="st_field_name" value="s_start_dt"/>
                                        <jsp:param name="ed_field_name" value="s_end_dt"/>
                                        <jsp:param name="click_exec_yn" value="Y"/>
                                        <jsp:param name="exec_func_name" value="goSearch();"/>
                                    </jsp:include>
                                </div>
                            </td>
                            <th>타입</th>
                            <td>
                                <select class="form-control" id="s_backup_type_cd" name="s_backup_type_cd"
                                        style="width: 120px">
                                    <option value="">- 전체 -</option>
                                    <c:forEach var="list" items="${codeMap['BACKUP_TYPE']}">
                                        <option value="${list.code_value}">${list.code_name}</option>
                                    </c:forEach>
                                </select>
                            </td>
                            <td>
                                <div class="form-check form-check-inline checkline">
                                    <label><input class="form-check-input" type="checkbox" id="s_back_target_yn" checked="checked"
                                                  name="s_back_target_yn" value="Y">백업대상여부</label>
                                </div>
                                <div class="form-check form-check-inline checkline">
                                    <label><input class="form-check-input" type="checkbox" id="s_back_not_yn"
                                                  name="s_back_not_yn" value="Y">백업미생성자료</label>
                                </div>
                                <div class="form-check form-check-inline checkline">
                                    <label><input class="form-check-input" type="checkbox" id="s_line_not_yn"
                                                  name="s_line_not_yn" value="Y">전송미완료자료</label>
                                </div>
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 50px;"
                                        onclick="javascript:goSearch();">조회
                                </button>
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 60px;"
                                        onclick="javascript:fnBackupAndSync('backup','date');">백업
                                </button>
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 60px;"
                                        onclick="javascript:fnBackupAndSync('sync','date');">동기화
                                </button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <%-- /검색영역 --%>
                <%-- 그리드 타이틀, 컨트롤 영역--%>
                <div class="title-wrap mt10">
                    <h4>조회결과</h4>
                    <div class="btn-group">
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                <jsp:param name="pos" value="TOP_R"/>
                            </jsp:include>
                        </div>
                    </div>
                </div>
                <%-- /그리드 타이틀, 컨트롤 영역--%>

                <div id="auiGrid" style="height: 555px; margin-top: 5px;"></div>

                <div class="btn-group mt5">
                    <div class="left">
                        <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
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
