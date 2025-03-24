<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 모바일관리 > 고객앱관리 > 인증관리
-- 작성자 : 정선경
-- 최초 작성일 : 2023-07-11 17:52:38
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var page = 1;
        var moreFlag = "N";
        var isLoading = false;

        $(document).ready(function() {
            createAUIGrid();

            var selectedCodeArr = ["02", "05"]; // 가입완료, 승인완료 선택상태
            $('#s_c_cust_status_cd').combogrid("setValues", selectedCodeArr);
        });

        //엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "고객앱관리", "");
        }

        function enter(fieldObj) {
            var field = ["s_cust_name"];
            $.each(field, function() {
                if(fieldObj.name == this) {
                    goSearch();
                }
            });
        }

        // 그리드생성
        function createAUIGrid() {
            var gridPros = {
                enableCellMerge : true,
                rowIdField : "_$uid",
                showRowNumColumn : true,
                headerHeight : 45,
                // 체크박스 출력 여부
                showRowCheckColumn : true,
                // 전체 체크박스 표시 설정
                showRowAllCheckBox : true,
            };

            var columnLayout = [
                {
                    dataField: "app_cust_no",
                    visible : false
                },
                {
                    headerText: "계정아이디",
                    dataField: "web_id",
                    width : "8%"
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width : "8%"
                },
                {
                    headerText : "휴대전화",
                    dataField : "hp_no",
                    width : "9%"
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
                    headerText : "최종로그인일시",
                    dataField : "last_login_date",
                    width : "10%",
                    dataType : "date",
                    formatString : "yy-mm-dd HH:MM:ss",
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
                    dataField : "app_exit_yn",
                    headerText : "앱종료예약여부",
                    width : "10%",
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
                    headerText : "앱종료일시",
                    dataField : "app_exit_date",
                    width : "10%",
                    dataType : "date",
                    formatString : "yy-mm-dd HH:MM:ss",
                },
            ];
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
            AUIGrid.resize(auiGrid);
        }

        // 조회
        function goSearch() {
            // 조회 버튼 눌렀을경우 1페이지로 초기화
            page = 1;
            moreFlag = "N";
            fnSearch(function (result) {
                AUIGrid.setGridData(auiGrid, result.list);
                AUIGrid.resize(auiGrid);
                for (var i = 0; i < result.list.length; ++i) {
                    result.list[i]["isCheck"] = false;
                }
                $("#total_cnt").html(result.total_cnt);
                $("#curr_cnt").html(result.list.length);
                if (result.more_yn == 'Y') {
                    moreFlag = "Y";
                    page++;
                }
            });
        }

        function fnSearch(successFunc) {
            isLoading = true;
            var param = {
                "s_cust_name" : $M.getValue("s_cust_name"),
                "s_c_cust_grade_cd" : $M.getValue("s_c_cust_grade_cd"),
                "s_c_cust_status_cd_str" : $M.getValue("s_c_cust_status_cd"),
                "s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "page" : page,
                "rows" : $M.getValue("s_rows")
            };
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if(result.success) {
                        isLoading = false;
                        if(result.success) {
                            successFunc(result);
                        }
                    }
                }
            );
        }

        // 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
        function fnScollChangeHandelr(event) {
            if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
                goMoreData();
            }
        }

        function goMoreData() {
            fnSearch(function(result){
                result.more_yn == "N" ? moreFlag = "N" : page++;
                if (result.list.length > 0) {
                    AUIGrid.appendData("#auiGrid", result.list);
                    $("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
                }
            });
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

        function goCustAppLogout() {
            var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
            if(checkedItems.length <= 0) {
                alert("선택된 데이터가 없습니다.");
                return;
            }

            var frm = fnCheckedGridDataToForm(auiGrid);
            var msg = "선택한 고객을 로그아웃처리 하겠습니까?";
            $M.goNextPageAjaxMsg(msg, this_page +"/logout", frm, {method : 'POST'},
                function(result) {
                    if(result.success) {
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
                                <col width="80px">
                                <col width="120px">
                                <col width="80px">
                                <col width="180px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>고객명</th>
                                <td>
                                    <input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
                                </td>
                                <th>앱고객등급</th>
                                <td>
                                    <select class="form-control" id="s_c_cust_grade_cd" name="s_c_cust_grade_cd">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${codeMap['C_CUST_GRADE']}" var="item">
                                            <option value="${item.code_value}">${item.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>앱고객상태</th>
                                <td>
                                    <input type="text" style="width : 180px;"
                                           id="s_c_cust_status_cd"
                                           name="s_c_cust_status_cd"
                                           easyui="combogrid"
                                           header="Y"
                                           easyuiname="c_cust_status_list"
                                           panelwidth="200"
                                           maxheight="300"
                                           textfield="code_name"
                                           multi="Y"
                                           idfield="code_value" />
                                </td>
                                <td>
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
                                <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                        <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                                    </div>
                                </c:if>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->

                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>

                    <!-- 그리드 서머리, 컨트롤 영역 -->
                    <div class="btn-group mt5">
                        <div class="left">
                            <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
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
