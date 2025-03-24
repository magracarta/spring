<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 일계표 > null > 전표내역조회
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});
		
		function fnInit() {
			if("${inputParam.s_inout_gubun}" == "IN") {
				$("#title").text("매입");
			}
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "inout_doc_no",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					showBranchOnGrouping : false,
					showFooter : true,
					footerPosition : "top",
					editable : false
				};
			var columnLayout = [
				{
					headerText : "전표번호", 
					dataField : "inout_doc_no", 
					width : "8%",
					style : "aui-center"
				},
				{ 
					headerText : "부서", 
					dataField : "org_name", 
					width : "6%",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "6%",
					style : "aui-center",
				},
				{ 
					headerText : "상호", 
					dataField : "breg_name", 
					width : "8%",
					style : "aui-center",
				},
				{ 
					headerText : "구분", 
					dataField : "inout_type_name", 
					width : "5%",
					style : "aui-center",
				},
				{ 
					headerText : "계정", 
					dataField : "acc_type_name", 
					width : "5%",
					style : "aui-center",
				},
				{ 
					headerText : "내용", 
					dataField : "count_remark", 
					style : "aui-left",
				},
				{ 
					headerText : "물품대", 
					dataField : "doc_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%",
					style : "aui-right",
				},
				{ 
					headerText : "세액", 
					dataField : "vat_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%",
					style : "aui-right",
				},
				{ 
					headerText : "합계", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%",
					style : "aui-right",
				},
				{ 
					headerText : "입(출)금액", 
					dataField : "inout_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "7%",
					style : "aui-right",
				},
				{ 
					headerText : "처리", 
					dataField : "tax_yn",
					width: "4%",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						var taxYn = value == "Y" ? "OK" : "";
						return taxYn;
					}
				},
				{
					headerText: "요청",
					dataField: "vat_treat_cd",
					width: "5%",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						var vatTreatName = "";
						if (value == "Y") {
							vatTreatName = "세금";
						} else if (value == "R") {
							vatTreatName = "보류";
						} else if (value == "S") {
							vatTreatName = "합산";
						} else if (value == "F" && item.taxbill_send_cd == "5") {
							vatTreatName = "수정";
						} else if (value == "C") {
							vatTreatName = "카드매출";
						} else if (value == "A") {
							vatTreatName = "현금영수증";
						} else if (value == "N") {
							vatTreatName = "무증빙";
						}
						return vatTreatName;
					}
				},
				{
					headerText: "작성자",
					dataField: "mem_name",
					width: "5%",
					style: "aui-center",
				},
				{
					dataField: "taxbill_send_cd",
					visible: false
				}
			];

			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "count_remark",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "doc_amt",
					positionField : "doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "total_amt",
					positionField : "total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
		}
	
		function fnDownloadExcel() {
			// 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "전표내역조회", exportProps);
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
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4><span class="text-primary" id="title">매출</span> 조회결과</h4>					
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>						
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>		
<!-- /폼테이블 -->
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