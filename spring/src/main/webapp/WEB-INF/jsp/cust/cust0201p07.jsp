<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > null > 장기/충당재고
-- 작성자 : 김상덕
-- 최초 작성일 : 2023-03-24 00:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				<c:if test="${inputParam.apply_yn eq 'Y'}">
				// 체크박스 출력 여부
				showRowCheckColumn: true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox: true,
				</c:if>
			};
			var columnLayout = [
				{ 
					headerText : "부품번호",
					dataField : "part_no",
					width : "200",
					minWidth : "200",
					style : "aui-center",
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "250",
					minWidth : "250",
					style : "aui-left"
				},				
				{ 
					headerText : "호환모델",
					dataField : "machine_name",
					width : "300",
					minWidth : "300",
					style : "aui-left"
				},
				{ 
					headerText : "가용재고",
					dataField : "part_able_stock",
					dataType : "numeric",
					formatString : "#,##0",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var qty = value;
						if(item["seq_depth"] == "1") {
							qty = "";
						}
				    	return $M.setComma(qty); 
					}
				},
				{ 
					headerText : "정상판매가",
					dataField : "vip_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "100",
					minWidth : "100",
					style : "aui-right",
				},
				{
                    headerText : "관리구분",
                    dataField : "part_mng_name",
                    width : "90",
                    minWidth : "90",
                    style : "aui-left"
				},
				{ 
					headerText : "장기/충당 판매가",
					dataField : "vip_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "100",
					minWidth : "100",
					style : "aui-right",
				},
				{
					dataField : "sale_price",
					visible : false,
				},
				{
					dataField : "unit_price",
					visible : false,
				},
				{
					dataField : "warning_text",
					visible : false,
				},
				{
					dataField : "part_name_change_yn",
					visible : false,
				},
				{
					dataField : "vip_sale_vat_price",
					visible : false,
				},
				{
					dataField : "storage_name",
					visible : false,
				},
				{
					dataField : "sale_mi_qty",
					visible : false,
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
					// Row행 클릭 시 반영
					try{
						var item = [];
						item.push(event.item);
						if(opener.${inputParam.parent_js_name}(item) != undefined) {
							alert(opener.${inputParam.parent_js_name}(item));
							return false;
						}
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
			});
			$("#total_cnt").html("${total_cnt}");
			$("#auiGrid").resize();
		}

		// 적용
		function fnApply() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크 후 적용하세요.");
				return false;
			}

			<c:if test="${not empty inputParam.parent_js_name}">
				try {
					opener.${inputParam.parent_js_name}(items);
					window.close();
				} catch(e) {
					console.log(e);
					alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
				}
			</c:if>
		}

        // 닫기
        function fnClose() {
            window.close();
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
<!-- 검색영역 -->

<!-- /검색영역 -->
			<div class="title-wrap mt5">
				<h4>부품목록</h4>
				<div class="btn-group">
					<div class="right">
						<c:if test="${inputParam.apply_yn eq 'Y'}">
							<button type="button" class="btn btn-primary" onclick="javascript:fnApply();" >적용</button>
						</c:if>
					</div>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
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