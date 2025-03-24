<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > 센터고과평가 > 분기별 평가(조정)
-- 작성자 : jsk
-- 최초 작성일 : 2024-06-12 14:09:10
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

        // 그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                fillColumnSizeMode : true,
                showStateColumn: true,
                editable: true
            };

            var columnLayout = [
                {
                    dataField : "eval_year",
                    visible : false
                },
                {
                    dataField : "org_code",
                    visible : false
                },
                {
                    headerText : "부서",
                    dataField : "org_name",
                    width : "8%",
                    minWidth : "70",
                    style : "aui-center",
                    editable: false
                },
                {
                    headerText : "1/4분기",
                    children: [
                        {
                            headerText : "최종평점",
                            dataField : "q1_eval_point",
                            width : "5%",
                            style : "aui-center",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                validator : pointValidation
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        },
                        {
                            headerText : "비고",
                            dataField : "q1_remark",
                            width : "15%",
                            style : "aui-left",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                maxlength : 100,
                                validator : AUIGrid.commonValidator
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        }
                    ]
                },
                {
                    headerText : "2/4분기",
                    children: [
                        {
                            headerText : "최종평점",
                            dataField : "q2_eval_point",
                            width : "5%",
                            style : "aui-center",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                validator : pointValidation
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        },
                        {
                            headerText : "비고",
                            dataField : "q2_remark",
                            width : "15%",
                            style : "aui-left",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                maxlength : 100,
                                validator : AUIGrid.commonValidator
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        }
                    ]
                },
                {
                    headerText : "3/4분기",
                    children: [
                        {
                            headerText : "최종평점",
                            dataField : "q3_eval_point",
                            width : "5%",
                            style : "aui-center",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                validator : pointValidation
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        },
                        {
                            headerText : "비고",
                            dataField : "q3_remark",
                            width : "15%",
                            style : "aui-left",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                maxlength : 100,
                                validator : AUIGrid.commonValidator
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        }
                    ]
                },
                {
                    headerText : "4/4분기",
                    children: [
                        {
                            headerText : "최종평점",
                            dataField : "q4_eval_point",
                            width : "5%",
                            style : "aui-center",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                validator : pointValidation
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        },
                        {
                            headerText : "비고",
                            dataField : "q4_remark",
                            width : "15%",
                            style : "aui-left",
                            editable: true,
                            editRenderer : {
                                type : "InputEditRenderer",
                                maxlength : 100,
                                validator : AUIGrid.commonValidator
                            },
                            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                                if ("${inputParam.s_current_year}" == item["eval_year"]) {
                                    return "aui-editable"
                                }
                                return null;
                            }
                        }
                    ]
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
                // 당해년도만 수정 가능
                if (event.dataField.endsWith("_remark") || event.dataField.endsWith("_point")) {
                    if ("${inputParam.s_current_year}" != event.item["eval_year"]) {
                        return false;
                    }
                }
            });

            AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
                // 최종평점 공백 삭제 및 숫자 처리
				if (event.dataField.endsWith("_eval_point")) {
					// 공백 삭제 및 숫자 처리
                    if (event.value) {
					    AUIGrid.setCellValue(auiGrid, event.rowIndex, event.dataField, Number(event.value.trim()));
                    }
				}
			});
        }

        // 최종평점 validation
        var pointValidation = function (oldValue, newValue, item, dataField, fromClipboard, which) {
            var maxPoint = 100;
            var isValid = true;
            var msg = null;

            if (isNaN(newValue)) {
                isValid = false;
            } else {
                var numVal = Number(newValue);
                if (numVal > maxPoint || numVal < 0) {
                    isValid = false;
                    msg = numVal > maxPoint ? "최대 평점은 " + maxPoint +"점입니다." : null;
                }
            }
            return {"validate" : isValid, "message" : msg};
        }


        //조회
        function goSearch() {
            var param = {
                "s_year": $M.getValue("s_year"),
                "s_org_code": $M.getValue("s_org_code")
            };
            $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if(result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);
                        $("#total_cnt").html(result.total_cnt);
                    }
                }
            );
        }

        // 저장
        function goSave() {
            if (fnChangeGridDataCnt(auiGrid) == 0){
                alert("변경된 데이터가 없습니다.");
                return false;
            }

            var concatCols = fnGetColumns(auiGrid);
            var concatList = AUIGrid.getEditedRowItems(auiGrid);
            var gridForm = fnGridDataToForm(concatCols, concatList);

            $M.goNextPageAjaxSave(this_page + '/save', gridForm, {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearch();
                        window.opener.goSearch();
                    }
                }
            );
        }

        // 엑셀다운로드
        function fnDownloadExcel() {
            var exportProps = {};
            fnExportExcel(auiGrid, "분기별평가(조정)", exportProps);
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
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="contents">
                <!-- 검색영역 -->
                <div class="search-wrap mt10">
                    <table class="table">
                        <colgroup>
                            <col width="60px">
                            <col width="80px">
                            <col width="50px">
                            <col width="120px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>조회년도</th>
                            <td>
                                <select class="form-control" id="s_year" name="s_year" required="required" alt="조회년도">
                                    <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                        <c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
                                        <option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
                                    </c:forEach>
                                </select>
                            </td>
                            <th>부서</th>
                            <td>
                                <select class="form-control" id="s_org_code" name="s_org_code">
                                    <option value="">- 전체 -</option>
                                    <c:forEach var="item" items="${org_center_list}">
                                        <option value="${item.org_code}" <c:if test="${item.org_code eq inputParam.s_org_code}">selected</c:if>>${item.org_name}</option>
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
                <div class="title-wrap mt10">
                    <h4>조회결과</h4>
                    <div class="btn-group">
                        <div class="left text-warning ml5">
                            ※ 엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                        </div>
                    </div>
                </div>
                <!-- 그리드 -->
                <div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
                <!-- 하단 영역 -->
                <div class="btn-group mt10">
                    <div class="left">
                        총 <strong class="text-primary" id="total_cnt">0</strong>건
                    </div>
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
    </form>
</body>
</html>