<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈대장 > 렌탈장비대장 > null > 렌탈장비 감가이력
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
				editable : true,	
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true
			};
			var columnLayout = [
				{ 
					headerText : "소유센터", 
					dataField : "own_org_name", 
					formatString : "yyyy-mm-dd",
					width : "8%", 
					style : "aui-center",
					editable:false
				},
				{
					headerText : "관리센터", 
					dataField : "mng_org_name",					
					width : "8%", 
					style : "aui-center",
					editable:false
				},
				{ 
					headerText : "감가여부", 
					dataField : "reduce_yn",					
					width : "7%", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value === "Y" ? "적용" : "미적용";
					},
					style : "aui-center",
					editable:false
				},
				{ 
					headerText : "감가시작일", 
					dataType : "date",
					dataField : "reduce_st_dt", 
					formatString : "yyyy-mm-dd",
					width : "9%",  
					style : "aui-center",
					editable:false
				},
				{ 
					headerText : "감가종료일", 
					dataType : "date",
					dataField : "reduce_ed_dt", 
					formatString : "yyyy-mm-dd",
					width : "9%", 
					style : "aui-center",
					editable:false
				},
				{ 
					headerText : "월 감가액", 
					dataField : "reduce_price", 
					width : "8%", 
					style : "aui-right",
					editable:false,
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "감가총액", 
					dataField : "total_reduce_amt",					
					width : "9%", 
					style : "aui-right",
					editable:false,
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "최소판가", 
					dataField : "min_sale_price",					
					width : "9%", 
					style : "aui-right",
					editable:false,
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "비고", 
					dataField : "remark",					
					style : "aui-left",
					editable:true,					
					editRenderer : {
				    	type : "InputEditRenderer",
			     	 	maxlength : 100,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					}	
				},
				{
					headerText : "삭제",
					dataField : "j",
					width : "6%", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
	 					var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);		
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							} 
						}

					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					}
				},
				{
					dataField : "rental_machine_no",
					visible : false
				},
				{
					dataField : "seq_no",
					visible : false
				}
			];
			
			var list = ${list};
			$("#total_cnt").html(list.length);
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, list);
			$("#auiGrid").resize();
		}
	
		function fnDownloadExcel() {
	    	fnExportExcel(auiGrid, "렌탈장비 감가이력", {})
	    }
			
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page, frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
					};
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body  class="bg-white" >
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
					<h4>${item.maker_name } ${item.machine_name } (차대번호 : ${item.body_no } / 년식 : ${item.made_dt } / 가동시간 : <fmt:formatNumber type="number" maxFractionDigits="3" value="${item.op_hour}" />hr)</h4>	
					<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();" ><i class="icon-btn-excel inline-btn"  ></i>엑셀다운로드</button>
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