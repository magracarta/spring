<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > 센터고과평가 > 평가비율설정
-- 작성자 : jsk
-- 최초 작성일 : 2024-06-12 14:09:10
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGrid;
        var memberIdx;
        var evalMemList = ${eval_mem_list};
        var evalMemListStr = JSON.stringify(${eval_mem_list});
        var delMemNoArr = [];

        $(document).ready(function () {
            createAUIGrid();
        });

        // 그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showStateColumn: true,
                editable: true
            };

            var columnLayout = [
                {
                    dataField : "org_code",
                    visible : false
                },
                {
                    headerText : "평가대상부서",
                    dataField : "org_name",
                    width : "10%",
                    minWidth : "70",
                    style : "aui-center",
                    editable: false
                }
            ];
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            for (var i=0; i<evalMemList.length; i++) {
                fnAddColumnObj(evalMemList[i]);
            }

            AUIGrid.setGridData(auiGrid, ${list});
            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
                // 적용 체크시에만 평점비율 입력 가능
                if (event.dataField.endsWith("_point_rate")) {
                    var memNo = event.dataField.split("_")[0];
                    if (event.item[memNo +"_apply_yn"] != "Y") {
                        return false;
                    }
                }
            });
            AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
                // 적용 체크 변경시 평점비율 초기화
                if (event.dataField.endsWith("_apply_yn")) {
                    var memNo = event.dataField.split("_")[0];
                    if (AUIGrid.getColumnItemByDataField(auiGrid, memNo).headerText != "") {
                        var param = {};
                        param[memNo + "_point_rate"] = 0;
                        AUIGrid.updateRow(auiGrid, param, event.rowIndex);
                    }
                }
            });
        }

        // 평가직원 추가
        function goAddMemberPopup() {
            if (evalMemList.length >= 7) {
                alert("직원은 최대 7명까지 추가할 수 있습니다.");
                return false;
            }
            // 직원조회 팝업
            openSearchMemberPanel('fnSetMemInfo');
        }

        // 직원정보 세팅
        function fnSetMemInfo(data) {
            if (fnCheckExistsMem(data.mem_no) == true) {
                setTimeout(function() {
                    alert("이미 추가된 직원입니다.");
                }, 1);
            } else {
                var addMemObj = {
                    "sort_no": evalMemList.length,
                    "eval_year": $M.getValue("s_year"),
                    "mem_no": data.mem_no,
                    "mem_name": data.mem_name
                }
                fnAddColumnObj(addMemObj);
                evalMemList.push(addMemObj);
            }
        }

        function fnAddColumnObj(memObj) {
            var memNo = memObj.mem_no.toLowerCase();

            var columnObj = {
                headerText : memObj.mem_name,
                dataField: memNo,
                headerRenderer : { // 헤더 렌더러
                    type : "ButtonHeaderRenderer",
                    position : "right",
                    text : "✕",
                    onClick : function(event) {
                        // 해당컬럼 삭제
                        AUIGrid.removeColumn(auiGrid, event.columnIndex+1);
                        AUIGrid.removeColumn(auiGrid, event.columnIndex);
                        for (var i=0; i<evalMemList.length; i++) {
                            if (evalMemList[i].mem_no == memObj.mem_no) {
                                evalMemList.splice(i, 1);
                                break;
                            }
                        }
                        delMemNoArr.push(memObj.mem_no);
                    },
                },
                children: [
                    {
                        headerText : "적용",
                        dataField : memNo +"_apply_yn",
                        width : "3%",
                        style : "aui-center aui-editable",
                        renderer : {
                            type: "CheckBoxEditRenderer",
                            editable: true, // 체크박스 편집 활성화 여부(기본값 : false)
                            checkValue: "Y",
                            unCheckValue: "N"
                        }
                    },
                    {
                        headerText : "평점비율",
                        dataField : memNo +"_point_rate",
                        width : "10%",
                        style : "aui-center",
                        editable: true,
                        dataType: "numeric",
                        formatString: "#,##0",
                        editRenderer : {
                            type : "InputEditRenderer",
                            max : 100,
                            onlyNumeric : true,
                            validator : AUIGrid.commonValidator
                        },
                        labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                            return value == "" ? 0 : AUIGrid.formatNumber(value, "#,##0");
                        },
                        styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                            // 적용 체크시에만 평점비율 입력 가능
                            if (dataField.endsWith("_point_rate")) {
                                var memNo = dataField.split("_")[0];
                                if (item[memNo +"_apply_yn"] == "Y") {
                                    return "aui-editable";
                                }
                            }
                        }
                    }
                ]
            };
            AUIGrid.addColumn(auiGrid, columnObj, 'last');
        }

        // 평가직원 추가 유효성체크
        function fnCheckExistsMem(memNo) {
            var existsYn = false;
            for (var i=0; i<evalMemList.length; i++) {
                if (evalMemList[i].mem_no == memNo) {
                    existsYn = true;
                    break;
                }
            }
            return existsYn;
        }

        //조회
        function goSearch() {
            var param = {
                "s_year": $M.getValue("s_year")
            }
            $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if(result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);
                    }
                }
            );
        }

        // 저장
        function goSave() {
            if (JSON.stringify(evalMemList) == evalMemListStr && fnChangeGridDataCnt(auiGrid) == 0){
                alert("변경된 데이터가 없습니다.");
                return false;
            }

            // 적용비율 합 100 체크
            var gridData = AUIGrid.getGridData(auiGrid);
            for (var i=0; i<gridData.length; i++) {
                var rateArr = [];
                var sumRate = 0;
                for (var j=0; j<evalMemList.length; j++) {
                    var memNo = evalMemList[j].mem_no.toLowerCase();
                    var applyYn = AUIGrid.getCellValue(auiGrid, i, memNo+"_apply_yn");
                    if (applyYn == 'Y') {
                        var rate = Number(AUIGrid.getCellValue(auiGrid, i, memNo+"_point_rate"));
                        rateArr.push(rate);
                        sumRate += rate;
                    }
                }
                if (rateArr.length > 0 && sumRate != 100) {
                    var orgName = AUIGrid.getCellValue(auiGrid, i, "org_name");
                    alert("'" + orgName + "' 부서의 적용비율을 확인하시기 바랍니다.");
                    return false;
                }
            }

            // 평가비율 데이터 세팅
            var orgCodeArr = [];
            var memNoArr = [];
            var pointRateArr = [];
            var applyYnArr = [];
            var sortNoArr = [];
            for (var i=0; i<evalMemList.length; i++) {
                var memNo = evalMemList[i].mem_no;
                var sortNo = evalMemList[i].sort_no;

                for (var j=0; j<gridData.length; j++) {
                    orgCodeArr.push(gridData[j]["org_code"]);
                    memNoArr.push(memNo);
                    pointRateArr.push($M.nvl(gridData[j][memNo.toLowerCase()+"_point_rate"], 0));
                    applyYnArr.push($M.nvl(gridData[j][memNo.toLowerCase()+"_apply_yn"], "N"));
                    sortNoArr.push(sortNo);
                }
            }

            var frm = document.main_form;
            var option = {
                isEmpty : true
            };
            $M.setHiddenValue(frm, "del_mem_no_str", $M.getArrStr(delMemNoArr, option));
            $M.setHiddenValue(frm, "org_code_str", $M.getArrStr(orgCodeArr, option));
            $M.setHiddenValue(frm, "mem_no_str", $M.getArrStr(memNoArr, option));
            $M.setHiddenValue(frm, "point_rate_str", $M.getArrStr(pointRateArr, option));
            $M.setHiddenValue(frm, "apply_yn_str", $M.getArrStr(applyYnArr, option));
            $M.setHiddenValue(frm, "sort_no_str", $M.getArrStr(sortNoArr, option));

            $M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm), {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearch();
                    }
                }
            );
        }

        // 닫기 버튼
        function fnClose() {
            window.close();
        }
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" id="s_year" name="s_year" value="${inputParam.s_year}"/>
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="contents">
                <div class="title-wrap mt10">
                    <h4>평가비율설정</h4>
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                </div>
                <!-- 그리드 -->
                <div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
                <!-- 하단 영역 -->
                <div class="btn-group mt10">
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