<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 전화상담분석 > 장비대수 목록
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
        });

        //엑셀다운로드
        // function fnExcelDownload() {
        //     fnExportExcel(auiGrid, "서비스업무평가");
        // }

        function goSearch() {

            var params = {
                "s_center_org_code" : ${inputParam.s_center_org_code},
                "s_cnt" : "${inputParam.s_cnt}",
                "s_start_dt" : ${inputParam.s_start_dt},
                "s_end_dt" : ${inputParam.s_end_dt},
                "s_except_yk_yn" : "${inputParam.s_except_yk_yn}",
                "s_except_used_yn" : "${inputParam.s_except_used_yn}",
                "s_except_rental_yn" : "${inputParam.s_except_rental_yn}",
                "s_except_agency_yn" : "${inputParam.s_except_agency_yn}"
            }

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGrid, result.list);

                        $("#title").text("장비목록 - " + result.center_name);
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
                headerHeight : 40
            };

            var columnLayout = [
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    style: "aui-center",
                    width : "150"
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    style: "aui-center",
                    width : "150"
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    style: "aui-center",
                    width : "150"
                },
                {
                    headerText: "SA-R 가동시간",
                    dataField: "sar_op_hour",
                    style: "aui-center",
                    width : "90",
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
                    }
                },
                {
                    headerText: "조회 기간 내<br>전화횟수",
                    dataField: "real_cnt",
                    style: "aui-center",
                    width : "90",
                    postfix : "건"
                },
                {
                    headerText: "마지막<br>전화상담 일자",
                    dataField: "as_dt",
                    style: "aui-center aui-popup",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width : "80",
                },
                {
                	dataField: "as_no",
                	visible : false
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            $("#auiGrid").resize();
            
            AUIGrid.bind(auiGrid, "cellClick", function(event) {
            	if(event.dataField == "as_dt") {
            		var asNo = event.item.as_no;
            		if (asNo) {
						var params = {
							"s_as_no" : asNo
						};

						var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=820, left=0, top=0";
						$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus : popupOption});
            		}
            	}
            });
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
                <div class="title-wrap">
                    <h4 id="title"></h4>
                </div>
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