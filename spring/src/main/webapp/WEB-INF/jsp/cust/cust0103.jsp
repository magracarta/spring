<%@ page contentType="text/html;charset=utf-8" language="java" %><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 장비차주변경이력
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-15 14:23:48
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

        $(document).ready(function () {
            createAUIGrid();
            fnInit();
        });

        function fnInit() {
            var popupYn = "${inputParam.s_popup_yn}";
            var bodyNo = "${inputParam.body_no}";

            if (popupYn == "Y") {
                $("#s_cust_name").prop("disabled", true);
                $("#s_body_no").prop("disabled", true);

                $M.setValue("s_body_no", bodyNo);
            }
        }

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_cust_name", "s_body_no"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
        }

        // 엑셀 다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "장비차주변경이력");
        }

        function goSearch() {
            /*
            기간일만으로도 검색이 되게 필수체크 제거(Q&A 15587, 22-07-21, 손광진)
            if ($M.getValue("s_cust_name") == "" && $M.getValue("s_body_no") == "") {
                alert("[고객명, 차대번호] 중 하나는 필수입니다.");
                return;
            }
            */
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

            var params = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_cust_name": $M.getValue("s_cust_name"),
                "s_body_no": $M.getValue("s_body_no"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "page": page,
                "rows": $M.getValue("s_rows")
            };
            _fnAddSearchDt(params, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
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

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
            };

            // AUIGrid 칼럼 설정
            var columnLayout = [
                {
                    headerText: "장비번호",
                    dataField: "machine_seq",
                    visible: false
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width: "160",
                    minWidth: "160",
                    style: "aui-center",
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width: "130",
                    minWidth: "130",
                    style: "aui-left aui-popup",
                },
                {
                    headerText: "변경일",
                    dataField: "change_dt",
                    width: "90",
                    minWidth: "90",
                    style: "aui-center",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
                {
                    headerText: "변경자",
                    dataField: "reg_mem_name",
                    width: "90",
                    minWidth: "90",
                    style: "aui-center",
                },
                {
                    headerText: "변경전",
                    dataField: "before",
                    children: [
                        {
                            headerText: "고객명",
                            dataField: "before_cust_name",
                            style: "aui-center aui-popup",
                            width: "150",
                            minWidth: "150",
                        },
                        {
                            headerText: "고객코드",
                            dataField: "before_cust_no",
                            visible: false
                        },
                        {
                            headerText: "휴대폰",
                            dataField: "before_hp_no",
                            width: "130",
                            minWidth: "130",
                        }
                    ]
                },
                {
                    headerText: "변경후",
                    dataField: "after",
                    children: [
                        {
                            headerText: "고객명",
                            dataField: "after_cust_name",
                            style: "aui-center aui-popup",
                            width: "150",
                            minWidth: "150",
                        },
                        {
                            headerText: "고객코드",
                            dataField: "after_cust_no",
                            visible: false
                        },
                        {
                            headerText: "휴대폰",
                            dataField: "after_hp_no",
                            width: "130",
                            minWidth: "130",
                        }
                    ]
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
                if (event.dataField == "machine_name") {
                    // 보낼 데이터
                    var params = {
                        "s_machine_seq": event.item.machine_seq
                    };

                    $M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
                }

                if (event.dataField == "before_cust_name" && event.item.before_cust_name != "") {
                    var params = {
                        "cust_no": event.item.before_cust_no
                    };

                    $M.goNextPage('/cust/cust0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                }

                if (event.dataField == "after_cust_name" && event.item.after_cust_name != "") {
                    var params = {
                        "cust_no": event.item.after_cust_no
                    };

                    $M.goNextPage('/cust/cust0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                }
            });

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
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
                            <col width="270px">
                            <col width="50px">
                            <col width="130px">
                            <col width="80px">
                            <col width="130px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>변경일</th>
                            <td>
                                <div class="row mg0">
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="변경 시작일" value="${searchDtMap.s_start_dt}">
                                        </div>
                                    </div>
                                    <div class="col-auto">~</div>
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="변경 종료일" value="${searchDtMap.s_end_dt}">
                                        </div>
                                    </div>
                                    <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
		                     		<jsp:param name="st_field_name" value="s_start_dt"/>
		                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
		                     		<jsp:param name="click_exec_yn" value="N"/>
		                     		<jsp:param name="exec_func_name" value="goSearch();"/>
		                     		</jsp:include>	
                                </div>
                            </td>
                            <th>고객명</th>
                            <td>
                                <div class="icon-btn-cancel-wrap">
                                    <input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
                                </div>
                            </td>
                            <th>차대번호</th>
                            <td>
                                <div class="icon-btn-cancel-wrap">
                                    <input type="text" class="form-control" id="s_body_no" name="s_body_no">
                                </div>
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
                    <h4>변경내역</h4>
                    <div class="btn-group">
                        <div class="right">
                            <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                    <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                                </div>
                            </c:if>
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
</form>
</body>
</html>