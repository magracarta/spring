<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 마일리지관리 > 전표관리 > null
-- 작성자 : 한승우
-- 최초 작성일 : 2023-08-11 15:06:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        $(document).ready(function() {
            // AUIGrid 생성
            createAuiGrid();
        });

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_org_code","s_mile_gubun", "s_proc_mem_name"];
            $.each(field, function() {
                if(fieldObj.name == this) {
                    goSearch();
                };
            });
        }

        //조회
        function goSearch() {
            if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                return;
            };

            var param = {
                "s_sort_key" : "reg_date",
                "s_sort_method" : "desc",
                "s_org_code" : $M.getValue("s_org_code"),
                "s_mile_gubun" : $M.getValue("s_mile_gubun"),
                "s_proc_mem_name" : $M.getValue("s_proc_mem_name"),
                "s_start_dt" : $M.getValue("s_start_dt"),
                "s_end_dt" : $M.getValue("s_end_dt"),
                <%--"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"--%>
            };
            _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if(result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);
                        $("#total_cnt").html(result.total_cnt);
                    };
                }
            );
        }

        //그리드생성
        function createAuiGrid() {
            var gridPros = {
                rowIdField : "inout_doc_no",
                // showStateColumn : false,
                showRowNumColumn: true,
                // showBranchOnGrouping : false,
                // editable : false,
                // enableMovingColumn : false,
                showRowCheckColumn : true,
                independentAllCheckBox : true,
                showFooter : true,
                footerPosition : "top",
                rowCheckVisibleFunction : function(rowIndex, isChecked, item) {
                    if (item.mile_gubun == "사용") {
                        return false;
                    }
                    return true;
                }
            };
            var columnLayout = [
                {
                  dataField: "inout_doc_no",
                  visible: false
                },
                {
                    headerText : "부서",
                    dataField : "org_name",
                    width : "70",
                    minWidth : "60",
                    style : "aui-center",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        var orgName = value;
                        if (orgName != null){
                            return orgName.replace("센터", "");
                        } else {
                            return ""
                        }
                    }
                },
                {
                    headerText : "일자",
                    dataField : "reg_dt",
                    dataType : "date",
                    formatString : "yy-mm-dd",
                    width : "80",
                    minWidth : "70",
                    style : "aui-center aui-popup"
                },
                {
                    headerText : "구분",
                    dataField : "mile_gubun",
                    width : "95",
                    minWidth : "90",
                    style : "aui-center",
                },
                {
                    headerText : "고객명",
                    dataField : "cust_name",
                    width : "95",
                    minWidth : "90",
                    style : "aui-center aui-popup",
                    filter: {
                        showIcon: true
                    }
                },
                {
                    dataField : "cust_no",
                    visible: false
                },
                {
                    headerText : "업체명",
                    dataField : "breg_name",
                    width : "95",
                    minWidth : "90",
                    style : "aui-center",
                },
                {
                    headerText : "사업자번호",
                    dataField : "breg_no",
                    width : "120",
                    minWidth : "90",
                    style : "aui-center",
                },
                {
                    headerText : "적립",
                    dataField : "accumulated",
                    width : "95",
                    minWidth : "90",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-center",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText : "사용",
                    dataField : "used",
                    width : "95",
                    minWidth : "90",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-center",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText : "소멸",
                    dataField : "expired",
                    width : "95",
                    minWidth : "90",
                    dataType : "numeric",
                    formatString : "#,##0",
                    style : "aui-center",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        value = AUIGrid.formatNumber(value, "#,##0");
                        return value == 0 ? "" : value;
                    },
                },
                {
                    headerText : "회계전송일",
                    dataField : "duzon_trans_dt",
                    width : "95",
                    minWidth : "90",
                    style : "aui-center",
                },
                {
                    headerText : "처리자",
                    dataField : "proc_mem_name",
                    width : "95",
                    minWidth : "90",
                    style : "aui-center",
                },
                {
                    headerText : "처리일자",
                    dataField : "proc_dt",
                    width : "95",
                    minWidth : "90",
                    style : "aui-center",
                },
                {
                    dataField: "duzon_trans_yn",
                    visible: false
                },
                {
                    dataField: "account_link_cd",
                    visible: false
                },
            ];

            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText : "합계",
                    positionField : "org_name",
                    style : "aui-center aui-footer",
                },
                {
                    dataField : "accumulated",
                    positionField : "accumulated",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-right aui-footer",
                },
                {
                    dataField : "used",
                    positionField : "used",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-right aui-footer",
                },
                {
                    dataField : "expired",
                    positionField : "expired",
                    operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-right aui-footer",
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, []);
            AUIGrid.bind(auiGrid, "cellClick", function(event) {
                if(event.dataField == "reg_dt") {
                    // 적립, 소멸은 마일리지전표상세 팝업 Open
                    // 사용은 매출처리상세 팝업 Open
                    var inoutDocNo = event.item["inout_doc_no"];
                    var param = {
                        inout_doc_no : inoutDocNo
                    }
                    if (event.item["mile_gubun"] == "사용"){
                        var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
                        $M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});
                    } else {
                        $M.goNextPage("/cust/cust0306p02", $M.toGetParam(param), {popupStatus : ""});
                    }
                } else if (event.dataField == "cust_name") {
                    // 거래원장상세 팝업 띄우기로 변경(230831 한승우)
                    // 거래원장상세 팝업
                    params = {
                        "s_cust_no": event.item.cust_no,
// 							"s_ledger_yn" : "Y",
                        "s_start_dt": $M.getValue("s_start_dt"),
                        "s_end_dt": $M.getValue("s_end_dt")
                    };
                    openDealLedgerPanel($M.toGetParam(params));
                    // 고객정보상세 팝업
                    // var custNo = event.item["cust_no"];
                    // var param = {
                    //     cust_no : custNo
                    // }
                    // $M.goNextPage("/cust/cust0102p01", $M.toGetParam(param), {popupStatus : ""});
                }
            });
            // 전체 체크박스 클릭 이벤트 바인딩
            AUIGrid.bind(auiGrid, "rowAllChkClick", function (event) {
                if (event.checked) {
                    // mile_gubun 의 값들 얻기
                    var uniqueValues = AUIGrid.getColumnDistinctValues(auiGrid, "mile_gubun");
                    // "사용" 제거하기
                    if (uniqueValues.indexOf("사용") != -1){
                        uniqueValues.splice(uniqueValues.indexOf("사용"), 1);
                    }
                    AUIGrid.setCheckedRowsByValue(auiGrid, "mile_gubun", uniqueValues);
                } else {
                    AUIGrid.setCheckedRowsByValue(auiGrid, "mile_gubun", []);
                }
            });
            $("#auiGrid").resize();
        }

        function fnDownloadExcel() {
            // 엑셀 내보내기 속성
            var exportProps = {
            };
            fnExportExcel(auiGrid, "마일리지전표관리", exportProps);
        }

        function goNewMile() {
            // 마일리지 적립전표 등록 페이지로 이동하기 ( 팝업 )
            var popupOption = "";
            $M.goNextPage('/cust/cust0306p01', "", {popupStatus : popupOption});
        }

        // 회계전송
        function goAccTrans() {
            // account_link_cd가 있어야 회계전송 가능
            // row행의 회계거래처코드가 없습니다.
            var row = "";
            var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
            var gridData = AUIGrid.getGridData(auiGrid);

            if (items.length == 0) {
                alert("체크된 데이터가 없습니다.");
                return false
            }

            for (var i = 0; i < items.length; i++) {
                // if(items[i].end_yn != "Y") {
                //     alert("마감처리된 건만 회계처리가 가능합니다.");
                //     return false;
                // }

                if(items[i].duzon_trans_yn == "Y") {
                    alert("회계처리된 데이터가 있습니다.");
                    return false;
                }

                if(items[i].account_link_cd == "") {
                    for(var j = 0; j < gridData.length; j++) {
                        if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
                            row = j + 1;
                        }
                    }
                    alert(row + "행의 회계거래처코드가 없습니다.");
                    return false;
                }
            }

            var param = {
                inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
            }

            var msg = "회계전송하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, "/cust/cust030602/accTrans", $M.toGetParam(param), {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearch();
                    };
                }
            );
        }

        function goCancelAccTrans() {
            var row = "";
            var items = AUIGrid.getCheckedRowItemsAll(auiGrid);

            if (items.length == 0) {
                alert("체크된 데이터가 없습니다.");
                return false
            }

            for (var i = 0; i < items.length; i++) {
                if(items[i].duzon_trans_yn != "Y") {
                    alert("회계처리된 건만 취소가 가능합니다.");
                    return false;
                }
            }

            var param = {
                inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
            }

            var msg = "회계전송을 취소하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, "/cust/cust030602/cancelAccTrans", $M.toGetParam(param), {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearch();
                    };
                }
            );
        }
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <div class="contents">
                    <input type="hidden" id="cust_no" name="cust_no" >
                    <!-- 검색영역 -->
                    <div class="search-wrap mt10">
                        <table class="table">
                            <colgroup>
                                <col width="45px">
                                <col width="270px">
                                <col width="60px">
                                <col width="120px">
                                <col width="40px">
                                <col width="120px">
                                <col width="50px">
                                <col width="120px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>기간</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" value="${searchDtMap.s_start_dt}" dateformat="yyyy-MM-dd" alt="조회 시작일" >
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일" value="${searchDtMap.s_end_dt}" >
                                            </div>
                                        </div>
                                        <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                            <jsp:param name="st_field_name" value="s_start_dt"/>
                                            <jsp:param name="ed_field_name" value="s_end_dt"/>
                                            <jsp:param name="click_exec_yn" value="Y"/>
                                            <jsp:param name="exec_func_name" value="goSearch();"/>
                                        </jsp:include>
                                    </div>
                                </td>
                                <th>소속부서</th>
                                <td>
                                    <!-- 센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
                                    <%--										<c:if test="${SecureUser.org_type ne 'BASE'}">--%>
                                    <c:if test="${page.fnc.F05086_001 ne 'Y'}">
                                        <input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly" style="width:120px;">
                                        <input type="hidden" value="${SecureUser.org_code}" id="s_org_code" name="s_org_code" readonly="readonly">
                                    </c:if>
                                    <!-- 본사의 경우, 전체 센터목록 선택가능 -->
                                    <%--										<c:if test="${SecureUser.org_type eq 'BASE'}">--%>
                                    <c:if test="${page.fnc.F05086_001 eq 'Y'}">
                                        <input class="form-control" style="width: 99%;" type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
                                               easyuiname="orgList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
                                    </c:if>
                                </td>
                                <th>구분</th>
                                <td>
                                    <input class="form-control" style="width: 99%;" type="text" id="s_mile_gubun" name="s_mile_gubun" easyui="combogrid"
                                           easyuiname="gubunList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
                                </td>
                                <th>처리자</th>
                                <td>
                                    <input type="text" class="form-control" id="s_proc_mem_name" name="s_proc_mem_name">
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javasctipt:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
                    <!-- 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="right">
<%--                            <c:if test="${page.add.POS_UNMASKING eq 'Y'}">--%>
<%--                                <div class="form-check form-check-inline">--%>
<%--                                    <input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >--%>
<%--                                    <label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>--%>
<%--                                </div>--%>
<%--                            </c:if>--%>
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                        </div>
                    </div>
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
                    <!-- /조회결과 -->
                    <div class="btn-group mt5">
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
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>
