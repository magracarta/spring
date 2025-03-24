<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB > 업무DB팝업 > 뎁스 팝업
-- 작성자 : 류성진
-- 최초 작성일 : 2021-03-24 15:20:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;

        $(document).ready(function () {
			createAUIGrid()
        });

        function createAUIGrid(){
            var gridPros = {
                rowIdField : "_$uid",
                enableFilter: true,
                displayTreeOpen: true,
                showRowCheckColumn: false,
                rowCheckDependingTree: true,
                showRowNumColumn: false
            };

            var columnLayouts = [ /////////////////////////////////////////////////////// 0번 그리드 (다운로드 권한)
                {
                    headerText: "분류",
                    dataField: "folder_name",
                    style: "aui-center",
                    editable: false
                },
                {
                    headerText: "시퀀스",
                    dataField: "work_db_seq", // WORK_DB_SEQ
                    style: "aui-center",
                    visible : false,
                    editable: false
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayouts, gridPros);
            AUIGrid.setGridData(auiGrid, ${list}); // 데이터 설정
            // AUIGrid.bind(auiGrid, "cellClick", clickItem); // 셀클릭 이벤트

            // AUIGrid.bind(auiGrid, "cellDoubleClick", function(event) {
            AUIGrid.bind(auiGrid, "cellClick", function(event) { // 더블클릭 -> 클릭으로 변경
                try {
                    opener.${inputParam.parent_js_name}(event.item);
                    window.close();
                } catch(e) {
                    console.log(e)
                    alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
                }
            });

            // $("#auiGrid").resize();

        }

        // 닫기
        function fnClose() {
            window.close();
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
        <div class="content-wrap">
            <div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
        </div>
    </div>
</form>
</body>
</html>