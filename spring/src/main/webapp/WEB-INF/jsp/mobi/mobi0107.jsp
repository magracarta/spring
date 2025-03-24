<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 모바일관리 > 기준정보 > 인증관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-06-30 17:37:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        $(document).ready(function() {
            createAUIGrid();
        });

        //엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "인증관리", "");
        }

        function enter(fieldObj) {
            var field = ["s_mem_name"];
            $.each(field, function() {
                if(fieldObj.name == this) {
                    goSearch();
                };
            });
        }

        // 그리드생성
        function createAUIGrid() {
            var gridPros = {
                enableCellMerge : true,
                rowIdField : "_$uid",
                showRowNumColumn : true,
                headerHeight : 45
            };
            // AUIGrid 칼럼 설정
            var columnLayout = [
                {
                    dataField: "mem_no",
                    visible : false
                },
                {
                    headerText: "계정아이디",
                    dataField: "web_id",
                    width : "8%"
                },
                {
                    headerText: "직원구분",
                    dataField: "mem_type_name",
                    width : "6%"
                },
                {
                    headerText: "직원명",
                    dataField: "kor_name",
                    width : "8%"
                },
                {
                    headerText : "부서",
                    dataField : "org_name",
                    width : "9%"
                },
                {
                    headerText : "직위",
                    dataField : "grade_name",
                    width : "6%"
                },
                {
                    headerText : "직급",
                    dataField : "job_name",
                    width : "5%"
                },
                {
                    headerText : "휴대전화",
                    dataField : "hp_no",
                    width : "9%",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return $M.phoneFormat(value)
                    }
                },
                {
                    headerText : "재직구분",
                    dataField : "work_status_name",
                    width : "5%"
                },
                {
                    headerText : "앱버전",
                    dataField : "app_ver",
                    width : "6%"
                },
                {
                    headerText : "모델명",
                    dataField : "model_name",
                    width : "8%"
                },
                {
                    headerText : "OS버전",
                    dataField : "os_ver",
                    width : "6%"
                },
                {
                    dataField : "app_web_yn",
                    headerText : "웹접속허용",
                    width : "5%",
                    headerRenderer : {
                        type : "CheckBoxHeaderRenderer",
                        dependentMode : true,
                        position : "bottom"
                    },
                    renderer : {
                        type : "CheckBoxEditRenderer",
                        showLabel : false,
                        editable : true,
                        checkValue : "Y",
                        unCheckValue : "N"
                    },
                },
                {
                    dataField : "app_device_upt_yn",
                    headerText : "인증적용",
                    width : "5%",
                    headerRenderer : {
                        type : "CheckBoxHeaderRenderer",
                        dependentMode : true,
                        position : "bottom"
                    },
                    renderer : {
                        type : "CheckBoxEditRenderer",
                        showLabel : false,
                        editable : true,
                        checkValue : "Y",
                        unCheckValue : "N"
                    },
                },
                {
                    headerText : "인증일시",
                    dataField : "auth_date",
                    width : "10%",
                    dataType : "date",
                    formatString : "yy-mm-dd HH:MM:ss",
                },
            ];
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.resize(auiGrid);
        }

        // 조회
        function goSearch() {
            var param = {
                "s_mem_name" : $M.getValue("s_mem_name"),
                "s_org_code" : $M.getValue("s_org_code"),
                "s_mem_type_cd" : $M.getValue("s_mem_type_cd"),
                "s_work_status_cd" : $M.getValue("s_work_status_cd"),
            };
            
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if(result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        for (var i = 0; i < result.list.length; ++i) {
                            result.list[i]["isCheck"] = false;
                        }
                        AUIGrid.setGridData(auiGrid, result.list);
                        AUIGrid.resize(auiGrid);
                    };
                }
            );
        }

        function goSave() {
            if (AUIGrid.getEditedRowItems(auiGrid).length == 0) {
                alert("변경내역이 없습니다.");
                return;
            }

            var frm = fnChangeGridDataToForm(auiGrid);

            $M.goNextPageAjaxSave(this_page + "/save", frm , {method : 'POST'},
                function(result) {
                    if(result.success) {
                        alert("저장이 완료되었습니다.");
                        goSearch();
                    }
                }
            );
        }

    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="clickedRowIndex" name="clickedRowIndex">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 기본 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="55px">
                                <col width="120px">
                                <col width="50px">
                                <col width="120px">
                                <col width="75px">
                                <col width="120px">
                                <col width="75px">
                                <col width="120px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>직원명</th>
                                <td>
                                    <input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
                                </td>
                                <th>부서</th>
                                <td>
                                    <input class="form-control" style="width: 99%;"type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
                                           easyuiname="pathOrgList" panelwidth="350" idfield="org_code" textfield="path_org_name" multi="N"/>
                                </td>
                                <th>직원구분</th>
                                <td>
                                    <select class="form-control" id="s_mem_type_cd" name="s_mem_type_cd">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="list" items="${codeMap['MEM_TYPE']}">
                                            <option value="${list.code_value}">${list.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>재직구분</th>
                                <td>
                                    <select class="form-control" id="s_work_status_cd" name="s_work_status_cd">
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="list" items="${codeMap['WORK_STATUS']}">
                                            <option value="${list.code_value}" <c:if test="${list.code_value eq '01'}">selected</c:if>>${list.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /기본 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->

                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

                    <!-- 그리드 서머리, 컨트롤 영역 -->
                    <div class="btn-group mt5">
                        <div class="left">
                            총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                    <!-- /그리드 서머리, 컨트롤 영역 -->
                </div>

            </div>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>