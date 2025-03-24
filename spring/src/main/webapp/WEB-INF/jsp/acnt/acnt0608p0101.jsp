<%@ page contentType="text/html;charset=utf-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인센티브 비중관리 > 그룹 설정 > 그룹관리
-- 작성자 : 정재호
-- 최초 작성일 : 2021-07-20 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>

<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        // 그리트 객체
        var auiGridGroup;

        $(document).ready(function () {
            // 그리드 생성
            createAUIGrid();

            // 그리드 초기화
            gridInit();
        });

        /////////////////////// 기본 메서드 //////////////////////

        /**
         * 그리드 초기화
         */
        function gridInit() {
            var param = {
                "s_incen_year": ${inputParam.s_incen_year},
                "s_sort_key": "incen_grp_seq",
                "s_sort_method": "desc"
            };
            $M.goNextPageAjax("/acnt/acnt0608p01/grpsearch", $M.toGetParam(param), {method: 'get'}, function (result) {
                AUIGrid.setGridData(auiGridGroup, result.list);
            });
        }
        ////////////////////////////////////////////////////////

        ///////////////// 그룹 그리드 이벤트 메서드 ////////////////

        function createAUIGrid() {

            // 그리드 속성
            var gridPros = {
                rowIdField: "_$uid",
                editable: true,
                showStateColumn: true
            };

            // 생성 될 칼럼 레이아웃
            var columnLayout = [
                {
                    dataField: "incen_grp_seq",
                    visible: false
                },
                {
                    dataField: "group_code",
                    visible: false
                },
                {
                    dataField: "use_yn",
                    visible: false
                },
                {
                    dataField: "group_name",
                    headerText: "그룹명",
                    required: true
                },
                {
                    dataField: "group_count",
                    headerText: "조직원수",
                    editable: false,
                    required: true

                },
                {
                    dataField: "removeBtn",
                    headerText: "삭제",
                    width: "15%",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                            if (event.item.group_count == undefined || event.item.group_count == 0) { // 그룹 삭제 조건
                                var isRemoved = AUIGrid.isRemovedById(auiGridGroup, event.item._$uid);
                                if (isRemoved == false) {
                                    AUIGrid.updateRow(auiGridGroup, {use_yn: "N"}, event.rowIndex);
                                    AUIGrid.removeRow(event.pid, event.rowIndex);
                                } else {
                                    AUIGrid.restoreSoftRows(auiGridGroup, "selectedIndex");
                                    AUIGrid.updateRow(auiGridGroup, {use_yn: "Y"}, event.rowIndex);
                                }
                            } else {
                                alert("조직원이 없어야 삭제가 가능합니다.");
                            }
                        }
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                    style: "aui-center",
                    editable: false
                }
            ];

            // 그리드 생성
            auiGridGroup = AUIGrid.create("#auiGridGroup", columnLayout, gridPros);

            AUIGrid.bind(auiGridGroup, "cellEditEndBefore", auiCellEditEndBeforeHandlerGroup);
        }

        // 그룹 그리드 - 셀 수정 핸들러
        // part0703p02
        function auiCellEditEndBeforeHandlerGroup(event) {
            if (event.item.group_name == event.value) { // 그룹명을 클릭하고 다른 그룹을 눌렀을 때 예외 처리
                return event.oldValue;
            }

            var isUnique = AUIGrid.isUniqueValue(auiGridGroup, event.dataField, event.value); // 중복 체크

            if (isUnique == false && event.value != "") {
                setTimeout(function () {
                    AUIGrid.showToastMessage(auiGridGroup, event.rowIndex, event.columnIndex, "그룹명이 중복됩니다.");
                }, 1);
                return "";
            } else {
                if (event.value = "") {
                    return event.oldValue;
                }
            }
        }

        ////////////////////////////////////////////////////////

        /////////////////////// 버튼 메서드 //////////////////////

        // 저장 버튼
        function goSave() {
            if (fnChangeGridDataCnt(auiGridGroup) == 0) {
                alert("변경사항이 없습니다.");
                return;
            }

            var isValid = AUIGrid.validation(auiGridGroup);

            if (isValid) {
                var frm = fnChangeGridDataToForm(auiGridGroup);
                $M.setValue(frm, "s_incen_year", ${inputParam.s_incen_year});

                if (frm != null) {
                    $M.goNextPageAjaxSave(this_page + "/save", frm, {method: 'POST'}, function (result) {
                        if (result.success) {
                            opener.parent.location.reload();
                            window.close();
                        }
                    });
                }
            }
        }

        // 닫기 버튼
        function fnClose() {
            window.close();
        }

        // 그룹 추가 버튼
        function fnAddSec() {
            var item = new Object();
            item.group_name = "";
            item.incen_grp_seq = -1;
            item.group_code = "";
            item.group_count = "0";
            item.use_yn = "Y"
            AUIGrid.addRow(auiGridGroup, item, 'last');
        }

        ////////////////////////////////////////////////////////

    </script>
</head>

<body class="bg-white">
<!-- 팝업 -->
<div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
        <!-- 그룹 영역 -->
        <div class="title-wrap">
            <div class="left">
                <h4>그룹관리</h4>
            </div>
            <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                    <jsp:param name="pos" value="TOP_L"/>
                </jsp:include>
            </div>
        </div>
        <div id="auiGridGroup" style="margin-top: 5px; height: 300px;"></div>
        <!-- /그룹 영역 -->
        <!-- 버튼 영역 -->
        <div class="btn-group mt10 mr5">
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
</body>

</html>