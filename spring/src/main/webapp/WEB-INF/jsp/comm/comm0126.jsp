<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 영업 > 렌탈어태치먼트QR코드관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-12-04 10:56:34
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
            var field = ["s_attach_name", "s_part_no"];
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
                "s_search_type" : $M.getValue("s_search_type"),
                "s_start_dt" : $M.getValue("s_start_dt"),
                "s_end_dt" : $M.getValue("s_end_dt"),
                "s_mng_org_code" : $M.getValue("s_mng_org_code"),
                "s_own_org_code" : $M.getValue("s_own_org_code"),
                "s_attach_name" : $M.getValue("s_attach_name"),
                "s_part_no" : $M.getValue("s_part_no"),
                "s_sale_include_yn" : $M.getValue("s_sale_include_yn") == "Y" ? "Y" : "N",
                "s_sort_key" : "a.buy_dt desc,",
                "s_sort_method" : "a.rental_attach_no desc",
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

        // 액셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "QR코드관리");
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
            };

            // 컬럼레이아웃
            var columnLayout = [
                {
                    headerText: "등록일자",
                    dataField: "assign_dt",
                    width: "8%",
                    style: "aui-center",
                    dataType: "date",
                    formatString: "yyyy-mm-dd"
                },
                {
                    headerText : "관리센터",
                    dataField : "mng_org_name",
                    width: "7%",
                    style : "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "소유센터",
                    dataField : "own_org_name",
                    width: "7%",
                    style : "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "관리번호",
                    dataField : "rental_attach_no",
                    width: "8%",
                    filter : {
                        showIcon : true
                    },
                    // 그리드 스타일 함수 정의
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (item["assign_yn"] == "Y" && item["qr_no"] != "") {
                            return "aui-popup";
                        }
                        return "aui-center";
                    }
                },
                {
                    headerText : "어태치먼트명",
                    dataField : "attach_name",
                    width: "10%",
                    style : "aui-left",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "부품번호",
                    dataField : "part_no",
                    width: "10%",
                    style : "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "일련번호",
                    dataField : "product_no",
                    width: "7%",
                    style : "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "매입일자",
                    dataField : "buy_dt",
                    dataType : "date",
                    dataInputString : "yyyymmdd",
                    formatString : "yy-mm-dd",
                    width: "8%",
                    style : "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText: "QR등록여부",
                    dataField: "assign_yn",
                    width : "7%",
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
                if (event.dataField == "rental_attach_no") {
                    if(event.item["assign_yn"] == "Y" && event.item["qr_no"] != "") {
                        var params = {
                            "rental_attach_no": event.item["rental_attach_no"]
                        };
                        var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
                        $M.goNextPage('/comm/comm0126p01', $M.toGetParam(params), {popupStatus: popupOption});
                    };
                }
            });
            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
            $("#auiGrid").resize();
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
                                <col width="80px">
                                <col width="260px">
                                <col width="65px">
                                <col width="90px">
                                <col width="65px">
                                <col width="90px">
                                <col width="90px">
                                <col width="120px">
                                <col width="65px">
                                <col width="120px">
                                <col width="90px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>
                                    <select class="form-control" id="s_search_type" name="s_search_type">
                                        <option value="reg">등록일자</option>
                                        <option value="buy">매입일자</option>
                                    </select>
                                </th>
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
                                <th>관리센터</th>
                                <td>
                                    <select class="form-control" id="s_mng_org_code" name="s_mng_org_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="item" items="${orgCenterList}">
                                            <option value="${item.org_code}">${item.org_name}</option>
                                        </c:forEach>
                                        <option value="5010">서비스지원</option>
                                    </select>
                                </td>
                                <th>소유센터</th>
                                <td>
                                    <select class="form-control" id="s_own_org_code" name="s_own_org_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="item" items="${orgCenterList}">
                                            <option value="${item.org_code}">${item.org_name}</option>
                                        </c:forEach>
                                        <option value="5010">서비스지원</option>
                                    </select>
                                </td>
                                <th>어태치먼트명</th>
                                <td>
                                    <input type="text" class="form-control" id="s_attach_name" name="s_attach_name" value="">
                                </td>
                                <th>부품번호</th>
                                <td>
                                    <input type="text" class="form-control" id="s_part_no" name="s_part_no" value="">
                                </td>
                                <td>
                                    <div class="form-check form-check-inline pl5">
                                        <label><input class="form-check-input" style="margin: 2px .3125rem 1px 0" type="checkbox" id="s_sale_include_yn" name="s_sale_include_yn" value="Y" onclick="javascript:goSearch()">판매포함</label>
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
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
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
