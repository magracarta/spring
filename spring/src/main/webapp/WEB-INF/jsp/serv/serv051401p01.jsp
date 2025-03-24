<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 신)서비스업무평가-센터 > null > MBO등록
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-12-03 12:25
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

        function goSearch() {
            var param = {
                "s_year" : $M.getValue("s_year"),
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);
                    }
                }
            );
        }

        // 저장
        function goSave() {
            if (fnChangeGridDataCnt(auiGrid) == 0){
                alert("변경된 데이터가 없습니다.");
                return false;
            };

            // if (fnCheckGridEmpty(auiGrid) === false){
            //     alert("필수 항목은 반드시 값을 입력해야합니다.");
            //     return false;
            // }

            var frm = fnChangeGridDataToForm(auiGrid);
            $M.setValue(frm, "svc_mbo_year", $M.getValue("s_year"));
            console.log("frm : ", frm);

            $M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'},
                function(result) {
                    if(result.success) {
                        alert("저장이 완료되었습니다.");
                        goSearch();
                    };
                }
            );
        }

        // 닫기
        function fnClose() {
            window.close();
        }
        
        function createAUIGrid() {
            var gridPros = {
                rowIdField : "_$uid",
                editable: true, // 수정 모드
                showStateColumn: true,
                showFooter : true,
                footerPosition : "top",
            };

            var columnLayout = [
                {
                    dataField: "org_code",
                    visible : false,
                },
                {
                    headerText: "센터",
                    dataField: "org_kor_name",
                    style: "aui-center",
                    width: "150",
                    minWidth: "50",
                    editable: false
                },
                {
                    headerText: "매출",
                    dataField: "sale_amt",
                    style: "aui-right aui-editable",
                    width: "150",
                    minWidth: "50",
                   	dataType: "numeric",
   					formatString: "#,##0",
                },
                {
                    headerText: "수익",
                    dataField: "profit_amt",
                    style: "aui-right aui-editable",
                    width: "150",
                    minWidth: "50",
                    dataType: "numeric",
                    formatString: "#,##0",
                }
            ];

            // 푸터 설정
            var footerLayout = [
                {
                    labelText : "합계",
                    positionField : "org_kor_name"
                },
                {
                    dataField: "sale_amt",
                    positionField: "sale_amt",
                    operation: "SUM",
                    formatString : "#,##0",
                    style: "aui-right aui-footer"
                },
                {
                    dataField: "profit_amt",
                    positionField: "profit_amt",
                    operation: "SUM",
                    formatString : "#,##0",
                    style: "aui-right aui-footer"
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerLayout);
            AUIGrid.setGridData(auiGrid, []);

            $("#auiGrid").resize();

            // cellEditEndBefore 이벤트 바인딩
            AUIGrid.bind(auiGrid, "cellEditEndBefore", function (event) {
                if (event.isClipboard) {
                    return event.value;
                }
                return event.value; // 원래값
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
            <!-- 검색조건 -->
            <div class="search-wrap mt5">
                <table class="table">
                    <colgroup>
                        <col width="50px">
                        <col width="80px">
                        <col width="*">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th>년도</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-auto">
                                    <select class="form-control" id="s_year" name="s_year">
                                        <c:forEach var="i" begin="${s_start_year}" end="${s_end_year}" step="1">
                                            <option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </td>
                        <td>
                            <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /검색조건 -->
            <div class="title-wrap mt10">
            	<h4>MBO 등록</h4>
            </div>
            <div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>

            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
                    <button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>