<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지(일반) > null > 상세검색
-- 작성자 : 김경빈
-- 최초 작성일 : 2022-09-21 15:02:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        $(document).ready(function () {
            createAUIGrid();
            goSearch();
        });

        // 엔터키 이벤트
        function enter(fieldObj) {
            if (fieldObj.name == "s_work_text") {
                goSearch();
            }
        }

        // 닫기
        function fnClose() {
            window.close();
        }

        // 조회
        function goSearch() {
            var param = {
                // 로그인한 사용자 본인의 일지만 볼 수 있도록
                "s_mem_no" : '${SecureUser.mem_no}',
                "s_start_dt" : $M.getValue("s_start_dt"),
                "s_end_dt" : $M.getValue("s_end_dt"),
                "s_work_text" : $M.getValue("s_work_text")
            };
            _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);
                    }
                }
            );
        }

        // 업무일지 상세
        function goDetail(workDt) {
            var url = /mmyy/;
            var org_gubun = '${inputParam.s_org_code}'.substring(0, 1);
            var param = {
                "s_mem_no" : '${SecureUser.mem_no}',
                "s_work_dt" : workDt.replaceAll('-', '')
            };

            switch (org_gubun) {
                // 서비스부, 기획부(김태공상무님 부서)
                case "5":
                case "8":
                    url += 'mmyy0103p01';
                    break;
                // 영업부
                case "4":
                    url += 'mmyy0103p02';
                    break;
                // 관리부, 경영지원부
                case "2":
                case "3":
                    url += 'mmyy0103p03';
                    break;
                // 부품부
                case "6":
                    url += 'mmyy0103p04';
                    break;
            }
            $M.goNextPage(url, $M.toGetParam(param), {popupStatus : ""});
        }

        // 그리드 생성
        function createAUIGrid() {
            var gridPros = {
                // 툴팁 출력 지정
                showTooltip : true,
                // 마우스 오버 100ms 후 툴팁 출력
                tooltipSensitivity : 100,
                // 행 줄번호 출력
                showRowNumColumn: false
            };

            var columnLayout = [
                {
                    headerText : "날짜",
                    dataField : "work_dt",
                    width : "12%",
                    style : "aui-popup",
                    tooltip : {
                        show : false
                    }
                },
                {
                    headerText : "금일진행사항",
                    dataField : "work_text",
                    style : "aui-left",
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", initColumnLayout(columnLayout), gridPros);
            AUIGrid.setGridData(auiGrid, []);

            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function(event) {
                if (event.dataField === "work_dt") {
                    goDetail(event.value);
                }
            });
        }
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 검색영역 -->
            <div class="search-wrap">
                <table class="table">
                    <colgroup>
                        <col width="250px">
                        <col width="150px">
                    </colgroup>
                    <tbody>
                        <tr>
                            <td>
                                <div class="form-row inline-pd">
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}">
                                        </div>
                                    </div>
                                    <div class="col-auto"> ~ </div>
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
                                        </div>
                                    </div>
                                    <div style="margin-left: 5px">
                                        <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                            <jsp:param name="st_field_name" value="s_start_dt"/>
                                            <jsp:param name="ed_field_name" value="s_end_dt"/>
                                            <jsp:param name="click_exec_yn" value="Y"/>
                                            <jsp:param name="exec_func_name" value="goSearch();"/>
                                        </jsp:include>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="icon-btn-cancel-wrap" style="margin-left: 2px">
                                    <input type="text" class="form-control" id="s_work_text" name="s_work_text">
                                </div>
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 50px; margin-left: 5px" onclick="javascript:goSearch();">조회</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <!-- /검색영역 -->
            <!-- 그리드 영역 -->
            <div id="auiGrid" style="width: 100%; margin-top: 10px"></div>
            <!-- /그리드 영역 -->
            <!-- 버튼 영역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
            <!-- /버튼 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>
