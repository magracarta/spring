<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 계좌입출금내역 > null > 가상계좌등록
-- 작성자 : 정재호
-- 최초 작성일 : 2023-06-30 09:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
        });

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                noDataMessage: "엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여 넣기(Ctrl+V) 하십시오.",
                editable: true, // 수정 모드
                editableOnFixedCell: true,
                selectionMode: "multipleCells", // 다중셀 선택
                showStateColumn: true,
                showEditedCellMarker: false,
                softRemovePolicy: "exceptNew",
                enableFilter: false,
                softRemoveRowMode: true,
                showAutoNoDataMessage: true,
            };

            var columnLayout = [
                {
                    headerText: "가상계좌번호",
                    dataField: "virtual_account_no",
                    style: "aui-center"
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "pasteBegin", function(event) {
                console.log(event);
            });
        }

        // 초기화 버튼 이벤트
        function fnReset() {
            AUIGrid.clearGridData(auiGrid);
        }

        // 닫기 이벤트
        function fnClose() {
            window.close();
        }

        // 저장 이벤트
        function goSave() {
            const gridData = AUIGrid.getGridData(auiGrid);
            if(gridData.length === 0) {
                alert("등록된 데이터가 없습니다.")
                return;
            }

            var param = {
                virtual_account_no_list : gridData.map(item => item.virtual_account_no)
            }
            $M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), {method: 'POST'},
                function (result) {
                    if (result.success) {
                        opener.${inputParam.parent_js_name}();
                        window.close();
                    }
                }
            );
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
            <!-- 처리내역 -->
            <div>
                <div class="title-wrap">
                    <div class="left">
                        <h4>가상계좌등록</h4>
                    </div>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                            <jsp:param name="pos" value="TOP_R"/>
                        </jsp:include>
                    </div>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
            </div>
            <!-- /처리내역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>