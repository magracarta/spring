<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품조회 > 부품재고조회 > 부품재고상세 > 창고별재고현황
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGridFirst();
			goSearch();
		});
		
		
		//조회
		function goSearch() { 
			var param = {
					"part_no" : '${inputParam.part_no}'
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		} 
		
		function createAUIGridFirst() {
			var gridPros = {
					// rowIdField 설정
					rowIdField : "sort_no",
					// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
					wrapSelectionMove : false,
					// rowNumber 
					showRowNumColumn: false,
					showFooter : true,
					footerPosition : "top",
					fillColumnSizeMode : false,
					editable : false,
			};
			var columnLayout = [
				{ 
					headerText : "창고명", 
					dataField : "warehouse_name", 
					width : "192", 
					minWidth : "177", 
					style : "aui-center"
				},
				{
					dataField : "warehouse_cd",
					visible : false
				},
				{
					headerText : "가용재고",
					dataField : "use_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "135",
					minWidth : "135",
					style : "aui-center"
				},
				{
					headerText : "정비중",
					dataField : "job_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "135",
					minWidth : "135",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != 0) {
							return "aui-popup"
						};
						return "aui-center";
					},
				},
				{
					headerText : "판매중",
					dataField : "sale_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "135",
					minWidth : "135",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != 0) {
							return "aui-popup"
						};
						return "aui-center";
					},
				},
				{
					headerText : "선주문",
					dataField : "preorder_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "135",
					minWidth : "135",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != 0) {
							return "aui-popup"
						};
						return "aui-center";
					},
				},
				{
					headerText : "이동중",
					dataField : "trans_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "135",
					minWidth : "135",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != 0) {
							return "aui-popup"
						};
						return "aui-center";
					},
				},
				{ 
					headerText : "현재고", 
					dataField : "current_stock",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "135", 
					minWidth : "135", 
					style : "aui-center aui-popup"
				},
				{ 
					headerText : "저장위치", 
					dataField : "storage_name", 
					width : "135", 
					minWidth : "135", 
					style : "aui-center"
				}
			]
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "계",
					positionField : "warehouse_name",
				}, 
				{
					dataField : "current_stock",
					positionField : "current_stock",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "job_qty",
					positionField : "job_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "trans_qty",
					positionField : "trans_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "preorder_qty",
					positionField : "preorder_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_qty",
					positionField : "sale_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "use_qty",
					positionField : "use_qty",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 부품명 셀 클릭 시 부품마스터상세 팝업 호출
				var popupOption = "";
				var param = {
					"part_no" : "${inputParam.part_no}",
					"warehouse_cd" : event.item["warehouse_cd"]
				};
				if(event.dataField == 'current_stock') {
					param.s_part_move_type_cd_move = "Y";
					
					fnInoutPartInfo(param);
				};
				if(event.dataField == 'job_qty' && event.item["job_qty"] != 0) {
					$M.goNextPage('/part/part0101p03', $M.toGetParam(param), {popupStatus : popupOption});
				};
				if(event.dataField == 'trans_qty' && event.item["trans_qty"] != 0) {
					$M.goNextPage('/part/part0101p04', $M.toGetParam(param), {popupStatus : popupOption});
				};
				if(event.dataField == 'preorder_qty' && event.item["preorder_qty"] != 0) {
					$M.goNextPage('/part/part0101p05', $M.toGetParam(param), {popupStatus : popupOption});
				};
				// [정윤수] 23.06.13 Q&A 17407 판매중 조회 팝업 추가
				if(event.dataField == 'sale_qty' && event.item["sale_qty"] != 0) {
					$M.goNextPage('/part/part0101p06', $M.toGetParam(param), {popupStatus : popupOption});
				};
			});
			$("#auiGrid").resize();
		}
		
		// 입출고내역
	    function fnInoutPartInfo(param) {
			// var param = {};
	  	  	openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
	    }

		// [재호] [3차-Q&A 16088] 부품재고조회 수정으로 인한 메인 페이지로 이동
		// 이동요청
		<%--function goTransPart() {--%>
		<%--	var param = {--%>
		<%--		'part_no' : '${inputParam.part_no}',--%>

		<%--	};--%>
		<%--	openTransPartPanel('setMovePartInfo', $M.toGetParam(param));--%>
		<%--}--%>

		// 이동요청 콜백
		// function setMovePartInfo() {
		// }
	
		//팝업 끄기
		function fnClose() {
			top.fnClose();
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
<!-- /타이틀영역 -->
        <div class="content-wrap">				
<!-- 창고별재고현황 -->
				<div style="width: 100%">
					<div class="title-wrap mt10">
						<h4>창고별재고현황</h4>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 500px; width:100%"></div>
				</div>
<!-- /창고별재고현황 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5 custheight">		
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건 
						</div>				
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /이동요청 -->				
			</div>
        </div>
<!-- /팝업 -->
</form>
</body>
</html>