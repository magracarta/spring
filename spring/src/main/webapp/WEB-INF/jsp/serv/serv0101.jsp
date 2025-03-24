<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-05 19:54:29
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
            var org = ${orgBeanJson};
            if (org.org_gubun_cd != "BASE") {
                $("#s_center_code").prop("disabled", true);
            }
        }

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_body_no", "s_cust_name", "s_report_no"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
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

            var param = {
                "s_body_no": $M.getValue("s_body_no"),
                "s_cust_name": $M.getValue("s_cust_name"),
                "s_org_code": $M.getValue("s_center_code"),
                "s_job_status_cd": $M.getValue("s_job_status_cd"),
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_date_type": $M.getValue("s_date_type"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "s_report_no": $M.getValue("s_report_no"),
                "page": page,
                "rows": $M.getValue("s_rows")
            };
            _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
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

        // 엑셀 다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "정비지시서");
        }

        // 등록페이지 호출
        function goNew() {
            var popupOption = "";
            var params = {
                "s_popup_yn": "Y"
            };

            $M.goNextPage('/serv/serv010101', $M.toGetParam(params), {popupStatus: popupOption});
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                enableFilter :true,
            };

            var columnLayout = [
                {
                    headerText: "관리번호",
                    dataField: "job_report_no",
                    width : "100",
                    minWidth : "45",
                    style: "aui-center aui-popup",
                    filter : {
		                  showIcon : true
		            },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value.substring(4, 16);
                    }
                },
                {
                    headerText: "센터",
                    dataField: "org_name",
                    width : "80",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText: "상태",
                    dataField: "job_status_name",
                    width : "80",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "고객신청일자",
                    dataField: "request_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width : "90",
                    minWidth : "90",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "상담일자",
                    dataField: "consult_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width : "70",
                    minWidth : "60",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "방문일자",
                    dataField: "visit_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width : "70",
                    minWidth : "60",
                    headerStyle : "aui-fold",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "입고일자",
                    dataField: "in_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width : "70",
                    minWidth : "60",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "완료일자",
                    dataField: "job_ed_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width : "70",
                    minWidth : "60",
                    headerStyle : "aui-fold",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width : "150",
                    minWidth : "140",
                    style: "aui-left",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width : "150",
                    minWidth : "140",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width : "150",
                    minWidth : "140",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "휴대폰",
                    dataField: "hp_no",
                    width : "100",
                    minWidth : "90",
                    headerStyle : "aui-fold",
                    style: "aui-center",
                    editable: true,
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true,
                    },
                    filter : {
		                  showIcon : true
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
                    headerText: "주소",
                    dataField: "addr",
                    headerStyle : "aui-fold",
                    width : "460",
                    minWidth : "100",
                    style: "aui-left",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "담당지역",
                    dataField: "area_si",
                    headerStyle : "aui-fold",
                    style: "aui-center",
                    width : "90",
                    minWidth : "80",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "접수자",
                    dataField: "reg_mem_name",
                    width : "80",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "정비자",
                    dataField: "eng_mem_name",
                    width : "80",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            // 상세팝업
            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "job_report_no") {
                    var params = {
                        "s_job_report_no": event.item["job_report_no"]
                    };
                    var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
                    $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
                }
            });

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

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
                        <table class="table table-fixed">
                            <colgroup>
                                <col width="100px">
                                <col width="260px">
                                <col width="50px">
                                <col width="100px">
                                <col width="70px">
                                <col width="100px">
                                <col width="50px">
                                <col width="100px">
                                <col width="40px">
                                <col width="100px">
                                <col width="60px">
                                <col width="210px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <td>
                                    <select id="s_date_type" name="s_date_type" class="form-control">
                                        <option value="consult_dt">상담일자</option>
                                        <option value="in_dt">입고일자</option>
                                        <option value="visit_dt">방문일자</option>
                                        <option value="job_ed_dt">완료일자</option>
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
                                        <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                            <jsp:param name="st_field_name" value="s_start_dt"/>
                                            <jsp:param name="ed_field_name" value="s_end_dt"/>
                                            <jsp:param name="click_exec_yn" value="Y"/>
                                            <jsp:param name="exec_func_name" value="goSearch();"/>
                                        </jsp:include>
                                    </div>
                                </td>
                                <th>센터</th>
                                <td>
                                    <select class="form-control" name="s_center_code" id="s_center_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="list" items="${codeMap['WAREHOUSE']}">
                                            <c:if test="${list.code_value ne '5010' and list.code_value ne '6000' and list.code_v2 eq 'Y'}">
                                                <option value="${list.code_value}" <c:if test="${list.code_value eq orgBean.org_code}">selected</c:if> >${list.code_name}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>차대번호</th>
                                <td>
                                    <input type="text" id="s_body_no" name="s_body_no" class="form-control">
                                </td>
                                <th>차주명</th>
                                <td>
                                    <input type="text" id="s_cust_name" name="s_cust_name" class="form-control">
                                </td>
                                <th>상태</th>
                                <td>
                                    <select class="form-control" name="s_job_status_cd" id="s_job_status_cd">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="list" items="${codeMap['JOB_STATUS']}">
                                            <c:if test="${list.code_value ne '8'}">
                                            <option value="${list.code_value}" <c:if test="${list.code_value == 0}">selected="selected"</c:if> >${list.code_name}</option>
                                            </c:if>
                                        </c:forEach>
                                        <option value="1">일지미작성</option>
                                    </select>
                                </td>
                                <th>관리번호</th>
                                <td>
                                    <div style="display: inline-block; ">
                                        <input type="search" style="width: 198px; padding: 4px;" class="form-control" placeholder="240101-001 또는 JR20240101-001" name="s_report_no" id="s_report_no" title="입력 시, 다른 조건 무시하고 관리번호로만 조회"
                                               onkeyup=" var start = this.selectionStart; var end = this.selectionEnd; this.value = this.value.toUpperCase(); this.setSelectionRange(start, end); ">
                                    </div>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important mr10" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="text-warning" style="margin-left:10px; width:70%;">
                            ※ 업무 플로우는 고객신청/접수 -> 배정 -> 예약완료 -> 미정산완료-> 완료 순서입니다.
                        </div>
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
                    <div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
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
    </div>
</form>
</body>
</html>