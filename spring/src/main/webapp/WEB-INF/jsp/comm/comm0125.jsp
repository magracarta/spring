<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > QR코드관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-06-05 13:32:00
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
            goSearch();
        });

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_body_no", "s_cust_name", "s_part_no", "s_attach_name"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
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

        // 검색기능
        function fnSearch(successFunc) {
            isLoading = true;
            var param = {
                "s_start_dt" : $M.getValue("s_start_dt"),
                "s_end_dt" : $M.getValue("s_end_dt"),
                "s_body_no" : $M.getValue("s_body_no"),
                "s_cust_name" : $M.getValue("s_cust_name"),
                "s_part_no" : $M.getValue("s_part_no"),
                "s_attach_name" : $M.getValue("s_attach_name"),
                "s_assign_yn" : $M.getValue("s_assign_yn"),
                "page": page,
                "rows": $M.getValue("s_rows")
            };
            _fnAddSearchDt(param, 's_start_dt', 's_end_dt');

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
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
                showRowCheckColumn : true,
                showRowAllCheckBox : true,
            };

            // 컬럼레이아웃
            var columnLayout = [
                {
                    headerText: "QR코드",
                    dataField: "qr_no",
                    width: "8%",
                    style: "aui-popup"
                },
                {
                    headerText: "등록일자",
                    dataField: "assign_dt",
                    width: "8%",
                    style: "aui-center",
                    dataType: "date",
                    formatString: "yyyy-mm-dd"
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width : "12%",
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width : "10%",
                    style: "aui-center"
                },
                {
                    headerText: "부품번호",
                    dataField: "part_no",
                    width : "8%",
                    style: "aui-center"
                },
                {
                    headerText: "어태치먼트명",
                    dataField: "attach_name",
                    width : "10%",
                    style: "aui-center"
                },
                {
                    headerText: "QR등록여부",
                    dataField: "assign_yn",
                    width : "5%",
                    style: "aui-center"
                },
                {
                    headerText: "비고",
                    dataField: "remark",
                    style: "aui-left"
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "qr_no") {
                    var params = {
                        "qr_no": event.item["qr_no"]
                    };
                    var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
                    $M.goNextPage('/comm/comm0125p01', $M.toGetParam(params), {popupStatus: popupOption});
                }
            });
            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
            $("#auiGrid").resize();
        }

        // QR코드생성
        function goCreateQrNo() {
            if ($M.getValue("qty") == "" || $M.getValue("qty") == 0) {
                alert("수량을 입력해주세요.");
                return false;
            }

            var param = {
                qty : $M.getValue("qty")
            }

            if (confirm("QR코드를 생성하시겠습니까?")) {
                $M.goNextPageAjax(this_page + "/new/save", $M.toGetParam(param) , {method : 'POST'},
                    function(result) {
                        if(result.success) {
                            goSearch();
                        }
                    }
                );
            }
        }

        // QR 프린트
        function fnPrint() {
            var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
            if(rows.length == 0) {
                alert("선택된 데이터가 없습니다.");
                return false;
            }

            var param = {
                "data" : rows
            }
            openReportPanel('comm/comm0125_01.crf', param);
        }
    </script>
</head>
<body>
<!-- contents 전체 영역 -->
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
                    <!-- 기본 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="60px">
                                <col width="260px">
                                <col width="70px">
                                <col width="100px">
                                <col width="60px">
                                <col width="100px">
                                <col width="70px">
                                <col width="120px">
                                <col width="85px">
                                <col width="120px">
                                <col width="90px">
                                <col width="120px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>등록일자</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}">
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
                                <th>차대번호</th>
                                <td>
                                    <div class="icon-btn-cancel-wrap">
                                        <input type="text" id="s_body_no" name="s_body_no" class="form-control">
                                    </div>
                                </td>
                                <th>고객명</th>
                                <td>
                                    <div class="icon-btn-cancel-wrap">
                                        <input type="text" id="s_cust_name" name="s_cust_name" class="form-control">
                                    </div>
                                </td>
                                <th>부품번호</th>
                                <td>
                                    <div class="icon-btn-cancel-wrap">
                                        <input type="text" id="s_part_no" name="s_part_no" class="form-control">
                                    </div>
                                </td>
                                <th>어태치먼트명</th>
                                <td>
                                    <div class="icon-btn-cancel-wrap">
                                        <input type="text" id="s_attach_name" name="s_attach_name" class="form-control">
                                    </div>
                                </td>
                                <th>QR등록여부</th>
                                <td>
                                    <select class="form-control" id="s_assign_yn" name="s_assign_yn" style="width: 100%;">
                                        <option value="">- 전체 -</option>
                                        <option value="Y">등록</option>
                                        <option value="N">미등록</option>
                                    </select>
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
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <span>수량: </span>
                                <input type="text" id="qty" name="qty" style="width: 40px; border-radius: 4px;" format="decimal">
                                <button type="button" class="btn btn-default mr10" onclick="javascript:goCreateQrNo();">QR코드생성</button>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGrid" style="height:555px; margin-top: 5px;"></div>
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
<!-- /contents 전체 영역 -->
</body>
</html>
