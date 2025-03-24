<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 담당지역관리현황
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-04-21 11:29:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        let auiGrid;
        let sYear; // 조회년도
        let sOrgCd; // 조회센터
        let foldColList = []; // 펼침 항목 (create할때 넣음)

        $(document).ready(function () {
            createAUIGrid();
            goSearch();
        });

        function goSearch() {

            const hideList = ["trip_first_yn", "area_name", "service_mem_name", "remark"]
            sYear = $M.getValue("s_year");
            sOrgCd = $M.getValue("s_center_org_code");

            if (sOrgCd) {
                AUIGrid.showColumnByDataField(auiGrid, hideList);
            } else {
                AUIGrid.hideColumnByDataField(auiGrid, hideList);
            }

            const param = {
                "s_year" : sYear,
                "s_org_code" : sOrgCd,
            }
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);
                        // 전체 센터 조회 시, 센터 스타일 변경
                        AUIGrid.setColumnPropByDataField(auiGrid, "center_org_name", {
                            style: !sOrgCd ? "aui-popup" : "aui-center"
                        });
                    }
                }
            );
        }

        function goSave() {
            // 변경내역 check
            if (AUIGrid.getEditedRowItems(auiGrid).length == 0) {
                alert("변경내역이 없습니다.");
                return;
            }

            const frm = fnChangeGridDataToForm(auiGrid);
            $M.setValue(frm, "svc_year", sYear);

            $M.goNextPageAjaxSave(this_page + "/save", frm , {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearch();
                    }
                }
            );
        }

        // 펼침 이벤트
        function fnChangeColumn(event) {
            const target = event.target || event.srcElement;
            if (!target)	return;

            if (target.checked) {
                AUIGrid.showColumnByDataField(auiGrid, foldColList);
            } else {
                AUIGrid.hideColumnByDataField(auiGrid, foldColList);
            }
        }

        // 순회우선지역 맨 위로 정렬
        function fnMove() {
            AUIGrid.setSorting(auiGrid, [{dataField : "trip_first_yn", sortType : -1}]);
        }

        // 엑셀다운로드
        function fnExcelDownload() {
            fnExportExcel(auiGrid, "담당지역 관리현황");
        }

        // 기준정보 재생성
        // 담당별 장비관리와 동일
        function goChangeSave() {
            var msg = "기준정보를 재생성 하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, "/serv/serv0401/updateStandardInfo", '', {method: 'POST'},
                function (result) {
                    if (result.success) {
                    	location.reload();
                    }
                }
            );
        }

        //그리드생성
        function createAUIGrid() {
            const gridPros = {
                rowIdField: "_$uid",
                headerHeight : 40,
                showRowNumColumn: true,
                showStateColumn : true,
                editable : true,
                showFooter: true, // 푸터 사용
                footerPosition : "top", // 푸터 위치
                showTooltip : true, // 툴팁 출력
            };

            const columnLayout = [
                {
                    dataField : "center_org_code",
                    visible: false,
                },
                {
                    headerText: "담당센터",
                    dataField: "center_org_name",
                    width : "70",
                    editable : false,
                    style: "aui-center"
                },
                {
                    dataField : "area_si", // 구역시
                    visible: false,
                },
                {
                    dataField : "sale_area_code", // 영업구역코드
                    visible: false,
                },
                {
                    headerText: "담당지역",
                    dataField: "area_name",
                    width : "80",
                    editable : false,
                    style: "aui-center aui-popup"
                },
                {
                    headerText: "담당자",
                    dataField: "service_mem_name",
                    width : "80",
                    editable : false,
                    style: "aui-center"
                },
                {
                    dataField : "service_mem_no", // 서비스담당자
                    visible: false,
                },
                {
                    headerText: "총 장비<br>대수",
                    dataField: "total_cnt",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "65",
                    editable : false,
                    style: "aui-center"
                },
                {
                    // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                    // headerText: "대리점<br>장비",
                    headerText: "위탁판매점<br>장비",
                    dataField: "cnt_d",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "65",
                    editable : false,
                    style: "aui-center"
                },
                {
                    headerText: "미관리<br>장비",
                    dataField: "cnt_m",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "65",
                    editable : false,
                    style: "aui-center"
                },
                {
                    headerText: "관리장비",
                    dataField: "cnt_mng",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "65",
                    editable : false,
                    style: "aui-center",
                    headerTooltip: {
                        show: true,
                        // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
                        // tooltipHtml: "총 장비대수 - 미관리장비 - 대리점장비"
                        tooltipHtml: "총 장비대수 - 미관리장비 - 위탁판매점장비"
                    }
                },
                {
                    headerText: "마케팅장비<br>비율",
                    dataField: "cnt_b_rate",
                    width : "65",
                    editable : false,
                    style: "aui-center",
                    labelFunction : customLabelFunction,
                },
                {
                    headerText: "당년평균<br>가동시간",
                    dataField: "mon_avg_run_time",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "65",
                    editable : false,
                    style: "aui-center"
                },
                {
                    headerText: "정비율",
                    dataField: "maintenance_rate",
                    width : "55",
                    style: "aui-center",
                    editable : false,
                    labelFunction : customLabelFunction,
                    headerTooltip: {
                        show: true,
                        // tooltipHtml: "당년 정비건수 / (당년 가동시간 / 500)"
                        tooltipHtml: "당년 정비건수 / ((당년 가동시간 / 500) + 잔여대수)"
                    }
                },
                {
                    headerText: "당년접촉<br>장비대수",
                    dataField: "contact_cnt",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "70",
                    editable : false,
                    style: "aui-center"
                },
                {
                    headerText: "잔여대수",
                    dataField: "remain_cnt",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "70",
                    editable : false,
                    style: "aui-center"
                },
                {
                    headerText: "당년<br>접촉률",
                    dataField: "contact_rate",
                    width : "65",
                    editable : false,
                    style: "aui-center",
                    labelFunction : customLabelFunction,
                },
                {
                    headerText: "전년대비",
                    dataField: "contact_rate_yoy",
                    width : "65",
                    editable : false,
                    style: "aui-center",
                    labelFunction : customLabelFunction,
                    headerTooltip: {
                        show: true,
                        tooltipHtml: "당년접촉율 - 전년접촉율"
                    }
                },
                {
                    headerText: "전년접촉<br>장비대수",
                    headerStyle : "aui-fold",
                    dataField: "last_contact_cnt",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "65",
                    editable : false,
                    style: "aui-center"
                },
                {
                    headerText: "전년미접촉<br>장비대수",
                    headerStyle : "aui-fold",
                    dataField: "last_non_contact_cnt",
                    dataType : "numeric",
                    formatString : "#,###",
                    width : "65",
                    editable : false,
                    style: "aui-center"
                },
                {
                    headerText: "전년<br>미접촉률",
                    headerStyle : "aui-fold",
                    dataField: "last_non_contact_rate",
                    width : "65",
                    editable : false,
                    style: "aui-center",
                    labelFunction : customLabelFunction,
                },
                {
                    headerText: "당년MS",
                    dataField: "ms_rate",
                    width : "65",
                    editable : false,
                    style: "aui-center",
                    labelFunction : customLabelFunction,
                    headerTooltip: {
                        show: true,
                        tooltipHtml: "(당년 해당 지역의) 얀마 소계 / 미니굴삭기 소계"
                    }
                },
                {
                    headerText: "전년MS",
                    dataField: "last_ms_rate",
                    width : "65",
                    editable : false,
                    style: "aui-center",
                    labelFunction : customLabelFunction,
                    headerTooltip: {
                        show: true,
                        tooltipHtml: "(전년 해당 지역의) 얀마 소계 / 미니굴삭기 소계"
                    }
                },
                {
                    headerText: "순회우선<br>지역",
                    dataField: "trip_first_yn",
                    width : "65",
                    style: "aui-center",
                    renderer : {
                        type : "CheckBoxEditRenderer",
                        editable : true,
                        checkValue : "Y",
                        unCheckValue : "N"
                    }
                },
                {
                    headerText: "메모",
                    dataField: "remark",
                    minWidth : "100",
                    style: "aui-center aui-editable"
                },
            ];

            // 푸터레이아웃
            const footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "#base", // 엑스트라 렌더러안에 푸터라벨 넣기
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "total_cnt", // 총 장비 대수
                    positionField: "total_cnt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "cnt_d", // 대리점 장비
                    positionField: "cnt_d",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "cnt_m", // 미관리장비
                    positionField: "cnt_m",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "cnt_mng", // 관리장비
                    positionField: "cnt_mng",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "mon_avg_run_time", // 당년평균 가동시간
                    positionField: "mon_avg_run_time",
                    operation: "AVG",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "contact_cnt", // 당년접촉 장비대수
                    positionField: "contact_cnt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "remain_cnt", // 잔여대수
                    positionField: "remain_cnt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "last_contact_cnt", // 전년 접촉 장비대수
                    positionField: "last_contact_cnt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "last_non_contact_cnt", // 전년 미접촉 장비대수
                    positionField: "last_non_contact_cnt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-center aui-footer",
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            // 접힐 컬럼 목록 추가 및 접기
            (AUIGrid.getColumnInfoList(auiGrid)).forEach(col => {
                if (col.headerStyle != null && col.headerStyle == "aui-fold") {
                    foldColList.push(col.dataField);
                    AUIGrid.hideColumnByDataField(auiGrid, col.dataField);
                }
            });

            // 담당지역 클릭 시, [장비모델 별 분포] 팝업 호출
            AUIGrid.bind(auiGrid, "cellClick", function(event) {
                if (event.dataField === "area_name") {
                    const param = {
                        "s_year" : sYear, // 조회년도
                        "s_area_code" : event.item.sale_area_code, // 영업구역코드
                        "target_name" : event.item.area_name, // 구역명
                        "s_org_code" : sOrgCd,
                    }
                    $M.goNextPage("/serv/serv0406p01", $M.toGetParam(param), {popupStatus : ""});
                }
                // 전체 센터 조회 및 담당센터 클릭 시, [장비모델 별 분포] 팝업 호출
                if (event.dataField === "center_org_name" && !sOrgCd) {
                    const param = {
                        "s_year" : sYear, // 조회년도
                        "s_center_org_code" : event.item.center_org_code, // 센터코드
                        "target_name" : event.item.center_org_name, // 센터명
                    };
                    $M.goNextPage("/serv/serv0406p01", $M.toGetParam(param), {popupStatus : ""});
                }
            });
        }

        // % prefix Label Function
        function customLabelFunction(rowIndex, columnIndex, value, headerText, item) {
            return value == 0 ? "" : Math.round(value) + "%";
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
                        <table class="table">
                            <colgroup>
                                <col width="70px">
                                <col width="75px">
                                <col width="40px">
                                <col width="90px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년도</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-12">
                                            <select class="form-control" id="s_year" name="s_year">
                                                <c:choose>
                                                    <c:when test="${'12' eq fn:substring(inputParam.s_current_mon, 4, 6)}">
                                                        <c:forEach var="i" begin="2021" end="${inputParam.s_current_year + 1}" step="1">
                                                            <option value="${i}" <c:if test="${i==inputParam.s_current_year}">selected</c:if>>${i}년</option>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach var="i" begin="2021" end="${inputParam.s_current_year}" step="1">
                                                            <option value="${i}" <c:if test="${i==inputParam.s_current_year}">selected</c:if>>${i}년</option>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                                
                                            </select>
                                        </div>
                                    </div>
                                </td>
                                <th>센터</th>
                                <td>
                                    <select class="form-control" id="s_center_org_code" name="s_center_org_code">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="item" items="${orgCenterList}">
                                            <option value="${item.org_code}">${item.org_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();">조회</button>
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
                            <div class="left" style="margin-left:50px;">
                                <span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}&nbsp;&nbsp;&nbsp;</span>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
                            </div>
                            <div class="right">
                                <label for="s_toggle_column" style="margin-right: 10px;">
                                    <input type="checkbox" id="s_toggle_column" onclick="fnChangeColumn(event)">펼침
                                </label>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <!-- 그리드 및 하위 버튼 영역 -->
                    <div class="btn-group mt5">
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                    <!-- /그리드 및 하위 버튼 영역 -->
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>
