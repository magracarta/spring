<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 인사관리 > null > 기준요율설정
-- 작성자 : 정재호
-- 최초 작성일 : 2022-08-09 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            goSearch();
        });

        function createAUIGrid() {
            var gridPros = {
                showRowNumColumn : false,
                showRowCheckColumn : false,
                rowIdField : "rate_id",
                editable : true, // 수정 모드
            };

            var columnLayout = [
                {
                    headerText: "구분",
                    dataField: "rate_kind",
                    editable: false,
                },
                {
                    headerText: "1월",
                    dataField: "out_amt_01",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "2월",
                    dataField: "out_amt_02",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "3월",
                    dataField: "out_amt_03",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "4월",
                    dataField: "out_amt_04",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "5월",
                    dataField: "out_amt_05",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "6월",
                    dataField: "out_amt_06",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "7월",
                    dataField: "out_amt_07",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "8월",
                    dataField: "out_amt_08",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "9월",
                    dataField: "out_amt_09",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "10월",
                    dataField: "out_amt_10",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "11월",
                    dataField: "out_amt_11",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                },
                {
                    headerText: "12월",
                    dataField: "out_amt_12",
                    dataType: "numeric",
                    style : "aui-right",
                    width: "85",
                    minWidth: "50",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value === undefined) return value;

                        if(typeof value !== "number") {
                            alert("요율은 숫자만 입력 가능합니다.");
                            return 0;
                        }

                        return value;
                    }
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            // AUIGrid.setGridData(auiGrid, []);
            // 테스트
            AUIGrid.setGridData(auiGrid, [{"rate_kind" : "국민"}, {"rate_kind" : "건강"}, {"rate_kind" : "고용"}]);

            $("#auiGrid").resize();

            // cellEditEndBefore 이벤트 바인딩
            // AUIGrid.bind(auiGrid,  "cellEditEndBefore", function(event) {
            //     // 검증 결과 컬럼엔 복사 안되도록 추가
            //     if(event.isClipboard) {
            //         return event.value;
            //     }
            //     return event.value; // 원래값
            // });

        }

        function changeDate() {
            if(fnChangeGridDataCnt(auiGrid) != 0){
                var check = confirm("변경한 내역을 저장하지않고 넘어가시겠습니까?");
                if(!check){
                    return false;
                }
            }

            goSearch();
        }

        function goSearch() {
            var param = {
                "s_year" : $M.getValue("out_year"),
            }

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"}, function (result) {
                if (result.success) {
                    AUIGrid.setGridData(auiGrid, result.list);
                }
            });
        }

        function goSave() {
            var changeCnt = fnChangeGridDataCnt(auiGrid);
            if (changeCnt == 0) {
                alert("변경사항이 없습니다.");
                return;
            }

            var editedRowColumnItems = AUIGrid.getEditedRowColumnItems(auiGrid);
            var editedMonth = []; // 수정된 월 구하기
            editedRowColumnItems.forEach(item => {
                var arr = Object.keys(item).filter(value => value != 'rate_id');
                editedMonth = editedMonth.concat(arr);
            });

            editedMonth = editedMonth.filter((item, pos) => editedMonth.indexOf(item) === pos); // 중복 제거
            editedMonth = editedMonth.map(item => $M.getValue("out_year").concat(item.substring(8,10))); // 월 정보만 끊어 내기

            var frm = fnChangeGridDataToForm(auiGrid);
            $M.setValue(frm, "s_year", $M.getValue("out_year"));
            $M.setValue(frm, "edited_month", editedMonth);

            $M.goNextPageAjaxSave(this_page + '/save', frm, {method: 'POST'},
                function (result) {
                    if (result.success) {
                        location.reload();
                    }
                }
            )
        }

        function fnClose() {
            window.close();
        }

    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <div class="popup-wrap width-100per">
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 검색조건 -->
            <div class="search-wrap mt5">
                <table class="table">
                    <colgroup>
                        <col width="60px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th>기준년도</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-auto">
                                    <select class="form-control essential-bg" id="out_year" name="out_year" required="required" onchange="javascript:changeDate();" alt="지출년도">
                                        <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                            <c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
                                            <option value="${year_option}" <c:if test="${year_option eq inputParam.out_year}">selected</c:if>>${year_option}년</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /검색조건 -->
            <div id="auiGrid" style="margin-top: 5px; height: 150px;"></div>

            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>