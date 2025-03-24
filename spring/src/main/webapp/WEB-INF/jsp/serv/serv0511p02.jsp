<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 정비현황분석 > 총 정비건수
-- 작성자 : 정재호
-- 최초 작성일 : 2021-09-24 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        $(document).ready(function () {
            // AUIGrid 생성
            createAUIGrid();
            goSearch();

            // 마스킹 적용 체크 이벤트
            $("#s_masking_yn").change(function(){
                if($("#s_masking_yn").is(":checked")){
                    goSearch();
                }else{
                    goSearch();
                }
            });

        });

        //엑셀다운로드
        // function fnExcelDownload() {
        //     fnExportExcel(auiGrid, "서비스업무평가");
        // }

        function goSearch() {
            var params = {
                "s_center_org_code": ${inputParam.s_center_org_code},
                "s_start_dt": ${inputParam.s_start_dt},
                "s_end_dt": ${inputParam.s_end_dt},
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "s_except_yk_yn" : "${inputParam.s_except_yk_yn}",
                "s_except_used_yn" : "${inputParam.s_except_used_yn}",
                "s_except_rental_yn" : "${inputParam.s_except_rental_yn}",
                "s_except_agency_yn" : "${inputParam.s_except_agency_yn}"
            }

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);

                        $("#title").text("정비건수 목록 - " + result.center_name);
                        $("#total_cnt").text(result.total_cnt);
                    }
                }
            );
        }

        // 닫기
        function fnClose() {
            window.close();
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                enableCellMerge : true,
                headerHeight : 40
            };

            var columnLayout = [
                // {
                //     headerText: "상태",
                //     dataField: "appr_proc_status",
                //     style: "aui-center",
                // },
                {
                    headerText: "처리일자",
                    dataField: "as_dt",
                    style: "aui-center",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                },
                {
                    headerText: "지역",
                    dataField: "area_si",
                    style: "aui-center",
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    style: "aui-center aui-popup",
                },
                {
                    headerText: "휴대폰",
                    dataField: "hp_no",
                    style: "aui-center",
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    style: "aui-center",
                },
                {
                    headerText: "업체명",
                    dataField: "breg_name",
                    style: "aui-center",
                },
                {
                    headerText : "매출계<br>(부품비+출장비+공임비)",
                    dataField : "sum_sale_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    cellMerge : true, // 구분1 셀 세로 병합 실행
                    mergeRef : "job_report_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
                    mergePolicy : "restrict",
                    width : "140",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                },
                {
                    headerText : "부품비",
                    dataField : "part_total_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    cellMerge : true, // 구분1 셀 세로 병합 실행
                    mergeRef : "job_report_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
                    mergePolicy : "restrict",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                },
                {
                    headerText : "출장비",
                    dataField : "travel_total_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    cellMerge : true, // 구분1 셀 세로 병합 실행
                    mergeRef : "job_report_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
                    mergePolicy : "restrict",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                },
                {
                    headerText : "공임비",
                    dataField : "work_total_amt",
                    style : "aui-center",
                    dataType : "numeric",
                    cellMerge : true, // 구분1 셀 세로 병합 실행
                    mergeRef : "job_report_no", // 대분류(gubun0 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
                    mergePolicy : "restrict",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return value == 0 ? '' : $M.setComma(value);
                    },
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            $("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function(event) {
                var custNo = event.item.cust_no;
                if (custNo) {
                    var param = {
                        "cust_no" : custNo
                    };
                    var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
                    $M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
                }
            });
        }

        // 엑셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, $("#title").html());
        }
    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 폼테이블 -->
            <div>
                <div class="title-wrap mt-5">
                    <h4 id="title"></h4>
                    <div class="btn-group">
                        <div class="right">
                            <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                <div class="form-check form-check-inline">
                                    <input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                    <label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
                                </div>
                            </c:if>
                        </div>
                        <button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
                    </div>
                </div>
                <%--                <div style="display: flex; justify-content: space-around">--%>
                <%--                    <div>--%>
                <%--                        <h4 id="title"></h4>--%>
                <%--                    </div>--%>
                <%--                    <div>--%>
                <%--                        <c:if test="${page.add.POS_UNMASKING eq 'Y'}">--%>
                <%--                            <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"--%>
                <%--                                   checked="checked" value="Y">--%>
                <%--                            <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>--%>
                <%--                        </c:if>--%>
                <%--                    </div>--%>
                <%--                </div>--%>
                <div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
                </div>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>