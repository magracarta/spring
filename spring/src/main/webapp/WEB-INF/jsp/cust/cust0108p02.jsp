<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > ARS > 전월통계 > null
-- 작성자 : 황다은
-- 최초 작성일 : 2024-07-16 10:29:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGrid;

        $(document).ready(function () {
            createAUIGrid();
            goSearch();
        });

        // 조회
        function goSearch() {
            var param = {
                s_year: $M.getValue("s_year"),
                s_mon: $M.getValue("s_mon"),
            }

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if(result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.setGridData(auiGrid, result.list);
                    };
                }
            );
        }

        // 그리드 생성
        function createAUIGrid() {
            var gridPros = {
                showRowNumColumn: true,
            }

            // 컬럼레이아웃
            var columnLayout = [
                {
                    headerText: "상담부서",
                    dataField: "org_name",
                },
                {
                    headerText: "수신횟수",
                    dataField: "call_receive_cnt",
                },
                {
                    headerText: "발신횟수",
                    dataField: "call_send_cnt",
                },
                {
                    headerText: "콜백횟수",
                    dataField: "call_back_cnt",
                },
                {
                    headerText: "콜백분배대상",
                    dataField: "next_batch_yn",
                },
                {
                    headerText: "누적분배수",
                    dataField: "next_batch_cnt",
                },
                {
                    dataField: "ars_mon",
                    visible : false
                },
                {
                    dataField: "org_code",
                    visible : false
                },
            ];

            // 실제 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, []);

        }

        // 닫기
        function fnClose() {
            window.close();
        }

    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" name="s_year" value="${search_year}">
    <input type="hidden" name="s_mon" value="${search_mon}">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 메인 타이틀 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /메인 타이틀 -->
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="title-wrap">
                <h4 class="primary" style="font-weight: bold"> ${search_year}년 ${search_mon}월 ARS통계현황</h4>
            </div>
            <div id="auiGrid" style="height: 345px; margin-top: 5px;"></div>
            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt5">
                <div class="left">
                    총 <strong id="total_cnt" class="text-primary">0</strong>건
                </div>
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
        <!-- /contents 전체 영역 -->
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>
