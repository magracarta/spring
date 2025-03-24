<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 장비입금관리 > null > 은행거래내역조회
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var fundsShowYn = "${inputParam.funds_show_yn}";
        var machineDocNo = "${inputParam.machine_doc_no}";
        var auiGrid;

        var virtualList; // 가상계좌 리스트
        var list; // 검색 조건 리스트

        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            fnInit();
            goSearch();
            checkBoxVirtualShow();
        });

        // 가상계좌 표시 체크박스 이벤트
        function checkBoxVirtualShow() {
            $("#s_show_virtual").change(function () { // 체크 박스 변경 이벤트 연결
                if ($("#s_show_virtual").is(":checked")) {
                    if (virtualList == undefined) { // 가상계좌 리스트가 없다면 다시 검색하는 알람
                        alert("가상계좌 데이터가 검색되지 않습니다.\n날짜, 검색 조건을 확인해주세요.");
                        $("#s_show_virtual").attr("checked", false); // 체크 해제 상태로 초기화
                        return;
                    }
                    AUIGrid.setGridData(auiGrid, virtualList); // 연결된 가상계좌만 표시
                } else {
                    AUIGrid.setGridData(auiGrid, list); // 검색 조건 계좌 표시
                }
            });
        }

        function fnDownloadExcel() {
            // 엑셀 내보내기 속성
            var exportProps = {};
            fnExportExcel(auiGrid, "계좌입출금내역", exportProps);
        }

        // 검색 시작일자 세팅 현재날짜의 7일전, 입금 셋팅
        // 전도금일때 시작일 = 전표일, 이전 처리불가
        function fnInit() {
            var now = "${inputParam.s_current_dt}";
            if ("${inputParam.s_dt}" == "") {
                $M.setValue("s_start_dt", $M.addDates($M.toDate(now), -7));
            } else {
                $M.setValue("s_start_dt", "${inputParam.s_dt}");
                $M.setValue("s_end_dt", "${inputParam.s_dt}");
            }
            if ("${inputParam.deposit_dt}" != "") {
                $M.setValue("s_start_dt", "${inputParam.deposit_dt}");
                $M.setValue("s_end_dt", "${inputParam.deposit_dt}");
            }
            $M.setValue("s_inout_type_io", "${inputParam.inout_type_io}");
            $("#s_inout_type_io").prop("disabled", true);

            // 자금일보에서 넘어왔을경우 Y
            if (fundsShowYn == "Y") {
                $M.setValue("s_account_no", "${inputParam.s_account_no}");
            }

            // 전도금에서 넘어왔을경우 Y
            if ("${inputParam.imprest_yn}" == "Y") {
                $M.setValue("s_account_no", "${inputParam.s_imprest_account_no}");
                $M.setValue("s_deal_type_rv", "R");
                $("#s_account_no").prop("disabled", true);
                $("#s_deal_type_rv").prop("disabled", true);
            }
        }

        function goSearch() {
            if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                return false;
            }
            ;
            var param = {
                "s_inout_type_io": $M.getValue("s_inout_type_io"),
                "s_account_no": $M.getValue("s_account_no"),
                "s_deal_type_rv": $M.getValue("s_deal_type_rv"),
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_sort_key": "deal_dt",
                "s_sort_method": "asc",
                "s_show_virtual": $M.getValue("s_show_virtual"),
                "machine_doc_no": machineDocNo
            };
            $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if (result.success) {
                        virtualList = result.virtual_list; // 가상 계좌 리스트 변경
                        list = result.list; // 검색 조건 리스트 변경
                        AUIGrid.setGridData(auiGrid, list);
                        $("#total_cnt").html(result.total_cnt);
                    };
                }
            );
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "rowIdField",
                showStateColumn: false,
                // No. 제거
                showRowNumColumn: true,
                showBranchOnGrouping: false,
                showFooter: true,
                footerPosition: "top",
                editable: false
            };
            var columnLayout = [
                {
                    dataField: "ibk_iss_acct_his_seq",
                    visible: false
                },
                {
                    dataField: "ibk_rcv_vacct_reco_seq",
                    visible: false
                },
                {
                    dataField: "acct_txday_seq",
                    visible: false
                },
                {
                    dataField: "ibk_bank_cd",
                    visible: false
                },
                {
                    dataField: "inout_type_io",
                    visible: false
                },
                {
                    dataField: "acct_no",
                    visible: false
                },
                {
                    dataField: "site_no",
                    visible: false
                },
                {
                    headerText: "은행명",
                    dataField: "ibk_bank_name",
                    width: "6%",
                    style: "aui-center"
                },
                {
                    headerText: "계좌구분",
                    dataField: "deal_type_rv",
                    width: "6%",
                    style: "aui-center",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return item["deal_type_rv"] == "R" ? "통장" : "가상계좌";
                    }
                },
                {
                    headerText: "계좌번호",
                    dataField: "account_no",
                    width: "12%",
                    style: "aui-center",
                },
                {
                    headerText: "처리일자",
                    dataField: "deal_dt",
                    width: "8%",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    style: "aui-center",
                },
                {
                    headerText: "입금",
                    dataField: "in_tx_amt",
                    width: "9%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right"
                },
                {
                    headerText: "출금",
                    dataField: "out_tx_amt",
                    width: "9%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right"
                },
                {
                    headerText: "잔액",
                    dataField: "balance_amt",
                    width: "9%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right"
                },
                {
                    headerText: "입출금정보",
                    dataField: "deposit_name",
                    width: "10%",
                    style: "aui-left"
                },
                {
                    headerText: "메모",
                    dataField: "erp_memo",
                    style: "aui-left"
                },
                {
                    headerText: "처리액",
                    dataField: "erp_amt",
                    width: "9%",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right"
                },
                {
                    headerText: "처리내역",
                    dataField: "remark",
                    width: "10%",
                    style: "aui-center"
                },
            ];

            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "ibk_bank_name",
                    style: "aui-center aui-footer",
                    colSpan: 4
                },
                {
                    dataField: "in_tx_amt",
                    positionField: "in_tx_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "out_tx_amt",
                    positionField: "out_tx_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "balance_amt",
                    positionField: "balance_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                },
                {
                    dataField: "erp_amt",
                    positionField: "erp_amt",
                    operation: "SUM",
                    formatString: "#,##0",
                    style: "aui-right aui-footer",
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            // 푸터 객체 세팅
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();
            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                // 실입금액 <= 입금액 callback 가능
                if (fundsShowYn != "Y") {  // 자금일보에서 넘어왔을경우 Y
                    if ("${inputParam.imprest_yn}" == "Y") { // 전도금에서 넘어왔을 경우 Y
                        if ("${inputParam.s_dt}" != event.item.deal_dt) {
                            alert("전표일자와 처리일자가 다릅니다.");
                            return false;
                        } else {
                            opener.${inputParam.parent_js_name}(event.item);
                            fnClose();
                        }
                    } else {
                        if ("${inputParam.amt}" <= event.item["in_tx_amt"] || "${inputParam.amt}" <= event.item["out_tx_amt"]) {
                            opener.${inputParam.parent_js_name}(event.item);
                            fnClose();
                        } else {
                            alert("입금금액을 확인해 주세요.");
                            return false;
                        }
                    }
                }
            });
        }

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
            <!-- 검색영역 -->
            <div class="search-wrap mt5">
                <table class="table table-fixed">
                    <colgroup>
                        <col width="65px">
                        <col width="250px">
                        <col width="65px">
                        <col width="100px">
                        <col width="65px">
                        <col width="180px">
                        <col width="65px">
                        <col width="100px">
                        <c:if test="${not empty inputParam.machine_doc_no }">
                            <col width="70px">
                        </c:if>
                    </colgroup>
                    <tbody>
                    <tr>
                        <th>처리일자</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width110px">
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0 calDate" id="s_start_dt"
                                               name="s_start_dt" dateformat="yyyy-MM-dd" alt=""
                                               value="${inputParam.s_current_dt}">
                                    </div>
                                </div>
                                <div class="col width16px text-center">~</div>
                                <div class="col-5">
                                    <div class="input-group width140px">
                                        <input type="text" class="form-control border-right-0 calDate" id="s_end_dt"
                                               name="s_end_dt" dateformat="yyyy-MM-dd" alt=""
                                               value="${inputParam.s_end_dt}">
                                    </div>
                                </div>
                            </div>
                        </td>
                        <c:if test="${inputParam.funds_show_yn ne 'Y'}">
                            <th>계좌구분</th>
                            <td>
                                <select class="form-control" id="s_deal_type_rv" name="s_deal_type_rv">
                                    <option value="">- 전체 -</option>
                                    <option value="R">통장</option>
                                    <option value="V">가상계좌</option>
                                </select>
                            </td>
                            <th>계좌번호</th>
                            <td>
                                <select class="form-control" id="s_account_no" name="s_account_no">
                                    <option value="">- 전체 -</option>
                                    <c:forEach items="${bankList}" var="item">
                                        <option value="${item.acct_no}">${item.bank_name}</option>
                                    </c:forEach>
                                </select>
                            </td>
                            <th>입출구분</th>
                            <td>
                                <select class="form-control" id="s_inout_type_io" name="s_inout_type_io">
                                    <option value="">- 전체 -</option>
                                    <option value="I">입금</option>
                                    <option value="O">출금</option>
                                </select>
                            </td>
                        </c:if>
                        <td>
                            <button type="button" class="btn btn-important" style="width: 50px;"
                                    onclick="javasctipt:goSearch();">조회
                            </button>
                        </td>
                        <c:if test="${not empty inputParam.machine_doc_no }">
                            <td class="form-check form-check-inline checkline">
                                <input class="form-check-input" id="s_show_virtual" name="s_show_virtual" value="Y"
                                       type="checkbox" value="true">
                                <label class="form-check-label" for="s_show_virtual">품의서 연결된 가상계좌 표시</label>
                            </td>
                        </c:if>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /검색영역 -->
            <!-- 폼테이블 -->
            <div>
                <div id="auiGrid" style="margin-top: 5px; height: 270px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong class="text-primary" id="total_cnt">0</strong>건
                </div>
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>