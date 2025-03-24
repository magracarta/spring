<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-부서별 > null > 실주목록
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
			/* AUIGrid.bind(auiGrid, "cellClick", function(event) {
				
			}); */
		});
		
		function fnDownloadExcel() {
			alert("엑셀다운로드");
		}
		
		function fnClose() {
			window.close(); 
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row_id",
			};
			var columnLayout = [
				{ 
					headerText : "관리번호", 
					dataField : "yearid_slipno", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "담당자", 
					dataField : "cust_grade_cd", 
					width : "10%", 
					style : "aui-center",
				},
				{ 
					headerText : "고객명", 
					dataField : "sales_mem_no",
					width : "10%", 
					style : "aui-center"
				},
				{
					headerText : "모델명", 
					dataField : "cust_name", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "예정일자", 
					dataField : "machine_maker", 
					dataType : "date",
					width : "10%", 
					formatString :"yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "장비가", 
					dataField : "cust_maker_cd", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%", 
					style : "aui-right"
				},
				{ 
					headerText : "Net가", 
					dataField : "body_no", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%", 
					style : "aui-right"
				},
				{ 
					headerText : "기회비용", 
					dataField : "engineno", 
					style : "aui-center",
				},
				{ 
					headerText : "중고손실", 
					dataField : "made_year_id", 
					width : "10%", 
					style : "aui-center",
				},
				{ 
					headerText : "자사부담", 
					dataField : "month1", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "본사부담", 
					dataField : "month2", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "경쟁사", 
					dataField : "month3", 
					width : "7%", 
					style : "aui-center",
				},
				{	 
					headerText : "결재", 
					dataField : "month4", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "품의일자", 
					dataField : "month5", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "출하일자", 
					dataField : "month6", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "실주적용", 
					dataField : "month7", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "자격할인", 
					dataField : "month8", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "지급품계", 
					dataField : "month9", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "수수료", 
					dataField : "month10", 
					width : "7%", 
					style : "aui-center",
				},
				{ 
					headerText : "본사지원", 
					dataField : "month11", 
					style : "aui-center",
				}
			];
			var testData = [
				{
					"yearid_slipno" : "2016-1973-01",
					"cust_grade_cd" : "장현석",
					"sales_mem_no" : "엄정영",
					"cust_name" : "VIO17",
					"machine_maker" : "20190924",
					"cust_maker_cd" : "29000000",
					"body_no" : "26500000",
					"engineno" : "",
					"made_year_id" : "",
					"month1" : "",
					"month2" : "",
					"month3" : "",
					"month4" : "실주확정",
					"month5" : "",
					"month6" : "",
					"month7" : "",
					"month8" : "",
					"month9" : "",
					"month10" : "",
					"month11" : "",
					"month12" : ""
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, testData);
			$("#auiGrid").resize();
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">		
				<h4>얀마 1.2ton (2019-08)</h4>
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>		
			</div>

			<div id="auiGrid" style="margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">		
				<div class="left">
					총 <strong class="text-primary">25</strong>건
				</div>				
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>