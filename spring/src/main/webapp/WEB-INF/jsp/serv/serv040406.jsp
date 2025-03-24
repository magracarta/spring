<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > 정기검사 Call > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-21 19:54:29
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
            // AUIGrid 생성
            createAUIGrid();
            fnInit();
        });

        function fnInit() {
            var now = $M.getCurrentDate("yyyyMMdd");

            if ("${inputParam.s_work_gubun}" != "Y") {
                $M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -12));
                $M.setValue("s_end_dt", $M.toDate(now));
            }

            if ("${inputParam.s_work_gubun}" == "Y") {
                $M.setValue("s_total_search", "Y");
                $M.setValue("s_treat_yn", "");

            }

            var org = ${orgBeanJson};
            if (org.org_gubun_cd != "BASE") {
                $("#s_center_org_code").prop("disabled", true);
            }
            goSearch();
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "row",
                showRowNumColumn: true,
                enableFilter :true,
            };
            var columnLayout = [
                {
                    headerText: "고객명",
                    dataField: "cust_name",
					width : "155", 
					minWidth : "155",
                    style: "aui-center",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
					width : "130", 
					minWidth : "130",
                    style: "aui-left",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
					width : "160", 
					minWidth : "160",
                    style: "aui-center aui-popup",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "연락처",
                    dataField: "hp_no",
					width : "120", 
					minWidth : "120",
                    style: "aui-center",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "판매일자",
                    dataField: "out_dt",
                    style: "aui-center",
                    dataType: "date",
					width : "90", 
					minWidth : "90",
                    formatString: "yy-mm-dd",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "검사예정",
                    dataField: "deadline_dt",
                    style: "aui-center",
                    dataType: "date",
					width : "90", 
					minWidth : "90",
                    formatString: "yy-mm-dd",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "차수",
                    dataField: "seq_no",
					width : "60", 
					minWidth : "60",
                    style: "aui-center",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "담당센터",
                    dataField: "center_org_name",
					width : "100", 
					minWidth : "100",
                    style: "aui-center",
					filter : {
						showIcon : true
					},
                },
                {
                    headerText: "Call 일자",
                    dataField: "as_dt",
                    style: "aui-center aui-popup",
                    dataType: "date",
                    formatString: "yy-mm-dd",
   					width : "90", 
   					minWidth : "90",
					filter : {
						showIcon : true,
						displayFormatValues : true,
					},
                    styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        return "aui-grid-selection-row-satuday-bg";
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        if (item.treat_yn == "N" && value != "") {
                            return "작성중";
                        } else if (item.treat_yn == "N" && value == "") {
                            return "일지등록"
                        } else if (item.treat_yn == "Y") {
                            return value;
                        }
                    },
                },
                {
                    headerText: "AS번호",
                    dataField: "as_no",
                    visible: false
                },
                {
                    headerText: "장비대장번호",
                    dataField: "machine_seq",
                    visible: false
                },
                {
                    headerText: "일지상태",
                    dataField: "treat_yn",
                    visible: false
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
                if (event.dataField == "as_dt") {
                    var params = {
                        "as_call_type_cd": "8"
                    };
                    if (event.item.as_no == "") {
                        params.s_machine_seq = event.item.machine_seq;
                        $M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
                    } else {
                        params.s_as_no = event.item.as_no;
                        $M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
                    }
                }

                if (event.dataField == "body_no") {
                    var params = {
                        "s_machine_seq": event.item.machine_seq
                    };

                    $M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
                }
            });

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
        }

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "정기검사Call");
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
            var param = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_center_org_code": $M.getValue("s_center_org_code"),
                "s_treat_yn": $M.getValue("s_treat_yn"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "s_total_search": $M.getValue("s_total_search"),
                "page": page,
                "rows": $M.getValue("s_rows")
            };

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

        // 정기검사 유효기간 안내
        function goPopupCheckCycleInfo() {
            openCheckCycleInfoPanel('setCheckCycleInfoPanel');
        }

        function setCheckCycleInfoPanel() {
        }
    </script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
    <input type="hidden" id="s_total_search" name="s_total_search">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="60px">
                                <col width="250px">
                                <col width="70px">
                                <col width="100px">
                                <col width="70px">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>예정일자</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width110px">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="조회 시작일" value="${inputParam.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col width16px text-center">~</div>
                                        <div class="col width120px">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="조회 완료일" value="${inputParam.s_end_dt}">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <th>담당센터</th>
                                <td>
                                    <select class="form-control" id="s_center_org_code" name="s_center_org_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${orgCenterList}" var="item">
                                            <option value="${item.org_code}" <c:if test="${item.org_code eq orgBean.org_code}">selected="selected"</c:if> >${item.org_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>일지상태</th>
                                <td>
                                    <select id="s_treat_yn" name="s_treat_yn" class="form-control">
                                        <option value="">- 전체 -</option>
                                        <option value="N" selected="selected">미결</option>
                                    </select>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 정기검사 Call 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>정기검사 Call 조회결과</h4>
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
                    <!-- /정기검사 Call 조회결과 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <div class="btn-group mt5">
                        <div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>