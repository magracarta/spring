<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 그룹코드 관리 > 팝업
-- 작성자 : 류성진
-- 최초 작성일 : 2022-08-24 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var numberFormat = "thousand";
        var group_code = "";
        var all_yn = "";
        var show_extra_cols = "";
        var codes = {};
        var regExp =  /^[A-Za-z0-9_+]*$/;// 코드 값 필터링 정규식

        $(document).ready(function () {
            createAUIGrid(); // 로딩후 컬럼 계산
            goSearch();
        });

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "전년대비누적손익");
        }

        // 날짜 Setting
        function fnSetYearMon(year, mon) {
            return year + (mon.length == 1 ? "0" + mon : mon);
        }

        // 경력사항 행 추가
        function fnAdd() {
            // 그리드 필수값 체크
            if(fnCheckGridEmpty(auiGrid)){
                var item = new Object();
                var money_type_cd = $M.getValue("s_doc_money_type_cd");
                var money_man_type_cd = $M.getValue("s_doc_money_man_type_cd");
                item.doc_money_type_cd = money_type_cd ; // s_doc_money_type_cd
                item.doc_money_man_type_cd = money_man_type_cd; // s_doc_money_man_type_cd

                item.doc_money_type_name = $("#s_doc_money_type_cd option[value=" + money_type_cd +"]").html() ; // s_doc_money_type_cd
                item.doc_money_man_type_name = $("#s_doc_money_man_type_cd option[value=" + money_man_type_cd +"]").html(); // s_doc_money_man_type_cd

                item.min_work_cnt = "";
                item.temp_yn = "N";
                item.money_amt = "0";
                item.flower_yn = "N";
                item.use_yn = "Y";
                item.flower_amt = "0";
                item.cmd = "C";

                console.log(money_type_cd + money_man_type_cd)
                item.seq_no = (codes[money_type_cd + money_man_type_cd] || []).length + 1;

                AUIGrid.addRow(auiGrid, item, "last");
            }else {
                console.log("??")
            }
        }

1
        // 그리드 벨리데이션
        function fnCheckGridEmpty() {
            return AUIGrid.validateGridData(auiGrid, [
                "doc_money_type_cd",
                "doc_money_man_type_cd",
                "min_work_cnt",
                "temp_yn",
                "money_amt",
                "flower_yn",
                "flower_amt",
            ], "필수 항목은 반드시 값을 입력해야합니다.");
        }

        // 조회
        function goSearch() {
            var param  = { };

            $M.goNextPageAjax("/mmyy/mmyy01110401p01/search", $M.toGetParam(param), {method: "get"},
                function (result) {
                    if (result.success) {
                        for ( var i = 0; i < result.list.length; i++) {
                            var item = result.list[i];
                            var key = item.doc_money_type_cd + item.doc_money_man_type_cd;
                            if ( !codes[key] ) codes[key]= [];
                            codes[key].push(item.min_work_cnt);
                            item.temp = item.temp_yn == 'Y';

                            item.cmd = "U";
                        }
                        console.log(result.list);

                        AUIGrid.setGridData(auiGrid, result.list);
                    }
                }
            );
        }


        // 저장
        function goSave() {
            if (fnChangeGridDataCnt(auiGrid) == 0) {
                alert("변경된 데이터가 없습니다.");
                return false;
            }

            if( !fnCheckGridEmpty(auiGrid) ){
                return;
            }

            var columns = [ "seq_no", "doc_money_type_cd", "doc_money_man_type_cd", "min_work_cnt", "temp_yn", "money_amt", "flower_yn", "flower_amt", "cmd", "use_yn"];

            var gridFrm = fnChangeGridDataToForm(auiGrid, true, columns);


            $M.goNextPageAjaxSave("/mmyy/mmyy01110401p01/save", gridFrm, {method: "POST"},
                function (result) {
                    if (result.success) {
                        goSearch();
                    }
                }
            );
        }

        // 창 닫기
        function fnClose() {
            window.close();
        }

        // 그리드 재생성
        function fnAUIGridInit() {
            destroyGrid();
            createAUIGrid();
        }

        // 그리드 초기화
        function destroyGrid() {
            AUIGrid.destroy("#auiGrid");
            auiGrid = null;
        }

        // 천 단위
        function fnSetNumberFormatToggle() {
            if (numberFormat == "all") {
                numberFormat = "thousand";
            } else {
                numberFormat = "all"
            }

            AUIGrid.resize(auiGrid);
        }

        function createAUIGrid() {
            var gridPros = {
                // Row번호 표시 여부
                rowIdField: "_$uid",
                showStateColumn : true,
                footerPosition : "top",
                // showFooter: true,
                // enableFilter : false,
                // fillValueGroupingSummary: true,
                // showBranchOnGrouping: false,
                // groupingFields : ["doc_money_type_cd", "doc_money_man_type_cd"],

                // 그룹핑 썸머리행에 값을 채움
                // fillValueGroupingSummary : true,
                // 동일 선상은 groupingFields 의 마지막 필드인 name 에 일치시킵니다.
                // adjustSummaryPosition : true,
                // No. 제거
                showRowNumColumn: true,
                enableFilter :true,
                enableCellMerge: true, // 셀병합 사용여부

                editable : true,
            };
            var layoutHide = [ ]
            var columnLayout = [
                {
                    headerText: "시퀸스번호",
                    dataField: "seq_no",
                    visible : false,
                },
                {
                    headerText: "경조구분",
                    dataField: "doc_money_type_cd",
                    visible : false,
                },
                {
                    headerText: "경조구분",
                    dataField: "doc_money_man_type_cd",
                    visible : false,
                },
                {
                    headerText: "경조구분",
                    dataField: "doc_money_type_name",
                    width: "160",
                    minWidth: "150",
                    style: "aui-center",
                    cellMerge: true, // 셀 세로병합
                    editable: false,
                    filter : {
                        showIcon : true
                    },
                },
                {
                    headerText: "경조구분(지급대상)",
                    // dataField: "doc_money_type_name",
                    dataField: "doc_money_man_type_name",
                    width: "160",
                    minWidth: "150",
                    cellMerge: true, // 셀 세로병합
                    style: "aui-center",
                    editable: false,
                    filter : {
                        showIcon : true
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return item.doc_money_man_type_name + " (" + item.doc_money_type_name + ")";
                    },
                },
                {
                    headerText: "수습여부",
                    dataField: "temp_yn",
                    width: "70",
                    minWidth: "55",
                    style: "aui-center",
                    editable: true,
                    filter : {
                        showIcon : true
                    },
                    renderer: {
                        type : "CheckBoxEditRenderer",
                        checked : true,
                        checkValue : "Y",
                        unCheckValue : "N",
                        editable : true
                    },
                },
                {
                    headerText: "최소근무기간(개월)",
                    dataField: "min_work_cnt",
                    width: "160",
                    minWidth: "150",
                    style: "aui-editable",
                    editable: true
                },
                {
                    headerText: "지급금액(원)",
                    dataField: "money_amt",
                    width: "160",
                    minWidth: "150",
                    style: "aui-editable",
                    editable: true,
                    dataType : "numeric",
                    formatString : "#,##0",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "화환대상여부",
                    dataField: "flower_yn",
                    width: "160",
                    minWidth: "150",
                    style: "aui-center",
                    editable: true,
                    renderer: {
                        type : "CheckBoxEditRenderer",
                        checked : true,
                        checkValue : "Y",
                        unCheckValue : "N",
                        editable : true
                    },
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText: "화환금액(원)",
                    dataField: "flower_amt",
                    width: "160",
                    minWidth: "150",
                    style: "aui-editable",
                    editable: true,
                    dataType : "numeric",
                    formatString : "#,##0",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText: "사용여부",
                    dataField: "use_yn",
                    width: "160",
                    minWidth: "150",
                    style: "aui-center",
                    editable: true,
                    renderer: {
                        type : "CheckBoxEditRenderer",
                        checked : true,
                        checkValue : "Y",
                        unCheckValue : "N",
                        editable : true
                    },
                    filter : {
                        showIcon : true
                    }
                },
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.hideColumnByDataField(auiGrid, layoutHide);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();
        }

        function goMoneyTypeEdit() {
            var param = {
                group_code: "DOC_MONEY_TYPE",
                all_yn: "Y",
                show_extra_cols : "v2"
            }
            openGroupCodeDetailPanel($M.toGetParam(param));
        }

        function goMoneyManTypeEdit(){
            var param = {
                group_code : "DOC_MONEY_MAN_TYPE",
                all_yn : "Y"
            }
            openGroupCodeDetailPanel($M.toGetParam(param));
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
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <div class="contents">
                    <!-- 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4 id="title">경조금액 - 조회결과
                            <span style="color:#7f7f7f"># 장기근속의 경우 최대 6개월까지 신청 기한 입니다.</span>
<%--                            <span style="color:#7f7f7f"># 항목추가/삭제는 내부 로직과 연계되므로, SR요청으로 처리가능합니다.</span>--%>
                        </h4>
                        <div class="btn-group">
                            <div class="right">
                                <table style="width: 570px;float: right;">
                                    <colgroup>
                                        <col width="70px">
                                        <col width="70px">
                                        <col width="50px">
                                        <col width="70px">
                                        <col width="50px">
                                        <col width="70px">
                                        <col width="70px">
                                        <%-- 버튼 행 추가 버튼 --%>
                                    </colgroup>
                                    <tbody>
                                       <tr>
                                           <td><button type="button" id="_goCodeEdit" class="btn btn-info" onclick="javascript:goMoneyTypeEdit();">경조구분수정</button></td>
                                           <td><button type="button" id="_goCodeEdit" class="btn btn-info" onclick="javascript:goMoneyManTypeEdit();">지급대상수정</button></td>
                                           <td>경조구분 : </td>
                                            <td>
                                                <select class="form-control" id="s_doc_money_type_cd" name="s_doc_money_type_cd" >
                                                    <c:forEach items="${codeMap['DOC_MONEY_TYPE']}" var="item">
                                                        <option value="${item.code_value}">${item.code_name}</option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                           <td>지급대상 : </td>
                                            <td>
                                                <select class="form-control" id="s_doc_money_man_type_cd" name="s_doc_money_man_type_cd">
                                                    <c:forEach items="${codeMap['DOC_MONEY_MAN_TYPE']}" var="item">
                                                        <option value="${item.code_value}" >${item.code_name}</option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                           <td>
                                               <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                                           </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <!-- /조회결과 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <div class="btn-group mt5">
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                </div>
            </div>
            <!-- 하단 버튼 -->
        </div>
        <!-- /contents 전체 영역 -->
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>