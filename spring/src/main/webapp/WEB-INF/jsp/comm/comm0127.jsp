<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > API호출
-- 작성자 : 황다은
-- 최초 작성일 : 2024-03-15
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGridLeft;
        var auiGridRight;
        var page = 1;
        var moreFlag = "N";
        var isLoading = false;
        var checkStr = ''; // 체크 될 타겟 str
        var paramGridData;

        $(document).ready(function () {
            createAUIGridLeft();
            createAUIGridRight();
            fnNew();    // 신규
            checkStr = $('#main_form').serialize();
        });

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_api_name", "s_api_uri_host", "s_remark"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
        }

        // 조회(검색)
        function goSearch(isNew) {
            // 조회 버튼 눌렀을경우 1페이지로 초기화
            page = 1;
            moreFlag = "N";

            fnSearch(isNew, function (result) {
                AUIGrid.setGridData(auiGridLeft, result.list);
                $("#total_cnt").html(result.total_cnt);
                $("#curr_cnt").html(result.list.length);
                if (result.more_yn == 'Y') {
                    moreFlag = "Y";
                    page++;
                }
            });

            fnNew();

        }

        function fnSearch(isNew, successFunc){
            isLoading = true;

            var newSearch = isNew != undefined;

            var param = {
                "s_api_name": $M.getValue("s_api_name"),
                "s_api_uri_host": $M.getValue("s_api_uri_host"),
                "s_remark": $M.getValue("s_remark"),
                "s_use_yn": $M.getValue("s_use_yn"),
                "s_sort_key": newSearch ? "api_seq" : "api_name",
                "s_sort_method": newSearch ? "desc" : "asc",
                "page": page,
                "rows": $M.getValue("s_rows")
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
                function (result) {
                    isLoading = false;
                    if (result.success) {
                        successFunc(result);
                    }
                }
            );
        }

        // 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
        function fnScollChangeHandelr(event) {
            if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
                goMoreData(false);
            }
        }

        function goMoreData(isNew) {
            fnSearch(isNew,function (result) {
                result.more_yn == "N" ? moreFlag = "N" : page++;
                if (result.list.length > 0) {
                    AUIGrid.appendData("#auiGridLeft", result.list);
                    $("#curr_cnt").html(AUIGrid.getGridData(auiGridLeft).length);
                }
            });
        }

        // 신규
        function fnNew() {
            var param = {
                api_name: "",
                api_host: "",
                req_time_out : 0,
                use_yn: "Y",
                api_uri: "",
                api_method_cd: "",
                remark: "",
                api_seq: 0,
                param_char_set: "utf-8"
            }
            $M.setValue(param);

            $M.setValue("callResult", "");  // 호출결과textarea 공백초기화

            AUIGrid.clearGridData(auiGridRight);    // Param정보 그리드 초기화
        }

        // 행추가
        function fnAdd() {
            // 셀 포커스 param명으로 지정
            var colIndex = AUIGrid.getColumnIndexByDataField(auiGridRight, "param_name");
            fnSetCellFocus(auiGridRight, colIndex, "param_name");

            if (fnCheckGridEmpty(auiGridRight)) {
                var item = new Object();
                item.seq_no = 0;
                item.param_name = "";
                item.param_field = "";
                item.default_value = "";
                item.required_yn = "N";
                item.cmd = "C";

                // 실제 행추가
                AUIGrid.addRow(auiGridRight, item, 'last'); // 밑에서 부터 행추가

            }
        }

        // 그리드 빈값 체크
        function fnCheckGridEmpty() {
            return AUIGrid.validateGridData(auiGridRight, ["param_name", "param_field"], "필수 항목은 반드시 값을 입력해야합니다.");
        }

        // 호출할 때 필수여부 체크 시 기본값/전달값 필수
        function fnDefaultCheck() {
            var gridFrm = AUIGrid.getGridData(auiGridRight);
            var colIndex = AUIGrid.getColumnIndexByDataField(auiGridRight, "default_value");

            for (var i = 0; i < gridFrm.length; i++) {
                if (gridFrm[i].required_yn == 'Y' && gridFrm[i].default_value == '') {
                    alert("필수 Param값을 입력해 주세요");
                    AUIGrid.setSelectionByIndex(auiGridRight, i, colIndex);
                    return false;
                }
            }
            return true;
        }

        // API정보 편집유무 확인
        function fnCheckEdit() {
            var changeAPI = false;

            var currStr = $('#main_form').serialize();
            if (checkStr != currStr) {
                changeAPI = true;
            }
            return changeAPI;
        }

        // Param정보(그리드) 편집유무 확인
        function fnCheckGridEdit() {
            var changeGrid = false;

            var addLen = AUIGrid.getAddedRowItems(auiGridRight).length;
            var rmvLen = AUIGrid.getRemovedItems(auiGridRight).length;
            var edtrows = AUIGrid.getEditedRowColumnItems(auiGridRight);

            var conCheck = true;
            var count = 0;
            var tempCount = 0;

            edtrows.forEach(function (v, n) {
                // default_value (기본값/전달값), 필수여부 제외한 모든 필드들이 없어야 함.
                if ((v.required_yn !== undefined || v.default_value !== undefined || v.cmd !== undefined) && v.param_name === undefined && v.param_field === undefined) {
                    tempCount += 1;
                } else if (v.param_name !== undefined || v.param_field !== undefined) {
                    // default_value, required_yn 외에 다른 필드가 하나라도 있으면 false
                    conCheck = false;
                }
            });

            if (conCheck && tempCount > 0) {
                count = tempCount;
            } else {
                count = 0;
            }

            if (addLen > 0 || rmvLen > 0) { // 추가나 삭제있을경우는 무조건 true
                changeGrid = true;
            } else if (edtrows.length > 0) { // 수정된 행이 있지만, 추가나 삭제는 없는 경우
                // 수정되었을 때, count가 0이면
                if (count === 0) {
                    changeGrid = true;
                } else {
                    changeGrid = false;
                }
            }

            return changeGrid;
        }

        // API호출
        function fnApiCall() {
            // API정보 편집 유무 체크
            var changeAPI = fnCheckEdit();

            // 그리드 편집 유무체크
            var changeGrid = fnCheckGridEdit(auiGridRight);

            if ($M.validation(document.main_form, {field: ['api_name', 'use_yn', 'api_uri', 'api_method_cd']}) == false) {
                return;
            }

            if (fnCheckGridEmpty(auiGridRight) === false) {
                alert("필수 항목은 반드시 값을 입력해야합니다.");
                return false;
            }

            if (fnDefaultCheck(auiGridRight) === false) {
                return false;
            }

            var gridFrm = AUIGrid.getGridData(auiGridRight);

            // 파람필드와 전달값 매칭
            var map = {};

            for (var i = 0; i < gridFrm.length; i++) {
                var key = gridFrm[i].param_field;
                var value = gridFrm[i].default_value;

                map[key] = value;
            }

            var frm = $M.toValueForm(document.main_form);
            var gridData = fnGridObjDataToForm(auiGridRight);
            // $M.copyForm(gridData, frm);
            // gridData.remove('#callResult');

            // $M.copyForm(gridData, frm)에 callResult빼고 카피
            var len = frm.length;
            for (var i = 0; i < len; ++i) {
                var item = frm[i];
                if (item.name == "callResult") {
                    continue;
                }
                $M.setValue(gridData, item.name, $M.getValue(frm, item.name));
            }


            var msg = "API호출을 하시겠습니까?";
            // 편집한 흔적있으면 알림, 없으면 api호출 수행
            if (changeGrid == true || changeAPI == true) {
                alert("저장 후 다시 시도해주세요.")
            } else {
                var apiUri = $M.getValue("api_uri");
                var apiMethod = $M.getValue("api_method_cd");
                var reqTimeOut = $M.getValue("req_time_out");
                reqTimeOut = reqTimeOut == 0 ? 10 : reqTimeOut;

                if (frm.api_host.value !== "") {

                    $M.goNextPageAjaxMsg(msg, this_page + "/call", gridData, {method: 'GET', timeout : reqTimeOut*1000*60 },
                        function (result) {
                            // json 형태로 포멧팅
                            $M.setValue('callResult', JSON.stringify(result, null, 4));
                            $("#callResult").scrollTop(0);
                            checkStr = $('#main_form').serialize();
                        }
                    );
                } else {
                    $M.goNextPageAjaxMsg(msg, apiUri, $M.toGetParam(map), {method: apiMethod, timeout : reqTimeOut*1000*60},
                        function (result) {
                            // console.log("result : ", result);
                            // $M.setValue("callResult", "");
                            $M.setValue('callResult', JSON.stringify(result, null, 4));
                            $("#callResult").scrollTop(0);
                            checkStr = $('#main_form').serialize();
                        }
                    );
                }
            }
        }

        // Param 필드 중복체크
        function fnParamFiledCheck(paramField, rowIndex) {

            for (var i = 0; i < paramGridData.length; i++) {
                if (paramGridData[i].param_field == paramField) {
                    alert("Param 필드 중복입니다.")
                    AUIGrid.updateRow(auiGridRight, {"param_field": ""}, rowIndex);
                }
            }

        }

        // api정보, param정보 저장
        function goSave() {
            var frm = document.main_form;

            if ($M.validation(document.main_form) == false) {   // required인 곳 찾아서 밸리데이션
                return;
            }

            if (fnCheckGridEmpty(auiGridRight) === false) {
                return false;
            }

            var gridFrm = fnChangeGridDataToForm(auiGridRight);

            // URI 시작 문자 검사
            var apiUri = $M.getValue('api_uri');
            if (apiUri.charAt(0) !== '/') {
                alert("URI는 '/'부터 시작해야합니다.");
                $("#api_uri").focus();
                return false;
            }

            var reqTime = $M.getValue('req_time_out');
            var check = /^[0-9]+$/;
            if(!check.test(reqTime)){
                alert("0이상의 숫자를 입력해주시요");
                $("#req_time_out").focus();
                return false;
            }

            $M.copyForm(gridFrm, frm);

            $M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method: 'POST'},
                function (result) {
                    if (result.success) {
                        var api_seq = $M.getValue('api_seq');

                        if (api_seq == '0') {
                            goSearch(true);
                        } else {
                            goSearch();
                            goSearchDetail(api_seq);
                        }
                        $M.setValue("callResult", "");
                    }
                }
            );
        }

        // 상세 조회
        function goSearchDetail(apiSeq) {

            $M.goNextPageAjax(this_page + "/detail", "api_seq=" + apiSeq, {method: 'get'},
                function (result) {
                    if (result.success) {
                        $M.setValue(result.detail); // API정보
                        AUIGrid.setGridData(auiGridRight, result.list); // Param정보

                        checkStr = $('#main_form').serialize(); // 편집 유무 확인
                    }
                }
            )
        }

        // 왼쪽 그리드
        function createAUIGridLeft() {
            var gridPros = {
                // rowIdField 설정
                rowIdField: "api_seq",
                // rowNumber
                showRowNumColum: true
            }

            var columnLayout = [
                {
                    headerText: "API명",
                    dataField: "api_name",
                    width: "30%",
                    style: "aui-left aui-link",
                    editable: false
                },
                {
                    headerText: "URI",
                    dataField: "api_uri",
                    style: "aui-left",
                    editable: false,
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return item.api_host + item.api_uri;
                    }
                },
                {
                    headerText: "METHOD",
                    dataField: "api_method_cd",
                    width: "15%",
                    style: "aui-right",
                    editable: false
                },
                {
                    headerText: "사용여부",
                    dataField: "use_yn",
                    width: "10%",
                    style: "aui-center",
                    editable: false
                },
                {
                    dataField: "api_seq",
                    visible: false
                },
                {
                    dataField: "remark",
                    visible: false
                },
            ];
            // 실제로 #grid_wrap에 그리드 생성
            auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);

            // 그리드 갱신
            AUIGrid.setGridData(auiGridLeft, []);

            AUIGrid.bind(auiGridLeft, "vScrollChange", fnScollChangeHandelr);
        }

        // 오른쪽 그리드 생성
        function createAUIGridRight() {
            var gridPros = {
                rowIdField: "_$uid",
                // rowNumber
                showRowNumColum: true,
                showStateColumn: true,
                // 편집 유무
                editable: true
            }

            var columnLayout = [
                {
                    headerText: "Param명",
                    dataField: "param_name",
                    style: "aui-left aui-editable",
                    editRenderer: {
                        type: "InputEditRenderer",
                        maxlength: 100,
                    },
                    renderer: {
                        type: "TemplateRenderer",
                        aliasFunction: function (rowIndex, columnIndex, value) {
                            return value.replace(/\s/g, "　");
                        }
                    },
                    labelFunction: function (rowIndex, columnIndex, value) {
                        return value.replace(/\s/g, "&nbsp;"); // &nbsp; 로 공백 표현
                    },
                },
                {
                    headerText: "Param필드",
                    dataField: "param_field",
                    style: "aui-left aui-editable",
                    editRenderer: {
                        type: "InputEditRenderer",
                        maxlength: 100,
                    },
                    // renderer: {
                    //     type: "TemplateRenderer",
                    //     aliasFunction: function (rowIndex, columnIndex, value) {
                    //         return value.replace(/\s/g, "　");
                    //     }
                    // },
                    // labelFunction: function (rowIndex, columnIndex, value) {
                    //     return value.replace(/\s/g, "&nbsp;"); // &nbsp; 로 공백 표현
                    // },
                },
                {
                    headerText: "기본값/전달값",
                    dataField: "default_value",
                    style: "aui-left aui-editable",
                    editRenderer: {
                        type: "InputEditRenderer",
                        // showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
                        maxlength: 1000,
                    },
                    // renderer: {
                    //     type: "TemplateRenderer",
                    //     aliasFunction: function (rowIndex, columnIndex, value) {
                    //         return value.replace(/\s/g, "　");
                    //     }
                    // },
                    // labelFunction: function (rowIndex, columnIndex, value) {
                    //     return value.replace(/\s/g, "&nbsp;"); // &nbsp; 로 공백 표현
                    // },
                },
                {
                    headerText: "헤더유무",
                    dataField: "header_yn",
                    minWidth: "45",
                    width: "7%",
                    renderer: {
                        type: "CheckBoxEditRenderer",
                        editable: true,
                        checkValue: "Y",
                        unCheckValue: "N"
                    },
                },
                {
                    headerText: "필수여부",
                    dataField: "required_yn",
                    minWidth: "45",
                    width: "7%",
                    renderer: {
                        type: "CheckBoxEditRenderer",
                        editable: true,
                        checkValue: "Y",
                        unCheckValue: "N"
                    },
                },
                {
                    headerText: "인코딩여부",
                    dataField: "encoding_yn",
                    minWidth: "45",
                    width: "8%",
                    renderer: {
                        type: "CheckBoxEditRenderer",
                        editable: true,
                        checkValue: "Y",
                        unCheckValue: "N"
                    },
                },
                {
                    headerText: "삭제",
                    dataField: "removeBtn",
                    width: "8%",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                            var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
                            if (isRemoved == false) {
                                AUIGrid.updateRow(auiGridRight, {cmd: "D"}, event.rowIndex);
                                AUIGrid.removeRow(event.pid, event.rowIndex);
                            } else {
                                AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex");
                                AUIGrid.updateRow(auiGridRight, {cmd: ""}, event.rowIndex);
                            }
                        }
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                    style: "aui-center",
                    editable: true,

                },
                {
                    dataField: "seq_no",
                    visible: false
                },
                {
                    dataField: "cmd",
                    visible: false
                }
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);

            // 그리드 갱신
            AUIGrid.setGridData(auiGridRight, []);

            // 왼쪽 그리드 셀 클릭시 이벤트
            AUIGrid.bind(auiGridLeft, "cellClick", function (event) {
                $M.setValue("callResult", "");
                if (event.dataField == "api_name") {
                    goSearchDetail(event.item["api_seq"]);
                }
            });

            AUIGrid.bind(auiGridRight, "cellEditBegin", function (event) {
                paramGridData = AUIGrid.getGridData(auiGridRight);
            });

            AUIGrid.bind(auiGridRight, "cellEditEnd", function (event) {
                // param필드 중복체크
                if (event.dataField == "param_field") {
                    if (event.item.param_field != "") {
                        fnParamFiledCheck(event.item.param_field, event.rowIndex);
                    }
                }
            });
        }

    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="api_seq" name="api_seq" value="0"/>
    <!-- contents 전체 영역 -->
    <div class="content-wrap">
        <div class="content-box">
            <!-- 메인 타이틀 -->
            <div class="main-title">
                <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            </div>
            <!-- /메인 타이틀 -->
            <div class="contents">
                <%--검색영역--%>
                <div class="search-wrap">
                    <table class="table">
                        <colgroup>
                            <col width="70">
                            <col width="130">
                            <col width="70">
                            <col width="130">
                            <col width="50">
                            <col width="130">
                            <col width="70">
                            <col width="80">
                            <col width="*">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>API명</th>
                            <td>
                                <input type="text" class="form-control" id="s_api_name" name="s_api_name">
                            </td>
                            <th>API URI</th>
                            <td>
                                <input type="text" class="form-control" id="s_api_uri_host" name="s_api_uri_host"
                                       maxlength="100" size="100">
                            </td>
                            <th>비고</th>
                            <td>
                                <input type="text" class="form-control" id="s_remark" name="s_remark" maxlength="135"
                                       size="135">
                            </td>
                            <th>사용여부</th>
                            <td>
                                <select class="form-control" id="s_use_yn" name="s_use_yn">
                                    <option value="">- 전체 -</option>
                                    <option value="Y" selected>사용</option>
                                    <option value="N">미사용</option>
                                </select>
                            </td>
                            <td class="">
                                <button type="button" class="btn btn-important" style="width: 50px;"
                                        onclick="javascript:goSearch();">조회
                                </button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <%--/검색영역--%>
                <div class="row">
                    <%-- 조회결과(API목록) --%>
                    <div class="col-5">
                        <div class="title-wrap mt10">
                            <h4>조회결과</h4>
                        </div>
                        <div style="margin-top: 10px; height: 470px;" id="auiGridLeft"></div>
                        <div class="btn-group mt5">
                            <div class="left">
                                <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                            </div>
                        </div>
                    </div>
                    <%-- /조회결과(API목록) --%>

                    <div class="col-7">
                        <%-- api정보 --%>
                        <div class="row">
                            <div class="col-12" style="padding-left : 20px;">
                                <div class="title-wrap mt10" style="">
                                    <h4>API 정보</h4>
                                    <div class="btn-group">
                                        <div class="right">
                                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                                <jsp:param name="pos" value="TOP_R"/>
                                            </jsp:include>
                                        </div>
                                    </div>
                                </div>
                                <%-- 폼테이블 --%>
                                <div>
                                    <table class="table-border mt10" id="apiDetail">
                                        <colgroup>
                                            <col width="100px">
                                            <col width="45%">
                                            <col width="100px">
                                            <col width="">
                                            <col width="100px">
                                            <col width="">
                                        </colgroup>
                                        <tbody>
                                        <tr>
                                            <th class="text-right essential-item">API명</th>
                                            <td colspan="5">
                                                <input type="text" class="form-control essential-bg" id="api_name"
                                                       name="api_name" alt="API명" maxlength="25" required="required">
                                            </td>
                                        </tr>
                                        <tr>
                                            <th class="text-right">외부HOST</th>
                                            <td>
                                                <input type="text" class="form-control" id="api_host" name="api_host"
                                                       maxlength="50">
                                            </td>

                                            <th class="text-right essential-item">요청타임아웃</th>
                                            <td>
                                                <input type="number" style="padding-left: 3px;" class="form-control essential-bg" id="req_time_out" name="req_time_out" placeholder="분단위로 입력하세요." required="required">
                                            </td>
                                            <th class="text-right">Param문자셋</th>
                                            <td>
                                                <input type="text" class="form-control" name="param_char_set" id="param_char_set" alt="Param문자셋" maxlength="5" value="utf-8">
                                            </td>
                                        </tr>
                                        <tr>
                                            <th class="text-right essential-item">URI</th>
                                            <td>
                                                <input type="text" class="form-control essential-bg" id="api_uri"
                                                       name="api_uri" required="required" maxlength="100">
                                            </td>
                                            <th class="text-right essential-item">METHOD</th>
                                            <td>
                                                <select class="form-control essential-bg" id="api_method_cd" alt="메소드명"
                                                        name="api_method_cd" required="required">
                                                    <option value="">- 선택 -</option>
                                                    <c:forEach items="${codeMap['API_METHOD']}" var="item">
                                                        <option value="${item.code_value}">${item.code_name}</option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                            <th class="text-right essential-item">사용여부</th>
                                            <td>
                                                <div class="form-check form-check-inline">
                                                    <input class="form-check-input" type="radio" name="use_yn" value="Y"
                                                           id="yesOption" alt="사용여부">
                                                    <label class="form-check-label" for="yesOption">Y</label>
                                                </div>
                                                <div class="form-check form-check-inline">
                                                    <input class="form-check-input" type="radio" name="use_yn"
                                                           id="noOption" value="N">
                                                    <label class="form-check-label" for="noOption">N</label>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th class="text-right">비고</th>
                                            <td colspan="5">
                                                <textarea class="form-control" style="height: 50px;" id="remark"
                                                          name="remark" maxlength="135" size="135"></textarea>
                                            </td>
                                        </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <%-- /api정보 --%>
                        <%-- Param 정보 --%>
                        <div class="row">
                            <div class="col-12" style="padding-left : 20px;">
                                <div class="title-wrap mt10">
                                    <h4>Param 정보</h4>
                                    <div class="btn-group">
                                        <div class="right">
                                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                                <jsp:param name="pos" value="MID_R"/>
                                            </jsp:include>
                                        </div>
                                    </div>
                                </div>
                                <div style="margin-top: 10px; height: 250px;" id="auiGridRight"></div>
                            </div>
                        </div>
                        <%-- /Param 정보 --%>
                        <div class="btn-group mt5">
                            <div class="right">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                    <jsp:param name="pos" value="BOM_R"/>
                                </jsp:include>
                            </div>
                        </div>
                        <%-- 호출결과 --%>
                        <div class="row">
                            <div class="col-12" style="padding-left: 20px;">
                                <div class="title-wrap mt10">
                                    <h4>호출결과</h4>
                                </div>
                                <div style="margin-top: 5px;">
                                    <textarea id="callResult" name="callResult" class="form-control"
                                              style="height: 300px; background-color: white;" disabled></textarea>
                                </div>
                            </div>
                        </div>
                        <%-- /호출결과 --%>
                    </div>
                </div>

            </div>
        </div>
    </div>
    <!-- /contents 전체 영역 -->
</form>

</body>
</html>
