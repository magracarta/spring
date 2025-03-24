<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 서비스비용
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-09-06 11:51:26
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
            fnInit();
		});
        function fnInit() {
            // 센터별실적분석에서 서비스비용으로 호출한게 아니라면 이관컬럼 숨김
            if("${inputParam.free_cost_yn}" != "Y") {
                AUIGrid.hideColumnByDataField(auiGrid, ["coworkBtn", "cowork_result"] ); // 숨길대상
            }
        }
        
		//엑셀다운로드
		function fnExcelDownload() {
			fnExportExcel(auiGrid, "서비스금액");
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
				footerPosition : "top"
			};

			var columnLayout = [
				{
					headerText: "출하일자",
					dataField: "out_dt",
					width : "100",
					minWidth : "90",
					dataType: "date",
                    formatString: "yy-mm-dd",
					style: "aui-center",
				},
				{
					headerText: "장비명",
					dataField: "machine_name",
					width : "100",
					minWidth : "90",
					style: "aui-center",
				},
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width : "120",
                    minWidth : "90",
                    style: "aui-center",
                },
				{
					headerText: "차대번호",
					dataField: "body_no",
					width : "150",
					minWidth : "90",
					style: "aui-center aui-link",
				},
				// {
				// 	headerText: "서비스담당/출하처리자",
				// 	dataField: "mem_name",
				// 	style: "aui-center",
				// 	width : "140",
				// 	minWidth : "90",
				// },
                {
                    headerText: "출하처리자/서비스담당",
                    dataField: "mem_name",
                    style: "aui-center",
                    width : "140",
                    minWidth : "90",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        console.log("item : ", item);
                        var freeCostMemName = item["free_cost_mem_name"];
                        var outCostMemName = item["out_cost_mem_name"];
                        if (freeCostMemName == undefined || freeCostMemName == '') {
                            freeCostMemName = '-';
                        }

                        if (outCostMemName == undefined || outCostMemName == '') {
                            outCostMemName = '-';
                        }

                        return outCostMemName + " / " + freeCostMemName;
                    }
                },
				{
					headerText: "출하비용",
					dataField: "out_cost_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric",
					formatString: "#,##0",
					style: "aui-right",
				},
				{
					headerText: "서비스비용",
					dataField: "free_cost_amt",
					width : "100",
					minWidth : "90",
					dataType : "numeric", 
					formatString: "#,##0",
					style: "aui-right",
				},
                {
                    dataField: "machine_seq",
                    visible : false
                },
                {
                    headerText : "이관여부",
                    dataField : "coworkBtn",
                    width : "100",
                    renderer : {
                        type : "ButtonRenderer",
                        onClick : function(event) {
                            console.log("event : ", event);
                            if (event.item.coworker_yn == "Y") {
                                alert("이관이 완료된 건 입니다.");
                                return false;
                            }

                            var param = {
                                "machine_doc_no" : event.item["machine_doc_no"],
                                "free_cost_amt" : $M.setComma(Math.abs($M.toNum(event.item["free_cost_amt"]))),
                                "modify_yn" : "Y"
                            };
                            var popupOption = "";
                            $M.goNextPage('/serv/serv0501p19', $M.toGetParam(param), {popupStatus: popupOption});
                        },
                    },
                    labelFunction : function(rowIndex, columnIndex, value,
                                             headerText, item) {
                        if(item["svc_dt"] != "") {
                            return item["svc_dt"];
                        }else {
                            return '이관'
                        }
                    },
                    style : "aui-center",
                    editable : false,
                },
				{
					headerText: "이관처리결과",
					dataField: "cowork_result",
					style: "aui-center",
				},
				{
					headerText: "이관날짜",
					dataField: "svc_dt",
					style: "aui-center",
                    visible: false,
				},
                {
                    headerText: "이관여부",
                    dataField: "coworker_yn",
                    style: "aui-center",
                    visible: false,
                },
			];

			var footerColumnLayout = [];
			
			// 출장비/공임
			footerColumnLayout = [
				{
					labelText: "합계",
					positionField: "service_mem_name",
					style: "aui-right aui-footer",
				},
				{
					dataField: "out_cost_amt",
					positionField: "out_cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_cost_amt",
					positionField: "free_cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
                    expFunction : function(columnValues) {
                        var sum = 0;
                        for (var i = 0; i < columnValues.length; i++) {
                            if (columnValues[i] > 0) {
                                sum += $M.toNum(columnValues[i]);
                            }
                        }
                        return $M.toNum(sum);
                    },
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${list});

			$("#auiGrid").resize();

            AUIGrid.bind(auiGrid, "cellClick", function(event) {
                // 차대번호 클릭시 장비대장 상세 호출
                if (event.dataField == "body_no") {
                    var params = {
                        "s_machine_seq": event.item.machine_seq
                    };
                    var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
                    $M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
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
                    <h4>무상서비스비용</h4>
                    <div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    </div>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
            </div>
            <!-- /폼테이블-->
            <div class="btn-group mt10">
                <div class="left">
                    총 <strong class="text-primary">${total_cnt}</strong>건
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