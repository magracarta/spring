<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 유상정비시간평가
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-04 17:05:29
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
        });

		//엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "유상정비시간평가");
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
                showFooter: true,
                footerPosition : "top",
            };

            var columnLayout = [
                {
                    headerText: "처리일자",
                    dataField: "as_dt",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    style: "aui-center",
                    width: 100,
					minWidth: 100,
                },
                {
                    headerText: "매출전표",
                    dataField: "inout_doc_no_dis",
                    style: "aui-center aui-popup",
                    width: 100,
					minWidth: 100,
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    style: "aui-center aui-popup",
                    width: 150,
					minWidth: 150,
                },
                {
                    headerText: "장비명",
                    dataField: "machine_name",
                    style: "aui-center",
                    width: 150,
					minWidth: 150,
                },
                {
                    headerText: "as_no",
                    dataField: "as_no",
                    style: "aui-center",
                    visible: false,
                },
                {
                    headerText: "판매일자",
                    dataField: "sale_dt",
                    dataType: "date",
                    formatString: "yyyy-mm-dd",
                    style: "aui-center",
                    width: 100,
					minWidth: 100,
                },
                {
                    headerText: "차주명",
                    dataField: "cust_name",
                    style: "aui-center",
                    width: 100,
					minWidth: 100,
                },
                {
                    headerText: "업체명",
                    dataField: "breg_name",
                    style: "aui-center",
                    width: 150,
					minWidth: 150,
                },
                {
                    headerText: "작성자",
                    dataField: "mem_name",
                    style: "aui-center",
                    width: 100,
					minWidth: 100,
                },
                {
                    headerText: "구분",
                    dataField: "clm_name",
                    style: "aui-center",
                    width: 50,
					minWidth: 50,
                },
                {
                    headerText: "이동H",
                    dataField: "move_hour",
                    style: "aui-center",
                    width: 50,
					minWidth: 50,
                },
                {
                    headerText: "정비H",
                    dataField: "repair_hour",
                    style: "aui-center",
                    width: 50,
					minWidth: 50,
                },
                {
                    headerText: "규정H",
                    dataField: "standard_hour",
                    style: "aui-center",
                    width: 50,
					minWidth: 50,
                },

                {
                    headerText: "정비지시서",
                    dataField: "job_report_no_dis",
                    style: "aui-center aui-popup",
                    width: 100,
					minWidth: 100,
                },
                {
                    headerText: "매출전표",
                    dataField: "inout_doc_no",
                    style: "aui-center",
                    visible: false,
                },
                {
                    headerText: "정비지시서",
                    dataField: "job_report_no",
                    style: "aui-center",
                    visible: false,
                },
            ];

            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText: "합계",
                    positionField: "clm_name",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "move_hour",
                    positionField: "move_hour",
                    operation: "SUM",
                    formatString: "#,##0.0####",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "repair_hour",
                    positionField: "repair_hour",
                    operation: "SUM",
                    formatString: "#,##0.0####",
                    style: "aui-center aui-footer",
                },
                {
                    dataField: "standard_hour",
                    positionField: "standard_hour",
                    operation: "SUM",
                    formatString: "#,##0.0####",
                    style: "aui-center aui-footer",
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, ${list});
            // 푸터 객체 세팅
            AUIGrid.setFooter(auiGrid, footerColumnLayout);

            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                switch(event.dataField) {
            	case 'body_no':
                    var params = {
                        "s_as_no": event.item.as_no,
                    };
                    $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: ''});
                    break;
            	case 'inout_doc_no_dis':
            		if(event.item.inout_doc_no == '') { return; }
            		var param = {
						"inout_doc_no" : event.item.inout_doc_no
					};
					$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : ''});
            		break;
              	case 'job_report_no_dis':
              		if(event.item.job_report_no == '') { return; }
              		var params = {
                        "s_job_report_no": event.item.job_report_no
                    };
                    $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: ''});
            		break;
            	}
            });

            $("#auiGrid").resize();
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
                    <h4>유상정비시간평가</h4>
                    <div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
                </div>
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