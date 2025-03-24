<%@ page contentType="text/html;charset=utf-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인센티브 비중관리 > 그룹 설정
-- 작성자 : 정재호
-- 최초 작성일 : 2021-07-13 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>

<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

    <script type="text/javascript">
        var auiGridGroup;
        var auiGridMember;

        $(document).ready(function () {
            // aui 생성
            createAUIGridGroup();
            createAUIGridMember();

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
            $M.goNextPageAjax(this_page + '/grpsearch', $M.toGetParam(param), {method: 'get'}, function (result) {
                AUIGrid.setGridData(auiGridGroup, result.list);

                var incen_grp_seq = "${inputParam.incen_grp_seq}";
                if (incen_grp_seq != "") { // 메인에서 조직원수 클릭으로 들어올 경우 incen_grp_seq가 넘어옴
                    gridSelectUI(auiGridGroup, incen_grp_seq); // 선택된 그리드 UI 설정
                    setMemberGridData(incen_grp_seq); // 맴버 데이터 셋팅
                    $M.setValue("curr_incen_grp_seq", incen_grp_seq); // 현재 선택된 seq값 변경
                }
            });
        }

        /**
         * 그리드에 특정 데이터 선택하기
         * @param auiGrid  체크할 그리드
         * @param checkRow 체크할 로우
         */
        function gridSelectUI(auiGrid, checkRow) {
            var groupData = AUIGrid.getGridData(auiGrid);
            for (var i = 0; i < groupData.length; i++) {
                if (groupData[i].incen_grp_seq == checkRow) {
                    AUIGrid.setSelectionByIndex(auiGrid, i, 2);
                }
            }
        }

        /**
         * 매개변수로 넘어온 맴버 데이터 셋팅
         * @param memberObj 맴버 데이터
         * @param callback 실행할 콜백 메서드
         */
        function modifyMemberGridInfo(memberObj, callback) {
            if ($M.getValue("curr_incen_grp_seq") == "") { // 선택한 그룹이 없는데 조직원을 추가할 경우
                callback();
                return;
            }

            var item = {};
            if (memberObj.length != undefined) { // 배열일 경우
                for (var i = 0; i < memberObj.length; i++) {
                    if (!(AUIGrid.isUniqueValue(auiGridMember, "mem_no", memberObj[i].mem_no))) { // 같은 직원 중복 체크
                        continue;
                    }
                    item.mem_no = memberObj[i].mem_no;
                    item.incen_grp_seq = memberObj[i].incen_grp_seq;
                    item.mem_name = memberObj[i].mem_name;
                    item.org_code = memberObj[i].org_code;
                    item.org_name = memberObj[i].org_name;
                    item.eval_yn = memberObj[i].eval_yn;
                    AUIGrid.addRow(auiGridMember, item, 'last');
                }
            } else { // 배열이 아닐 경우
                if ((AUIGrid.isUniqueValue(auiGridMember, "mem_no", memberObj.mem_no))) { // 같은 직원 중복 체크
                    item.mem_no = memberObj.mem_no;
                    item.incen_grp_seq = memberObj.incen_grp_seq;
                    item.mem_name = memberObj.mem_name;
                    item.org_code = memberObj.org_code;
                    item.org_name = memberObj.org_name;
                    item.eval_yn = memberObj.eval_yn;
                    AUIGrid.addRow(auiGridMember, item, 'last');
                }
            }
        }

        /**
         * 해당 그룹 시퀀스의 조직원 그리드 셋팅
         * @param incenGrpSeq
         */
        function setMemberGridData(incenGrpSeq) {
            var param = {
                "incen_grp_seq": incenGrpSeq,
                "s_sort_key": "incen_grp_seq",
                "s_sort_method": "desc"
            };
            $M.goNextPageAjax(this_page + '/memsearch', $M.toGetParam(param), {method: 'get'}, function (result) {
                AUIGrid.setGridData(auiGridMember, result.list);
            });
        }

        ////////////////////////////////////////////////////////

        ///////////////// 그룹 그리드 이벤트 메서드 ////////////////

        // 맴버 그리드
        function createAUIGridMember() {

            // 그리드 속성
            var gridPros = {
                rowIdField: "_$uid",
                editable: false,
                // 체크박스 표시 설정
                showRowCheckColumn: true,
                // 전체 체크박스 표시 설정
                showRowAllCheckBox: true,
                // 칼럼 상태 표시
                showStateColumn:true,
                // 삭제 예정 설정
                softRemoveRowMode: true,
                // 전체 선택 체크박스가 독립적인 역할을 할지 여부
                independentAllCheckBox: true,
                // 체크박스 설정
                rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
                    if (item.eval_yn == 'Y') { // 그룹이 있으면 체크 enable
                        return false;
                    }
                    return true;
                },
            };

            // 생성 될 칼럼 레이아웃
            var columnLayout = [
                {
                    dataField: "mem_no",
                    visible: false
                },
                {
                    dataField: "org_code",
                    visible: false
                },
                {
                    dataField: "incen_grp_seq",
                    visible: false
                },
                {
                    dataField: "org_name",
                    headerText: "부서명",
                },
                {
                    dataField: "mem_name",
                    headerText: "직원명",
                },
                {
                    dataField: "eval_yn",
                    headerText: "평가여부",
                    style: "aui-center",

                },
                {
                    dataField: "removeBtn",
                    headerText: "삭제",
                    width: "15%",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                            if (event.item.eval_yn == 'Y') {
                                if (confirm("평가된 조직원을 삭제하시겠습니까?") == true) { // 예
                                    AUIGrid.removeRow(auiGridMember, event.rowIndex);
                                    return;
                                } else { // 아니요
                                    return;
                                }
                            } else {
                                AUIGrid.removeRow(auiGridMember, event.rowIndex);
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
            auiGridMember = AUIGrid.create("#auiGridMember", columnLayout, gridPros);

            // 전체 선택 체크 박스 클릭 이벤트
            AUIGrid.bind(auiGridMember, "rowAllChkClick", auiRowAllChkClickHandlerMember);
        }

        function auiRowAllChkClickHandlerMember(event) {
            if (event.checked) { // 체크 상태
                AUIGrid.setCheckedRowsByValue(event.pid, "eval_yn", "N"); // 그룹이 없는 데이터 모두 체크

            } else { // 체크 해제
                AUIGrid.setCheckedRowsByValue(event.pid, "eval_yn", []);
            }
        }

        // 그룹 그리드
        function createAUIGridGroup() {

            // 그리드 속성
            var gridPros = {
                rowIdField: "_$uid",

                editable: false,

                showRowNumColumn: true,

                showRowCheckColumn: false,
            };

            // 생성 될 칼럼 레이아웃
            var columnLayout = [
                {
                    dataField: "incen_grp_seq",
                    visible: false
                },
                {
                    dataField: "group_count",
                    visible: false
                },
                {
                    dataField: "group_name",
                    headerText: "그룹명",
                    style: "aui-center aui-link"
                },
            ];

            // 그리드 생성
            auiGridGroup = AUIGrid.create("#auiGridGroup", columnLayout, gridPros);

            // 셀 클릭 이벤트
            AUIGrid.bind(auiGridGroup, "cellClick", auiCellClickHandlerGroup);
        }

        // 그룹 그리드 - 셀 클릭 핸들러
        function auiCellClickHandlerGroup(event) {
            var field = event.dataField;
            switch (field) {
                case "group_name" :
                    if (fnChangeGridDataCnt(auiGridMember) != 0) { // 변경 사항이 있다면
                        if (confirm("저장하지 않고 넘어가겠습니까?") == true) { // 예

                            $M.setValue("curr_incen_grp_seq", event.item.incen_grp_seq);
                            $M.setValue("curr_group_name", event.value);

                            setMemberGridData(event.item.incen_grp_seq);
                            return;
                        } else { // 아니요
                            AUIGrid.search(auiGridGroup, "group_name", $M.getValue("curr_group_name"), {wholeWord: true});
                            return;
                        }
                    }

                    $M.setValue("curr_incen_grp_seq", event.item.incen_grp_seq);
                    $M.setValue("curr_group_name", event.value);

                    setMemberGridData($M.getValue("curr_incen_grp_seq"));
                    break;
            }
        }

        ////////////////////////////////////////////////////////

        /////////////////////// 버튼 메서드 //////////////////////

        // 저장 버튼
        function goSave() {
            if (fnChangeGridDataCnt(auiGridMember) == 0) {
                alert("변경사항이 없습니다.");
                return;
            }

            var frm = fnChangeGridDataToForm(auiGridMember);
            $M.setValue(frm, "incen_grp_seq", $M.getValue("curr_incen_grp_seq"));
            $M.setValue(frm, "s_incen_year", ${inputParam.s_incen_year});
            if (frm != null) {
                $M.goNextPageAjaxSave(this_page + "/save", frm, {method: 'POST'}, function (result) {
                    if (result.success) {
                        setMemberGridData($M.getValue("curr_incen_grp_seq"));
                    }
                });
            }
        }

        // 닫기 버튼
        function fnClose() {
            window.close();
        }

        // 전체 삭제 버튼
        function fnCheckRemove() {
            AUIGrid.removeCheckedRows(auiGridMember);
        }

        // 그룹 추가 버튼
        function goGroupSet() {
            var param = {
                "s_incen_year": ${inputParam.s_incen_year}
            };
            $M.goNextPage('/acnt/acnt0608p0101', $M.toGetParam(param), {popupStatus: ""});
        }

        // 조직원 추가 버튼
        function goAddMemberPopup() {
            if ($M.getValue("curr_incen_grp_seq") != "") { // 선택한 그룹이 있을 때
                var param = {
                    "s_incen_year": ${inputParam.s_incen_year},
                    "parent_js_name": "modifyMemberGridInfo"
                };
                $M.goNextPage('/acnt/acnt0608p0102', $M.toGetParam(param), {popupStatus: ""});
            } else {
                alert("그룹을 선택해주세요.");
            }
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
        <div class="row">
            <!-- 그룹 영역 -->
            <div class="col-4">
                <div class="title-wrap">
                    <div class="left">
                        <h4>그룹</h4>
                    </div>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                            <jsp:param name="pos" value="TOP_L"/>
                        </jsp:include>
                    </div>
                </div>
                <div id="auiGridGroup" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /그룹 영역 -->
            <!-- 조직원 영역 -->
            <div class="col-8">
                <div class="title-wrap">
                    <div class="left">
                        <h4>조직원</h4>
                    </div>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                            <jsp:param name="pos" value="TOP_R"/>
                        </jsp:include>
                    </div>
                </div>
                <div id="auiGridMember" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /조직원 영역 -->
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
</div>
<input type="hidden" id="curr_incen_grp_seq" name="curr_incen_grp_seq" value=""/>
<input type="hidden" id="curr_group_name" name="curr_group_name" value=""/>
<!-- /팝업 -->
</body>

</html>