<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > 렌탈장비 이동이력
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
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true
			};
			var columnLayout = [
				{ 
					headerText : "관리번호", 
					dataField : "rental_trans_no", 
					width : "7%",
					style : "aui-popup"
				},
				{ 
					headerText : "이동처리일", 
					dataField : "trans_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "6%", 
					style : "aui-center"
				},
				{
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name",  
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "15%", 
					style : "aui-center"
				},
				{ 
					headerText : "연식", 
					dataField : "made_dt", 
					width : "4%", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substring(0, 4);
					},
					style : "aui-center"
				},
				{ 
					headerText : "가동시간", 
					dataField : "op_hour",					
					width : "5%", 
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "소유센터", 
					dataField : "from_org_name", 
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "요청센터", 
					dataField : "to_org_name", 
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "요청자", 
					dataField : "receipt_mem_name",
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "정산가격", 
					dataField : "sale_price", 
					width : "6%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "어태치가격", 
					dataField : "attach_price",
					width : "6%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "장비가액", 
					dataField : "machine_price",
					width : "6%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "정산기준가", 
					dataField : "refer_price",
					width : "6%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "정산 매입가(구매센터)", 
					dataField : "from_balance_price",
					width : "8%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "정산 매도가(판매센터)", 
					dataField : "to_balance_price",
					width : "8%", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "비고", 
					dataField : "remark",
					style : "aui-center"
				}			
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			var list = ${list}
			if (list) {
				$("#total_cnt").html(list.length);
			}
			AUIGrid.setGridData(auiGrid, list);
			$("#auiGrid").resize();

			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//차대번호셀 선택한 경우
				if(event.dataField == "rental_trans_no" ) {
					var params = {"rental_trans_no" : event.item.rental_trans_no};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=870, left=0, top=0";
					$M.goNextPage('/rent/rent050201p01', $M.toGetParam(params), {popupStatus : poppupOption});
				}
			});
		}
	
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "렌탈장비 이동이력", exportProps);
	    }
			
		// 닫기
		function fnClose() {
			window.close();
		}
		
	
	</script>
</head>
<body   class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>
				<div class="title-wrap">
					<h4>${not empty inputParam.custom_menu_name ? inputParam.custom_menu_name : '렌탈장비 이동이력'}</h4>	
					<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();" ><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
				</div>
				<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
				<div class="btn-group mt10">
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
<!-- /팝업 -->
</form>
</body>
</html>