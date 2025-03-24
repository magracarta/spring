<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > 렌탈장비 판매이력
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		var auiGrid;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			<c:if test="${not empty inputParam.rental_attach_no}">
				$("#navi > h2").html("렌탈어태치먼트 판매이력")
			</c:if>
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true
			};
			var columnLayout = [
				{ 
					headerText : "판매일자", 
					dataType : "date",
					dataField : "sale_dt", 
					formatString : "yyyy-mm-dd",
					width : "8%", 
					style : "aui-center"
				},
				{
					headerText : "판매가격", 
					dataField : "sale_price",					
					width : "9%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "판매수익", 
					dataField : "sale_profit_amt",					
					width : "9%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "판매센터", 
					dataField : "sale_org_name", 
					width : "8%",  
					style : "aui-center"
				},
				{ 
					headerText : "판매자", 
					dataField : "sale_mem_name", 
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "차주명", 
					dataField : "cust_name", 
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "판매최소금액", 
					dataField : "min_sale_price",					
					width : "9%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "렌탈수익", 
					dataField : "rental_profit_amt",					
					width : "9%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "판매손익금액", 
					dataField : "sale_org_profit_amt",					
					/* width : "9%",  */
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				<c:if test="${not empty inputParam.rental_machine_no}">
				{ 
					headerText : "번호판종류", 
					dataField : "mreg_no_type_name", 
					width : "7%", 
					style : "aui-center"
				},
				</c:if>
				{ 
					headerText : "서비스담당자", 
					dataField : "service_mem_name", 
					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "마케팅담당자",
					dataField : "area_sale_mem_name", 
					width : "8%", 
					style : "aui-center"
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			console.log(${list});
			var list = ${list}
			if (list.length != 0) {
				AUIGrid.setGridData(auiGrid, list);
				$("#total_cnt").html("1");
			} else {
				AUIGrid.setGridData(auiGrid, []);
				$("#total_cnt").html("0");
			}
			
			$("#auiGrid").resize();
			
		}
		
	
		function fnDownloadExcel() {
			 // 엑셀 내보내기 속성
			 var exportProps = {
			         // 제외항목
			         //exceptColumnFields : ["removeBtn"]
			 };
			 fnExportExcel(auiGrid, "판매이력", exportProps);
	    }
			
		// 닫기
		function fnClose() {
			window.close();
		}
		
	
		
		
	</script>
</head>
<body  class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title" id="navi">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>
				<div class="title-wrap">
					<h4>
					<c:choose>
						<c:when test="${not empty inputParam.rental_attach_no}">렌탈어태치먼트</c:when>
						<c:otherwise>렌탈장비</c:otherwise>
					</c:choose> 판매이력</h4>	
					<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"  ><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
				</div>
				<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right">
						<button type="button" class="btn btn-info"  onclick="javascript:fnClose();" >닫기</button>
					</div>
				</div>
			</div>			
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>