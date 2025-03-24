<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 회계연관팝업 > 회계연관팝업 > null > 퇴사자 업무 이관
-- 작성자 : 김경빈
-- 최초 작성일 : 2022-10-24 PM 2:53
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var misuListCnt = ${misu_list_cnt};
        var todoListCnt = ${todo_list_cnt};

        $(document).ready(function() {
            createAUIGrid();
        });

        function createAUIGrid() {
            // 그리드 설정 - 공통
            var gridPros = {
                editable : false,
            };

            // 그리드 생성 - 미수담당 고객
            var columnLayoutMisu = [
                {
                    headerText: "고객번호",
                    dataField: "cust_no",
                    width : "20%",
                    style : "aui-center",
                },
                {
                    headerText: "이름",
                    dataField: "cust_name",
                    width : "15%",
                    style : "aui-center",
                },
                {
                    headerText: "지역",
                    dataField: "addr1",
                    width: "50%",
                    style : "aui-left",
                },
                {
                    headerText: "센터",
                    dataField: "org_kor_name",
                    style : "aui-center",
                },
            ];
            if (misuListCnt > 0) {
                auiGridMisu = AUIGrid.create("#auiGrid-misu", columnLayoutMisu, gridPros);
                AUIGrid.setGridData(auiGridMisu, ${misu_list});
                $("#auiGrid-misu").resize();
            }

            // 그리드 생성 - 미결업무
            var columnLayoutTodo = [
                {
                    headerText : "정비일",
                    dataField : "show_todo_dt",
                    width : "90",
                    dataType : "date",
                    formatString : "yy-mm-dd",
                    style : "aui-center",
                },
                {
                    headerText : "상담구분",
                    dataField : "service_type",
                    width : "90",
                    style : "aui-center",
                },
                {
                    headerText : "고객명",
                    dataField : "cust_name",
                    width : "120",
                    style : "aui-center",
                },
                {
                    headerText : "모델명",
                    dataField : "machine_name",
                    width : "100",
                },
                {
                    headerText : "차대번호",
                    dataField : "body_no",
                    width : "140",
                },
                {
                    headerText : "휴대폰",
                    dataField : "hp_no",
                    width : "100",
                    style : "aui-center",
                },
                {
                    headerText : "담당자",
                    dataField : "assign_mem_name",
                    width : "90",
                    style : "aui-center",
                },
                {
                    headerText : "작업구분",
                    dataField : "as_todo_status_name",
                    width : "90",
                    style : "aui-center",
                },
                {
                    headerText : "미결사항",
                    dataField : "todo_text",
                    width : "200",
                    style : "aui-left",
                },
                {
                    headerText : "예정일",
                    dataField : "show_plan_dt",
                    width : "90",
                    dataType : "date",
                    formatString : "yy-mm-dd",
                    style : "aui-center",
                },
                {
                    dataField : "as_todo_seq",
                    visible : false,
                },
                {
                    dataField : "as_no",
                    visible : false,
                },
                {
                    dataField : "as_todo_status_cd",
                    visible : false,
                },
                {
                    dataField : "as_todo_type_cd",
                    visible : false,
                },
                {
                    dataField : "machine_seq",
                    visible : false,
                },
                {
                    dataField : "assign_mem_no",
                    visible : false,
                },
                {
                    dataField : "m_ref_key",
                    visible : false,
                },
                {
                    dataField : "delay_dt",
                    visible : false,
                },
                {
                    dataField : "todo_dt",
                    visible : false,
                },
                {
                    dataField : "plan_dt",
                    visible : false,
                },
                {
                    dataField : "cmd",
                    visible : false,
                },
            ];
            if (todoListCnt > 0) {
                auiGridTodo = AUIGrid.create("#auiGrid-todo", columnLayoutTodo, gridPros);
                AUIGrid.setGridData(auiGridTodo, ${todo_list});
                AUIGrid.bind(auiGridTodo, "cellClick", function(event) {
                    if(event.dataField == "todo_text" ) {
                        var params = {
                            "s_machine_seq" : event.item.machine_seq,
                            "s_as_todo_seq" : event.item.as_todo_seq
                        };
                        $M.goNextPage('/serv/serv0101p17', $M.toGetParam(params), {popupStatus : ""});
                    }
                });
                $("#auiGrid-todo").resize();
            }
        }

        // 팝업 닫기
        function fnClose() {
            window.close();
        }

        // 이관 미수담당자 찾기
        function fnSetMisuMem(data) {
            $M.setValue("misu_mem_name", data.mem_name);
            $M.setValue("misu_mem_no", data.mem_no);
        }

        // 이관 미결업무 담당자 찾기
        function fnSetTodoMem(data) {
            $M.setValue("todo_mem_name", data.mem_name);
            $M.setValue("todo_mem_no", data.mem_no);
        }

        // 저장
        function goSave() {
            // validation check
            if (misuListCnt > 0 && $M.getValue("misu_mem_no") == "") {
                alert("이관되지 않은 미수담당이 있습니다.\n이관될 미수담당자를 등록해 주세요.");
                return;
            }

            if (todoListCnt > 0 && $M.getValue("todo_mem_no") == "") {
                alert("이관되지 않은 미결업무가 있습니다.\n이관될 미결담당자를 등록해 주세요.");
                return;
            }

            var result = confirm("저장하시겠습니까?");
            if (result) {
                var data = {
                    "misu_mem_no" : $M.getValue("misu_mem_no"),
                    "misu_mem_name" : $M.getValue("misu_mem_name"),
                    "todo_mem_no" : $M.getValue("todo_mem_no"),
                    "todo_mem_name" : $M.getValue("todo_mem_name"),
                }
                opener.${inputParam.parent_js_name}(data);
                fnClose();
            }
        }

    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" id="misu_list_cnt">
    <input type="hidden" id="todo_list_cnt">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 미수담당 고객 -->
            <c:if test="${misu_list_cnt > 0}">
                <div class="mt5">
                    <div class="form-row inline-pd widthfix">
                        <div class="col-9">
                            <h4 id="title">미수담당 고객</h4>
                        </div>
                        <div class="col-3 text-right">
                            <div class="input-group">
                                <input type="text" class="form-control border-right-0" id="misu_mem_name" name="misu_mem_name" placeholder="이관 미수담당자" readonly="readonly" style="background: white">
                                <input type="hidden" id="misu_mem_no" name="misu_mem_no">
                                <button type="button" class="btn btn-icon btn-primary-gra" id="_fnSetMisuMem" onclick="javascript:openSearchMemberPanel('fnSetMisuMem');"><i class="material-iconssearch"></i></button>
                            </div>
                        </div>
                    </div>
                    <!-- 미수담당 고객 그리드 -->
                    <div id="auiGrid-misu" style="margin-top: 5px; height: 270px;"></div>
                </div>
            </c:if>
            <!-- /미수담당 고객 -->
            <!-- 미결업무 -->
            <c:if test="${todo_list_cnt > 0}">
                <div class="mt15">
                    <div class="form-row inline-pd widthfix">
                        <div class="col-9">
                            <h4 id="title">미결업무</h4>
                        </div>
                        <div class="col-3 text-right">
                            <div class="input-group">
                                <input type="text" class="form-control border-right-0" id="todo_mem_name" name="todo_mem_name" placeholder="이관 미결담당자" readonly="readonly" style="background: white">
                                <input type="hidden" id="todo_mem_no" name="todo_mem_no">
                                <button type="button" class="btn btn-icon btn-primary-gra" id="_fnSetTodoMem" onclick="javascript:openSearchMemberPanel('fnSetTodoMem');"><i class="material-iconssearch"></i></button>
                            </div>
                        </div>
                    </div>
                    <!-- 미결업무 그리드 -->
                    <div id="auiGrid-todo" style="margin-top: 5px; height: 270px;"></div>
                </div>
            </c:if>
            <!-- /미결업무 -->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>