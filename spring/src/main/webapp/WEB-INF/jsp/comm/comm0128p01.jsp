<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%--
-- 업   무 : 공통 > 기준정보 > 라인백업관리 > 백업현황상세
-- 작성자 : 황다은
-- 최초 작성일 : 2024-04-22
--%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGrid;

        $(document).ready(function () {
            createAUIGrid();
        });

        // 닫기
        function fnClose() {
            window.close();
        }

        // 그리드 생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "line_backup_seq",
                editable: false,
                showRowNumColumn: true,
                // 체크박스 표시 설정
                showRowCheckColumn: true,
                // 전체 체크박스 표시 설정
                showRowAllCheckBox: true,
                independentAllCheckBox: true,
                rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
                    if (item.file_yn == 'Y' && item.sync_yn == 'N') {
                        return true;
                    }
                    return false;
                }
            }

            // 컬럼레이아웃
            var columnLayout = [
                {
                    headerText: "파일경로",
                    dataField: "line_file_dir",
                    style: "aui-left",
                },
                {
                    headerText: "파일명",
                    dataField: "line_file_name",
                    style: "aui-left",
                    width: "700"
                },
                {
                    dataField: "line_backup_seq",
                    visible: false
                },
                {
                    dataField: "file_seq",
                    visible: false
                },
                {
                    headerText: "파일",
                    dataField: "file_yn",
                    style: "aui-center aui-link",
                    width: "60"
                },
                {
                    headerText: "동기화",
                    dataField: "sync_yn",
                    style: "aui-center",
                    width: "60"
                }
            ]

            // 실제로 #grid_wrap에 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, ${list});

            // 전체 선택 체크 박스 클릭 이벤트

            AUIGrid.bind(auiGrid, "rowAllChkClick", auiRowAllChkClickHandlerMember);


            // 팝업창 이벤트
            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "file_yn") {
                    var fileSeq = event.item.file_seq;
                    var fileYn = event.item.file_yn;
                    if (fileYn == 'N') {
                        alert("파일이 존재하지 않습니다.");
                        return false;
                    }
                    goFile(fileSeq);
                }
            });
        }

        function auiRowAllChkClickHandlerMember(event) {
            var gridData = AUIGrid.getGridData(auiGrid);
            // 체크 상태 일 경우
            if(event.checked) {
                for (var i = 0; i < gridData.length; i++) {
                    var data = gridData[i];
                    // 파일여부 Y && 동기화 N 일 때
                    if(data.file_yn == 'Y' && data.sync_yn == 'N') {
                        // 해당 row check 로 변경
                        AUIGrid.addCheckedRowsByIds(auiGrid, data.line_backup_seq);
                    }
                }
            } else {
                // 전체 체크 해제
                AUIGrid.setCheckedRowsByValue(event.pid, "line_backup_seq", []);
            }
        }

        function fnSyncLineToChecked() {
            var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
            if (items.length == 0) {
                alert("체크된 데이터가 없습니다.");
                return false
            }
            var param = {
                backup_type_cd : '${inputParam.backup_type_cd}',
                line_backup_seq_str: $M.getArrStr(items, {key: 'line_backup_seq'}),
                backup_dt : '${inputParam.backup_dt}'
            }

            var msg = "체크된 항목을 동기화 하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, this_page + "/sync", $M.toGetParam(param), {method: 'POST'},
                function (result) {
                    if (result.success) {
                        location.reload();
                    }
                }
            );
        }

        // 파일미리보기 팝업
        function goFile(fileSeq) {
            openFileViewerPanel(fileSeq);
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <%-- 팝업 --%>
    <div class="popup-wrap width-100per">
        <%-- 타이틀 영역--%>
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <%-- /타이틀영역--%>
        <%-- 컨텐츠 영역--%>
        <div class="content-wrap">
            <div class="title_wrap">
                <h4>백업현황 상세</h4>
            </div>
            <table class="table-border mt5">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                    <col width="70px">
                    <col width="60px">
                </colgroup>
                <tbody>
                <tr>
                    <th class="text-right">관리번호</th>
                    <td><c:out value="${inputParam.mng_no}"/></td>
                    <th class="text-right">문서타입</th>
                    <td><c:out value="${inputParam.backup_type_name}"/></td>
                    <th class="text-right">등록일자</th>
                    <td>
                        <fmt:parseDate value="${inputParam.backup_dt}" var="backup_dt" pattern="yyyyMMdd"/>
                        <fmt:formatDate value="${backup_dt}" pattern="yyyy-MM-dd"/>
                    </td>
                    <th class="text-right">파일 수</th>
                    <td class="text-right"><c:out value="${inputParam.back_cnt}"/></td>
                </tr>
                <tr>
                    <th class="text-right">문서명</th>
                    <td colspan="7"><c:out value="${inputParam.remark}"/></td>
                </tr>
                <tr>
                    <th class="text-right">문서생성규칙</th>
                    <td colspan="7"><c:out value="${result.file_naming_rule}"/></td>
                </tr>
                </tbody>
            </table>
            <div class="btn-group mt5">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="TOP_R"/>
                    </jsp:include>
                </div>
            </div>
            <div id="auiGrid" style="height: 350px; margin-top: 5px;"></div>
            <!-- 우측 하단 버튼 영역 -->
            <div class="btn-group mt5">
                <div class="left">
                    총 <strong class="text-primary" id="total_cnt">${size}</strong>건
                </div>
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
        </div>
    </div>
</form>

</body>
</html>
